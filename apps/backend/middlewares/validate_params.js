/**
 * @file validate_params.js
 * @brief Parameter validation middleware for HTTP requests
 */
// const { logger } = require('../utils.dev.js');
const { logger } = require('../logger.js');
const { LOG_LEVEL } = require('../constants.js');

/**
 * @brief Validates required parameters in HTTP request
 * @param req Request object containing body and form data
 * @param res Response object
 * @param next Next middleware function
 * @return void
 */
function validate_params(req, res, next) {
  // Extract parameters from request body or form data
  const req_label = req.body?.label || req.form?.get("label");
  const req_sso_account = req.body?.sso_account || req.form?.get("sso_account");
  const req_token = req.body?.token || req.form?.get("token");
  const req_task_objid = req.body?.task_objid || req.form?.get("task_objid");

  const route = req.originalUrl || req.url || '[unknown route]';

  // Log request data for debugging
  logger(LOG_LEVEL.INFO_TABLE, req.form);
  logger(LOG_LEVEL.INFO_TABLE, req.body);

  // Validate required parameters
  if (!req_sso_account || !req_label || !req_token || !req_task_objid) {
    logger(LOG_LEVEL.ERROR,  
      `${route}: Missing parameters:\n` +
      ` sso_account  = ${req_sso_account}\n` +
      ` token        = ${req_token}\n` +
      ` label        = ${req_label}\n` +
      ` objid        = ${req_task_objid}`
    );
  }
  next();
}

module.exports = {
  validate_params
}