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
  console.log('Connecting...');
  await client.connect();
  console.log('Connected.');

  const result = await client.query(`
    SELECT
      table_schema,
      table_name
    FROM information_schema.tables
    WHERE table_schema IN ('storage')
    ORDER BY table_schema, table_name;
  `);

  console.log('');
  console.log('===== SUPABASE STORAGE TABLES =====');
  console.log('COUNT:', result.rows.length);

  for (const row of result.rows) {
    console.log(
      `${row.table_schema}.${row.table_name}`
    );
  }

  console.log('===================================');

  await client.end();
}

main().catch((error) => {
  console.error('ERROR:', error.message);
  process.exit(1);
});
