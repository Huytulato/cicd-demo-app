package com.project1.cicd_demo_app;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

// Import lớp HelloController để có thể tham chiếu trong @WebMvcTest
import com.project1.cicd_demo_app.HelloController;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// *** THAY ĐỔI QUAN TRỌNG: Chỉ định Controller cần test là HelloController ***
@WebMvcTest(HelloController.class)
class CicdDemoAppApplicationTests {

	// Tự động inject MockMvc để giả lập việc gửi HTTP request
	@Autowired
	private MockMvc mockMvc;

	@Test
	void helloEndpointShouldReturnSuccessMessage() throws Exception {
		// Thực hiện một GET request tới "/hello"
		mockMvc.perform(get("/hello"))
				// Mong đợi status code là 200 OK
				.andExpect(status().isOk())
				// Mong đợi nội dung trả về là chuỗi chính xác
				.andExpect(content().string("Hello CI/CD with Spring Boot, Jenkins, and Docker!"));
	}

	// Test này kiểm tra xem context tối thiểu cho WebMvcTest với HelloController có load được không
	@Test
	void contextLoads() {
		// Test này thường được tạo tự động và chỉ kiểm tra việc load context cơ bản cho test.
		// Với @WebMvcTest(HelloController.class), nó xác nhận rằng môi trường test tối thiểu
		// cho controller này đã được thiết lập thành công.
	}
}