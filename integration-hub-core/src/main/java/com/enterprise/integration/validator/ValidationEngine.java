package com.enterprise.integration.validator;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.jayway.jsonpath.JsonPath;
import org.springframework.stereotype.Component;
import java.util.List;
import java.util.regex.Pattern;

@Component
public class ValidationEngine {

    private final ObjectMapper objectMapper = new ObjectMapper();

    public boolean validate(String json, List<ValidationRule> rules) throws Exception {
        if (json == null || rules == null) return false;

        JsonNode node = objectMapper.readTree(json);
        String jsonStr = node.toString();

        for (ValidationRule rule : rules) {
            Object value = null;
            try {
                value = JsonPath.read(jsonStr, rule.fieldPath());
            } catch (Exception ignored) {}

            if (rule.required() && value == null) {
                return false;
            }

            if (value != null) {
                if (rule.type() == ValidationType.REGEX && rule.pattern() != null) {
                    if (!Pattern.matches(rule.pattern(), value.toString())) return false;
                }
                if (rule.type() == ValidationType.RANGE) {
                    // Simplified range check logic
                    if (value instanceof Number num) {
                        // Real impl would parse min/max from rule
                    }
                }
            }
        }
        return true;
    }
}