import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';
import jwt from 'jsonwebtoken';
import { RouteEngine } from './router/RouteEngine.js';
import { RouteRule } from './router/RouteRule.js';
import { DataTransformer } from './transformer/DataTransformer.js';
import { MappingRule } from './transformer/MappingRule.js';
import { ValidationEngine } from './validator/ValidationEngine.js';
import { ValidationRule } from './validator/ValidationRule.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, '../public')));

const JWT_SECRET = 'YOUR_APP_SECRET';

// Mock users
const users = [
  { username: 'admin', password: 'YOUR_PASSWORD', role: 'admin' },
  { username: 'user', password: 'YOUR_PASSWORD', role: 'user' }
];

const routeEngine = new RouteEngine();
const dataTransformer = new DataTransformer();
const validationEngine = new ValidationEngine();

const mockRules = [
  new RouteRule({ ruleId: 'r1', priority: 10, matchType: 'PREFIX', pattern: '/api/v1', targetService: 'service_v1' }),
  new RouteRule({ ruleId: 'r2', priority: 20, matchType: 'EXACT', pattern: '/health', targetService: 'health_svc' })
];

// Auth middleware
const authenticateToken = (req, res, next) => {
  const token = YOUR_SECRET' ')[1];
  if (!token) return res.status(401).json({ success: false, message: '未授权' });
  
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ success: false, message: 'Token 无效' });
    req.user = user;
    next();
  });
};

// Login route
app.post('/api/v1/login', (req, res) => {
  const { username, password } = req.body;
  const user = users.find(u => u.username === username && u.password === password);
  
  if (user) {
    const token = YOUR_SECRET username: user.username, role: user.role }, JWT_SECRET, { expiresIn: '24h' });
    res.json({ success: true, token, user: { username: user.username, role: user.role } });
  } else {
    res.status(401).json({ success: false, message: '用户名或密码错误' });
  }
});

// Protected routes
app.post('/api/v1/route', authenticateToken, (req, res) => {
  try {
    const { path: reqPath, headers } = req.body;
    const target = routeEngine.resolveRoute(reqPath, headers, mockRules);
    res.json({ success: true, targetService: target });
  } catch (err) {
    res.status(404).json({ success: false, error: err.message });
  }
});

app.post('/api/v1/transform', authenticateToken, (req, res) => {
  try {
    const { source, rules } = req.body;
    const mappingRules = rules.map(r => new MappingRule(r));
    const result = dataTransformer.transform(source, mappingRules);
    res.json({ success: true, data: JSON.parse(result) });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

app.post('/api/v1/validate', authenticateToken, (req, res) => {
  try {
    const { data, rules } = req.body;
    const validationRules = rules.map(r => new ValidationRule(r));
    const isValid = validationEngine.validate(data, validationRules);
    res.json({ success: true, valid: isValid });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

// Dashboard route
app.get('/dashboard', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/dashboard.html'));
});

// Login page
app.get('/login', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/login.html'));
});

// Redirect root to login
app.get('/', (req, res) => {
  res.redirect('/login');
});

const PORT = process.env.PORT || 3000;
let server;

if (process.env.NODE_ENV !== 'test') {
  server = app.listen(PORT, () => console.log(`Integration Hub running on http://localhost:${PORT}`));
}

export { app, server };
export default app;