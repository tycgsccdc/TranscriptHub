// db-init.js - Database Initialization Script (Revised for AI_AP as target, using createdb.sql)

const fs = require('fs'); // Standard fs module for existsSync
const fsPromises = require('fs').promises; // fs.promises for async operations
const path = require('path');
const sql = require('mssql');

// Load environment variables from .env file
require('dotenv').config();

/**
 * Executes statements from a single SQL file.
 * Statements are expected to be separated by 'GO'.
 */
async function execute_sql_file(pool, file_path) {
  console.log(`Executing SQL file: ${path.basename(file_path)}...`);
  try {
    const content = await fsPromises.readFile(file_path, 'utf8');
    // Split statements by 'GO' on its own line (case-insensitive, trims whitespace)
    const statements = content.split(/^\s*GO\s*$/im).filter(stmt => stmt.trim());

    if (statements.length === 0 && content.trim() !== '') {
        // If no GO separator but file has content, treat as single statement
        console.log(`  Executing as single statement (no GO separator found)...`);
        await pool.request().query(content.trim());
        console.log(`  Executed single statement from ${path.basename(file_path)}`);
    } else {
        let executedCount = 0;
        for (const statement of statements) {
          const trimmedStatement = statement.trim();
          if (trimmedStatement) {
            // console.log(`  Executing statement: ${trimmedStatement.substring(0, 100)}...`); // Log part of the statement
            await pool.request().query(trimmedStatement);
            executedCount++;
          }
        }
        console.log(`  Executed ${executedCount} statement(s) from ${path.basename(file_path)}`);
    }
  } catch (error) {
    // Log the specific error and the file it occurred in
    console.error(`\n--- ERROR executing ${path.basename(file_path)} ---`);
    console.error(`SQL Error Code: ${error.code}, Number: ${error.number}, Message: ${error.message}`);
    // Log the statement that might have caused the error (if easily possible)
    // This requires more complex parsing, so we'll skip for now.
    console.error(`Error details:`, error);
    console.error(`-----------------------------------------------\n`);
    throw error; // Re-throw error to stop the initialization process
  }
}

/**
 * Initializes the database by connecting and executing SQL scripts in order.
 * Assumes createdb.sql handles database creation.
 */
async function initialize_database() {
  // --- Configuration to connect initially (likely to master to run createdb.sql) ---
  // Although createdb.sql *should* run against master, mssql driver might require
  // a database context, even if it's just master. Let's try master first.
  const masterConfig = {
    server: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: 'master', // Connect to master initially
    options: {
      trustServerCertificate: true // Important for local Docker connections
    }
  };

  // --- Configuration to connect to the target database (AI_AP) after creation ---
  const targetDbName = process.env.DB_NAME;
  if (!targetDbName) {
      console.error("FATAL ERROR: DB_NAME environment variable is not set in .env file.");
      process.exit(1);
  }
  const targetConfig = {
    ...masterConfig, // Inherit server, user, password, options
    database: targetDbName // Target the correct database (AI_AP)
  };

  let pool = null; // Define pool outside try block

  try {
    // --- Step 1: Define the order of SQL scripts ---
    const sql_dir = path.join(__dirname, 'sql');
    console.log(`Looking for SQL files in: ${sql_dir}`);

    // Ensure createdb.sql is first, followed by others
    const file_order = [
      'createdb.sql',
      'access_operation.sql',         // <--- 先創建表
      'access_operation_error.sql', // <--- 再創建相關表
      'task.sql',                     // <--- 再創建 TASK 表
      'initial.sql'                  // <--- 最後執行初始化腳本
    ];
    console.log('SQL script execution order:', file_order.join(', '));

    // --- Step 2: Execute scripts ---
    // We need to connect differently for createdb.sql vs the rest.

    // Execute createdb.sql against master
    console.log(`Connecting to 'master' database on ${masterConfig.server} to run createdb.sql...`);
    pool = await sql.connect(masterConfig);
    console.log("Connected to 'master'.");
    const createDbPath = path.join(sql_dir, 'createdb.sql');
    if (fs.existsSync(createDbPath)) {
        await execute_sql_file(pool, createDbPath);
    } else {
        console.warn(`Warning: 'createdb.sql' not found at ${createDbPath}. Assuming database '${targetDbName}' already exists or is created elsewhere.`);
    }
    console.log("Closing connection to 'master'.");
    await pool.close();
    pool = null; // Reset pool

    // Now connect to the target database (AI_AP) to run the rest
    console.log(`Connecting to target database '${targetDbName}' on ${targetConfig.server}...`);
    pool = await sql.connect(targetConfig);
    console.log(`Connected to target database '${targetDbName}'.`);

    // Execute remaining files in specified order against the target DB
    for (const file of file_order) {
      // Skip createdb.sql as it was already run
      if (file.toLowerCase() === 'createdb.sql') {
          continue;
      }

      const file_path = path.join(sql_dir, file);
      if (fs.existsSync(file_path)) {
        await execute_sql_file(pool, file_path);
      } else {
        // Log warning but continue if other essential scripts might exist
        console.warn(`Warning: SQL script ${file} not found at ${file_path}`);
      }
    }

    console.log('\n-----------------------------------------------');
    console.log('Database initialization completed successfully.');
    console.log('-----------------------------------------------');

  } catch (error) {
    // Catch errors from connect or execute_sql_file
    console.error('\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    console.error('Database initialization failed.');
    console.error('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    // Error details were already logged in execute_sql_file or connect catch
    process.exit(1); // Exit with error code
  } finally {
    // Ensure the final connection pool is closed
    if (pool && pool.connected) {
      console.log('Closing final database connection.');
      await pool.close();
    } else if (sql.connected) { // Fallback check
        await sql.close();
    }
  }
}

// --- Run the initialization ---
initialize_database();