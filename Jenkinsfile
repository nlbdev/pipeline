node {
    stage 'Checkout'
    checkout scm
    
    stage 'Build'
    sh 'make clean'
    sh 'mkdir -p .maven-cache'
    sh 'make clean || true'
    sh 'make SKIP_RELEASE=true SKIP_GROUP_EVAL_TARGET=true EVAL=eval check || true'
    sh 'make SKIP_RELEASE=true SKIP_GROUP_EVAL_TARGET=true EVAL=eval dist-zip-minimal'
    
    stage 'Test'
    sh 'make SKIP_RELEASE=true SKIP_GROUP_EVAL_TARGET=true EVAL=eval check-modules/nlb'
    sh 'make SKIP_RELEASE=true SKIP_GROUP_EVAL_TARGET=true EVAL=eval check-modules/nordic'
    
    stage 'Distribute'
    sh './distribute.sh'
}
