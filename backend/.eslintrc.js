module.exports = {
  parser: '@typescript-eslint/parser',
  extends: [
    'eslint:recommended',
    '@typescript-eslint/recommended',
  ],
  plugins: [
    '@typescript-eslint',
  ],
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
    project: './tsconfig.json',
  },
  rules: {
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-explicit-any': 'warn',
    'no-console': 'warn',
  },
  env: {
    node: true,
    jest: true,
  },
  ignorePatterns: ['dist/', 'node_modules/', '*.js'],
};