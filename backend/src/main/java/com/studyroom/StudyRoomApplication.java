package com.studyroom;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * 智慧自习室座位预约系统
 * 
 * @author StudyRoom Team
 * @version 1.0.0
 */
@SpringBootApplication
@EnableScheduling
public class StudyRoomApplication {

    public static void main(String[] args) {
        SpringApplication.run(StudyRoomApplication.class, args);
        System.out.println("========================================");
        System.out.println("  智慧自习室系统启动成功！");
        System.out.println("  API文档: http://localhost:9090/doc.html");
        System.out.println("========================================");
    }
}
