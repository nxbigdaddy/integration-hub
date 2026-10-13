export class ValidationRule {
  constructor({ fieldPath, type, pattern, required }) {
    this.fieldPath = fieldPath;
    this.type = type; // 'REGEX', 'RANGE', 'REQUIRED'
    this.pattern = pattern || null;
    this.required = required || false;
  }
}