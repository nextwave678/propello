# 🔄 Complete Database Rebuild Instructions

## Overview

Use these scripts to completely rebuild your Supabase database from scratch. This gives you a clean slate with the correct schema, proper RLS policies, and all necessary triggers.

---

## ⚠️ IMPORTANT: Before You Start

### 1. Backup Your Data (If Needed)

If you have any data you want to keep:

```sql
-- Run these in Supabase SQL Editor and save results as CSV:

SELECT * FROM user_profiles;
SELECT * FROM leads;
SELECT * FROM lead_activities;
SELECT id, email, created_at FROM auth.users;
```

### 2. Understand What Will Be Lost

- ❌ All user profiles
- ❌ All leads
- ❌ All activities
- ⚠️ Auth users will remain (unless you uncomment the delete line)

---

## 📋 Step-by-Step Instructions

### Step 1: Open Supabase SQL Editor

1. Go to https://app.supabase.com/project/yzxbjcqgokzbqkiiqnar
2. Click on **SQL Editor** in the left sidebar
3. Click **New Query**

### Step 2: Run DELETE Script

1. Open this file in your editor: `supabase/migrations/00_DELETE_ALL_TABLES.sql`
2. Copy the **entire contents**
3. Paste into Supabase SQL Editor
4. Click **Run** (bottom right)
5. You should see: "All tables, triggers, and functions have been dropped."

**Expected result**: 
```
✓ Statement 1 executed successfully
✓ Statement 2 executed successfully
...
✓ All tables, triggers, and functions have been dropped.
```

### Step 3: Run BUILD Script

1. Click **New Query** in Supabase
2. Open this file: `supabase/migrations/01_BUILD_ALL_TABLES.sql`
3. Copy the **entire contents**
4. Paste into Supabase SQL Editor
5. Click **Run**
6. Wait for completion (should take 5-10 seconds)

**Expected result**:
```
=============================================
DATABASE BUILD COMPLETE!
=============================================
Tables created: 3
RLS policies created: 13
Triggers created: 3
Indexes created: 16
=============================================
```

### Step 4: Verify Tables Were Created

Run this query to verify:

```sql
-- Check tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('user_profiles', 'leads', 'lead_activities')
ORDER BY table_name;

-- Should return:
-- lead_activities
-- leads
-- user_profiles
```

### Step 5: Verify RLS Policies

```sql
-- Check RLS policies
SELECT tablename, policyname, cmd
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Should show policies for:
-- - user_profiles (3 policies)
-- - leads (5 policies)
-- - lead_activities (3 policies)
```

### Step 6: Verify Triggers

```sql
-- Check triggers
SELECT 
    tgname as trigger_name,
    tgrelid::regclass as table_name
FROM pg_trigger
WHERE tgrelid IN (
    'public.leads'::regclass,
    'public.user_profiles'::regclass
)
AND tgisinternal = false;

-- Should return:
-- auto_assign_lead_user_trigger | leads
-- update_leads_updated_at | leads
-- update_user_profiles_updated_at | user_profiles
```

---

## ✅ Testing Your New Database

### Test 1: Create a User Account

1. Go to your Propello app: http://localhost:5173 (or your deployed URL)
2. Click **Sign Up**
3. Fill in:
   - Email: test@example.com
   - Password: Test123456!
   - Full Name: Test User
   - Agent Phone Number: +1234567890
4. Click **Create Account**

**Expected**: User created successfully, redirected to dashboard

### Test 2: Check User Profile in Database

```sql
-- Run in Supabase SQL Editor:
SELECT * FROM user_profiles;

-- Should show 1 row with your test user
```

### Test 3: Send Test Webhook

Use this curl command (replace values):

```bash
curl -X POST "https://your-app.vercel.app/api/webhook" \
  -H "Content-Type: application/json" \
  -d '{
    "event": "call_analyzed",
    "call": {
      "call_id": "test-123",
      "from_number": "+19876543210",
      "to_number": "+1234567890",
      "transcript": "Test call transcript",
      "duration_ms": 60000,
      "call_analysis": {
        "custom_analysis_data": {
          "name": "John Doe",
          "email": "john@example.com",
          "type": "buyer",
          "lead_quality": "hot",
          "timeframe": "immediately",
          "property_details": "3BR house downtown"
        }
      }
    }
  }'
```

