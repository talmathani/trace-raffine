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
      column_name,
      data_type,
      is_nullable
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'designs'
    ORDER BY ordinal_position;
  `);

  console.log('');
  console.log('===== DESIGNS COLUMNS =====');

  for (const row of result.rows) {
    console.log(
      row.column_name +
      ' | ' +
      row.data_type +
      ' | nullable=' +
      row.is_nullable
    );
  }

  console.log('===========================');

  await client.end();
}

main().catch((error) => {
  console.error('ERROR:', error.message);
  process.exit(1);
});
