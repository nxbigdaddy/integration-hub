package com.enterprise.integration.router;

import org.springframework.stereotype.Component;
import java.util.List;
import java.util.Map;

@Component
public class RouteEngine {

    public String resolveRoute(String path, Map<String, String> headers, List<RouteRule> rules) {
        if (rules == null || rules.isEmpty()) {
            throw new IllegalArgumentException("Route rules cannot be empty");
        }

        return rules.stream()
            .sorted((r1, r2) -> Integer.compare(r2.priority(), r1.priority()))
            .filter(rule -> matches(rule, path, headers))
            .map(RouteRule::targetService)
            .findFirst()
            .orElseThrow(() -> new RuntimeException("No matching route found for path: " + path));
    }

    private boolean matches(RouteRule rule, String path, Map<String, String> headers) {
        return switch (rule.matchType()) {
            case EXACT -> path.equals(rule.pattern());
            case PREFIX -> path.startsWith(rule.pattern());
            case HEADER -> matchHeaders(rule.headerConditions(), headers);
        };
    }

    private boolean matchHeaders(Map<String, String> conditions, Map<String, String> actualHeaders) {
        if (conditions == null || conditions.isEmpty()) return false;
        return conditions.entrySet().stream()
            .allMatch(e -> actualHeaders != null && e.getValue().equals(actualHeaders.get(e.getKey())));
    }
}