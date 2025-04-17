# --- Stage 1: Build ---
# Sử dụng image Maven chính thức với JDK 17 (chọn phiên bản phù hợp với dự án của bạn)
# AS build đặt tên cho stage này là 'build' để có thể tham chiếu ở stage sau
FROM maven:3.9-eclipse-temurin-17 AS build

# Đặt thư mục làm việc bên trong container build
WORKDIR /app

# Copy chỉ file pom.xml trước tiên
# Điều này giúp tận dụng Docker layer caching. Bước tải dependencies chỉ chạy lại
# khi file pom.xml thay đổi, không phải mỗi khi code thay đổi.
COPY pom.xml .

# Tải tất cả dependencies được định nghĩa trong pom.xml về local Maven repository
# trong container. -B (batch mode) để chạy không tương tác.
RUN mvn dependency:go-offline -B

# Copy toàn bộ mã nguồn của dự án (thư mục src) vào thư mục làm việc /app
COPY src ./src

# Thực hiện build ứng dụng bằng Maven
# Lệnh package sẽ biên dịch code, chạy test (nếu không skip), và đóng gói thành file JAR
# -DskipTests bỏ qua việc chạy unit test trong quá trình build image này
# (Bạn có thể chạy test riêng biệt trong Jenkins nếu muốn kiểm soát kết quả tốt hơn)
# Nếu muốn chạy test ở đây, dùng: RUN mvn package
RUN mvn package -DskipTests

# --- Stage 2: Runtime ---
# Sử dụng một base image Java Runtime Environment (JRE) nhỏ gọn
# openjdk:17-jre-slim là một lựa chọn tốt, chỉ chứa những gì cần thiết để chạy Java
FROM openjdk:17-jre-slim

# Đặt thư mục làm việc cho container runtime
WORKDIR /app

# Copy file JAR đã được build thành công từ stage 'build' vào thư mục /app
# --from=build chỉ định lấy file từ stage có tên là 'build'
# Đường dẫn /app/target/cicd_demo_app-*.jar là nơi Maven tạo ra file JAR trong stage build
# app.jar là tên mới của file JAR trong container runtime này
COPY --from=build /app/target/cicd_demo_app-*.jar app.jar

# Khai báo cổng mà ứng dụng Spring Boot sẽ lắng nghe bên trong container
# (Mặc định Spring Boot Web chạy trên cổng 8080)
EXPOSE 8080

# Lệnh mặc định sẽ được thực thi khi container này khởi chạy
# Chạy ứng dụng Spring Boot từ file app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]