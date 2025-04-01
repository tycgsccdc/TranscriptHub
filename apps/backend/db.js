// db.js - Database connection module
const sql = require('mssql');
const cfg = require('./config.js');
const { LOG_LEVEL, TASK_STATUS, NOTIFY_STATUS } = require('./constants.js');
const { TASK_QUERIES } = require('./query_constants.js');


// Create and export the connection pool
const pool_promise = new sql.ConnectionPool(cfg.sql_config)
  .connect()
  .then(pool => {
    console.log('Database connected successfully');
    // logger(LOG_LEVEL.INFO, 'Database connected successfully');
    // console.log(generate_timestamp() + ` - INFO - [${process.pid}] Database connected successfully.`);
    return pool;
  })
  .catch(err => {
    console.error('Database connection failed:', err);
    // logger(LOG_LEVEL.ERROR, `Database connection failed: ${err}`);
    // console.error(generate_timestamp() + ` - ERROR - [${process.pid}] Database connection failed: ${err}`);
    throw err;
  });

async function log_operation_to_db(data) {
  /* Query syntax */
  const query_log_operation = TASK_QUERIES.ACCESS_OPERTION.LOG_OPERATION;
  const query_log_operation_error = TASK_QUERIES.ACCESS_OPERTION.LOG_OPERATION_ERROR;

  try {
    const pool = await pool_promise;
    await pool.request()
      .input('token', sql.NVarChar, data.token || '')
      .input('ip_address', sql.NVarChar, data.ip_address || '')
      .input('sso_account', sql.NVarChar, data.sso_account || '')
      .input('query_time', sql.NVarChar, data.query_time || '')
      .input('process_id', sql.NVarChar, data.process_id || '')
      .input('code', sql.NVarChar, data.code || '')
      .input('route', sql.NVarChar, data.route || '')
      .input('ref', sql.BigInt, data.ref)
      .input('log', sql.NVarChar, data.log || '')
      .query(query_log_operation);
  } catch (err) {
    const pool = await pool_promise;
    await pool.request()
      .input('token', sql.NVarChar, data.token || '')
      .input('ip_address', sql.NVarChar, data.ip_address || '')
      .input('sso_account', sql.NVarChar, data.sso_account || '')
      .input('query_time', sql.NVarChar, data.query_time || '')
      .input('process_id', sql.NVarChar, data.process_id || '')
      .input('code', sql.NVarChar, data.code || '-1')
      .input('route', sql.NVarChar, data.route || '')
      .input('ref', sql.BigInt, data.ref)
      .input('err', sql.NVarChar, err || '')
      .query(query_log_operation_error);
    console.error(`[${process.pid}] log_operation: data write failed ${err}.`);
  }
}

module.exports = {
  // sql_db,
  pool_promise,
  log_operation_to_db
};

