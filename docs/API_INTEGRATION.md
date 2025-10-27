# Propello API Integration Guide

## Overview

Propello integrates with AI phone agents through Make.com webhooks, which send structured lead data directly to Supabase. This document covers the complete integration setup, testing procedures, and production configuration.

## Make.com Webhook Configuration

### HTTP Module Setup

**Method**: POST  
**URL**: `https://[your-project-ref].supabase.co/rest/v1/leads`  
**Content-Type**: `application/json`

### Required Headers

```http
apikey: [your-supabase-anon-key]
Authorization: Bearer [your-supabase-anon-key]
Content-Type: application/json
Prefer: return=representation
```

### Webhook Payload Structure

The AI agent should send data in this exact format:

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
  "status": "new",
  "agent_phone_number": "{{agent.phone_number}}"
}
```

**CRITICAL**: The `agent_phone_number` field is **required** for proper lead routing to specific user accounts. This field must match the phone number assigned to the Retell AI agent and must correspond to a user's `agent_phone_number` in their profile.

### Multi-User Lead Routing

Propello uses the `agent_phone_number` field to route leads to the correct user account:

1. **User Registration**: Each user provides their AI agent's phone number during signup
2. **Agent Configuration**: Retell AI agents are configured with specific phone numbers
3. **Webhook Routing**: When a lead is captured, the `agent_phone_number` in the webhook payload determines which user sees the lead
4. **Data Isolation**: Row Level Security (RLS) ensures users only see leads with their `agent_phone_number`

**Example Flow**:
- User A signs up with agent phone `+1-555-123-4567`
- User B signs up with agent phone `+1-555-987-6543`
- Retell Agent 1 (phone: `+1-555-123-4567`) captures a lead → Lead appears in User A's dashboard
- Retell Agent 2 (phone: `+1-555-987-6543`) captures a lead → Lead appears in User B's dashboard

### Field Mapping Guide

| AI Agent Field | Database Column | Type | Required | Description |
|----------------|-----------------|------|----------|-------------|
| `agent.name` | `name` | TEXT | Yes | Lead's full name |
| `agent.phone` | `phone` | TEXT | Yes | Lead's phone number with country code |
| `agent.email` | `email` | TEXT | No | Lead's email address if provided |
| `agent.type` | `type` | TEXT | Yes | "buyer" or "seller" |
| `agent.timeframe` | `timeframe` | TEXT | Yes | "immediately", "1-3 months", "3-6 months", "6+ months" |
| `agent.property` | `property_details` | TEXT | No | Property preferences and details |
| `agent.quality` | `lead_quality` | TEXT | Yes | "hot", "warm", or "cold" |
| `agent.duration` | `call_duration` | INTEGER | No | Call duration in seconds |
| `agent.transcript` | `call_transcript` | TEXT | No | Full call transcript |
| `agent.phone_number` | `agent_phone_number` | TEXT | **Yes** | **AI agent's phone number for lead routing** |

## Supabase REST API Configuration

### Authentication Setup

1. **Get Supabase Credentials**:
   - Project URL: `https://[project-ref].supabase.co`
   - Anon Key: Found in Project Settings > API

2. **Configure Headers in Make.com**:
   ```
   apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   Content-Type: application/json
   Prefer: return=representation
   ```

### Endpoint Configuration

**Base URL**: `https://[your-project-ref].supabase.co/rest/v1/leads`

**Full Configuration**:
- **Method**: POST
- **URL**: `https://[your-project-ref].supabase.co/rest/v1/leads`
- **Headers**: As specified above
- **Body**: JSON payload from AI agent
- **Timeout**: 30 seconds
- **Retry**: 3 attempts with exponential backoff

## Testing Procedures

### 1. Local Testing with cURL

```bash
# Test webhook endpoint
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
    "call_transcript": "Test call transcript",
    "status": "new",
    "agent_phone_number": "+1-555-123-4567"
  }'
```

### 2. Make.com Test Scenario

1. **Create Test Scenario**:
   - Add HTTP module
   - Configure with test data
   - Run scenario manually
   - Verify data appears in Supabase

2. **Test Data Examples**:

```json
// Hot Buyer Lead
{
  "name": "Sarah Johnson",
  "phone": "+1555123456",
  "email": "sarah.j@email.com",
  "type": "buyer",
  "timeframe": "immediately",
  "property_details": "3BR/2BA house, downtown area, budget $600k-$800k",
  "lead_quality": "hot",
  "call_duration": 240,
  "call_transcript": "Very interested, ready to buy within 30 days",
  "status": "new",
  "agent_phone_number": "+1-555-123-4567"
}

// Warm Seller Lead
{
  "name": "Mike Chen",
  "phone": "+1555987654",
  "email": "mike.chen@email.com",
  "type": "seller",
  "timeframe": "3-6 months",
  "property_details": "4BR/3BA house in suburbs, needs appraisal",
  "lead_quality": "warm",
  "call_duration": 180,
  "call_transcript": "Considering selling, wants market analysis",
  "status": "new",
  "agent_phone_number": "+1-555-987-6543"
}

// Cold Lead
{
  "name": "Jennifer Davis",
  "phone": "+1555555555",
  "email": "jen.davis@email.com",
  "type": "buyer",
  "timeframe": "6+ months",
  "property_details": "Just browsing, no specific requirements",
  "lead_quality": "cold",
  "call_duration": 120,
  "call_transcript": "Early stage, just gathering information",
  "status": "new",
  "agent_phone_number": "+1-555-456-7890"
}
```

