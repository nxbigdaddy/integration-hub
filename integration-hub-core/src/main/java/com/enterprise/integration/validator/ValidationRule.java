package com.enterprise.integration.validator;

public record ValidationRule(
    String fieldPath,
    ValidationType type,
    String pattern,
    boolean required
) {
    public enum ValidationType {
        REGEX, RANGE, REQUIRED
    }
}