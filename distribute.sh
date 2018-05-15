#!/bin/bash

set -e # fail on first error

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "$DIR"

if [ "$DEBUG" = "1" ]; then
    set -x
fi

source ~/config/set-env.sh

HOST_DIR="/var/www/html"
CURRENT_BRANCH="nlb"
USE_SYMLINKS="true"

function find_existing {
    FILENAME="`echo $1 | sed 's/.*\///'`"
    DEPLOY_PATH="$2"
    MD5SUM="`md5sum $1 | awk '{print $1}'`"
    ssh -n $REPO_USER@$REPO_HOST "find $HOST_DIR/pipeline/files -type f | grep "$DEPLOY_PATH$" | xargs md5sum | grep $MD5SUM | head -n 1" | {
    while read match; do
        # found existing identical file
        echo $match | awk '{print $2}'
    done
    }
}

# create remote directory, and check return code
function ssh_mkdir {
    DIR="$1"
    ssh -n $REPO_USER@$REPO_HOST "mkdir -p \"$DIR\" ; echo \$? > /tmp/ret"
    RET="`ssh -n $REPO_USER@$REPO_HOST "cat /tmp/ret"`"
    if [ "$RET" != "0" ]; then
        exit $RET
    fi
}

# create remote symlink, and check return code
function ssh_symlink {
    TARGET="$1"
    LINK_NAME="$2"
    ssh -n $REPO_USER@$REPO_HOST "ln --symbolic \"$TARGET\" \"$LINK_NAME\" ; echo \$? > /tmp/ret"
    RET="`ssh -n $REPO_USER@$REPO_HOST "cat /tmp/ret"`"
    if [ "$RET" != "0" ]; then
        exit $RET
    fi
}


# NOTE: it is assumed that `make` has already cached all the necessary files in `.maven-workspace`
#       and that the minimal distribution has been build (`make dist-zip-minimal`).

# Directory layout:
# http://$REPO_PUBLIC_HOST/pipeline/index.html (website with links to latest *_minimal.zip and instructions)
# http://$REPO_PUBLIC_HOST/pipeline/current (descriptor)
# http://$REPO_PUBLIC_HOST/pipeline/branches/<branch> (descriptor)
# http://$REPO_PUBLIC_HOST/pipeline/commits/<short_sha> (descriptor)
# http://$REPO_PUBLIC_HOST/pipeline/commits/<full_sha> (descriptor)
# http://$REPO_PUBLIC_HOST/pipeline/files/<full_sha>/*.jar (if $USE_SYMLINKS: symlink to jar in earlier commit if no change)
# http://$REPO_PUBLIC_HOST/pipeline/files/<full_sha>/*_minimal.zip (if $USE_SYMLINKS: symlink to zip in earlier commit if no change)

java -cp "`find .maven-workspace/net/sf/saxon/Saxon-HE/9* -type f | grep jar$ | tail -n 1`" \
    net.sf.saxon.Transform \
    -s:assembly/target/tmp/effective-pom.xml \
    -xsl:assembly/src/main/xslt/pom-to-release.xslt \
    -o:releaseDescriptorRelative.xml \
    relativeHrefs=true

DESCRIPTOR_VERSION="`cat releaseDescriptorRelative.xml | grep "<releaseDescriptor " | sed 's/.* version="//' | sed 's/".*//'`"
GIT_FULL_SHA="`git rev-parse HEAD`"
GIT_SHORT_SHA="`git rev-parse --short HEAD`"
DESCRIPTOR_VERSION="`echo $DESCRIPTOR_VERSION | sed "s/SNAPSHOT/SNAPSHOT-\`date -u +"%Y%m%d%H%M%S"\`-$GIT_FULL_SHA/"`"

echo "Distributing Pipeline 2 version: $DESCRIPTOR_VERSION"

ssh_mkdir "$HOST_DIR/pipeline/branches"
ssh_mkdir "$HOST_DIR/pipeline/commits"
ssh_mkdir "$HOST_DIR/pipeline/files/$GIT_FULL_SHA"

