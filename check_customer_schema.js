const { Client } = require('pg');

const client = new Client({
  host: 'aws-0-ap-northeast-2.pooler.supabase.com',
  port: 6543,
  database: 'postgres',
  user: 'postgres.cncjkeeucwxiazfgdbiv',
  password: process.env.SUPABASE_DB_PASSWORD,
  ssl: { rejectUnauthorized: false },
});

const tables = [
  'profiles',
  'categories',
  'designs',
  'orders',
  'order_items',
  'downloads',
];

async function main() {
  await client.connect();

  for (const table of tables) {
    console.log('');
    console.log(`===== ${table.toUpperCase()} =====`);

    const columns = await client.query(`
      SELECT
        column_name,
        data_type,
        udt_name,
        is_nullable,
        column_default
      FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name = $1
      ORDER BY ordinal_position;
    `, [table]);

    for (const row of columns.rows) {
      console.log(
        `${row.column_name} | type=${row.data_type} | udt=${row.udt_name} | nullable=${row.is_nullable} | default=${row.column_default ?? 'NULL'}`
      );
    }

    const constraints = await client.query(`
      SELECT
        tc.constraint_name,
        tc.constraint_type,
        kcu.column_name,
        ccu.table_name AS foreign_table_name,
        ccu.column_name AS foreign_column_name
      FROM information_schema.table_constraints tc
      LEFT JOIN information_schema.key_column_usage kcu
        ON tc.constraint_name = kcu.constraint_name
       AND tc.table_schema = kcu.table_schema
      LEFT JOIN information_schema.constraint_column_usage ccu
        ON tc.constraint_name = ccu.constraint_name
       AND tc.table_schema = ccu.table_schema
      WHERE tc.table_schema = 'public'
        AND tc.table_name = $1
      ORDER BY tc.constraint_name, kcu.ordinal_position;
    `, [table]);

    console.log('--- CONSTRAINTS ---');

    for (const row of constraints.rows) {
      console.log(
        `${row.constraint_name} | ${row.constraint_type} | ${row.column_name ?? ''} | FK=${row.foreign_table_name ?? ''}.${row.foreign_column_name ?? ''}`
      );
    }
  }

  console.log('');
  console.log('===== RLS POLICIES =====');

  const policies = await client.query(`
    SELECT
      tablename,
      policyname,
      cmd,
      roles,
      qual,
      with_check
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename IN (
        'profiles',
        'categories',
        'designs',
        'orders',
        'order_items',
        'downloads'
      )
    ORDER BY tablename, policyname;
  `);

  for (const row of policies.rows) {
    console.log('');
    console.log(`TABLE: ${row.tablename}`);
    console.log(`POLICY: ${row.policyname}`);
    console.log(`COMMAND: ${row.cmd}`);
    console.log(`ROLES: ${row.roles}`);
    console.log(`USING: ${row.qual ?? 'NULL'}`);
    console.log(`WITH CHECK: ${row.with_check ?? 'NULL'}`);
  }

  await client.end();

  console.log('');
  console.log('===== DONE =====');
}

main().catch((error) => {
  console.error('ERROR:', error.message);
  process.exit(1);
});
