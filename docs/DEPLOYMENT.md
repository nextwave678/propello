# Propello Deployment Guide

## Overview

This guide covers the complete deployment process for Propello, from local development to production on Vercel with automatic GitHub deployments.

## Prerequisites

### Mac Development Environment
- **Node.js**: v18+ (install via `brew install node`)
- **Git**: Latest version (install via `brew install git`)
- **VS Code**: Recommended IDE with TypeScript support
- **Terminal**: Default macOS Terminal or iTerm2

### Required Accounts
- **GitHub**: For version control and CI/CD
- **Supabase**: For database and real-time features
- **Vercel**: For hosting and deployment
- **Retell AI**: For AI agent integration (recommended)
- **Make.com**: For webhook integration (alternative)

## Local Development Setup

### 1. Project Initialization

```bash
# Navigate to your projects directory
cd ~/Documents/Projects

# Create React + TypeScript project with Vite
npm create vite@latest propello -- --template react-ts

# Navigate into project
cd propello

# Initialize Git repository
git init

# Create .gitignore (Vite template includes this)
# Verify .env is in .gitignore
cat .gitignore | grep .env
```

### 2. Environment Variables

```bash
# Create .env file
touch .env

# Open in VS Code or TextEdit
code .env
# Or: open -e .env

# Add Supabase credentials
VITE_SUPABASE_URL=https://[your-project-ref].supabase.co
VITE_SUPABASE_ANON_KEY=[your-supabase-anon-key]

# Create .env.example for reference
cp .env .env.example
```

### 3. Install Dependencies

```bash
# Install core dependencies
npm install @supabase/supabase-js react-router-dom lucide-react react-hot-toast recharts date-fns

# Install dev dependencies
npm install -D tailwindcss postcss autoprefixer

# Initialize Tailwind CSS
npx tailwindcss init -p
```

### 4. Folder Structure

```bash
# Create organized folder structure
mkdir -p docs
mkdir -p src/components/layout
mkdir -p src/components/leads
mkdir -p src/components/analytics
mkdir -p src/components/common
mkdir -p src/pages
mkdir -p src/services
mkdir -p src/types
mkdir -p src/hooks
mkdir -p src/utils
mkdir -p src/lib
```

## GitHub Repository Setup

### 1. Create GitHub Repository

