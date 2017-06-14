

node {
    def mvnHome
    stage('Preparation') { // for display purposes
        // Get some code from a GitHub repository
        git 'https://github.com/eschweit-at-tibco/bookstore.git'
        mvnHome = tool 'M3'
    }
    
    stage('Build') {
        // Run the maven build
        dir('tibco.bwce.sample.binding.rest.BookStore.application.parent') {
            if (isUnix()) {
                sh "'${mvnHome}/bin/mvn' -Dmaven.test.failure.ignore clean package"
            } else {
                bat(/"${mvnHome}\bin\mvn" -Dmaven.test.failure.ignore clean package/)
            }
        }
    }
    
    stage('Testing') {
        dir('tibco.bwce.sample.binding.rest.BookStore.application.parent') {
            if (isUnix()) {
                sh "ant build deploy-test-image newman undeploy-test-image"
            }
        }
    }
    
    stage('Results') {
        // junit '**/target/surefire-reports/TEST-*.xml'
        // archive 'target/*.jar'
    }
}
