#!/usr/bin/env groovy

pipeline {
    agent any
    
    options {
        skipDefaultCheckout()
    }
    
    stages {
        stage('Checkout') {
            steps {
                sh 'echo "Started job \"$JOB_NAME [$BUILD_NUMBER]\". Check console output at $RUN_DISPLAY_URL" | slack-cli -d braille-in-pipeline || true'
                deleteDir()
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'make RUBY=ruby clean'
                sh 'make RUBY=ruby dist-zip-minimal'
                sh 'make RUBY=ruby dist-zip-linux'
            }
        }
        
        stage('Test') {
            steps {
                sh 'make RUBY=ruby check-modules/nlb/book-to-pef'
                sh 'make RUBY=ruby check-modules/nlb/html-to-dtbook'
                sh 'make RUBY=ruby check-modules/nlb/mailchimp'
                sh 'make RUBY=ruby check-modules/nlb/catalog-month'
                sh 'make RUBY=ruby check-modules/nlb/catalog-year'
                sh 'make RUBY=ruby check-modules/nlb/metadata-utils'
                sh 'make RUBY=ruby check-modules/nlb/tts-adapter-filibuster'
                sh 'make RUBY=ruby check-modules/nordic/epub3-dtbook-migrator'
            }
        }
        
        stage('Distribute') {
            steps {
                sh './distribute.sh'
            }
        }
    }
    
    post {
        always {
            junit "**/target/surefire-reports/*.xml"
            archiveArtifacts artifacts: "modules/nlb/**/*.jar"
            archiveArtifacts artifacts: "modules/nordic/**/*.jar"
            archiveArtifacts artifacts: "**/target/test.log"
            archiveArtifacts artifacts: "maven.log"
            archiveArtifacts artifacts: "descriptor-current.xml"
            cleanWs()
        }
        
        failure {
            sh 'echo "(...)" > /tmp/maven.log && tail -n 30 maven.log >> /tmp/maven.log && slack-cli -d braille-in-pipeline -f /tmp/maven.log || true'
            sh 'echo "Build failed: \"$JOB_NAME [$BUILD_NUMBER]\"" | slack-cli -d braille-in-pipeline || true'
        }
        
        success {
            sh 'echo "Build successful: \"$JOB_NAME [$BUILD_NUMBER]\"" | slack-cli -d braille-in-pipeline || true'
        }
    }
}
