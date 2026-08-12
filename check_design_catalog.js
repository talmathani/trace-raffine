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

  const result = await client.query(`
    SELECT definition
    FROM pg_views
    WHERE schemaname = 'public'
      AND viewname = 'design_catalog';
  `);

  console.log('');
  console.log('===== DESIGN CATALOG VIEW =====');

  if (result.rows.length === 0) {
    console.log('VIEW NOT FOUND');
  } else {
    console.log(result.rows[0].definition);
  }

  console.log('===============================');

  await client.end();
}

main().catch((error) => {
  console.error('ERROR:', error.message);
  process.exit(1);
});
