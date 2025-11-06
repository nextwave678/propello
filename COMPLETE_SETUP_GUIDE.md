# Complete Setup Guide: Propello AI with New Supabase

This guide walks you through setting up Propello with a fresh Supabase project and deploying to Vercel.

---

## 🚀 Quick Start (5 Minutes)

### Step 1: Create New Supabase Project (2 minutes)

1. Go to [supabase.com](https://supabase.com)
2. Click **New Project**
3. Fill in:
   - **Name:** propello-production (or whatever you prefer)
   - **Database Password:** (save this somewhere safe!)
   - **Region:** Choose closest to your users
4. Click **Create new project**
5. Wait ~2 minutes for provisioning ☕

### Step 2: Get Your Credentials (30 seconds)

Once your project is ready:
1. Go to **Settings** → **API**
2. Copy these two values:
   - **Project URL** (e.g., `https://abcdefgh.supabase.co`)
   - **anon public** key (long JWT token)

### Step 3: Run Database Migrations (2 minutes)

#### Option A: Supabase Dashboard (Easiest)

1. Go to **SQL Editor** in your Supabase project
2. Click **New query**
3. Copy/paste the entire content of `supabase/migrations/01_BUILD_ALL_TABLES.sql`
4. Click **Run** ▶️
5. Wait for "Success" message
6. Click **New query** again
7. Copy/paste the entire content of `supabase/migrations/02_FIX_AUTH_AND_PROFILE_CREATION.sql`
8. Click **Run** ▶️
9. You should see confirmation messages! ✅

#### Option B: Supabase CLI

```bash
npx supabase link --project-ref your-project-ref
npx supabase db push
```

### Step 4: Update Local Environment (1 minute)

Create a `.env` file in your project root:

```bash
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

**Remove hardcoded credentials** (optional but recommended):

Edit `src/lib/supabase.ts` and change:

```typescript
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY
```

(Remove the `|| 'hardcoded-fallback'` parts)

### Step 5: Test Locally (1 minute)

```bash
npm install
npm run dev
```

Visit `http://localhost:5173` and try:
1. Click **Sign Up**
2. Create a test account
3. You should be automatically logged in! 🎉

---

## 🌐 Deploy to Vercel (5 Minutes)

### Step 1: Push to GitHub

```bash
git add .
git commit -m "Configure for new Supabase project"
git push origin main
```

### Step 2: Deploy to Vercel

1. Go to [vercel.com](https://vercel.com)
2. Click **Add New... → Project**
3. Import your GitHub repository
4. Configure:
   - **Framework Preset:** Vite
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`

5. **Add Environment Variables:**
   ```
   VITE_SUPABASE_URL=https://your-project-ref.supabase.co
   VITE_SUPABASE_ANON_KEY=your-anon-key-here
   ```

6. Click **Deploy** 🚀

### Step 3: Configure Supabase Auth URLs

1. Go to your Supabase project → **Authentication** → **URL Configuration**
2. Set **Site URL** to your Vercel URL:
   ```
   https://your-app.vercel.app
   ```
3. Add to **Redirect URLs:**
   ```
   https://your-app.vercel.app/**
   ```

### Step 4: Test Your Deployment

Visit your Vercel URL and create an account. It should work perfectly!

---

## 📋 What Was Fixed?

### The Problem (Before)
- Users couldn't sign up because RLS policies required them to be authenticated before creating a profile
- This was a "chicken and egg" problem

### The Solution (Now)
- **Database trigger** automatically creates user profiles when a new auth user signs up
- **Updated RLS policies** allow proper authentication flow
- **Metadata passing** ensures profile has all user information
- **Better error handling** provides clear feedback

### Files Changed
1. ✅ `supabase/migrations/02_FIX_AUTH_AND_PROFILE_CREATION.sql` - New migration with trigger
2. ✅ `src/context/AuthContext.tsx` - Updated signup flow
3. ✅ `VERCEL_DEPLOYMENT_GUIDE.md` - Complete deployment instructions
4. ✅ `COMPLETE_SETUP_GUIDE.md` - This file!

---

## 🔐 Security Checklist

- ✅ RLS enabled on all tables
- ✅ Users can only see their own data
- ✅ Service role key only used server-side
- ✅ Email confirmations disabled (optional, can enable later)
- ✅ HTTPS enforced by Vercel
- ✅ Environment variables not committed to Git

---

## 🐛 Troubleshooting

### "Missing Supabase environment variables"

**Fix:** Create `.env` file with your Supabase credentials

### "User profile not found"

**Fix:** Make sure you ran `02_FIX_AUTH_AND_PROFILE_CREATION.sql` migration

### "Invalid credentials" on login

**Fix:** 
- Check your Supabase URL and anon key are correct
- Make sure you're using the anon key, not the service role key

### Build fails on Vercel

**Fix:**
- Check build logs in Vercel dashboard
- Make sure environment variables are set in Vercel
- Try `npm run build` locally first

### "Agent phone number already in use"

**Fix:** Each user needs a unique agent phone number. Use different numbers for different accounts.

---

## 🎯 What's Next?

### Configure Retell AI (Optional)

If you're using Retell AI for phone agents:

1. Set webhook URL to: `https://your-app.vercel.app/api/webhook`
2. Add service role key to Vercel environment variables:
   ```
   SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
   ```

### Enable Email Confirmations (Optional)

If you want users to verify their email:

1. Go to Supabase → **Authentication** → **Settings**
2. Enable **Confirm email**
3. Configure email templates
4. Update your app to handle email verification flow

### Add Custom Domain (Optional)

1. Go to Vercel → **Settings** → **Domains**
2. Add your custom domain
3. Update Supabase redirect URLs

---

## 📊 Monitoring

### Vercel Analytics
- View deployment status
- Check build logs
- Monitor traffic

### Supabase Logs
- Database queries
- Auth events
- API requests

---

## 💰 Costs

Both platforms have generous free tiers:

**Vercel Free Tier:**
- Unlimited deployments
- 100GB bandwidth/month
- Automatic HTTPS
- Perfect for side projects and MVPs

**Supabase Free Tier:**
- 500MB database
- 1GB file storage
- 2GB bandwidth/month
- 50,000 monthly active users

You can grow significantly before needing to upgrade!

---

## 🆘 Need Help?

1. Check browser console (F12) for errors
2. Check Vercel deployment logs
3. Check Supabase logs (Database → Logs)
4. Review this guide again
5. Check the detailed `VERCEL_DEPLOYMENT_GUIDE.md`

---

## ✅ Success Checklist

Before considering your setup complete:

- [ ] Supabase project created
- [ ] Both migrations run successfully
- [ ] Local `.env` file created
- [ ] Can sign up locally
- [ ] Can log in locally
- [ ] Can see dashboard with no errors
- [ ] Deployed to Vercel
- [ ] Environment variables set in Vercel
- [ ] Can sign up on production
- [ ] Can log in on production
- [ ] Supabase auth URLs configured

---

**Congratulations! 🎉** Your Propello app is now running on a fresh Supabase instance and deployed to Vercel!

