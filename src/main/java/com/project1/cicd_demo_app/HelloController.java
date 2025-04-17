package com.project1.cicd_demo_app;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController // Đánh dấu đây là Controller
public class HelloController {

    @GetMapping("/hello") // Xử lý request GET /hello
    public String sayHello() {
        return "Hello CI/CD with Spring Boot, Jenkins, and Docker!";
    }

}
