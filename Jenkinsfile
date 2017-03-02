node {
    stage 'Checkout'
    checkout scm
    
    stage 'Build'
    sh 'make clean'
    sh 'mkdir -p .maven-cache'
    sh 'make dist-zip-linux'
    
    stage 'Test'
    sh 'make check'
    
    stage 'Distribute'
    sh './distribute.sh'
}
