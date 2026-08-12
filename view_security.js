const { Client } = require('pg');

const client = new Client({
  host: 'aws-0-ap-northeast-2.pooler.supabase.com',
  port: 6543,
  database: 'postgres',
  user: 'postgres.cncjkeeucwxiazfgdbiv',
  password: process.env.SUPABASE_DB_PASSWORD,
  ssl: { rejectUnauthorized: false },
});

async function main() {
  await client.connect();

  const r = await client.query(`
    SELECT
      c.relname AS view_name,
      c.reloptions
    FROM pg_class c
    JOIN pg_namespace n
      ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relname = 'design_catalog';
  `);

  console.log('===== VIEW SECURITY =====');
  console.log(JSON.stringify(r.rows, null, 2));
  console.log('=========================');

  await client.end();
}

main().catch(e => {
  console.error('ERROR:', e.message);
  process.exit(1);
});
