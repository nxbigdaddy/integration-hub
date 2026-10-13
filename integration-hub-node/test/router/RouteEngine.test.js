import { RouteEngine } from '../../src/router/RouteEngine.js';
import { RouteRule } from '../../src/router/RouteRule.js';

describe('RouteEngine', () => {
  let engine;
  let rules;

  beforeEach(() => {
    engine = new RouteEngine();
    rules = [
      new RouteRule({ ruleId: 'r1', priority: 10, matchType: 'PREFIX', pattern: '/api/v1', targetService: 'svc_v1' }),
      new RouteRule({ ruleId: 'r2', priority: 20, matchType: 'PREFIX', pattern: '/api/v2', targetService: 'svc_v2' }),
      new RouteRule({ ruleId: 'r3', priority: 30, matchType: 'EXACT', pattern: '/health', targetService: 'health' }),
      new RouteRule({ ruleId: 'r4', priority: 40, matchType: 'HEADER', headerConditions: { 'X-Tenant': 'A' }, targetService: 'tenant_a' })
    ];
  });

  test('should resolve exact match', () => {
    expect(engine.resolveRoute('/health', {}, rules)).toBe('health');
  });

  test('should resolve prefix match with higher priority', () => {
    expect(engine.resolveRoute('/api/v2/users', {}, rules)).toBe('svc_v2');
  });

  test('should resolve header match', () => {
    expect(engine.resolveRoute('/any', { 'X-Tenant': 'A' }, rules)).toBe('tenant_a');
  });

  test('should throw error when no rules match', () => {
    expect(() => engine.resolveRoute('/unknown', {}, rules)).toThrow('No matching route found');
  });

  test('should throw error when rules are empty', () => {
    expect(() => engine.resolveRoute('/api', {}, [])).toThrow('Route rules cannot be empty');
  });

  test('should throw error when rules are null', () => {
    expect(() => engine.resolveRoute('/api', {}, null)).toThrow('Route rules cannot be empty');
  });
});