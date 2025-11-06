# Vercel Deployment Guide for Propello AI

This guide will help you deploy Propello to Vercel and connect it to your new Supabase project.

## Prerequisites

- A Vercel account (free tier works great)
- A Supabase project with migrations applied
- Your Supabase credentials ready

---

## Step 1: Create New Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Wait ~2 minutes for provisioning
3. Go to **Project Settings → API** and copy:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public** key (the long JWT token)

---

## Step 2: Run Database Migrations

You have two options:

### Option A: Via Supabase Dashboard (Easiest)

1. Go to your Supabase project → **SQL Editor**
2. Create a new query
3. Copy and paste the contents of `supabase/migrations/01_BUILD_ALL_TABLES.sql`
4. Click **Run**
5. Create another new query
6. Copy and paste the contents of `supabase/migrations/02_FIX_AUTH_AND_PROFILE_CREATION.sql`
7. Click **Run**

### Option B: Via Supabase CLI

```bash
# Link your local project to the new Supabase project
npx supabase link --project-ref your-project-ref

# Push all migrations
npx supabase db push
```

---

## Step 3: Deploy to Vercel

### Option A: Via Vercel Dashboard (Recommended)

1. Go to [vercel.com](https://vercel.com) and sign in
2. Click **Add New... → Project**
3. Import your GitHub repository (or connect your Git provider)
4. Configure your project:
   - **Framework Preset:** Vite
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`
   - **Install Command:** `npm install`

5. **Add Environment Variables** (Critical step!):
   ```
   VITE_SUPABASE_URL=https://your-project-ref.supabase.co
   VITE_SUPABASE_ANON_KEY=your-anon-key-here
   ```

6. Click **Deploy**

### Option B: Via Vercel CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Login to Vercel
vercel login

# Deploy
vercel

# Add environment variables
vercel env add VITE_SUPABASE_URL
vercel env add VITE_SUPABASE_ANON_KEY

# Deploy to production
vercel --prod
```

---

## Step 4: Configure Environment Variables in Vercel

This is **CRITICAL** - without these, your app won't connect to Supabase!

### Via Vercel Dashboard:

1. Go to your project on Vercel
2. Click **Settings** → **Environment Variables**
3. Add these variables:

| Variable Name | Value | Environments |
|--------------|-------|--------------|
| `VITE_SUPABASE_URL` | Your Supabase Project URL | Production, Preview, Development |
| `VITE_SUPABASE_ANON_KEY` | Your Supabase Anon Key | Production, Preview, Development |

4. **Redeploy** your project after adding environment variables:
   - Go to **Deployments** tab
   - Find your latest deployment
   - Click the three dots → **Redeploy**

---

## Step 5: Update Supabase Auth Settings

1. Go to your Supabase project → **Authentication** → **URL Configuration**
2. Add your Vercel deployment URL to **Site URL**:
   ```
   https://your-app.vercel.app
   ```
3. Add to **Redirect URLs**:
   ```
   https://your-app.vercel.app
   https://your-app.vercel.app/**
   ```

---

## Step 6: Test Your Deployment

1. Visit your Vercel deployment URL
2. Click **Sign Up**
3. Create a test account with:
   - Email
   - Password
   - Full Name
   - Agent Phone Number (e.g., `+1-555-123-4567`)
4. You should be automatically logged in and see your dashboard!

---

## Step 7: Configure Retell AI Webhook (Optional)

If you're using Retell AI for lead capture:

1. Go to your Retell AI dashboard
2. Set your webhook URL to:
   ```
   https://your-app.vercel.app/api/webhook
   ```
3. Add your Supabase Service Role key as an environment variable in Vercel:
   ```
   SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
   ```
   (Found in Supabase → Settings → API → service_role key)

---

## Troubleshooting

### Issue: "Missing Supabase environment variables"

**Solution:** 
- Make sure you added the environment variables in Vercel
- Redeploy after adding variables
- Check that variable names are exactly: `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`

### Issue: "User profile not found" after signup

**Solution:**
- Make sure you ran the `02_FIX_AUTH_AND_PROFILE_CREATION.sql` migration
- This migration creates a database trigger that auto-creates user profiles

### Issue: "Invalid credentials" on login

**Solution:**
- Check that your Supabase URL and keys are correct
- Make sure email confirmation is disabled in Supabase:
  - Go to **Authentication** → **Settings**
  - Disable "Enable email confirmations"

### Issue: Build fails on Vercel

**Solution:**
- Check the build logs in Vercel dashboard
- Make sure all dependencies are in `package.json`
- Try running `npm run build` locally first

---

## Monitoring Your Deployment

### Check Vercel Logs:
1. Go to your project on Vercel
2. Click **Deployments**
3. Click on a deployment to see logs

### Check Supabase Logs:
1. Go to your Supabase project
2. Click **Database** → **Logs**
3. View auth events and database queries

---

## Updating Your Deployment

### When you push to Git:
- Vercel automatically deploys new commits to your main branch
- Preview deployments are created for pull requests

### Manual redeploy:
```bash
vercel --prod
```

Or via Vercel dashboard:
1. Go to **Deployments**
2. Click three dots on latest deployment
3. Click **Redeploy**

---

## Security Best Practices

1. ✅ **Never commit** `.env` files to Git
2. ✅ **Use environment variables** in Vercel for all secrets
3. ✅ **Enable RLS** on all tables (already done in migrations)
4. ✅ **Use HTTPS only** (Vercel does this automatically)
5. ✅ **Rotate keys regularly** (Supabase Settings → API → Reset keys)

---

## Cost Optimization

### Vercel Free Tier:
- ✅ Unlimited deployments
- ✅ Automatic HTTPS
- ✅ 100GB bandwidth/month
- ✅ Serverless functions

### Supabase Free Tier:
- ✅ 500MB database
- ✅ 1GB file storage
- ✅ 2GB bandwidth/month
- ✅ 50,000 monthly active users

Both free tiers are more than enough to get started!

---

## Need Help?

- Vercel Docs: https://vercel.com/docs
- Supabase Docs: https://supabase.com/docs
- Check your browser console for errors (F12)
- Check Vercel deployment logs
- Check Supabase database logs

---

## Quick Reference Commands

```bash
# Deploy to Vercel
vercel --prod

# Check deployment status
vercel ls

# View logs
vercel logs

# Add environment variable
vercel env add VITE_SUPABASE_URL

# Remove a deployment
vercel rm [deployment-url]
```

---

**You're all set!** 🚀 Your Propello app should now be live on Vercel and connected to your new Supabase project.

