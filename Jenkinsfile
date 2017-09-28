node {
    stage 'Checkout'
    checkout scm
    
    stage 'Build'
    sh 'make clean'
    sh 'mkdir -p .maven-cache'
    sh 'make clean || true'
    sh 'make SKIP_RELEASE=true check || true'
    sh 'make SKIP_RELEASE=true dist-zip-minimal'
    
    stage 'Test'
    sh 'make SKIP_RELEASE=true check-modules/nlb'
    sh 'make SKIP_RELEASE=true check-modules/nordic'
    
    stage 'Distribute'
    sh './distribute.sh'
}
