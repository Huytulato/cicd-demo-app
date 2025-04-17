// Khai báo pipeline theo cú pháp Declarative
pipeline {
    // --- Agent Configuration ---
    // Chỉ định rằng các stage (trừ những stage có agent riêng) sẽ chạy
    // bên trong một container Docker được tạo tự động.
    agent {
        docker {
            // Sử dụng image Docker chính thức, tag 'latest' (luôn lấy bản mới nhất)
            // Image này có chứa sẵn Docker client CLI.
            image 'docker:latest'
            // Tùy chọn: Cho phép Jenkins tái sử dụng node agent nếu có thể,
            // thay vì luôn tạo container mới. Có thể tăng tốc độ build.
            reuseNode true
            // **Rất quan trọng:** Mount Docker socket từ máy host Jenkins vào
            // container agent này. Điều này cho phép Docker client bên trong agent
            // giao tiếp và điều khiển Docker daemon trên máy host.
            args '-v /var/run/docker.sock:/var/run/docker.sock'
            // Lưu ý: Nếu chạy Jenkins trên Linux và gặp lỗi quyền truy cập socket,
            // bạn có thể cần cấp quyền cho user chạy container agent (thường là 'jenkins')
            // để truy cập file socket trên host, hoặc chạy agent với user root:
            // args '-v /var/run/docker.sock:/var/run/docker.sock -u root'
        }
    }

    // --- Environment Variables ---
    // Định nghĩa các biến môi trường sẽ có sẵn trong suốt pipeline
    environment {
        // Tên đầy đủ của Docker image sẽ được build.
        // Thay 'huytu2004' bằng username Docker Hub của bạn nếu muốn push lên Hub.
        // Nếu chỉ chạy local, có thể đặt tên tùy ý, ví dụ 'my-local/springboot-app'.
        DOCKER_IMAGE_NAME = "huytu2004/springboot-app"
        // Tên sẽ đặt cho container ứng dụng khi chạy ở stage Deploy
        CONTAINER_NAME    = "springboot-cicd-demo"
    }

    // --- Pipeline Stages ---
    // Định nghĩa các giai đoạn chính của quy trình CI/CD
    stages {
        // Stage 1: Checkout Code
        // Stage này nên chạy trên node Jenkins chính (master hoặc agent cố định)
        // để lấy code trước khi khởi động Docker agent.
        stage('Checkout') {
            // Chỉ định không sử dụng Docker agent đã khai báo ở cấp pipeline
            agent none
            steps {
                echo 'Checking out code on Jenkins master/node...'
                // Sử dụng step checkout scm để lấy code từ cấu hình SCM của Job
                checkout scm
            }
        }

        // Stage 2: Build Application & Docker Image
        // Stage này sẽ chạy bên trong Docker agent 'docker:latest'.
        // Nó thực thi lệnh 'docker build', sử dụng Dockerfile multi-stage
        // để biên dịch code Java và tạo ra image cuối cùng.
        stage('Build Application & Docker Image') {
            steps {
                echo "Building application and Docker image: ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                script {
                    // Lệnh sh sẽ được thực thi bởi shell bên trong container docker:latest
                    // Lệnh docker build sử dụng Dockerfile trong workspace hiện tại (.)
                    // và tag image với tên đã định nghĩa và số build của Jenkins.
                    sh "docker build -t ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ."

                    // (Tùy chọn) Tag thêm image vừa build với tag 'latest'.
                    // Giúp dễ dàng tham chiếu đến phiên bản mới nhất khi deploy hoặc kéo về.
                    sh "docker tag ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER} ${env.DOCKER_IMAGE_NAME}:latest"
                }
            }
        }

        // Stage 3: Deploy Application
        // Stage này cũng chạy bên trong Docker agent 'docker:latest'.
        // Nó sử dụng lệnh 'docker run' để khởi chạy container ứng dụng
        // từ image vừa được build ở stage trước.
        stage('Deploy') {
            steps {
                echo 'Deploying the application using Docker...'
                script {
                    // Định nghĩa cổng trên máy host và cổng bên trong container
                    def hostPort = 8081      // Cổng trên máy host (chọn cổng chưa được sử dụng)
                    def containerPort = 8080 // Cổng ứng dụng Spring Boot chạy (EXPOSE trong Dockerfile)
                    // Lấy tên image đầy đủ với tag là số build hiện tại
                    def imageToRun = "${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"

                    // Dừng container cũ có cùng tên (nếu đang chạy)
                    // '|| true' đảm bảo lệnh không bị lỗi nếu container chưa tồn tại
                    sh "docker stop ${env.CONTAINER_NAME} || true"
                    // Xóa container cũ đã dừng
                    sh "docker rm ${env.CONTAINER_NAME} || true"

                    // Chạy container mới từ image vừa build
                    // -d: Chạy ở chế độ nền (detached)
                    // --name: Đặt tên cho container để dễ quản lý
                    // -p: Map cổng hostPort tới containerPort
                    sh "docker run -d --name ${env.CONTAINER_NAME} -p ${hostPort}:${containerPort} ${imageToRun}"

                    echo "Application deployed successfully!"
                    // Hiển thị URL để truy cập ứng dụng (giả định truy cập từ localhost)
                    echo "Access it at: http://localhost:${hostPort}/hello"
                }
            }
        }

        // (Tùy chọn) Stage để push image lên Docker Hub
        // stage('Push Docker Image') {
        //     // Chỉ chạy stage này khi build trên nhánh 'main'
        //     when { branch 'main' }
        //     steps {
        //         echo "Pushing Docker image to Docker Hub..."
        //         // Sử dụng credentials đã lưu trong Jenkins (ID: 'dockerhub-credentials')
        //         // Credentials này cần là loại 'Username with password' cho Docker Hub
        //         withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
        //             // Đăng nhập vào Docker Hub bằng credentials
        //             sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
        //             // Push image với tag là build number
        //             sh "docker push ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
        //             // Push image với tag là 'latest'
        //             sh "docker push ${env.DOCKER_IMAGE_NAME}:latest"
        //             // Đăng xuất khỏi Docker Hub
        //             sh "docker logout"
        //         }
        //     }
        // }
    }

    // --- Post Build Actions ---
    // Các hành động được thực thi sau khi tất cả các stage hoàn thành
    post {
        // Luôn luôn thực thi, dù pipeline thành công hay thất bại
        always {
            echo 'Pipeline finished.'
            // Dọn dẹp workspace của Jenkins để tiết kiệm dung lượng
            cleanWs()
        }
        // Chỉ thực thi nếu pipeline thành công
        success {
            echo 'Pipeline succeeded!'
            // Có thể thêm bước gửi thông báo thành công (Slack, Email...)
        }
        // Chỉ thực thi nếu pipeline thất bại
        failure {
            echo 'Pipeline failed!'
            // Có thể thêm bước gửi thông báo lỗi
        }
    }
}