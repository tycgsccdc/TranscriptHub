// env.js
const NODE_ENV = process.env.NODE_ENV || 'development';
const NODE_DB = process.env.NODE_DB || 'mssql';

module.exports = {
  __DEV__: NODE_ENV !== 'production',
  __PROD__: NODE_ENV === 'production',
  __TEST__: NODE_ENV === 'test',

  __MYSQL__: NODE_DB === 'mysql',
  __MSSQL__: NODE_DB === 'mssql',
  __MSSQL_TEST__: NODE_DB === 'mssql_test'
};