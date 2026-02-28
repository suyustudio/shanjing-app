# Q2 自动化测试框架搭建

> Week 4 Day 1 - 极简基础搭建

---

## 1. Jest 配置文件

### `jest.config.js`

```javascript
module.exports = {
  // 测试环境
  testEnvironment: 'node',
  
  // 测试文件匹配模式
  testMatch: ['**/__tests__/**/*.test.js'],
  
  // 覆盖率配置
  collectCoverage: false,
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/**/*.test.js'
  ],
  
  // 测试超时
  testTimeout: 10000,
  
  // 模块路径别名
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1'
  },
  
  // 测试前准备
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js']
};
```

### `jest.setup.js`

```javascript
// 全局测试配置
// 可添加全局 mock、自定义 matcher 等

// 示例：扩展 Jest 超时
defaultTimeout = 10000;
```

---

## 2. 测试目录结构

```
project-root/
├── jest.config.js          # Jest 主配置
├── jest.setup.js           # 测试环境初始化
├── package.json            # 依赖: jest
├── src/                    # 源代码
│   └── utils/
│       └── calculator.js
└── __tests__/              # 测试目录
    ├── unit/               # 单元测试
    │   └── calculator.test.js
    ├── integration/        # 集成测试
    └── e2e/                # 端到端测试
```

---

## 3. 示例测试文件

### 源代码：`src/utils/calculator.js`

```javascript
class Calculator {
  add(a, b) {
    return a + b;
  }

  subtract(a, b) {
    return a - b;
  }

  multiply(a, b) {
    return a * b;
  }

  divide(a, b) {
    if (b === 0) {
      throw new Error('Cannot divide by zero');
    }
    return a / b;
  }
}

module.exports = Calculator;
```

### 测试文件：`__tests__/unit/calculator.test.js`

```javascript
const Calculator = require('../../src/utils/calculator');

describe('Calculator', () => {
  let calc;

  beforeEach(() => {
    calc = new Calculator();
  });

  describe('add()', () => {
    test('should add two positive numbers', () => {
      expect(calc.add(2, 3)).toBe(5);
    });

    test('should handle negative numbers', () => {
      expect(calc.add(-2, 3)).toBe(1);
    });
  });

  describe('subtract()', () => {
    test('should subtract two numbers', () => {
      expect(calc.subtract(5, 3)).toBe(2);
    });
  });

  describe('multiply()', () => {
    test('should multiply two numbers', () => {
      expect(calc.multiply(4, 3)).toBe(12);
    });
  });

  describe('divide()', () => {
    test('should divide two numbers', () => {
      expect(calc.divide(10, 2)).toBe(5);
    });

    test('should throw error when dividing by zero', () => {
      expect(() => calc.divide(10, 0)).toThrow('Cannot divide by zero');
    });
  });
});
```

---

## 4. 快速开始

### 安装依赖

```bash
npm init -y
npm install --save-dev jest
```

### 运行测试

```bash
# 运行所有测试
npm test

# 或直接使用 jest
npx jest

# 监视模式
npx jest --watch

# 生成覆盖率报告
npx jest --coverage
```

### package.json 脚本

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  }
}
```

---

## 5. 后续扩展建议

- [ ] 添加 ESLint + Prettier 代码规范
- [ ] 集成 CI/CD (GitHub Actions)
- [ ] 添加 API 测试 (supertest)
- [ ] 添加数据库测试 (testcontainers)
- [ ] 添加性能测试 (k6)

---

*完成时间: Week 4 Day 1*