**Expected**: Returns 204 No Content

### Test 4: Verify Lead in Database

```sql
-- Check lead was created
SELECT id, name, phone, lead_quality, user_id 
FROM leads 
ORDER BY created_at DESC 
LIMIT 1;

-- Should show:
-- - name: John Doe
-- - user_id: (matches your user's user_id)
```

### Test 5: Verify Data Isolation

1. Create a second user account (different email, different agent phone)
2. Log in as first user → Should see the test lead
3. Log in as second user → Should NOT see the test lead
4. Send webhook with second user's agent phone
5. Log in as second user → Should see their own lead only

**Expected**: Each user only sees their own leads ✓

---

## 🐛 Troubleshooting

### Error: "relation does not exist"

**Problem**: Tables weren't created properly

**Solution**: 
1. Run Step 2 (DELETE) again
2. Wait 5 seconds
3. Run Step 3 (BUILD) again

### Error: "policy already exists"

**Problem**: Old policies weren't fully removed

**Solution**:
```sql
-- Drop all policies manually:
DROP POLICY IF EXISTS "Users can view their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can view their own leads" ON leads;
-- (repeat for all policies)

-- Then run BUILD script again
```

### Error: "function does not exist"

**Problem**: Functions weren't created

**Solution**: Run just the PART 5 section from the BUILD script

### Webhook Returns "Could not route lead to user"

**Problem**: `agent_phone_number` in webhook doesn't match user profile

**Solution**:
1. Check user's profile:
```sql
SELECT user_id, agent_phone_number FROM user_profiles;
```

2. Make sure webhook payload has exact same phone number format:
```json
{
  "call": {
    "to_number": "+1234567890"  // Must match exactly
  }
}
```

### User Can See Other Users' Leads

**Problem**: RLS policies not working

**Solution**:
1. Verify RLS is enabled:
```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';
-- rowsecurity should be 't' (true)
```

2. Re-run PART 3 and PART 4 of BUILD script

---

## 📊 What Gets Created

### Tables (3)
1. **user_profiles** - User account info with agent phone numbers
2. **leads** - Lead data with user_id for isolation  
3. **lead_activities** - Activity history for leads

### Indexes (16)
- Performance indexes on all foreign keys
- Query optimization for common filters
- Full-text search support (future)

### RLS Policies (13)
- Users can only view/edit their own data
- Service role can insert leads (for webhook)
- Proper isolation between users

### Triggers (3)
- Auto-update `updated_at` timestamps
- Auto-assign `user_id` from `agent_phone_number`
- Activity logging (future)

### Functions (3)
- `update_updated_at_column()` - Timestamp automation
- `auto_assign_lead_user()` - User routing
- `assign_lead_to_user()` - Manual assignment helper

---

## 🎉 Success Checklist

After running both scripts, verify:

- [ ] 3 tables created (user_profiles, leads, lead_activities)
- [ ] 13+ RLS policies active
- [ ] 3 triggers active
- [ ] 16+ indexes created
- [ ] Can create user account via signup
- [ ] Can send test webhook successfully
- [ ] Lead appears in database with correct user_id
- [ ] User can see their own leads in dashboard
- [ ] User CANNOT see other users' leads
- [ ] Real-time updates working
- [ ] Analytics page loads

---

## ⏱️ Total Time Estimate

- **Reading/preparing**: 5 minutes
- **Running DELETE script**: 1 minute
- **Running BUILD script**: 2 minutes
- **Testing**: 10 minutes
- **Total**: ~20 minutes

---

## 📞 Need Help?

If you get stuck:

1. Check the error message carefully
2. Review the Troubleshooting section above
3. Check Supabase logs (Logs → Database)
4. Verify environment variables in Vercel
5. Test with curl commands (see Test 3)

---

## ✨ You're Done!

Your database is now properly configured with:
- ✅ Correct schema
- ✅ Proper data isolation
- ✅ Security policies
- ✅ Performance indexes
- ✅ Automatic triggers

**Next steps**: Deploy your updated frontend code and start using Propello!

