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
    SELECT
      policyname,
      cmd,
      roles,
      qual
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'designs'
      AND policyname = 'designs_customer_read_published';
  `);

  console.log('');
  console.log('===== CUSTOMER DESIGN POLICY CHECK =====');
  console.log('POLICY COUNT:', result.rows.length);

  for (const row of result.rows) {
    console.log('POLICY:', row.policyname);
    console.log('COMMAND:', row.cmd);
    console.log('ROLES:', row.roles);
    console.log('USING:', row.qual);
  }

  console.log('========================================');

  await client.end();
}

main().catch((error) => {
  console.error('ERROR:', error.message);
  process.exit(1);
});
