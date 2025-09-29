# Context Template for New AI Chats

## 🎯 **Copy and paste this when starting a new chat:**

---

**CONTEXT: NeeLedger Project Status**

I'm working on **NeeLedger**, a carbon credit management platform. Here's the current status:

### **Project Overview:**
- **Frontend**: React TypeScript app (COMPLETED ✅)
- **Backend**: Supabase integration (COMPLETED ✅)
- **Mobile**: Flutter app (IN PROGRESS 🔄)
- **Database**: PostgreSQL via Supabase

### **Supabase Integration Status:**
- ✅ **COMPLETED**: Full React integration with Supabase
- ✅ **Database Schema**: All tables created (projects, accounts, acvas, validations, verifications)
- ✅ **Authentication**: Working with test user
- ✅ **RLS Policies**: Configured and working
- ✅ **Sample Data**: Available for testing

### **Current Credentials:**
- **Supabase URL**: `https://sdnwzesuiulljxmwxpob.supabase.co`
- **Test User**: `testuser@gmail.com` / `password123`

### **What I Need Help With:**
[Describe your current task - e.g., "Flutter integration", "Code review", "New feature", etc.]

### **Key Files Available:**
- `SUPABASE_INTEGRATION_GUIDE.md` - Complete integration documentation
- `QUICK_REFERENCE.md` - Quick status reference
- All Supabase services and React hooks are implemented
- Debug tools and test scripts available

**Please help me with: [Your specific request]**

---

## 🎯 **For Flutter Specifically, add:**

### **Flutter Context:**
- **Platform**: Flutter mobile app
- **Backend**: Same Supabase instance as React app
- **Goal**: Mobile version of NeeLedger with same functionality
- **Status**: [Starting/In Progress/Debugging/etc.]

### **Supabase Flutter Integration Needed:**
- Authentication (sign in/up/out)
- Projects CRUD operations
- KYC account management
- ACVA management
- Validation/Verification workflows
- Real-time updates
- File uploads (if needed)

### **Database Schema Reference:**
The database is already set up with these tables:
- `projects` (id, user_id, account_id, credits_issued, country, status, metadata, etc.)
- `accounts` (id, user_id, company_name, kyc_status, account_type, etc.)
- `acvas` (id, user_id, agency_name, country, status, contact_info, etc.)
- `validations` (id, project_id, user_id, acva_id, status, etc.)
- `verifications` (id, project_id, user_id, acva_id, credits_recommended, etc.)

**Flutter Task**: [Describe what you want to do - e.g., "Set up Supabase client", "Create login screen", "Implement projects list", etc.]

---

## 🎯 **For Code Review, add:**

### **Code Review Context:**
- **Component/Feature**: [Specify what you want reviewed]
- **Technology**: [React/Flutter/etc.]
- **Integration**: Uses Supabase backend (already configured)
- **Focus Areas**: [Performance/Security/Best Practices/Bug fixes/etc.]

**Please review**: [Attach your code or describe the specific files]

---

## 🎯 **For New Features, add:**

### **New Feature Context:**
- **Feature**: [Describe the new feature]
- **Platform**: [React/Flutter/Both]
- **Database Impact**: [New tables needed/Use existing/etc.]
- **Integration**: Should work with existing Supabase setup

**Requirements**: [List what the feature should do]

---

## 📋 **Quick Commands Reference:**

If you need to reference our previous work:
```bash
# Test Supabase connection
node test-supabase.js

# Check database schema
node check-existing-schema.js

# Add sample data
node fix-and-add-data.js
```

**Login Credentials**: `testuser@gmail.com` / `password123`

---

*Use this template to give any AI assistant the full context of our NeeLedger project!*