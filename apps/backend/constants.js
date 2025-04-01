/**
 * @brief System-wide logging level constants
 * @enum {number}
 * 
 * Defines severity levels for system logging with ascending priority:
 * - INFO (0):       General information messages
 * - INFO_TABLE (5): Tabular data output
 * - WARNING (10):   Non-critical issues
 * - ERROR (99):     Critical system errors
 * 
 * Usage:
 * logger(LOG_LEVEL.INFO, "Operation completed successfully");
 * logger(LOG_LEVEL.ERROR, "Critical system failure");
 * 
 * @note Lower values indicate lower severity
 * @note Values are spaced to allow insertion of new levels
 */
const LOG_LEVEL = {
  INFO: 0,        /* General information logging */
  INFO_TABLE: 5,  /* Tabular data output */
  WARNING: 10,    /* Non-critical warnings */
  ERROR: 99       /* Critical system errors */
};
// const LOG_LEVEL = {
//     INFO: 0,        /* General information logging */
//     INFO_TABLE: 5,  /* Tabular data output */
//     WARNING: 10,    /* Non-critical warnings */
//     ERROR: 99       /* Critical system errors */
// };


/**
 * @brief Notification status constants for task state updates
 * @enum {number}
 * 
 * Defines notification status levels with descending priority:
 * - FINISH (10):  Task completed successfully
 * - PENDING (5):  Task is in progress/waiting
 * - CANCEL (1):   Task was cancelled
 * - ERROR (0):    Task failed with error
 * 
 * Usage:
 * send_notification(NOTIFY_STATUS.FINISH, "Task 123 completed");
 * send_notification(NOTIFY_STATUS.ERROR, "Task 123 failed");
 * 
 * @note Higher values indicate more positive outcomes
 * @note Values are spaced to allow insertion of new states
 */
const NOTIFY_STATUS = {
  FINISH: 10,   /* Task completed successfully */
  PENDING: 5,   /* Task in progress/waiting */
  CANCEL: 1,    /* Task cancelled by user/system */
  ERROR: 0      /* Task failed with error */
};
// const NOTIFY_STATUS = {
//   FINISH: 10,
//   PENDING: 5,
//   CANCEL: 1,
//   ERROR: 0
// };

/**
 * @brief Task lifecycle status constants
 * @enum {string}
 * 
 * Defines status codes for task lifecycle stages:
 * Positive values indicate normal progression:
 * - CREATED (0):      Task initially created
 * - IN_PROGRESS (1):  Task currently processing
 * - COMPLETED (2):    Task finished successfully
 * 
 * Negative values indicate abnormal termination:
 * - CANCELLED_BY_USER (-1): User-initiated cancellation
 * - TERMINATED (-2):       System-forced termination
 * - FILE_IO_ERROR (-3):    File operation failure
 * 
 * Usage:
 * update_task_status(task_id, TASK_STATUS.IN_PROGRESS);
 * if (task.status === TASK_STATUS.COMPLETED) { ... }
 * 
 * @note Status codes are strings for database compatibility
 * @note Values ordered by lifecycle progression
 */
const TASK_STATUS = {
  CREATED: '0',          /* Initial task creation */
  IN_PROGRESS: '1',      /* Active processing */
  COMPLETED: '2',        /* Successful completion */
  CANCELLED_BY_USER: '-1', /* User cancellation */
  TERMINATED: '-2',      /* System termination */
  FILE_IO_ERROR: '-3'    /* File operation failure */
};
// const TASK_STATUS = {
//   CREATED: '0',
//   IN_PROGRESS: '1',
//   COMPLETED: '2',
//   CANCELLED_BY_USER: '-1',
//   TERMINATED: '-2',
//   FILE_IO_ERROR: '-3'
// };

module.exports = {
  LOG_LEVEL,
  TASK_STATUS,
  NOTIFY_STATUS
};

  
