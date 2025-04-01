/**
 * @brief Multi-level logging system with file and database output
 * 
 * Writes log entries to console, file, and optionally database with:
 * - Timestamp (UTC+8)
 * - Log level
 * - Process ID
 * - Custom message
 * - Optional metadata
 * 
 * @param level   [in] LOG_LEVEL enum value indicating severity
 * @param message [in] Log message string
 * @param data    [in] Optional metadata object containing:
 *   - route       [string] API route path
 *   - token       [string] Authentication token
 *   - sso_account [string] User account
 *   - ip_address  [string] Client IP
 *   - query_time  [string] Operation timestamp
 *   - process_id  [string] Process identifier
 *   - ref         [bigint] Reference ID
 * @return void
 * 
 * Log Levels:
 * - INFO (0):       General information
 * - INFO_TABLE (5): Structured data output
 * - WARNING (10):   Non-critical issues
 * - ERROR (99):     Critical failures
 * 
 * Output Format:
 * YYYY-MM-DD HH:mm:ss - LEVEL - [PID] MESSAGE
 * 
 * Database Logging:
 * - Triggered when data parameter is provided
 * - Logs to ACCESS_OPERATION table
 * - Level stored as string in code field
 * 
 * @note Timestamp uses local system time
 * @note Database logging is asynchronous
 */
const { write_to_log_file, write_to_database} = require('./logger-writer.js');
const { LOG_LEVEL } = require('./constants.js');


async function logger(level, message, data = {}) {
  /* Generate UTC+8 timestamp */
  const timestamp = generate_timestamp();

  /* Formmatted message */
  const log_entry = formatted_message(timestamp, level, message);

  /* Handle output */
  // write_to_console(log_entry);
  write_to_log_file(log_entry);

  /* Write to database if metadata provided */
  if (has_metadata(data)) {
    await write_to_database(level, message, data);
  }
}

function generate_timestamp() {
  const UTC8_OFFSET = 0; // Correct UTC+8 offset
  const t = new Date((new Date().getTime()) + UTC8_OFFSET * 60 * 60 * 1000);
  
  const year = t.getFullYear();
  const month = pad_number(t.getMonth() + 1);
  const day = pad_number(t.getDate());
  const hours = pad_number(t.getHours());
  const minutes = pad_number(t.getMinutes());
  const seconds = pad_number(t.getSeconds());

  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
}

function formatted_message(timestamp, level, message) {
  const formatted = typeof message === 'object' ? JSON.stringify(message, null, 2) : message;
  let label = 'UNKNOWN';

  switch (level) {
    case LOG_LEVEL.INFO:        label = 'INFO'; break;
    case LOG_LEVEL.INFO_TABLE:  label = 'INFO_TABLE'; break;
    case LOG_LEVEL.WARNING:     label = 'WARNING'; break;
    case LOG_LEVEL.ERROR:       label = 'ERROR'; break;
  }

  return `${timestamp} - ${label} - [${process.pid}] ${formatted}`;

}

function pad_number(num) {
  return num.toString().padStart(2, '0');
}

function has_metadata(data) {
  return Object.keys(data).length > 0;
}



module.exports = {
  logger
};