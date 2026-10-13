import { ValidationEngine } from '../../src/validator/ValidationEngine.js';
import { ValidationRule } from '../../src/validator/ValidationRule.js';

describe('ValidationEngine', () => {
  let engine;

  beforeEach(() => {
    engine = new ValidationEngine();
  });

  test('should pass required field validation', () => {
    const json = JSON.stringify({ email: 'test@test.com' });
    const rules = [new ValidationRule({ fieldPath: '$.email', type: 'REQUIRED', required: true })];
    expect(engine.validate(json, rules)).toBe(true);
  });

  test('should fail required field validation', () => {
    const json = JSON.stringify({ name: 'test' });
    const rules = [new ValidationRule({ fieldPath: '$.email', type: 'REQUIRED', required: true })];
    expect(engine.validate(json, rules)).toBe(false);
  });

  test('should pass regex validation', () => {
    const json = JSON.stringify({ phone: '13800138000' });
    const rules = [new ValidationRule({ fieldPath: '$.phone', type: 'REGEX', pattern: '^1[3-9]\\d{9}$' })];
    expect(engine.validate(json, rules)).toBe(true);
  });

  test('should fail regex validation', () => {
    const json = JSON.stringify({ phone: '12345' });
    const rules = [new ValidationRule({ fieldPath: '$.phone', type: 'REGEX', pattern: '^1[3-9]\\d{9}$' })];
    expect(engine.validate(json, rules)).toBe(false);
  });

  test('should pass range validation', () => {
    const json = JSON.stringify({ age: 25 });
    const rules = [new ValidationRule({ fieldPath: '$.age', type: 'RANGE', pattern: '18,60' })];
    expect(engine.validate(json, rules)).toBe(true);
  });

  test('should fail range validation', () => {
    const json = JSON.stringify({ age: 10 });
    const rules = [new ValidationRule({ fieldPath: '$.age', type: 'RANGE', pattern: '18,60' })];
    expect(engine.validate(json, rules)).toBe(false);
  });

  test('should return false on null input', () => {
    expect(engine.validate(null, [])).toBe(false);
  });

  test('should return false on invalid JSON', () => {
    expect(engine.validate('{bad}', [])).toBe(false);
  });
});