import { DataTransformer } from '../../src/transformer/DataTransformer.js';
import { MappingRule } from '../../src/transformer/MappingRule.js';

describe('DataTransformer', () => {
  let transformer;

  beforeEach(() => {
    transformer = new DataTransformer();
  });

  test('should transform simple mapping', () => {
    const source = JSON.stringify({ id: 123, name: 'Alice' });
    const rules = [
      new MappingRule({ sourcePath: '$.id', targetPath: '$.user_id' }),
      new MappingRule({ sourcePath: '$.name', targetPath: '$.full_name', transformExpression: 'UPPER' })
    ];
    const result = JSON.parse(transformer.transform(source, rules));
    expect(result.user_id).toBe(123);
    expect(result.full_name).toBe('ALICE');
  });

  test('should apply LOWER transform', () => {
    const source = JSON.stringify({ email: 'TEST@EXAMPLE.COM' });
    const rules = [new MappingRule({ sourcePath: '$.email', targetPath: '$.contact', transformExpression: 'LOWER' })];
    const result = JSON.parse(transformer.transform(source, rules));
    expect(result.contact).toBe('test@example.com');
  });

  test('should apply TRIM transform', () => {
    const source = JSON.stringify({ name: '  Bob  ' });
    const rules = [new MappingRule({ sourcePath: '$.name', targetPath: '$.trimmed', transformExpression: 'TRIM' })];
    const result = JSON.parse(transformer.transform(source, rules));
    expect(result.trimmed).toBe('Bob');
  });

  test('should skip missing fields', () => {
    const source = JSON.stringify({ name: 'Bob' });
    const rules = [new MappingRule({ sourcePath: '$.missing', targetPath: '$.target' })];
    const result = JSON.parse(transformer.transform(source, rules));
    expect(result).toEqual({});
  });

  test('should throw on null input', () => {
    expect(() => transformer.transform(null, [])).toThrow('Source JSON and rules cannot be null');
  });

  test('should throw on invalid JSON', () => {
    expect(() => transformer.transform('{invalid}', [])).toThrow('Invalid JSON input');
  });

  test('should parse boolean and number values', () => {
    const source = JSON.stringify({ active: 'true', count: '42' });
    const rules = [
      new MappingRule({ sourcePath: '$.active', targetPath: '$.is_active' }),
      new MappingRule({ sourcePath: '$.count', targetPath: '$.total' })
    ];
    const result = JSON.parse(transformer.transform(source, rules));
    expect(result.is_active).toBe(true);
    expect(result.total).toBe(42);
  });
});