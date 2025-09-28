# Interconnect YourProjects, Uploads, and Data Screens

## Overview
This TODO tracks the implementation of interconnecting uploads with projects and data screens. When a file is uploaded in uploads_screen or data_screen, it will create linked evidence and a project entry in Supabase, updating yourprojects_screen (list and portfolio summary) and data_screen in real-time via providers.

## Steps

### 1. [ ] Create Supabase Tables
   - Create 'evidence' table: Columns - id (uuid), user_id (uuid), file_url (text), latitude (double precision), longitude (double precision), timestamp (timestamptz), detections (jsonb).
   - Create 'projects' table: Columns - id (uuid), user_id (uuid), name (text), status (text, default 'Planning'), evidence_id (uuid, foreign key to evidence.id), carbon_credits (int, default 0), total_value (int, default 0), progress (double precision, default 0.0), location (text), type (text), description (text), created_at (timestamptz).
   - Enable real-time on both tables.
   - RLS policies: Allow insert/select for authenticated users on own records (user_id = auth.uid()).

### 2. [ ] Create Model for Projects
   - Create models/project_model.dart: Define Project class with fromJson/toJson, including fields like id, name, status, evidence_id, carbon_credits, total_value, progress, etc.

### 3. [ ] Create ProjectProvider
   - Create providers/project_provider.dart: Use Supabase real-time stream for projects, methods: fetchProjects(), createProject(Map data), listen to changes, notifyListeners on updates.
   - Integrate with UserProvider for user_id.

### 4. [ ] Update ApiService
   - services/api_service.dart: Replace fetchUserProjects with Supabase query (select * from projects where user_id = auth.uid()).
   - Add createProject: Insert into evidence (if needed), then insert into projects linking evidence_id, using Supabase client.

### 5. [x] Migrate EvidenceProvider to Supabase
   - providers/evidence_provider.dart: Replace Firebase with Supabase storage upload (bucket 'evidence'), insert metadata to 'evidence' table, real-time listen on 'evidence' table.
   - Keep AI detection logic (YOLO/OpenCV), but upload to Supabase storage.
   - Update addEvidence and addPdfEvidence to use Supabase.

### 6. [x] Update UploadsScreen
   - screens/uploads_screen.dart: After addPdf/addImage in UploadProvider, call ProjectProvider.createProject, passing file details (name as project name, status 'Planning', etc.).
   - Added createProject calls for both PDF and image uploads.

### 7. [x] Update DataScreen
   - screens/data_screen.dart: Changed to display evidence from EvidenceProvider instead of UploadProvider for real-time Supabase data.
   - Shows evidence history with file names, locations, and timestamps.

### 8. [ ] Update YourProjectsScreen
   - screens/yourprojects_screen.dart: Replace ApiService fetch with Consumer<ProjectProvider> for _projects list and real-time updates.
   - Update portfolio summary calculations to use provider data; auto-recompute on notifyListeners.

### 9. [ ] Testing
   - Run 'flutter run'.
   - Test upload in uploads_screen: Verify evidence/project created in Supabase, yourprojects updates list/summary, data_screen shows evidence/project.
   - Test in data_screen: Similar verification.
   - Edge cases: No uploads, multiple uploads, navigation between screens.
   - Verify real-time: Upload in one screen, switch to another, see updates.

### 10. [ ] Cleanup and Finalize
   - Remove Firebase dependencies if unused elsewhere (update pubspec.yaml if needed).
   - Update main.dart providers to include ProjectProvider.
   - Mark completed steps, remove TODO.md if all done.

## Notes
- Assume user_id from Supabase.auth.currentUser?.id.
- Default project values: status='Planning', carbon_credits=0, total_value=0, progress=0.0, name=derived from file (e.g., 'Project from [filename]').
- No new dependencies needed.