1. Go to [GitHub.com](https://github.com)
2. Click "New repository"
3. Name: `propello`
4. Description: "AI Realtor Lead Management Dashboard"
5. Set to Public (for Vercel integration)
6. Don't initialize with README (we have existing code)

### 2. Connect Local to GitHub

```bash
# Add all files to Git
git add .

# Initial commit
git commit -m "Initial commit - Propello realtor dashboard"

# Set main branch
git branch -M main

# Add remote origin (replace with your GitHub username)
git remote add origin git@github.com:yourusername/propello.git

# Push to GitHub
git push -u origin main
```

## Supabase Database Setup

### 1. Create Supabase Project

1. Go to [Supabase.com](https://supabase.com)
2. Click "New Project"
3. Name: "Propello" or "propello-production"
4. Choose region closest to your users
5. Set strong database password
6. Wait for project creation (~2 minutes)

### 2. Get Project Credentials

1. Go to Project Settings > API
2. Copy Project URL and anon public key
3. Update your local `.env` file with these values

### 3. Database Schema Setup

Run the following SQL in Supabase SQL Editor:

```sql
-- Create leads table
CREATE TABLE leads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  type TEXT NOT NULL CHECK (type IN ('buyer', 'seller')),
  timeframe TEXT NOT NULL,
  property_details TEXT,
  lead_quality TEXT NOT NULL CHECK (lead_quality IN ('hot', 'warm', 'cold')),
  status TEXT DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'qualified', 'closed', 'dead')),
  call_duration INTEGER,
  call_transcript TEXT,
  call_recording_url TEXT,
  notes TEXT[] DEFAULT '{}',
  tags TEXT[] DEFAULT '{}',
  assigned_to UUID REFERENCES auth.users(id),
  is_archived BOOLEAN DEFAULT FALSE
);

-- Create lead_activities table
CREATE TABLE lead_activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  lead_id UUID NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
  performed_by UUID REFERENCES auth.users(id),
  activity_type TEXT NOT NULL,
  description TEXT,
  metadata JSONB
);

-- Create indexes
CREATE INDEX idx_leads_created_at ON leads(created_at DESC);
CREATE INDEX idx_leads_status ON leads(status);
CREATE INDEX idx_leads_quality ON leads(lead_quality);
CREATE INDEX idx_leads_type ON leads(type);
CREATE INDEX idx_leads_assigned_to ON leads(assigned_to);
CREATE INDEX idx_activities_lead_id ON lead_activities(lead_id);
CREATE INDEX idx_activities_created_at ON lead_activities(created_at DESC);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_leads_updated_at
  BEFORE UPDATE ON leads
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE lead_activities ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view all leads"
  ON leads FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Service role can insert leads"
  ON leads FOR INSERT
  TO service_role
  WITH CHECK (true);

CREATE POLICY "Users can update leads"
  ON leads FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Users can view activities"
  ON lead_activities FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert activities"
  ON lead_activities FOR INSERT
  TO authenticated
  WITH CHECK (true);
```

### 4. Generate TypeScript Types

```bash
# Install Supabase CLI
brew install supabase/tap/supabase

# Generate types (replace with your project ID)
supabase gen types typescript --project-id [your-project-id] > src/lib/database.types.ts
```

## Vercel Deployment Setup

### 1. Create Vercel Account

1. Go to [Vercel.com](https://vercel.com)
2. Sign up with GitHub account
3. Authorize Vercel to access your repositories

### 2. Deploy Project

1. Click "Add New..." → "Project"
2. Import your `propello` GitHub repository
3. Vercel will auto-detect Vite configuration
4. Set project name to "propello"

### 3. Configure Environment Variables

**CRITICAL**: Add environment variables before deploying:

1. Click "Environment Variables" section
2. Add the following variables:

```
VITE_SUPABASE_URL = https://[your-project-ref].supabase.co
VITE_SUPABASE_ANON_KEY = [your-supabase-anon-key]
```

3. Make sure both are set for "Production", "Preview", and "Development"

### 4. Deploy

1. Click "Deploy" button
2. Wait ~2 minutes for deployment
3. Vercel will provide live URL: `https://propello.vercel.app`

### 5. Configure Custom Domain (Optional)

1. Go to Project Settings > Domains
2. Add custom domain (e.g., `propello.yourdomain.com`)
3. Configure DNS records as instructed
4. Enable SSL certificate

## Retell AI Integration (Recommended)

### 1. Create Retell AI Account

1. Go to [Retell AI](https://retellai.com)
2. Sign up for an account
3. Create your first AI agent

### 2. Configure Webhook

1. In Retell dashboard, go to your agent settings
2. Navigate to **Webhooks** section
3. Configure webhook endpoint: `https://[your-project-ref].supabase.co/rest/v1/leads`
4. Set up headers and payload as described in [RETELL_WEBHOOK_SETUP.md](RETELL_WEBHOOK_SETUP.md)

### 3. Test Integration

1. Make a test call to your Retell agent
2. Verify lead appears in Propello dashboard
3. Check that lead is routed to correct user account

**Important**: Ensure your webhook payload includes the `agent_phone_number` field for proper lead routing.

## Make.com Webhook Integration (Alternative)

### 1. Create Make.com Account

1. Go to [Make.com](https://make.com)
2. Sign up for free account
3. Create new scenario

### 2. Configure Webhook

1. Add "HTTP" module to scenario
2. Configure with these settings:

**Method**: POST  
**URL**: `https://[your-project-ref].supabase.co/rest/v1/leads`  
**Headers**:
```
apikey: [your-supabase-anon-key]
Authorization: Bearer [your-supabase-anon-key]
Content-Type: application/json
Prefer: return=representation
```

**Body**:
```json
{
  "name": "{{agent.name}}",
  "phone": "{{agent.phone}}",
  "email": "{{agent.email}}",
  "type": "{{agent.type}}",
  "timeframe": "{{agent.timeframe}}",
  "property_details": "{{agent.property}}",
  "lead_quality": "{{agent.quality}}",
  "call_duration": "{{agent.duration}}",
  "call_transcript": "{{agent.transcript}}",
  "status": "new"
}
```

### 3. Test Webhook

```bash
# Test with cURL
curl -X POST "https://[your-project-ref].supabase.co/rest/v1/leads" \
  -H "apikey: [your-anon-key]" \
  -H "Authorization: Bearer [your-anon-key]" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "name": "Test Lead",
    "phone": "+1234567890",
    "email": "test@example.com",
    "type": "buyer",
    "timeframe": "3-6 months",
    "property_details": "3BR house in downtown",
    "lead_quality": "hot",
    "call_duration": 180,
    "status": "new"
  }'
```

## Automatic Deployment Workflow

### 1. Development Workflow

```bash
# Make changes to code
# Test locally
npm run dev

# Commit changes
git add .
git commit -m "Add new feature: [description]"
git push origin main

# Vercel automatically deploys in ~2 minutes
```

### 2. Branch Deployments

- **Main branch**: Deploys to production URL
- **Feature branches**: Deploy to preview URLs
- **Pull requests**: Automatic preview deployments

### 3. Deployment Monitoring

1. Go to Vercel Dashboard
2. Click on your Propello project
3. Monitor deployment status
4. View build logs if issues occur

## Production Configuration

### 1. Performance Optimization

```bash
# Build optimization
npm run build

# Check bundle size
npm run build -- --analyze

# Test production build locally
npm run preview
```

### 2. Security Configuration

- Environment variables are secure in Vercel
- Supabase RLS policies protect data
- HTTPS enforced automatically
- No sensitive data in client code

### 3. Monitoring Setup

1. **Vercel Analytics**: Enable in project settings
2. **Error Tracking**: Built-in Vercel error monitoring
3. **Performance**: Vercel Speed Insights
4. **Uptime**: Vercel status monitoring

## Testing Deployment

### 1. Local Testing

```bash
# Start development server
npm run dev

# Open in browser
open http://localhost:5173

# Test on iPhone/iPad (same WiFi)
# Use Network URL from terminal output
```

### 2. Production Testing

1. Visit your Vercel URL
2. Test all functionality
3. Check responsive design
4. Test on multiple devices
5. Verify real-time updates

### 3. End-to-End Testing

1. Trigger Make.com webhook
2. Check Supabase for new data
3. Refresh Propello dashboard
4. Verify lead appears correctly

## Troubleshooting

### Common Issues

**Deployment Fails**:
- Check build logs in Vercel dashboard
- Verify all dependencies installed
- Check for TypeScript errors
- Ensure environment variables set

**Webhook Not Working**:
- Verify Supabase URL and key
- Check Make.com scenario is active
- Test with cURL first
- Check Supabase logs

**Real-time Updates Not Working**:
- Verify Supabase real-time enabled
- Check browser console for errors
- Ensure proper subscription setup
- Test with manual data insert

### Debug Commands

```bash
# Check local build
npm run build

# Test production build
npm run preview

# Check environment variables
echo $VITE_SUPABASE_URL

# Verify Git status
git status

# Check Vercel deployment
vercel --version
```

## Maintenance

### 1. Regular Updates

```bash
# Update dependencies
npm update

# Check for security vulnerabilities
npm audit

# Update and commit
git add .
git commit -m "Update dependencies"
git push origin main
```

### 2. Backup Strategy

- **Database**: Supabase automatic backups
- **Code**: GitHub repository
- **Environment**: Vercel environment variables
- **Configuration**: Documented in this guide

### 3. Monitoring

- **Uptime**: Vercel status page
- **Performance**: Vercel analytics
- **Errors**: Vercel error tracking
- **Usage**: Supabase dashboard

## Rollback Plan

### 1. Code Rollback

```bash
# Revert to previous commit
git revert [commit-hash]
git push origin main

# Or reset to specific commit
git reset --hard [commit-hash]
git push --force origin main
```

### 2. Database Rollback

- Use Supabase point-in-time recovery
- Restore from backup if needed
- Contact Supabase support for assistance

### 3. Deployment Rollback

- Use Vercel deployment history
- Rollback to previous deployment
- Monitor for issues after rollback

---

*This deployment guide ensures Propello is properly configured, secure, and ready for production use.*








