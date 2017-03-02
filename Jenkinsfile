node {
    stage 'Checkout'
    checkout scm
    
    stage 'Build'
    sh 'make clean'
    sh 'mkdir -p .maven-cache'
    sh 'make dist-zip-minimal'
    
    stage 'Test'
    sh 'make check-modules/nlb'
    sh 'make check-modules/nordic'
    
    stage 'Distribute'
    sh './distribute.sh'
}
