const fs = require('fs').promises;
const path = require('path');
const sql = require('mssql');

require('dotenv').config();

async function execute_sql_file(pool, file_path) {
  try {
    const content = await fs.readFile(file_path, 'utf8');
    const statements = content.split('GO').filter(stmt => stmt.trim());
    
    for (const statement of statements) {
      if (statement.trim()) {
        await pool.request().query(statement);
        console.log(`Executed statement from ${path.basename(file_path)}`);
      }
    }
  } catch (error) {
    console.error(`Error executing ${file_path}:`, error);
    throw error;
  }
}

async function initialize_database() {
  const config = {
    server: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    options: {
      trustServerCertificate: true
    }
  };

  try {
    const pool = await sql.connect(config);
    
    // Create database if it doesn't exist
    await pool.request().query(
      `IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '${process.env.DB_NAME}')
       BEGIN
         CREATE DATABASE ${process.env.DB_NAME}
       END`
    );
    
    await pool.request().query(`USE ${process.env.DB_NAME}`);
    
    // Read SQL files from sql directory
    const sql_dir = path.join(__dirname, 'sql');
    const files = await fs.readdir(sql_dir);
    
    // Define the specific order of files
    const file_order = [
      'createdb.sql',
      'initial.sql',
      'acces_operation.sql',
      'access_opration_error.sql',
      'task.sql'
    ];

    // Execute files in specified order
    for (const file of file_order) {
      const file_path = path.join(sql_dir, file);
      if (fs.existsSync(file_path)) {
        await execute_sql_file(pool, file_path);
      } else {
        console.warn(`Warning: ${file} not found in sql directory`);
      }
    }

    console.log('Database initialization completed successfully');
  } catch (error) {
    console.error('Database initialization failed:', error);
    process.exit(1);
  } finally {
    await sql.close();
  }
}

// Run the initialization
initialize_database();