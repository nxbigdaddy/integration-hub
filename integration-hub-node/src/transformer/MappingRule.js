export class MappingRule {
  constructor({ sourcePath, targetPath, transformExpression }) {
    this.sourcePath = sourcePath;
    this.targetPath = targetPath;
    this.transformExpression = transformExpression || null;
  }
}