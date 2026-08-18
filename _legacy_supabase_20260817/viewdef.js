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
    SELECT pg_get_viewdef(
      'public.design_catalog'::regclass,
      true
    ) AS definition
  `);

  console.log('===== DESIGN CATALOG =====');
  console.log(r.rows[0].definition);
  console.log('==========================');

  await client.end();
}

main().catch(e => {
  console.error('ERROR:', e.message);
  process.exit(1);
});
