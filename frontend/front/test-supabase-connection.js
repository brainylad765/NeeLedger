// Test Supabase connection and basic operations
// Run with: node test-supabase-connection.js

const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://sdnwzesuiulljxmwxpob.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkbnd6ZXN1aXVsbGp4bXd4cG9iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwNDk5NjEsImV4cCI6MjA3NDYyNTk2MX0.cHjCwwKpq7s1EjNWP-1dzXHnnd8iNP-9MdBGNeC9Jas';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testConnection() {
  console.log('🧪 Testing Supabase connection...\n');

  try {
    // Test 1: Basic connection
    console.log('1. Testing basic connection...');
    const { data: connectionTest, error: connectionError } = await supabase
      .from('projects')
      .select('count', { count: 'exact', head: true });

    if (connectionError) {
      console.log('❌ Connection failed:', connectionError.message);
      return;
    }
    console.log('✅ Connection successful');

    // Test 2: Check tables exist
    console.log('\n2. Checking database tables...');
    const tables = ['projects', 'documents'];

    for (const table of tables) {
      try {
        const { error } = await supabase
          .from(table)
          .select('*', { count: 'exact', head: true });

        if (error) {
          console.log(`❌ Table '${table}' error:`, error.message);
        } else {
          console.log(`✅ Table '${table}' exists`);
        }
      } catch (err) {
        console.log(`❌ Table '${table}' check failed:`, err.message);
      }
    }

    // Test 3: Check storage buckets
    console.log('\n3. Checking storage buckets...');
    const { data: buckets, error: bucketsError } = await supabase.storage.listBuckets();

    if (bucketsError) {
      console.log('❌ Storage check failed:', bucketsError.message);
    } else {
      const expectedBuckets = ['documents', 'images'];
      const existingBuckets = buckets.map(b => b.name);

      for (const bucket of expectedBuckets) {
        if (existingBuckets.includes(bucket)) {
          console.log(`✅ Bucket '${bucket}' exists`);
        } else {
          console.log(`❌ Bucket '${bucket}' missing`);
        }
      }
    }

    // Test 4: Authentication check (will fail without auth, but tests auth setup)
    console.log('\n4. Testing authentication setup...');
    const { data: authUser, error: authError } = await supabase.auth.getUser();

    if (authError && authError.message !== 'Auth session missing!') {
      console.log('❌ Auth setup error:', authError.message);
    } else {
      console.log('✅ Auth setup OK (no session expected in test)');
    }

    console.log('\n🎉 Supabase integration test completed!');
    console.log('\n📋 Next steps:');
    console.log('1. Run the SQL schema: create-database-schema.sql');
    console.log('2. Test authentication by signing up/logging in');
    console.log('3. Verify RLS policies are working');

  } catch (error) {
    console.error('❌ Test failed with error:', error.message);
  }
}

testConnection();
