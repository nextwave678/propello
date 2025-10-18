# Propello Database Schema

## Overview

The Propello database is built on Supabase (PostgreSQL) with two main tables designed to capture and track real estate leads from AI phone agents. The schema supports real-time updates, comprehensive lead tracking, and scalable analytics.

## Tables

### 1. Leads Table

**Purpose**: Store all lead information captured by AI phone agents

```sql
CREATE TABLE leads (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Contact Information
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  
  -- Lead Classification
  type TEXT NOT NULL CHECK (type IN ('buyer', 'seller')),
  timeframe TEXT NOT NULL,
  property_details TEXT,
  lead_quality TEXT NOT NULL CHECK (lead_quality IN ('hot', 'warm', 'cold')),
  
  -- Status Management
  status TEXT DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'qualified', 'closed', 'dead')),
  
  -- Call Information
  call_duration INTEGER, -- Duration in seconds
  call_transcript TEXT,
  call_recording_url TEXT,
  
  -- Lead Management
  notes TEXT[] DEFAULT '{}',
  tags TEXT[] DEFAULT '{}',
  assigned_to UUID REFERENCES auth.users(id),
  is_archived BOOLEAN DEFAULT FALSE
);
```

### 2. Lead Activities Table

**Purpose**: Track all interactions and changes for each lead

```sql
CREATE TABLE lead_activities (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Relationships
  lead_id UUID NOT NULL REFERENCES leads(id) ON DELETE CASCADE,
  performed_by UUID REFERENCES auth.users(id),
  
  -- Activity Details
  activity_type TEXT NOT NULL, -- 'status_change', 'note_added', 'quality_updated', 'call_made', etc.
  description TEXT,
  metadata JSONB -- Flexible storage for activity-specific data
);
```

## Indexes

### Performance Indexes

```sql
-- Leads table indexes
CREATE INDEX idx_leads_created_at ON leads(created_at DESC);
CREATE INDEX idx_leads_status ON leads(status);
CREATE INDEX idx_leads_quality ON leads(lead_quality);
CREATE INDEX idx_leads_type ON leads(type);
CREATE INDEX idx_leads_assigned_to ON leads(assigned_to);
CREATE INDEX idx_leads_archived ON leads(is_archived);

-- Activities table indexes
CREATE INDEX idx_activities_lead_id ON lead_activities(lead_id);
CREATE INDEX idx_activities_created_at ON lead_activities(created_at DESC);
CREATE INDEX idx_activities_type ON lead_activities(activity_type);
```

## Triggers

### Automatic Updated At

```sql
-- Function to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for leads table
CREATE TRIGGER update_leads_updated_at
  BEFORE UPDATE ON leads
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

## Row Level Security (RLS)

### Enable RLS

```sql
-- Enable RLS on both tables
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE lead_activities ENABLE ROW LEVEL SECURITY;
```

### Security Policies

```sql
-- Leads table policies
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

CREATE POLICY "Users can delete leads"
  ON leads FOR DELETE
  TO authenticated
  USING (true);

-- Activities table policies
CREATE POLICY "Users can view activities"
  ON lead_activities FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can insert activities"
  ON lead_activities FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Users can update activities"
  ON lead_activities FOR UPDATE
  TO authenticated
  USING (true);
```

## Sample Data Structure

### Lead Record Example

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z",
  "name": "John Smith",
  "phone": "+1234567890",
  "email": "john.smith@email.com",
  "type": "buyer",
  "timeframe": "3-6 months",
  "property_details": "3BR house in downtown area, budget $500k-$700k",
  "lead_quality": "hot",
  "status": "new",
  "call_duration": 180,
  "call_transcript": "Caller interested in buying home in downtown area...",
  "call_recording_url": "https://storage.supabase.co/recordings/call_123.mp3",
  "notes": ["Very interested", "Prefers downtown location"],
  "tags": ["first-time-buyer", "downtown"],
  "assigned_to": null,
  "is_archived": false
}
```

### Activity Record Example

```json
{
  "id": "456e7890-e89b-12d3-a456-426614174001",
  "created_at": "2024-01-15T11:00:00Z",
  "lead_id": "123e4567-e89b-12d3-a456-426614174000",
  "performed_by": "789e0123-e89b-12d3-a456-426614174002",
  "activity_type": "status_change",
  "description": "Status changed from 'new' to 'contacted'",
  "metadata": {
    "old_status": "new",
    "new_status": "contacted",
    "reason": "Initial contact made"
  }
}
```

## Data Types Reference

### Lead Quality Values
- **hot**: High priority, immediate action needed
- **warm**: Moderate priority, follow up within 24-48 hours
- **cold**: Low priority, nurture over time

### Lead Type Values
- **buyer**: Looking to purchase property
- **seller**: Looking to sell property

### Status Values
- **new**: Just received from AI agent
- **contacted**: Initial contact made by realtor
- **qualified**: Lead meets criteria for follow-up
- **closed**: Deal completed successfully
- **dead**: Lead no longer viable

### Activity Types
- **status_change**: Lead status updated
- **quality_updated**: Lead quality assessment changed
- **note_added**: New note added to lead
- **call_made**: Outbound call to lead
- **email_sent**: Email communication sent
- **meeting_scheduled**: Meeting or showing scheduled
- **deal_closed**: Successful transaction completed

## Analytics Queries

### Common Analytics Patterns

```sql
-- Lead count by quality
SELECT lead_quality, COUNT(*) as count
FROM leads
WHERE is_archived = false
GROUP BY lead_quality;

-- Leads by status
SELECT status, COUNT(*) as count
FROM leads
WHERE is_archived = false
GROUP BY status;

-- Recent activity
SELECT l.name, la.activity_type, la.description, la.created_at
FROM leads l
JOIN lead_activities la ON l.id = la.lead_id
WHERE la.created_at > NOW() - INTERVAL '24 hours'
ORDER BY la.created_at DESC;

-- Lead conversion rate
SELECT 
  COUNT(CASE WHEN status = 'closed' THEN 1 END) as closed_leads,
  COUNT(*) as total_leads,
  ROUND(
    COUNT(CASE WHEN status = 'closed' THEN 1 END)::DECIMAL / COUNT(*) * 100, 2
  ) as conversion_rate
FROM leads
WHERE is_archived = false;
```

## Migration Strategy

### Initial Setup
1. Create tables with proper constraints
2. Add indexes for performance
3. Set up triggers for automation
4. Configure RLS policies
5. Generate TypeScript types

### Future Enhancements
- Add lead source tracking
- Implement lead scoring algorithm
- Add team collaboration features
- Create automated lead assignment rules
- Add lead lifecycle analytics

---

*This schema is designed to scale with Propello's growth while maintaining data integrity and performance.*

