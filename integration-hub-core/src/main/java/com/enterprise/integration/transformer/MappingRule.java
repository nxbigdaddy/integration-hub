package com.enterprise.integration.transformer;

public record MappingRule(
    String sourcePath,
    String targetPath,
    String transformExpression
) {}