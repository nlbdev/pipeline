node {
    try {
        notifyBuild('STARTED')
        
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
        
    } catch (e) {
        // If there was an exception thrown, the build failed
        currentBuild.result = "FAILED"
        
    } finally {
        // Success or failure, always send notifications
        notifyBuild(currentBuild.result)
    }
}

def notifyBuild(String buildStatus = 'STARTED') {
  // build status of null means successful
  buildStatus =  buildStatus ?: 'SUCCESSFUL'

  // Default values
  def colorName = 'RED'
  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"
  def details = """<p>STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
    <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>"""

  // Override default values based on build status
  if (buildStatus == 'STARTED') {
    color = 'YELLOW'
    colorCode = '#FFFF00'
  } else if (buildStatus == 'SUCCESSFUL') {
    color = 'GREEN'
    colorCode = '#00FF00'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
  }

  // Send notifications
  slackSend(color: colorCode, message: summary, channel: "#braille-in-pipeline")
}
