pipeline {
    agent {
        docker {
            image 'docker:latest'
            reuseNode true // Giữ nguyên hoặc bỏ đi tùy ý
            // *** THÊM -u root VÀO ĐÂY ***
            args '-v /var/run/docker.sock:/var/run/docker.sock -u root'
        }
    }
    environment {
        DOCKER_IMAGE_NAME = "huytu2004/springboot-app"
        CONTAINER_NAME    = "springboot-cicd-demo"
    }
    stages {
        // Các stages giữ nguyên như phiên bản trước
        stage('Checkout') {
            agent none
            steps {
                echo 'Checking out code on Jenkins master/node...'
                checkout scm
            }
        }
        stage('Build Application & Docker Image') {
            steps {
                echo "Building application and Docker image: ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                script {
                    // Lệnh sh sẽ chạy bên trong agent docker:latest với quyền root
                    sh "docker build -t ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ."
                    sh "docker tag ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ${env.DOCKER_IMAGE_NAME}:latest"
                }
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying the application using Docker...'
                script {
                    def hostPort = 8081
                    def containerPort = 8080
                    def imageToRun = "${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"

                    // Lệnh sh sẽ chạy bên trong agent docker:latest với quyền root
                    sh "docker stop ${env.CONTAINER_NAME} || true"
                    sh "docker rm ${env.CONTAINER_NAME} || true"
                    sh "docker run -d --name ${env.CONTAINER_NAME} -p ${hostPort}:${containerPort} ${imageToRun}"

                    echo "Application deployed successfully!"
                    echo "Access it at: http://localhost:${hostPort}/hello"
                }
            }
        }
    }
    post {
        always {
            echo 'Pipeline finished.'
            node('') {
                echo 'Cleaning workspace...'
                cleanWs()
            }
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}