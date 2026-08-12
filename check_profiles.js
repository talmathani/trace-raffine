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
      role,
      display_name,
      created_at
    FROM public.profiles
    ORDER BY created_at DESC
    LIMIT 20;
  `);

  console.log('');
  console.log('===== PROFILES CHECK =====');
  console.log('PROFILES FOUND:', result.rows.length);

  if (result.rows.length === 0) {
    console.log('NO PROFILES FOUND');
  }

  for (const row of result.rows) {
    console.log('');
    console.log('ID:', row.id);
    console.log('ROLE:', row.role);
    console.log('DISPLAY NAME:', row.display_name ?? 'NULL');
    console.log('CREATED AT:', row.created_at);
  }

  console.log('');
  console.log('==========================');

  await client.end();
  console.log('Done.');
}

main().catch((error) => {
  console.error('ERROR:', error.message);
  process.exit(1);
});
