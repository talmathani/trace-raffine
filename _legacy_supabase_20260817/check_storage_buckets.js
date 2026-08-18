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
      name,
      public,
      file_size_limit,
      allowed_mime_types
    FROM storage.buckets
    ORDER BY name;
  `);

  console.log('');
  console.log('===== STORAGE BUCKETS =====');
  console.log('COUNT:', result.rows.length);

  for (const row of result.rows) {
    console.log('');
    console.log('ID:', row.id);
    console.log('NAME:', row.name);
    console.log('PUBLIC:', row.public);
    console.log('FILE SIZE LIMIT:', row.file_size_limit ?? 'NULL');
    console.log(
      'ALLOWED MIME TYPES:',
      row.allowed_mime_types
        ? JSON.stringify(row.allowed_mime_types)
        : 'NULL'
    );
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
