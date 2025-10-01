# Firebase Migration TODO

## Migration from Supabase to Firebase

### Phase 1: Dependencies and Auth
- [ ] Remove supabase_flutter dependency from pubspec.yaml
- [x] Update signup_screen.dart to use Firebase Auth instead of Supabase
- [ ] Update login_screen.dart to use Firebase Auth instead of Supabase
- [ ] Update nextlogin.dart to use Firebase Auth instead of Supabase

### Phase 2: Data Storage Migration
- [ ] Migrate upload_provider.dart from Supabase storage to Firebase Storage/Firestore
- [ ] Migrate document_upload_service.dart to Firebase Storage/Firestore
- [ ] Migrate api_service.dart project operations to Firestore
- [ ] Migrate projects_screen.dart to Firestore
- [ ] Migrate dashboard_screen.dart to Firestore

### Phase 3: Testing and Cleanup
- [ ] Update any other files using Supabase
- [ ] Test Firebase Auth flows (sign up, sign in, sign out)
- [ ] Test Firebase Storage operations
- [ ] Test Firestore data operations
- [ ] Run flutter pub get after dependency changes
- [ ] Clean up any remaining Supabase references

---

# Django Backend Development

## Backend Setup
- [x] Create Django project structure
- [x] Configure Django settings with apps and middleware
- [x] Create requirements.txt with dependencies
- [x] Set up custom User model with roles

## Models Created
- [x] accounts/models.py - Custom User model with roles and Firebase integration
- [x] projects/models.py - Project, ProjectImage, ProjectDocument models
- [x] transactions/models.py - Transaction, CreditWallet, CreditHolding models
- [x] evidence/models.py - Evidence, EvidenceComment, EvidenceRevision models

## Admin Interface
- [x] accounts/admin.py - Custom user admin
- [x] projects/admin.py - Project management admin
- [x] transactions/admin.py - Transaction and wallet admin
- [x] evidence/admin.py - Evidence management admin

## API Development (Next Steps)
- [x] accounts/serializers.py - User serializers for API
- [ ] Create serializers for projects, transactions, evidence
- [ ] Create API views for all models
- [ ] Set up URL routing
- [ ] Add authentication and permissions
- [ ] Create API documentation

## Testing and Deployment
- [ ] Write unit tests for models and views
- [ ] Set up CI/CD pipeline
- [ ] Configure production settings
- [ ] Deploy to production server
