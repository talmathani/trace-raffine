const fs = require('fs');
const { Client } = require('pg');

const sql = fs.readFileSync(
  'supabase/migrations/001_initial_schema.sql',
  'utf8'
);

const password = process.env.SUPABASE_DB_PASSWORD;

if (!password) {
  throw new Error('SUPABASE_DB_PASSWORD is missing.');
}

const client = new Client({
  host: 'aws-0-ap-northeast-2.pooler.supabase.com',
  port: 6543,
  database: 'postgres',
  user: 'postgres.cncjkeeucwxiazfgdbiv',
  password,
  ssl: { rejectUnauthorized: false },
});

(async () => {
  try {
    console.log('Connecting to Supabase PostgreSQL...');
    await client.connect();

    console.log('Connected successfully.');
    console.log('Applying TRACÉ RAFINÉ database schema...');

    await client.query(sql);

    console.log('========================================');
    console.log('DATABASE SCHEMA APPLIED SUCCESSFULLY');
    console.log('========================================');
  } catch (error) {
    console.error('DATABASE MIGRATION FAILED');
    console.error(error.message);
    process.exitCode = 1;
  } finally {
    await client.end().catch(() => {});
  }
})();
