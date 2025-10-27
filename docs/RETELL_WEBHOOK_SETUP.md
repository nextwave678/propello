# Retell AI Webhook Setup Guide

## Overview

This guide walks you through configuring Retell AI agents to send lead data directly to Propello via webhooks. Each Retell agent uses the same webhook endpoint but includes its unique `agent_phone_number` to route leads to the correct user account.

## Prerequisites

- Propello account with Supabase project configured
- Retell AI account with active agents
- Supabase project URL and anon key
- User accounts created in Propello with `agent_phone_number` set

## Step 1: Get Supabase Credentials

1. Go to your Supabase project dashboard
2. Navigate to **Settings** → **API**
3. Copy the following values:
   - **Project URL**: `https://[your-project-ref].supabase.co`
   - **Anon Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

## Step 2: Configure Retell Agent Webhook

### 2.1 Access Agent Settings

1. Log into your Retell AI dashboard
2. Navigate to **Agents** → Select your agent
3. Go to **Settings** → **Webhooks**

### 2.2 Configure Webhook Endpoint

**Webhook URL**: `https://[your-project-ref].supabase.co/rest/v1/leads`

**Method**: POST

**Headers**:
```
apikey: [your-supabase-anon-key]
Authorization: Bearer [your-supabase-anon-key]
Content-Type: application/json
Prefer: return=representation
```

### 2.3 Configure Payload Template

Replace `[AGENT_PHONE_NUMBER]` with your agent's actual phone number:

```json
{
  "name": "{{caller_name}}",
  "phone": "{{caller_phone}}",
  "email": "{{caller_email}}",
  "type": "{{lead_type}}",
  "timeframe": "{{timeframe}}",
  "property_details": "{{property_details}}",
  "lead_quality": "{{lead_quality}}",
  "call_duration": "{{call_duration}}",
  "call_transcript": "{{call_transcript}}",
  "status": "new",
  "agent_phone_number": "[AGENT_PHONE_NUMBER]"
}
```

**Important**: Replace `[AGENT_PHONE_NUMBER]` with your agent's actual phone number (e.g., `+1-555-123-4567`)

## Step 3: Multiple Agent Configuration

### 3.1 Agent 1 Example

**Agent Phone**: `+1-555-123-4567`
**Payload**:
```json
{
  "name": "{{caller_name}}",
  "phone": "{{caller_phone}}",
  "email": "{{caller_email}}",
  "type": "{{lead_type}}",
  "timeframe": "{{timeframe}}",
  "property_details": "{{property_details}}",
  "lead_quality": "{{lead_quality}}",
  "call_duration": "{{call_duration}}",
  "call_transcript": "{{call_transcript}}",
  "status": "new",
  "agent_phone_number": "+1-555-123-4567"
}
```

### 3.2 Agent 2 Example

**Agent Phone**: `+1-555-987-6543`
**Payload**:
```json
{
  "name": "{{caller_name}}",
  "phone": "{{caller_phone}}",
  "email": "{{caller_email}}",
  "type": "{{lead_type}}",
  "timeframe": "{{timeframe}}",
  "property_details": "{{property_details}}",
  "lead_quality": "{{lead_quality}}",
  "call_duration": "{{call_duration}}",
  "call_transcript": "{{call_transcript}}",
  "status": "new",
  "agent_phone_number": "+1-555-987-6543"
}
```

### 3.3 Agent 3 Example

**Agent Phone**: `+1-555-456-7890`
**Payload**:
```json
{
  "name": "{{caller_name}}",
  "phone": "{{caller_phone}}",
  "email": "{{caller_email}}",
  "type": "{{lead_type}}",
  "timeframe": "{{timeframe}}",
  "property_details": "{{property_details}}",
  "lead_quality": "{{lead_quality}}",
  "call_duration": "{{call_duration}}",
  "call_transcript": "{{call_transcript}}",
  "status": "new",
  "agent_phone_number": "+1-555-456-7890"
}
```

## Step 4: Testing Your Configuration

### 4.1 Test with cURL

Replace the placeholders with your actual values:

```bash
curl -X POST "https://[your-project-ref].supabase.co/rest/v1/leads" \
  -H "apikey: [your-supabase-anon-key]" \
  -H "Authorization: Bearer [your-supabase-anon-key]" \
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

### 4.2 Verify in Propello Dashboard

1. Log into Propello with the user account that has `agent_phone_number: +1-555-123-4567`
2. Check if the test lead appears in the dashboard
3. Verify the lead only appears for the correct user

### 4.3 Test Multiple Agents

1. Send test webhooks with different `agent_phone_number` values
2. Verify each lead appears only for the corresponding user
3. Confirm users cannot see leads from other agents

## Step 5: Production Deployment

### 5.1 Enable Webhook in Retell

1. In Retell dashboard, go to your agent settings
2. Enable the webhook configuration
3. Test with a real call to ensure it works

### 5.2 Monitor Webhook Delivery

1. Check Retell webhook logs for successful deliveries
2. Monitor Supabase logs for incoming requests
3. Verify leads appear in Propello dashboard

## Troubleshooting

### Common Issues

#### Issue: Lead not appearing in dashboard
**Causes**:
- `agent_phone_number` doesn't match user's profile
- Webhook payload missing required fields
- Supabase authentication issues

**Solutions**:
1. Verify `agent_phone_number` matches exactly (including format)
2. Check webhook payload includes all required fields
3. Test Supabase connection with cURL

#### Issue: Webhook returns 401 Unauthorized
**Causes**:
- Incorrect Supabase anon key
- Missing or malformed headers

**Solutions**:
1. Verify anon key is correct and complete
2. Check headers are properly formatted
3. Test authentication with Supabase dashboard

#### Issue: Lead appears for wrong user
**Causes**:
- `agent_phone_number` mismatch
- User profile not created properly

**Solutions**:
1. Verify user's `agent_phone_number` in Propello profile
2. Check webhook payload `agent_phone_number` value
3. Ensure exact string match (including +1, dashes, etc.)

### Debugging Steps

1. **Check Supabase Logs**:
   - Go to Supabase dashboard → Logs
   - Look for incoming webhook requests
   - Check for any error messages

2. **Verify User Profile**:
   ```sql
   SELECT agent_phone_number, email FROM user_profiles 
   WHERE agent_phone_number = '+1-555-123-4567';
   ```

3. **Test Webhook Manually**:
   - Use cURL to test webhook endpoint
   - Verify response status and data
   - Check if lead is inserted correctly

4. **Check Propello Console**:
   - Open browser developer tools
   - Look for any JavaScript errors
   - Check network requests to Supabase

## Best Practices

### 1. Phone Number Formatting
- Use consistent format: `+1-555-123-4567`
- Include country code (+1 for US)
- Use dashes for readability

### 2. Webhook Reliability
- Set up webhook retry logic in Retell
- Monitor webhook delivery success rates
- Have fallback mechanisms for failed deliveries

### 3. Security
- Keep Supabase anon key secure
- Use HTTPS for all webhook communications
- Monitor for unusual webhook activity

### 4. Testing
- Test with multiple agent phone numbers
- Verify data isolation between users
- Test error scenarios (invalid data, network issues)

## Support

If you encounter issues:

1. Check this troubleshooting guide first
2. Review Supabase and Retell documentation
3. Test with the provided cURL examples
4. Contact support with specific error messages and logs

---

*This guide ensures reliable lead routing from Retell AI agents to Propello user accounts.*