### 3. Production Testing

1. **Deploy to Vercel**: Ensure Propello is live
2. **Configure Production Webhook**: Update Make.com with production Supabase URL
3. **Test End-to-End**: Trigger AI agent → Check Propello dashboard
4. **Verify Real-time Updates**: Confirm leads appear instantly

## Error Handling

### Common Error Responses

```json
// Validation Error
{
  "code": "23514",
  "message": "new row for relation \"leads\" violates check constraint \"leads_type_check\"",
  "details": "Failing row contains (..., invalid_type, ...)"
}

// Authentication Error
{
  "code": "PGRST301",
  "message": "JWT expired",
  "details": "Token has expired"
}

// Network Error
{
  "code": "PGRST204",
  "message": "Could not find the function",
  "details": "The function leads() does not exist"
}
```

### Error Handling in Make.com

1. **Add Error Handling Module**:
   - HTTP module → Error handling
   - Log errors to external service
   - Send notifications for critical failures

2. **Retry Logic**:
   - Maximum 3 retry attempts
   - Exponential backoff (1s, 2s, 4s)
   - Log all retry attempts

3. **Fallback Actions**:
   - Store failed requests in backup system
   - Send alert notifications
   - Manual intervention queue

## Production Configuration

### Environment Variables

**Make.com Variables**:
```
SUPABASE_URL=https://[your-project-ref].supabase.co
SUPABASE_ANON_KEY=[your-anon-key]
WEBHOOK_ENDPOINT=https://[your-project-ref].supabase.co/rest/v1/leads
```

**Propello Environment Variables**:
```
VITE_SUPABASE_URL=https://[your-project-ref].supabase.co
VITE_SUPABASE_ANON_KEY=[your-anon-key]
```

### Security Considerations

1. **API Key Protection**:
   - Store keys in Make.com variables (not hardcoded)
   - Rotate keys regularly
   - Monitor API usage

2. **Rate Limiting**:
   - Supabase has built-in rate limiting
   - Monitor for abuse patterns
   - Implement client-side throttling if needed

3. **Data Validation**:
   - Validate all incoming data
   - Sanitize text inputs
   - Check data types and constraints

### Monitoring & Alerts

1. **Success Metrics**:
   - Webhook success rate > 99%
   - Response time < 2 seconds
   - Zero data loss

2. **Alert Conditions**:
   - Webhook failures > 5% in 1 hour
   - Response time > 5 seconds
   - Database connection errors

3. **Monitoring Tools**:
   - Supabase Dashboard
   - Make.com execution logs
   - Vercel deployment logs

## Troubleshooting Guide

### Issue: Webhook Not Receiving Data

**Check**:
1. Make.com scenario is active
2. HTTP module URL is correct
3. Headers are properly configured
4. AI agent is sending data in correct format

**Solution**:
1. Test with cURL first
2. Check Make.com execution logs
3. Verify Supabase table permissions

### Issue: Data Not Appearing in Propello

**Check**:
1. Supabase data is being inserted
2. Propello is connected to correct database
3. Real-time subscriptions are working
4. No JavaScript errors in browser console

**Solution**:
1. Check Supabase table directly
2. Refresh Propello dashboard
3. Check browser network tab
4. Verify environment variables

### Issue: Slow Response Times

**Check**:
1. Network connectivity
2. Supabase performance
3. Make.com execution time
4. Database query performance

**Solution**:
1. Check Supabase status page
2. Optimize database queries
3. Consider caching strategies
4. Monitor resource usage

## API Documentation

### Supabase REST API Reference

**Base URL**: `https://[project-ref].supabase.co/rest/v1`

**Endpoints**:
- `GET /leads` - List all leads
- `POST /leads` - Create new lead
- `GET /leads/{id}` - Get specific lead
- `PATCH /leads/{id}` - Update lead
- `DELETE /leads/{id}` - Delete lead

**Query Parameters**:
- `select=*` - Select all columns
- `order=created_at.desc` - Order by creation date
- `limit=100` - Limit results
- `offset=0` - Pagination offset

**Example Queries**:
```bash
# Get recent leads
GET /leads?select=*&order=created_at.desc&limit=10

# Get hot leads only
GET /leads?select=*&lead_quality=eq.hot

# Get leads by status
GET /leads?select=*&status=eq.new
```

---

*This integration guide ensures reliable data flow from AI agents to Propello dashboard.*








