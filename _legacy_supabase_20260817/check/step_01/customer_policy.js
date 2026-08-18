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

  console.log('Connected.');

  await client.query(`
    DROP POLICY IF EXISTS "designs_customer_read_published"
    ON public.designs;

    CREATE POLICY "designs_customer_read_published"
    ON public.designs
    FOR SELECT
    TO anon, authenticated
    USING (
      status = 'published'
    );
  `);

  console.log('');
  console.log('===== CUSTOMER PUBLISHED-DESIGN POLICY =====');
  console.log('POLICY CREATED SUCCESSFULLY');
  console.log('Only designs with status = published are readable.');
  console.log('============================================');

  await client.end();
}

main().catch((error) => {
  console.error('ERROR:', error.message);
  process.exit(1);
});
