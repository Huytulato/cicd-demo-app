pipeline {
    agent any // Chạy trên master hoặc agent bất kỳ có cài đủ tool (JDK, Maven, Docker client)

    environment {
        // Biến môi trường để dễ quản lý tên image
        // Thay 'your-dockerhub-username' bằng username Docker Hub của bạn nếu muốn push
        // Nếu chỉ chạy local, có thể đặt tên tùy ý, ví dụ: 'my-local/springboot-app'
        DOCKER_IMAGE_NAME = "huytu2004/springboot-app"
        // Hoặc nếu không push lên Hub:
        // DOCKER_IMAGE_NAME = "cicd-demo-app-local"
        CONTAINER_NAME    = "springboot-cicd-demo" // Tên cho container khi chạy
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                // Sử dụng checkout scm để lấy code từ cấu hình SCM của job
                // Jenkins sẽ tự động dùng credentials nếu repo là private và job được cấu hình đúng
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Building the Spring Boot application with Maven Wrapper...'
                script {
                    // Đảm bảo Maven Wrapper thực thi được (quan trọng trên Linux/Mac)
                    if (isUnix()) {
                        sh 'chmod +x mvnw'
                    }
                    // Chạy lệnh build bằng Maven Wrapper
                    if (isUnix()) {
                        sh './mvnw clean package -DskipTests' // Bỏ qua test ở đây vì có stage riêng (hoặc gộp vào đây)
                    } else {
                        // Sử dụng bat cho Windows agent (nếu có) hoặc khi Jenkins chạy trực tiếp trên Windows
                        bat '.\\mvnw.cmd clean package -DskipTests'
                    }
                }
            }
        }

        stage('Test') { // Stage này có thể gộp vào Build nếu muốn
            steps {
                echo 'Running Unit tests...'
                script {
                    if (isUnix()) {
                        sh './mvnw test'
                    } else {
                        bat '.\\mvnw.cmd test'
                    }
                    // (Tùy chọn) Publish JUnit test results
                    // junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                script {
                    // Đảm bảo Dockerfile tồn tại
                    if (!fileExists('Dockerfile')) {
                        error "Dockerfile not found!"
                    }
                    // Build Docker image, tag với build number
                    // Dấu '.' cuối cùng chỉ định context build là thư mục hiện tại (workspace)
                    sh "docker build -t ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ."
                    // (Tùy chọn) Tag thêm là latest để dễ dàng tham chiếu phiên bản mới nhất
                    sh "docker tag ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ${env.DOCKER_IMAGE_NAME}:latest"
                }
            }
        }

        // (Tùy chọn) Stage để push image lên Docker Hub
        // stage('Push Docker Image') {
        //     when {
        //         branch 'main' // Chỉ push khi build trên nhánh main
        //     }
        //     steps {
        //         echo "Pushing Docker image to Docker Hub..."
        //         // Cần tạo credentials loại 'Username with password' cho Docker Hub trong Jenkins
        //         // với ID ví dụ là 'dockerhub-credentials'
        //         withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
        //             sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
        //             sh "docker push ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
        //             sh "docker push ${env.DOCKER_IMAGE_NAME}:latest"
        //             sh "docker logout"
        //         }
        //     }
        // }

        stage('Deploy') {
            steps {
                echo 'Deploying the application using Docker...'
                script {
                    def hostPort = 8081 // Chọn một cổng khác 8080 trên host để tránh xung đột với Jenkins
                    def containerPort = 8080 // Port mà Spring Boot chạy trong container (EXPOSE trong Dockerfile)
                    def imageToRun = "${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}" // Sử dụng image vừa build

                    // Dừng và xóa container cũ nếu đang chạy (dùng tên đã định nghĩa)
                    sh "docker stop ${env.CONTAINER_NAME} || true" // '|| true' để lệnh không fail nếu container chưa tồn tại
                    sh "docker rm ${env.CONTAINER_NAME} || true"

                    // Chạy container mới từ image vừa build
                    // -d: chạy nền
                    // --name: đặt tên container
                    // -p: map port host:container
                    // --rm: (Tùy chọn) tự xóa container khi nó dừng (nếu không muốn giữ lại log/trạng thái)
                    sh "docker run -d --name ${env.CONTAINER_NAME} -p ${hostPort}:${containerPort} ${imageToRun}"

                    echo "Application deployed successfully!"
                    // Lấy IP của máy host (cách này có thể không hoạt động trên mọi hệ thống, cần điều chỉnh)
                    // def hostIp = sh(script: 'hostname -I | cut -d\' \' -f1', returnStdout: true).trim()
                    // Thay thế bằng IP thực tế của máy bạn hoặc localhost nếu truy cập từ cùng máy
                    echo "Access it at: http://localhost:${hostPort}/hello"
                }
            }
        }
    }

    post { // Các hành động sau khi pipeline kết thúc
        always {
            echo 'Pipeline finished.'
            // Dọn dẹp workspace sau khi build
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
            // Gửi thông báo thành công (ví dụ: Slack, Email - cần cấu hình plugin)
        }
        failure {
            echo 'Pipeline failed!'
            // Gửi thông báo lỗi
        }
    }
}