package com.studyroom;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordGeneratorTest {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String rawPassword = "123456";
        String encodedPassword = encoder.encode(rawPassword);
        System.out.println("Raw: " + rawPassword);
        System.out.println("Encoded: " + encodedPassword);
        
        // 验证
        boolean matches = encoder.matches(rawPassword, encodedPassword);
        System.out.println("Matches: " + matches);
        
        // 验证现有密码
        String existingHash = "$2a$10$ZaacJxfVA2eMJyGXH2Jum.RwcqySt1dWb4o9leYuT4F1vc1eU6uOu";
        boolean existingMatches = encoder.matches(rawPassword, existingHash);
        System.out.println("Existing hash matches: " + existingMatches);
    }
}
