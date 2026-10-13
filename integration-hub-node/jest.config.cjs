module.exports = {
  testEnvironment: 'node',
  transform: {},
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/app.js'
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 90,
      lines: 90,
      statements: 90
    }
  }
};