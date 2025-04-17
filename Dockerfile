# Stage 1: Sử dụng base image chứa JRE phù hợp với phiên bản Java bạn dùng
# Ví dụ: openjdk:17-jre-slim nếu bạn dùng Java 17
FROM openjdk:17-jre-slim

# Đặt thư mục làm việc bên trong container
WORKDIR /app

# Copy file JAR đã được build bởi Maven vào thư mục /app trong container
# Dấu * giúp khớp với tên file JAR có chứa phiên bản (0.0.1-SNAPSHOT)
COPY target/cicd_demo_app-*.jar app.jar

# Expose port mà Spring Boot chạy (mặc định 8080)
EXPOSE 8080

# Lệnh để chạy ứng dụng khi container khởi động
ENTRYPOINT ["java", "-jar", "app.jar"]