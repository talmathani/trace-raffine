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
      bucket_id,
      COUNT(*) AS object_count
    FROM storage.objects
    GROUP BY bucket_id
    ORDER BY bucket_id;
  `);

  console.log('');
  console.log('===== STORAGE OBJECTS =====');

  if (result.rows.length === 0) {
    console.log('NO OBJECTS FOUND');
  } else {
    for (const row of result.rows) {
      console.log(
        `BUCKET: ${row.bucket_id} | OBJECTS: ${row.object_count}`
      );
    }
  }

  console.log('==========================');

  await client.end();
  console.log('Done.');
}

main().catch((error) => {
  console.error('ERROR:', error.message);
  process.exit(1);
});
