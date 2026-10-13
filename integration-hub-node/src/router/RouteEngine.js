import { RouteRule } from './RouteRule.js';

export class RouteEngine {
  resolveRoute(path, headers = {}, rules = []) {
    if (!rules || rules.length === 0) {
      throw new Error('Route rules cannot be empty');
    }

    const sortedRules = [...rules].sort((a, b) => b.priority - a.priority);
    
    for (const rule of sortedRules) {
      if (this.matches(rule, path, headers)) {
        return rule.targetService;
      }
    }

    throw new Error(`No matching route found for path: ${path}`);
  }

  matches(rule, path, headers) {
    switch (rule.matchType) {
      case 'EXACT':
        return path === rule.pattern;
      case 'PREFIX':
        return path.startsWith(rule.pattern);
      case 'HEADER':
        return this.matchHeaders(rule.headerConditions, headers);
      default:
        return false;
    }
  }

  matchHeaders(conditions, actualHeaders) {
    if (!conditions || Object.keys(conditions).length === 0) return false;
    return Object.entries(conditions).every(
      ([key, value]) => actualHeaders && actualHeaders[key] === value
    );
  }
}