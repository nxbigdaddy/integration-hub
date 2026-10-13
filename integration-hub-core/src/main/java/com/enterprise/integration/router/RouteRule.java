package com.enterprise.integration.router;

import java.util.Map;

public record RouteRule(
    String ruleId,
    int priority,
    MatchType matchType,
    String pattern,
    Map<String, String> headerConditions,
    String targetService
) {
    public enum MatchType {
        EXACT, PREFIX, HEADER
    }
}