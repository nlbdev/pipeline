node {
    stage 'Checkout'
    checkout scm
    
    stage 'Build'
    sh 'make clean'
    sh 'make SKIP_RELEASE=true dist-zip-minimal'
    sh 'make SKIP_RELEASE=true dist-zip-linux'
    
    stage 'Test'
    sh 'make SKIP_RELEASE=true check-modules/nlb'
    sh 'make SKIP_RELEASE=true check-modules/nordic'
    sh 'make SKIP_RELEASE=true check'
    
    stage 'Distribute'
    sh './distribute.sh'
}
