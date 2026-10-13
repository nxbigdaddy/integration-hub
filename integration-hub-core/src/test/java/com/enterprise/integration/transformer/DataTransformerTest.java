package com.enterprise.integration.transformer;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

class DataTransformerTest {

    private DataTransformer transformer;

    @BeforeEach
    void setUp() {
        transformer = new DataTransformer();
    }

    @Test
    void testSimpleMapping() throws Exception {
        String source = "{\"id\": 123, \"name\": \"Alice\"}";
        List<MappingRule> rules = List.of(
            new MappingRule("$.id", "$.user_id", null),
            new MappingRule("$.name", "$.full_name", "UPPER")
        );

        String result = transformer.transform(source, rules);
        JsonNode node = new ObjectMapper().readTree(result);

        assertEquals(123, node.get("user_id").asInt());
        assertEquals("ALICE", node.get("full_name").asText());
    }

    @Test
    void testTransformLower() throws Exception {
        String source = "{\"email\": \"TEST@EXAMPLE.COM\"}";
        List<MappingRule> rules = List.of(
            new MappingRule("$.email", "$.contact_email", "LOWER")
        );

        String result = transformer.transform(source, rules);
        assertTrue(result.contains("test@example.com"));
    }

    @Test
    void testNullInputThrowsException() {
        assertThrows(IllegalArgumentException.class, () -> 
            transformer.transform(null, List.of())
        );
    }

    @Test
    void testMissingFieldSkips() throws Exception {
        String source = "{\"name\": \"Bob\"}";
        List<MappingRule> rules = List.of(
            new MappingRule("$.missing_field", "$.target", null)
        );
        String result = transformer.transform(source, rules);
        assertEquals("{}", result);
    }
}