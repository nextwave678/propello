# Supabase Setup Guide

## 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up or log in to your account
3. Click "New Project"
4. Choose your organization
5. Enter project details:
   - **Name**: `propello-leads`
   - **Database Password**: Choose a strong password
   - **Region**: Choose the closest region to you
6. Click "Create new project"
7. Wait for the project to be set up (this takes a few minutes)

## 2. Get Your Project Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (looks like: `https://your-project-ref.supabase.co`)
   - **Anon public key** (starts with `eyJ...`)

## 3. Set Up Environment Variables

1. Create a `.env` file in your project root (if it doesn't exist)
2. Add your Supabase credentials:

```env
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

Replace `your-project-ref` and `your-anon-key-here` with your actual values.

## 4. Set Up the Database Schema

1. In your Supabase dashboard, go to **SQL Editor**
2. Click "New query"
3. Copy and paste the entire contents of `supabase-schema.sql` into the editor
4. Click "Run" to execute the SQL
5. You should see "Success. No rows returned" if everything worked correctly

## 5. Verify the Setup

1. Go to **Table Editor** in your Supabase dashboard
2. You should see two tables: `leads` and `lead_activities`
3. Click on the `leads` table to see the sample data
4. You should see 24 leads with various completion statuses

## 6. Test the Application

1. Make sure your `.env` file is properly configured
2. Restart your development server: `npm run dev`
3. The application should now connect to Supabase instead of using mock data
4. All lead sections should load properly with real data

## 7. Enable Real-time (Optional)

If you want real-time updates:

1. Go to **Database** → **Replication** in your Supabase dashboard
2. Enable replication for both `leads` and `lead_activities` tables
3. This will allow real-time updates when leads are modified

## Troubleshooting

### If you get "Missing Supabase environment variables" error:
- Check that your `.env` file is in the project root
- Verify the variable names are exactly `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`
- Restart your development server after adding the environment variables

### If the database schema doesn't work:
- Make sure you're running the SQL in the correct project
- Check that you have the necessary permissions
- Try running the SQL in smaller chunks if it fails

### If the application still shows loading:
- Check the browser console for any error messages
- Verify your Supabase credentials are correct
- Make sure the database schema was created successfully

## Database Schema Overview

The schema includes:

- **leads table**: Stores all lead information with completion status
- **lead_activities table**: Tracks lead interactions and activities
- **Row Level Security (RLS)**: Ensures data security
- **Indexes**: For better query performance
- **Triggers**: Automatically update timestamps
- **Sample data**: 24 leads across different categories

## Next Steps

Once everything is working:

1. You can start adding real leads through the application
2. The completion functionality will work with real database updates
3. All lead sections will show actual data from Supabase
4. Real-time updates will work if enabled
