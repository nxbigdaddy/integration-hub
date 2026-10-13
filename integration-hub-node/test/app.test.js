import request from 'supertest';
import app, { server } from '../src/app.js';

afterAll((done) => {
  if (server) server.close(done);
  else done();
});

describe('API Integration Tests', () => {
  test('POST /api/v1/route should resolve route', async () => {
    const res = await request(app)
      .post('/api/v1/route')
      .send({ path: '/health' });
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.targetService).toBe('health_svc');
  });

  test('POST /api/v1/route should return 404 on no match', async () => {
    const res = await request(app)
      .post('/api/v1/route')
      .send({ path: '/unknown' });
    expect(res.statusCode).toBe(404);
    expect(res.body.success).toBe(false);
  });

  test('POST /api/v1/transform should transform data', async () => {
    const res = await request(app)
      .post('/api/v1/transform')
      .send({
        source: JSON.stringify({ name: 'test' }),
        rules: [{ sourcePath: '$.name', targetPath: '$.user', transformExpression: 'UPPER' }]
      });
    expect(res.statusCode).toBe(200);
    expect(res.body.data.user).toBe('TEST');
  });

  test('POST /api/v1/validate should validate data', async () => {
    const res = await request(app)
      .post('/api/v1/validate')
      .send({
        data: JSON.stringify({ email: 'a@b.com' }),
        rules: [{ fieldPath: '$.email', type: 'REQUIRED', required: true }]
      });
    expect(res.statusCode).toBe(200);
    expect(res.body.valid).toBe(true);
  });
});