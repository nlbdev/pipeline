pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            checkout scm
        }
        
        stage('Build') {
            sh 'make clean'
            sh 'make SKIP_RELEASE=true dist-zip-minimal'
            sh 'make SKIP_RELEASE=true dist-zip-linux'
        }
        
        stage('Test') {
            sh 'make check-modules/nlb/book-to-pef'
            sh 'make check-modules/nlb/html-to-dtbook'
            sh 'make check-modules/nlb/mailchimp'
            sh 'make check-modules/nlb/catalog-month'
            sh 'make check-modules/nlb/catalog-year'
            sh 'make check-modules/nlb/metadata-utils'
            sh 'make check-modules/nlb/tts-adapter-filibuster'
            sh 'make check-modules/nordic/epub3-dtbook-migrator'
        }
        
        stage('Distribute') {
            sh './distribute.sh'
        }
    }
}
