import { JSONPath } from 'jsonpath-plus';

export class ValidationEngine {
  validate(json, rules = []) {
    if (!json || !rules) return false;

    let jsonObj;
    try {
      jsonObj = typeof json === 'string' ? JSON.parse(json) : json;
    } catch (e) {
      return false;
    }

    for (const rule of rules) {
      const values = JSONPath({ path: rule.fieldPath, json: jsonObj });
      const value = values && values.length > 0 ? values[0] : null;

      if (rule.required && (value === null || value === undefined)) {
        return false;
      }

      if (value !== null && value !== undefined) {
        if (rule.type === 'REGEX' && rule.pattern) {
          const regex = new RegExp(rule.pattern);
          if (!regex.test(String(value))) return false;
        }
        if (rule.type === 'RANGE') {
          // Simplified range check (assumes rule has min/max in pattern as "min,max")
          if (rule.pattern) {
            const [min, max] = rule.pattern.split(',').map(Number);
            const num = Number(value);
            if (isNaN(num) || num < min || num > max) return false;
          }
        }
      }
    }
    return true;
  }
}