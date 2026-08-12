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
      schemaname,
      tablename,
      policyname,
      permissive,
      roles,
      cmd,
      qual,
      with_check
    FROM pg_policies
    WHERE schemaname = 'public'
    ORDER BY tablename, policyname;
  `);

  console.log('');
  console.log('===== RLS POLICIES =====');
  console.log('POLICY COUNT:', result.rows.length);

  for (const row of result.rows) {
    console.log('');
    console.log('TABLE:', row.tablename);
    console.log('POLICY:', row.policyname);
    console.log('COMMAND:', row.cmd);
    console.log('ROLES:', row.roles);
    console.log('USING:', row.qual);
    console.log('WITH CHECK:', row.with_check);
  }

  console.log('');
  console.log('========================');

  await client.end();
  console.log('Done.');
}

main().catch((error) => {
  console.error('ERROR:', error.message);
  process.exit(1);
});
