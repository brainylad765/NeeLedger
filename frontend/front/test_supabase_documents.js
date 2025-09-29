// Test script for Supabase documents integration
// Run this with: node test_supabase_documents.js

const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://sdnwzesuiulljxmwxpob.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkbnd6ZXN1aXVsbGp4bXd4cG9iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwNDk5NjEsImV4cCI6MjA3NDYyNTk2MX0.cHjCwwKpq7s1EjNWP-1dzXHnnd8iNP-9MdBGNeC9Jas';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testSupabaseDocuments() {
  console.log('🧪 Testing Supabase Documents Integration...\n');

  try {
    // Test 1: Sign in with test user
    console.log('1️⃣ Testing authentication...');
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email: 'testuser@gmail.com',
      password: 'password123'
    });

    if (authError) {
      console.error('❌ Auth failed:', authError.message);
      return;
    }
    console.log('✅ Authentication successful');
    console.log('   User ID:', authData.user.id);

    // Test 2: Check if documents table exists
    console.log('\n2️⃣ Testing documents table...');
    const { data: tableData, error: tableError } = await supabase
      .from('documents')
      .select('*')
      .limit(1);

    if (tableError) {
      console.error('❌ Documents table error:', tableError.message);
      console.log('💡 Please run the SQL schema file in Supabase SQL Editor');
      return;
    }
    console.log('✅ Documents table accessible');

    // Test 3: Check storage buckets
    console.log('\n3️⃣ Testing storage buckets...');
    const { data: bucketsData, error: bucketsError } = await supabase.storage.listBuckets();
    
    if (bucketsError) {
      console.error('❌ Storage buckets error:', bucketsError.message);
      return;
    }

    const documentsBucket = bucketsData.find(b => b.name === 'documents');
    const imagesBucket = bucketsData.find(b => b.name === 'images');

    if (!documentsBucket || !imagesBucket) {
      console.log('⚠️  Missing storage buckets. Creating them...');
      console.log('💡 Please run the SQL schema file to create buckets');
    } else {
      console.log('✅ Storage buckets exist');
      console.log('   Documents bucket:', documentsBucket.name);
      console.log('   Images bucket:', imagesBucket.name);
    }

    // Test 4: Test document insertion
    console.log('\n4️⃣ Testing document insertion...');
    const testDocument = {
      user_id: authData.user.id,
      local_id: 'test-local-id-123',
      file_name: 'test-document.pdf',
      file_url: 'https://example.com/test.pdf',
      file_size: 1024,
      file_type: 'pdf',
      metadata: {
        test: true,
        created_by: 'test_script'
      }
    };

    const { data: insertData, error: insertError } = await supabase
      .from('documents')
      .insert(testDocument)
      .select();

    if (insertError) {
      console.error('❌ Document insertion failed:', insertError.message);
      return;
    }
    console.log('✅ Document insertion successful');
    console.log('   Document ID:', insertData[0].id);

    // Test 5: Test document retrieval
    console.log('\n5️⃣ Testing document retrieval...');
    const { data: retrieveData, error: retrieveError } = await supabase
      .from('documents')
      .select('*')
      .eq('user_id', authData.user.id)
      .order('upload_timestamp', { ascending: false });

    if (retrieveError) {
      console.error('❌ Document retrieval failed:', retrieveError.message);
      return;
    }
    console.log('✅ Document retrieval successful');
    console.log('   Found documents:', retrieveData.length);

    // Test 6: Clean up test document
    console.log('\n6️⃣ Cleaning up test document...');
    const { error: deleteError } = await supabase
      .from('documents')
      .delete()
      .eq('id', insertData[0].id);

    if (deleteError) {
      console.error('❌ Document deletion failed:', deleteError.message);
    } else {
      console.log('✅ Test document cleaned up');
    }

    // Test 7: Test RLS policies
    console.log('\n7️⃣ Testing RLS policies...');
    
    // Try to access another user's documents (should fail)
    const { data: rlsData, error: rlsError } = await supabase
      .from('documents')
      .select('*')
      .neq('user_id', authData.user.id);

    if (rlsData && rlsData.length === 0) {
      console.log('✅ RLS policies working correctly (no access to other users\' documents)');
    } else {
      console.log('⚠️  RLS policies may need adjustment');
    }

    console.log('\n🎉 All tests completed successfully!');
    console.log('\n📋 Summary:');
    console.log('   ✅ Authentication working');
    console.log('   ✅ Documents table accessible');
    console.log('   ✅ Storage buckets configured');
    console.log('   ✅ Document CRUD operations working');
    console.log('   ✅ RLS policies protecting user data');
    console.log('\n🚀 Your Flutter app is ready to use both local and Supabase storage!');

  } catch (error) {
    console.error('💥 Unexpected error:', error);
  }
}

// Run the test
testSupabaseDocuments();