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
      id,
      email,
      created_at,
      confirmed_at
    FROM auth.users
    ORDER BY created_at DESC
    LIMIT 20;
  `);

  console.log('');
  console.log('===== AUTH USERS CHECK =====');
  console.log('AUTH USERS FOUND:', result.rows.length);

  if (result.rows.length === 0) {
    console.log('NO AUTH USERS FOUND');
  }

  for (const row of result.rows) {
    console.log('');
    console.log('ID:', row.id);
    console.log('EMAIL:', row.email ?? 'NULL');
    console.log('CREATED AT:', row.created_at);
    console.log('CONFIRMED AT:', row.confirmed_at ?? 'NULL');
  }

  console.log('');
  console.log('============================');

  await client.end();
  console.log('Done.');
}

main().catch((error) => {
  console.error('ERROR:', error.message);
  process.exit(1);
});
