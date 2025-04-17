package com.project1.cicd_demo_app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication // Chỉ giữ lại annotation này
public class CicdDemoAppApplication {

	// Thêm phương thức main chuẩn vào đây
	public static void main(String[] args) {
		SpringApplication.run(CicdDemoAppApplication.class, args);
	}

}
