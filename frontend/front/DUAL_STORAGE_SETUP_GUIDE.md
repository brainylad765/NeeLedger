# Dual Storage Setup Guide - Local + Supabase

## 🎯 Overview

Your Flutter app now supports **dual storage paths**:

1. **Local Storage** (Temporary) - Cleared on hot reload, for development/testing
2. **Supabase Storage** (Persistent) - Permanent storage until manually deleted

## 🚀 Setup Instructions

### Step 1: Create Supabase Database Schema

1. Go to your Supabase project: https://sdnwzesuiulljxmwxpob.supabase.co
2. Navigate to **SQL Editor**
3. Run the contents of `supabase_documents_schema.sql`

This will create:
- `documents` table for metadata
- `documents` and `images` storage buckets
- RLS policies for security
- Proper indexes for performance

### Step 2: Test the Setup

Run the test script to verify everything works:

```bash
# Install dependencies if needed
npm install @supabase/supabase-js

# Run the test
node test_supabase_documents.js
```

Expected output:
```
🧪 Testing Supabase Documents Integration...
✅ Authentication successful
✅ Documents table accessible
✅ Storage buckets exist
✅ Document insertion successful
✅ Document retrieval successful
✅ Test document cleaned up
✅ RLS policies working correctly
🎉 All tests completed successfully!
```

### Step 3: Test in Flutter App

1. **Run your Flutter app**
2. **Navigate to Debug Screen**: Add this to your navigation or create a button:
   ```dart
   Navigator.pushNamed(context, '/debug-uploads');
   ```
3. **Upload some files** through the uploads screen
4. **Check the debug screen** to see both local and Supabase files

## 🔧 How It Works

### Upload Flow

When you upload a file through `UploadProvider.addPdf()` or `UploadProvider.addImage()`:

1. **Local Storage**: File is added to local lists (`_pdfs`, `_images`)
2. **Supabase Storage**: If enabled, file is uploaded to Supabase in parallel
3. **Database**: Metadata is saved to `documents` table
4. **UI Updates**: Both local and Supabase file lists are updated

### Storage Locations

**Local Storage:**
- PDFs: `List<PdfMeta> _pdfs`
- Images: `List<ImageUpload> _images`
- Cleared on: Hot reload, app restart

**Supabase Storage:**
- Files: `documents` and `images` buckets
- Metadata: `documents` table
- Persists: Until manually deleted

## 🎛️ Controls

### Toggle Supabase Integration
```dart
provider.toggleSupabaseIntegration(false); // Disable Supabase uploads
provider.toggleSupabaseIntegration(true);  // Enable Supabase uploads
```

### Load Supabase Documents
```dart
await provider.loadSupabaseDocuments();
```

### Delete Supabase Document
```dart
await provider.deleteSupabaseDocument(documentId);
```

## 📊 Debug Screen Features

The debug screen (`/debug-uploads`) shows:

- **Status Cards**: Local vs Supabase file counts
- **Supabase Status**: Integration enabled/disabled, upload progress, errors
- **Local Files List**: Temporary files with delete option
- **Supabase Files List**: Persistent files with view/delete options
- **Toggle Switch**: Enable/disable Supabase integration
- **Refresh Button**: Reload Supabase documents

## 🔍 Monitoring & Debugging

### Check Upload Status
```dart
// Local uploads
bool hasLocalUploads = provider.hasUploads;
int totalLocal = provider.totalUploads;

// Supabase uploads
bool hasSupabaseUploads = provider.hasSupabaseUploads;
bool isUploading = provider.isSupabaseUploading;
String? error = provider.supabaseError;
```

### Error Handling
```dart
if (provider.supabaseError != null) {
  print('Supabase Error: ${provider.supabaseError}');
  provider.clearSupabaseError();
}
```

## 🗃️ Database Schema

### Documents Table Structure
```sql
documents (
  id UUID PRIMARY KEY,
  user_id UUID (references auth.users),
  local_id TEXT (correlation with local uploads),
  file_name TEXT,
  file_url TEXT (public URL),
  file_size BIGINT,
  file_type TEXT ('pdf' or 'image'),
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  upload_timestamp TIMESTAMPTZ,
  metadata JSONB,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
```

### Storage Buckets
- `documents` - For PDF files
- `images` - For image files

Both buckets are public for easy access.

## 🔐 Security

### Row Level Security (RLS)
- Users can only access their own documents
- Policies enforce `user_id = auth.uid()`
- Storage policies protect file access

### Authentication Required
- All Supabase operations require authentication
- Use test credentials: `testuser@gmail.com` / `password123`

## 🚨 Troubleshooting

### Common Issues

**1. "Table 'documents' doesn't exist"**
- Solution: Run `supabase_documents_schema.sql` in Supabase SQL Editor

**2. "Storage bucket not found"**
- Solution: Check if buckets were created in the schema script

**3. "User not authenticated"**
- Solution: Ensure user is signed in before uploading

**4. "RLS policy violation"**
- Solution: Check if RLS policies are properly configured

### Debug Steps

1. **Check Authentication**:
   ```dart
   final user = Supabase.instance.client.auth.currentUser;
   print('User: ${user?.id}');
   ```

2. **Check Supabase Connection**:
   ```bash
   node test_supabase_documents.js
   ```

3. **Check Flutter Logs**:
   Look for `✅` (success) or `❌` (error) messages in console

4. **Use Debug Screen**:
   Navigate to `/debug-uploads` to see detailed status

## 🎉 Success Indicators

You'll know everything is working when:

- ✅ Test script passes all checks
- ✅ Debug screen shows both local and Supabase files
- ✅ Files persist after hot reload (Supabase only)
- ✅ No error messages in console
- ✅ Toggle switch enables/disables Supabase uploads

## 📝 Next Steps

1. **Test thoroughly** with different file types
2. **Monitor storage usage** in Supabase dashboard
3. **Implement file preview** functionality
4. **Add batch operations** for multiple files
5. **Set up file size limits** and validation
6. **Add progress indicators** for large uploads

---

**🎯 You now have a robust dual storage system that gives you the flexibility of local development with the persistence of cloud storage!**