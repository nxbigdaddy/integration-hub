package com.enterprise.integration.router;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import java.util.List;
import java.util.Map;
import static org.junit.jupiter.api.Assertions.*;

class RouteEngineTest {

    private RouteEngine routeEngine;
    private List<RouteRule> rules;

    @BeforeEach
    void setUp() {
        routeEngine = new RouteEngine();
        rules = List.of(
            new RouteRule("r1", 10, RouteRule.MatchType.PREFIX, "/api/v1", null, "service_v1"),
            new RouteRule("r2", 20, RouteRule.MatchType.PREFIX, "/api/v2", null, "service_v2"),
            new RouteRule("r3", 30, RouteRule.MatchType.EXACT, "/health", null, "health_service"),
            new RouteRule("r4", 40, RouteRule.MatchType.HEADER, null, Map.of("X-Tenant", "A"), "tenant_a_service")
        );
    }

    @Test
    void testExactMatch() {
        assertEquals("health_service", routeEngine.resolveRoute("/health", Map.of(), rules));
    }

    @Test
    void testPrefixMatchHigherPriority() {
        assertEquals("service_v2", routeEngine.resolveRoute("/api/v2/users", Map.of(), rules));
    }

    @Test
    void testHeaderMatch() {
        assertEquals("tenant_a_service", routeEngine.resolveRoute("/any", Map.of("X-Tenant", "A"), rules));
    }

    @Test
    void testNoMatchThrowsException() {
        assertThrows(RuntimeException.class, () -> 
            routeEngine.resolveRoute("/unknown", Map.of(), List.of())
        );
    }

    @Test
    void testEmptyRulesThrowsException() {
        assertThrows(IllegalArgumentException.class, () -> 
            routeEngine.resolveRoute("/api", Map.of(), null)
        );
    }
}