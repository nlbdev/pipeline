pipeline {
    agent any
    
    options {
        skipDefaultCheckout()
    }
    
    stages {
        stage('Checkout') {
            sh 'echo "Started job \"$JOB_NAME [$BUILD_NUMBER]\". Check console output at $BUILD_URL" | slack-cli -d braille-in-pipeline || true'
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
        
        post {
            always {
                junit "**/target/surefire-reports/*.xml"
                archiveArtifacts artifacts: "modules/nlb/**/*.jar"
                archiveArtifacts artifacts: "modules/nordic/**/*.jar"
                archiveArtifacts artifacts: "**/target/test.log"
                archiveArtifacts artifacts: "maven.log"
                archiveArtifacts artifacts: "descriptor-current.xml"
            }
            
            failure {
                sh 'tail -n 30 maven.log | slack-cli -d braille-in-pipeline || true'
                sh 'echo "Build failed: \"$JOB_NAME [$BUILD_NUMBER]\"" | slack-cli -d braille-in-pipeline || true'
            }
            
            success {
                sh 'echo "Build successful: \"$JOB_NAME [$BUILD_NUMBER]\"" | slack-cli -d braille-in-pipeline || true'
            }
        }
    }
}
