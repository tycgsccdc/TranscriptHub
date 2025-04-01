
/**
 * @file shared.js
 * @description Worker process management and operation memo utilities.
 * 
 * @module shared
 */
let process_sync_worker_pids = [];

function get_worker_pids() {
  return process_sync_worker_pids;
}

function set_worker_pids(pids) {
  process_sync_worker_pids = pids;
}

function add_worker_pid(pid) {
  process_sync_worker_pids.push(pid);
}

function remove_worker_pid(pid) {
  process_sync_worker_pids = process_sync_worker_pids.filter(p => p !== pid);
}


function operation_memo({
  route = '',
  token = '',
  sso_account = '',
  ip_address = '',
  query_time = '',
  ref = null
} = {}) {
  return {
    route,
    token,
    sso_account,
    ip_address,
    query_time,
    process_id: '' + process.pid, // automatically set to current process pid
    ref
  };
}


module.exports = {
  get_worker_pids,
  set_worker_pids,
  add_worker_pid,
  remove_worker_pid,
  operation_memo,
};
