package com.enterprise.integration.transformer;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.jayway.jsonpath.JsonPath;
import org.springframework.stereotype.Component;
import java.util.List;

@Component
public class DataTransformer {

    private final ObjectMapper objectMapper = new ObjectMapper();

    public String transform(String sourceJson, List<MappingRule> rules) throws Exception {
        if (sourceJson == null || rules == null) {
            throw new IllegalArgumentException("Source JSON and rules cannot be null");
        }

        JsonNode sourceNode = objectMapper.readTree(sourceJson);
        ObjectNode targetNode = objectMapper.createObjectNode();

        for (MappingRule rule : rules) {
            try {
                Object value = JsonPath.read(sourceNode.toString(), rule.sourcePath());
                if (value != null) {
                    String finalValue = applyTransform(value.toString(), rule.transformExpression());
                    JsonPath.parse(targetNode).set(rule.targetPath(), parseValue(finalValue));
                }
            } catch (Exception e) {
                // Log and continue or handle based on policy
            }
        }

        return objectMapper.writeValueAsString(targetNode);
    }

    private String applyTransform(String value, String expression) {
        if (expression == null || expression.isBlank()) return value;
        return switch (expression) {
            case "UPPER" -> value.toUpperCase();
            case "LOWER" -> value.toLowerCase();
            case "TRIM" -> value.trim();
            default -> value; // Support custom script evaluation in real impl
        };
    }

    private Object parseValue(String value) {
        if (value.equalsIgnoreCase("true") || value.equalsIgnoreCase("false")) return Boolean.parseBoolean(value);
        try { return Integer.parseInt(value); } catch (NumberFormatException ignored) {}
        try { return Double.parseDouble(value); } catch (NumberFormatException ignored) {}
        return value;
    }
}