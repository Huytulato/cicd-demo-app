    post {
        always {
            echo 'Pipeline finished.'
            // **THAY ĐỔI Ở ĐÂY:** Thêm label vào khối node
            // Sử dụng label trống '' để yêu cầu một executor bất kỳ có sẵn
            node('') {
                echo 'Cleaning workspace...'
                cleanWs()
            }
            // Hoặc nếu bạn biết label của node master (ví dụ: 'master' hoặc 'built-in'),
            // bạn có thể dùng nó:
            // node('master') { ... }
        }
        success {
            echo 'Pipeline succeeded!'
            // ...
        }
        failure {
            echo 'Pipeline failed!'
            // ...
        }
    }