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
      title_ar,
      status,
      preview_storage_key,
      design_storage_key,
      file_extension
    FROM public.designs
    ORDER BY created_at DESC
    LIMIT 20;
  `);

  console.log('');
  console.log('===== DESIGNS STORAGE KEYS CHECK =====');
  console.log('DESIGNS FOUND:', result.rows.length);

  if (result.rows.length === 0) {
    console.log('NO DESIGNS FOUND');
  }

  for (const row of result.rows) {
    console.log('');
    console.log('ID:', row.id);
    console.log('TITLE:', row.title_ar);
    console.log('STATUS:', row.status);
    console.log('PREVIEW KEY:', row.preview_storage_key);
    console.log('DESIGN KEY:', row.design_storage_key);
    console.log('EXTENSION:', row.file_extension ?? 'NULL');
  }

  console.log('');
  console.log('======================================');

  await client.end();
  console.log('Done.');
}

main().catch((error) => {
  console.error('ERROR:', error.message);
  process.exit(1);
});
