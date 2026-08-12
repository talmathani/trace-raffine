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
      policyname,
      cmd,
      roles,
      qual,
      with_check
    FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
    ORDER BY policyname;
  `);

  console.log('');
  console.log('===== STORAGE OBJECT POLICIES =====');
  console.log('COUNT:', result.rows.length);

  for (const row of result.rows) {
    console.log('');
    console.log('POLICY:', row.policyname);
    console.log('COMMAND:', row.cmd);
    console.log('ROLES:', row.roles);
    console.log('USING:', row.qual ?? 'NULL');
    console.log('WITH CHECK:', row.with_check ?? 'NULL');
  }

  console.log('');
  console.log('===================================');

  await client.end();
  console.log('Done.');
}

main().catch((error) => {
  console.error('ERROR:', error.message);
  process.exit(1);
});
