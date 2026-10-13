import { JSONPath } from 'jsonpath-plus';

export class DataTransformer {
  transform(sourceJson, rules = []) {
    if (!sourceJson || !rules) {
      throw new Error('Source JSON and rules cannot be null');
    }

    let sourceObj;
    try {
      sourceObj = typeof sourceJson === 'string' ? JSON.parse(sourceJson) : sourceJson;
    } catch (e) {
      throw new Error('Invalid JSON input');
    }

    const targetObj = {};

    for (const rule of rules) {
      try {
        const values = JSONPath({ path: rule.sourcePath, json: sourceObj });
        if (values && values.length > 0) {
          let value = values[0];
          value = this.applyTransform(String(value), rule.transformExpression);
          this.setNestedValue(targetObj, rule.targetPath, this.parseValue(value));
        }
      } catch (e) {
        // Skip missing fields
      }
    }

    return JSON.stringify(targetObj);
  }

  applyTransform(value, expression) {
    if (!expression) return value;
    switch (expression) {
      case 'UPPER': return value.toUpperCase();
      case 'LOWER': return value.toLowerCase();
      case 'TRIM': return value.trim();
      default: return value;
    }
  }

  parseValue(value) {
    if (value.toLowerCase() === 'true') return true;
    if (value.toLowerCase() === 'false') return false;
    if (!isNaN(value) && value.trim() !== '') return Number(value);
    return value;
  }

  setNestedValue(obj, path, value) {
    const parts = path.replace(/^\$/, '').split('.').filter(Boolean);
    let current = obj;
    for (let i = 0; i < parts.length - 1; i++) {
      if (!current[parts[i]]) current[parts[i]] = {};
      current = current[parts[i]];
    }
    current[parts[parts.length - 1]] = value;
  }
}