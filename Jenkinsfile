pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                // Build Docker image
                script {
                    docker.build('my-app-image')
                }
            }
        }
        stage('Code Quality Analysis') {
            steps {
                // Run SonarQube analysis
                withSonarQubeEnv('SonarQube') {
                    sh 'sonar-scanner'
                }
            }
        }
        stage('Test') {
            steps {
                // Run tests here (e.g., unit tests)
                sh 'docker run --rm my-app-image test-command'
            }
        }
        stage('Deploy') {
            steps {
                // Deploy to your environment (e.g., Kubernetes or directly on EC2)
                sh 'docker run -d --name my-app -p 80:80 my-app-image'
            }
        }
    }
}