# Compile a release descriptor where artifacts not present in other repositories are linked to NLBs repository
echo '<?xml version="1.0" encoding="UTF-8"?>' > descriptor-full-sha.xml
cat assembly/target/release-descriptor/releaseDescriptor.xml | grep "<releaseDescriptor" | sed "s/version=\"[^\"]*\"/version=\"$DESCRIPTOR_VERSION\"/" | sed "s|href=\"[^\"]*\"|href=\"http://$REPO_PUBLIC_HOST/pipeline/commits/$GIT_FULL_SHA\"|" >> descriptor-full-sha.xml
cat releaseDescriptorRelative.xml | grep "<artifact[ >]" | while read artifactLine; do
    GROUP_ID="`echo $artifactLine | sed 's/.* groupId="//' | sed 's/".*//'`"
    ARTIFACT_ID="`echo $artifactLine | sed 's/.* artifactId="//' | sed 's/".*//'`"
    ARTIFACT_VERSION="`echo $artifactLine | sed 's/.* version="//' | sed 's/".*//'`"
    ARTIFACT_CLASSIFIER="`echo $artifactLine | sed 's/.* classifier="//' | sed 's/".*//'`"
    DEPLOY_PATH="`echo $artifactLine | sed 's/.* deployPath="//' | sed 's/".*//'`"
    REMOTE_PATH="`cat assembly/target/release-descriptor/releaseDescriptor.xml | grep " classifier=\\\"$ARTIFACT_CLASSIFIER\\\"" | grep " groupId=\\\"$GROUP_ID\\\"" | grep " artifactId=\\\"$ARTIFACT_ID\\\"" | grep " version=\\\"$ARTIFACT_VERSION\\\"" | sed 's/.* href="//' | sed 's/".*//'`"
    RELATIVE_PATH="`echo $artifactLine | sed 's/.*href="//' | sed 's/".*//'`"
    RELATIVE_DIR="`echo $artifactLine | sed 's/.*href="//' | sed 's/".*//' | sed 's/\/[^/]*$//'`"
    LOCAL_PATH="`find .maven-workspace ~/.m2 -type f | grep "$RELATIVE_PATH$" | head -n 1`"
    FILENAME="`echo $LOCAL_PATH | sed 's/^.*\///'`"
    STATUS_CODE="`curl -I --write-out %{http_code} --silent --output /dev/null "$REMOTE_PATH"`"
    if [ "`echo $ARTIFACT_VERSION | grep SNAPSHOT | wc -l`" != "1" ] || [ "$STATUS_CODE" = "200" ] || [ "$STATUS_CODE" = "302" ] || [ "$STATUS_CODE" = "000" ]; then
        echo "using $GROUP_ID:$ARTIFACT_ID:$ARTIFACT_VERSION from remote server"
        cat assembly/target/release-descriptor/releaseDescriptor.xml | grep " classifier=\\\"$ARTIFACT_CLASSIFIER\\\"" | grep " groupId=\\\"$GROUP_ID\\\"" | grep " artifactId=\\\"$ARTIFACT_ID\\\"" | grep " version=\\\"$ARTIFACT_VERSION\\\"" >> descriptor-full-sha.xml
    else
        # upload artifact to pipeline server since it's not hosted anywhere else,
        # or since it's a snapshot and we want a backup in case it disappears from sonatype.
        echo "copying $GROUP_ID:$ARTIFACT_ID:$ARTIFACT_VERSION to local server"
        echo "    $artifactLine" | sed "s|href=\"[^\"]*\"|href=\"http://$REPO_PUBLIC_HOST/pipeline/files/$GIT_FULL_SHA/$DEPLOY_PATH\"|" | sed "s|version=\"\([^\"]*\)\"|version=\"\1-$GIT_FULL_SHA\"|" >> descriptor-full-sha.xml
        EXISTING=""
        TARGET="$HOST_DIR/pipeline/files/$GIT_FULL_SHA/$DEPLOY_PATH"
        ssh_mkdir "`echo $TARGET | sed 's/\/[^\/]*$//'`"
        if [ "$USE_SYMLINKS" == "true" ]; then
            EXISTING="`find_existing $LOCAL_PATH $DEPLOY_PATH`"
            if [ "$EXISTING" != "" ]; then
                if [ "$EXISTING" != "$TARGET" ]; then
                    ssh_symlink "$EXISTING" "$TARGET"
                fi
            fi
        fi
        if [ "$USE_SYMLINKS" != "true" ] || [ "$EXISTING" == "" ]; then
            rsync -av "$LOCAL_PATH" $REPO_USER@$REPO_HOST:"$HOST_DIR/pipeline/files/$GIT_FULL_SHA/$DEPLOY_PATH"
        fi
    fi
done

echo "</releaseDescriptor>" >> descriptor-full-sha.xml

ZIP_FILENAME="`ls *minimal.zip | head -n 1`"
echo "uploading $ZIP_FILENAME"
EXISTING=""
if [ "$USE_SYMLINKS" == "true" ]; then
    EXISTING="`find_existing $ZIP_FILENAME $ZIP_FILENAME`"
    if [ "$EXISTING" != "" ]; then
        TARGET="$HOST_DIR/pipeline/files/$GIT_FULL_SHA/$ZIP_FILENAME"
        if [ "$EXISTING" != "$TARGET" ]; then
            ssh_symlink "$EXISTING" "$TARGET"
        fi
    fi
fi
if [ "$USE_SYMLINKS" != "true" ] || [ "$EXISTING" == "" ]; then
    rsync -av "$ZIP_FILENAME" $REPO_USER@$REPO_HOST:"$HOST_DIR/pipeline/files/$GIT_FULL_SHA/$ZIP_FILENAME"
fi

echo "uploading descriptor as pipeline/commits/$GIT_FULL_SHA"
cat descriptor-full-sha.xml | ssh $REPO_USER@$REPO_HOST "cat > $HOST_DIR/pipeline/commits/$GIT_FULL_SHA"

echo "uploading descriptor as pipeline/commits/$GIT_SHORT_SHA"
cat descriptor-full-sha.xml | sed "s/pipeline\/commits\/[^\"']*/pipeline\/commits\/$GIT_SHORT_SHA/g" > descriptor-short-sha.xml
cat descriptor-short-sha.xml | ssh $REPO_USER@$REPO_HOST "cat > $HOST_DIR/pipeline/commits/$GIT_SHORT_SHA"

# for each branch with this commit at its tip
git show-ref | grep ' refs/remotes' | sed 's/ refs\/remotes\/[^/]*\// /' | grep -v '/[^/]*/' | grep $GIT_FULL_SHA | {
while read branch; do
    GIT_BRANCH="`echo $branch | awk '{print $2}'`"
    
    echo "uploading descriptor as pipeline/branches/$GIT_BRANCH"
    
    cat descriptor-full-sha.xml | sed "s/pipeline\/commits\/[^\"']*/pipeline\/branches\/$GIT_BRANCH/g" > descriptor-branch.xml
    cat descriptor-branch.xml | ssh $REPO_USER@$REPO_HOST "cat > $HOST_DIR/pipeline/branches/$GIT_BRANCH"
    
    # if this branch is the branch we use as "current"
    if [ "$GIT_BRANCH" == "$CURRENT_BRANCH" ]; then
        echo "uploading descriptor as pipeline/current"
        
        cat descriptor-full-sha.xml | sed "s/pipeline\/commits\/[^\"']*/pipeline\/current/g" > descriptor-current.xml
        cat descriptor-current.xml | ssh $REPO_USER@$REPO_HOST "cat > $HOST_DIR/pipeline/current"
        
        # upload zip as pipeline/pipeline2_minimal.zip
        if [ "$USE_SYMLINKS" == "true" ]; then
            TARGET="$HOST_DIR/pipeline/pipeline2_minimal.zip"
            ssh -n $REPO_USER@$REPO_HOST "rm $TARGET || true"
            ssh_symlink "$HOST_DIR/pipeline/files/$GIT_FULL_SHA/$ZIP_FILENAME" "$TARGET"
        else
            rsync -av "$ZIP_FILENAME" $REPO_USER@$REPO_HOST:"$HOST_DIR/pipeline/pipeline2_minimal.zip"
        fi
        
        # update index.html (only do this when we update "current", to prevent overwriting from feature branches)
        echo "<!DOCTYPE html>" > index.html
        echo "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\">" >> index.html
        echo "<head><meta charset=\"utf-8\"/><title>NLB-flavored DAISY Pipeline 2</title>" >> index.html
        echo "<link href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css\" rel=\"stylesheet\" integrity=\"sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u\" crossorigin=\"anonymous\">" >> index.html
        echo "</head><body class=\"container\">" >> index.html
        echo "<h1>NLB-flavored DAISY Pipeline 2</h1>" >> index.html
        echo "<p>This server hosts NLBs version of DAISY Pipeline 2.</p>" >> index.html
        echo "<p>To use this server, please read the installation guide describing the Pipeline 2 updater mechanism on the Pipeline 2 homepage:" >> index.html
        echo "<ul><li><a href=\"http://daisy.github.io/pipeline/Get-Help/User-Guide/Installation/#updater\">http://daisy.github.io/pipeline/Get-Help/User-Guide/Installation/#updater</a></li></ul>" >> index.html
        echo "<p>If you don't already have an existing installation of Pipeline 2, then you can download the latest build of the minimal version containing only the command line updater here:</p>" >> index.html
        echo "<ul><li><a href=\"pipeline2_minimal.zip\">pipeline2_minimal.zip</a></li></ul>" >> index.html
        echo "<p>Use the following update URL:</p>" >> index.html
        echo "<p><pre><code>http://$REPO_PUBLIC_HOST/pipeline/</code></pre></p>" >> index.html
        echo "<p>For version, you should use <code>current</code>. Alternatively, you may reference a specific branch or a specific commit as follows:</p>" >> index.html
        echo "<ul><li><code>branches/&lt;branch&gt;</code></li><li><code>commits/&lt;sha&gt;</code></li></ul>" >> index.html
        echo "<p>Replace <code>&lt;branch&gt;</code> and <code>&lt;sha&gt;</code> with the branchname and commit SHA respectively.</p>" >> index.html
        echo "<ul><li><a href=\"branches/\">Show all branches</a></li><li><a href=\"commits/\">Show all commits</a></li></ul>" >> index.html
        echo "</body></html>" >> index.html
        cat index.html | ssh $REPO_USER@$REPO_HOST "cat > $HOST_DIR/pipeline/index.html"
    fi
done
}
