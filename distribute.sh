#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "$DIR"

if [ "$DEBUG" = "1" ]; then
    set -x
fi

source ~/config/set-env.sh

# like `make cache`, but with snapshots
rsync -mr --exclude "maven-metadata-*.xml" .maven-workspace/ .maven-cache

java -cp "`find .maven-cache/net/sf/saxon/Saxon-HE/9* -type f | grep jar$ | tail -n 1`" \
    net.sf.saxon.Transform \
    -s:assembly/target/tmp/effective-pom.xml \
    -xsl:assembly/src/main/xslt/pom-to-release.xslt \
    -o:releaseDescriptorRelative.xml \
    relativeHrefs=true

DESCRIPTOR_VERSION="`cat releaseDescriptorRelative.xml | grep "<releaseDescriptor " | sed 's/.* version="//' | sed 's/".*//'`"
GIT_SHA="`git rev-parse --short HEAD`"
DESCRIPTOR_VERSION="`echo $DESCRIPTOR_VERSION | sed "s/SNAPSHOT/SNAPSHOT+\`date -u +"%Y%m%d%H%M%S"\`-$GIT_SHA/"`"
GIT_BRANCH="`git rev-parse --abbrev-ref HEAD`"

echo "Distributing Pipeline 2 version: $DESCRIPTOR_VERSION"

# Compile a release descriptor where artifacts not present in other repositories are linked to NLBs repository
echo '<?xml version="1.0" encoding="UTF-8"?>' > releaseDescriptor.xml
cat assembly/target/release-descriptor/releaseDescriptor.xml | grep "<releaseDescriptor" | sed "s/version=\"[^\"]*\"/version=\"$DESCRIPTOR_VERSION\"/" | sed "s|href=\"[^\"]*\"|href=\"http://$PIPELINE_HOST:$PIPELINE_REPO_PORT/pipeline-updates/$DESCRIPTOR_VERSION\"|" >> releaseDescriptor.xml
cat releaseDescriptorRelative.xml | grep "<artifact[ >]" | while read artifactLine; do
    if [ "$DEBUG" = "1" ]; then echo "current artifact line: $artifactLine" ; fi
    GROUP_ID="`echo $artifactLine | sed 's/.* groupId="//' | sed 's/".*//'`"
    ARTIFACT_ID="`echo $artifactLine | sed 's/.* artifactId="//' | sed 's/".*//'`"
    ARTIFACT_VERSION="`echo $artifactLine | sed 's/.* version="//' | sed 's/".*//'`"
    ARTIFACT_CLASSIFIER="`echo $artifactLine | sed 's/.* classifier="//' | sed 's/".*//'`"
    REMOTE_PATH="`cat assembly/target/release-descriptor/releaseDescriptor.xml | grep " classifier=\\\"$ARTIFACT_CLASSIFIER\\\"" | grep " groupId=\\\"$GROUP_ID\\\"" | grep " artifactId=\\\"$ARTIFACT_ID\\\"" | grep " version=\\\"$ARTIFACT_VERSION\\\"" | sed 's/.* href="//' | sed 's/".*//'`"
    RELATIVE_PATH="`echo $artifactLine | sed 's/.*href="//' | sed 's/".*//' | sed 's/\/[^/]*$//'`"
    LOCAL_PATH="`find .maven-cache ~/.m2 -type d | grep "$RELATIVE_PATH$" | head -n 1`"
    STATUS_CODE="`curl -I --write-out %{http_code} --silent --output /dev/null "$REMOTE_PATH"`"
    if [ "`echo $ARTIFACT_VERSION | grep SNAPSHOT | wc -l`" != "1" ] || [ "$STATUS_CODE" = "200" ] || [ "$STATUS_CODE" = "302" ]; then
        echo "using $GROUP_ID:$ARTIFACT_ID:$ARTIFACT_VERSION from remote server"
        if [ "$DEBUG" = "1" ]; then echo "adding: `cat assembly/target/release-descriptor/releaseDescriptor.xml | grep " classifier=\\\"$ARTIFACT_CLASSIFIER\\\"" | grep " groupId=\\\"$GROUP_ID\\\"" | grep " artifactId=\\\"$ARTIFACT_ID\\\"" | grep " version=\\\"$ARTIFACT_VERSION\\\""`" ; fi
        cat assembly/target/release-descriptor/releaseDescriptor.xml | grep " classifier=\\\"$ARTIFACT_CLASSIFIER\\\"" | grep " groupId=\\\"$GROUP_ID\\\"" | grep " artifactId=\\\"$ARTIFACT_ID\\\"" | grep " version=\\\"$ARTIFACT_VERSION\\\"" >> releaseDescriptor.xml
    else
        # upload artifact to pipeline server since it's not hosted anywhere else,
        # or since it's a snapshot and we want a backup in case it disappears from sonatype.
        echo "copying $GROUP_ID:$ARTIFACT_ID:$ARTIFACT_VERSION to local server"
        if [ "$DEBUG" = "1" ]; then
            echo "adding:"
            echo "    $artifactLine" | sed "s|href=\"|href=\"http://$PIPELINE_HOST:$PIPELINE_REPO_PORT/maven/|"
        fi
        echo "    $artifactLine" | sed "s|href=\"|href=\"http://$PIPELINE_HOST:$PIPELINE_REPO_PORT/maven/|" >> releaseDescriptor.xml
        ssh -n $PIPELINE_USER@$PIPELINE_HOST "mkdir -p /var/www/html/maven/$RELATIVE_PATH"
        rsync -av "$LOCAL_PATH" $PIPELINE_USER@$PIPELINE_HOST:"/var/www/html/maven/`echo "$RELATIVE_PATH" | sed 's/[^/]*$//'`"
        if [ "$DEBUG" = "1" ]; then echo $? ; fi
    fi
done
echo "</releaseDescriptor>" >> releaseDescriptor.xml

cat releaseDescriptor.xml | ssh $PIPELINE_USER@$PIPELINE_HOST "cat >> /var/www/html/pipeline-updates/$DESCRIPTOR_VERSION"

if [ "$GIT_BRANCH" != "HEAD" ]; then
    ssh -n $PIPELINE_USER@$PIPELINE_HOST "cp /var/www/html/pipeline-updates/$DESCRIPTOR_VERSION /var/www/html/pipeline-updates/$GIT_BRANCH"
fi

if [ "$GIT_BRANCH" != "nlb" ]; then
    ssh -n $PIPELINE_USER@$PIPELINE_HOST "cp /var/www/html/pipeline-updates/$DESCRIPTOR_VERSION /var/www/html/pipeline-updates/current"
fi

ssh -n $PIPELINE_USER@$PIPELINE_HOST "mkdir -p /var/www/html/maven/pipeline-builds"
rsync -av *zip $PIPELINE_USER@$PIPELINE_HOST:"/var/www/html/pipeline-builds"
