export class RouteRule {
  constructor({ ruleId, priority, matchType, pattern, headerConditions, targetService }) {
    this.ruleId = ruleId;
    this.priority = priority;
    this.matchType = matchType; // 'EXACT', 'PREFIX', 'HEADER'
    this.pattern = pattern;
    this.headerConditions = headerConditions || {};
    this.targetService = targetService;
  }
}