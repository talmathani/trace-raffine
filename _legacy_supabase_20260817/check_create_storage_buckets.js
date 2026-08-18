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

  await client.query(`
    INSERT INTO storage.buckets
      (id, name, public)
    VALUES
      ('design-previews', 'design-previews', true),
      ('design-files', 'design-files', false);
  `);

  console.log('');
  console.log('===== STORAGE BUCKETS CREATED =====');
  console.log('1. design-previews | PUBLIC = true');
  console.log('2. design-files    | PUBLIC = false');
  console.log('===================================');

  await client.end();
  console.log('Done.');
}

main().catch((error) => {
  console.error('ERROR:', error.message);
  process.exit(1);
});
