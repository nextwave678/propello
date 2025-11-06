# Webhook Security Implementation Guide

## Overview

This guide explains how to secure your Propello webhook endpoint with signature verification to prevent unauthorized webhook submissions and potential security attacks.

## Why Webhook Security Matters

Without signature verification, anyone who knows your webhook URL can send fake lead data to your system. This could lead to:

- **Data pollution**: Fake leads cluttering your database
- **Resource exhaustion**: Malicious actors flooding your system
- **Security breaches**: Injected malicious data
- **Financial impact**: Processing costs from spam webhooks

## Current State

✅ **Implemented:**
- Payload validation (required fields, data types)
- Idempotency checks (duplicate prevention)
- Input sanitization (email/phone validation)
- Value normalization (lowercase, trim)
- Rate limiting at Vercel level (automatic)

❌ **Not Implemented:**
- HMAC signature verification
- IP whitelist filtering
- Request timestamp validation

## Implementation: HMAC Signature Verification

### Step 1: Get Webhook Secret from Retell AI

1. Log into your Retell AI dashboard
2. Navigate to **Settings** → **Webhooks**
3. Find your webhook secret (or generate one if not available)
4. Copy the secret key (e.g., `whsec_abc123...`)

### Step 2: Add Secret to Vercel Environment

```bash
# In Vercel Dashboard → Settings → Environment Variables
RETELL_WEBHOOK_SECRET=whsec_abc123your_secret_here
```

Or via Vercel CLI:
```bash
vercel env add RETELL_WEBHOOK_SECRET
```

### Step 3: Update Webhook Code

Add signature verification to `/api/webhook.js`:

```javascript
import crypto from 'crypto'

// Webhook secret from environment
const webhookSecret = process.env.RETELL_WEBHOOK_SECRET

/**
 * Verify webhook signature using HMAC SHA-256
 * @param {string} payload - Raw request body as string
 * @param {string} signature - Signature from request header
 * @param {string} secret - Webhook secret
 * @returns {boolean} - True if signature is valid
 */
const verifyWebhookSignature = (payload, signature, secret) => {
  if (!signature || !secret) {
    return false
  }

  // Compute HMAC SHA-256 hash
  const hmac = crypto.createHmac('sha256', secret)
  hmac.update(payload)
  const computedSignature = hmac.digest('hex')

  // Compare signatures using timing-safe comparison
  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(computedSignature)
  )
}

export default async function handler(req, res) {
  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    // Get raw body as string for signature verification
    const rawBody = JSON.stringify(req.body)
    
    // Get signature from header
    const signature = req.headers['x-retell-signature'] || 
                      req.headers['x-webhook-signature']
    
    // Verify signature
    if (webhookSecret) {
      if (!signature) {
        console.error('Missing webhook signature')
        return res.status(401).json({ error: 'Missing signature' })
      }

      const isValid = verifyWebhookSignature(rawBody, signature, webhookSecret)
      
      if (!isValid) {
        console.error('Invalid webhook signature')
        return res.status(401).json({ error: 'Invalid signature' })
      }
      
      console.log('Webhook signature verified ✓')
    } else {
      console.warn('⚠️  WEBHOOK_SECRET not configured - signature verification skipped')
    }

    // Continue with existing webhook logic...
    const { event, call } = req.body
    
    // ... rest of your webhook code
    
  } catch (error) {
    console.error('Webhook error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
}
```

### Step 4: Configure Retell AI Webhook

In Retell AI dashboard, when configuring the webhook:

1. **Webhook URL**: `https://your-app.vercel.app/api/webhook`
2. **Secret**: Use the same secret you added to Vercel
3. **Signature Header**: `X-Retell-Signature` (default)
4. **Hash Algorithm**: HMAC SHA-256

### Step 5: Test Signature Verification

Test with a valid webhook:
```bash
# This should succeed
curl -X POST "https://your-app.vercel.app/api/webhook" \
  -H "Content-Type: application/json" \
  -H "X-Retell-Signature: <valid_signature>" \
  -d '{"event":"call_analyzed","call":{...}}'
```

Test with invalid signature:
```bash
# This should return 401 Unauthorized
curl -X POST "https://your-app.vercel.app/api/webhook" \
  -H "Content-Type: application/json" \
  -H "X-Retell-Signature: invalid_signature" \
  -d '{"event":"call_analyzed","call":{...}}'
```

## Additional Security Measures

### 1. IP Whitelist (Optional)

If Retell AI provides static IP addresses:

```javascript
const ALLOWED_IPS = [
  '123.456.789.0',
  '123.456.789.1',
  // Add Retell AI IPs
]

export default async function handler(req, res) {
  // Get client IP
  const clientIp = req.headers['x-forwarded-for'] || 
                   req.headers['x-real-ip'] || 
                   req.connection.remoteAddress

  if (!ALLOWED_IPS.includes(clientIp)) {
    console.error('Unauthorized IP:', clientIp)
    return res.status(403).json({ error: 'Forbidden' })
  }

  // Continue with webhook processing...
}
```

### 2. Timestamp Validation

Prevent replay attacks by validating request timestamps:

```javascript
const MAX_TIMESTAMP_AGE = 5 * 60 * 1000 // 5 minutes

const validateTimestamp = (timestamp) => {
  const now = Date.now()
  const requestTime = new Date(timestamp).getTime()
  const age = now - requestTime

  return age >= 0 && age <= MAX_TIMESTAMP_AGE
}

export default async function handler(req, res) {
  const timestamp = req.headers['x-retell-timestamp'] || 
                    req.body.timestamp

  if (!validateTimestamp(timestamp)) {
    console.error('Request timestamp too old or invalid')
    return res.status(401).json({ error: 'Request expired' })
  }

  // Continue with webhook processing...
}
```

### 3. Rate Limiting

Vercel automatically provides rate limiting, but you can add custom limits:

```javascript
import rateLimit from 'express-rate-limit'

const limiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 100, // 100 requests per minute
  message: 'Too many webhook requests'
})

export default async function handler(req, res) {
  // Apply rate limiting
  await limiter(req, res)

  // Continue with webhook processing...
}
```

## Monitoring & Alerts

### Log All Webhook Attempts

```javascript
const logWebhookAttempt = (req, success, error = null) => {
  console.log({
    timestamp: new Date().toISOString(),
    ip: req.headers['x-forwarded-for'] || req.connection.remoteAddress,
    event: req.body?.event,
    callId: req.body?.call?.call_id,
    success,
    error: error?.message,
    userAgent: req.headers['user-agent']
  })
}

// In webhook handler
try {
  // Process webhook
  logWebhookAttempt(req, true)
} catch (error) {
  logWebhookAttempt(req, false, error)
}
```

### Set Up Alerts

Monitor for suspicious activity:

1. **Failed signature verifications** (multiple in short time)
2. **Unknown IP addresses** (if using whitelist)
3. **Unusual request patterns** (volume spikes)
4. **Invalid payloads** (malformed data)

Use Vercel's built-in monitoring or integrate with:
- **Sentry** for error tracking
- **Datadog** for metrics
- **Logtail** for log aggregation

## Security Checklist

Before going to production:

- [ ] Webhook secret configured in Vercel
- [ ] Signature verification implemented and tested
- [ ] HTTPS enforced (automatic with Vercel)
- [ ] Payload validation for all fields
- [ ] Idempotency checks in place
- [ ] Input sanitization implemented
- [ ] Error messages don't leak sensitive info
- [ ] Logging configured (without PII)
- [ ] Monitoring and alerts set up
- [ ] Rate limiting configured
- [ ] (Optional) IP whitelist configured
- [ ] (Optional) Timestamp validation added
- [ ] Documentation updated for team

## Troubleshooting

### Signature Always Fails

**Problem**: Signature verification always returns false

**Solutions**:
1. Check webhook secret matches Retell AI configuration
2. Verify signature header name (`X-Retell-Signature`)
3. Ensure raw body is used (not parsed JSON)
4. Check for extra whitespace or encoding issues
5. Confirm hash algorithm (SHA-256)

### Legitimate Webhooks Rejected

**Problem**: Valid webhooks from Retell AI are rejected

**Solutions**:
1. Verify webhook secret is correct
2. Check Vercel environment variables are set
3. Test with Retell AI's webhook testing tool
4. Review logs for specific error messages
5. Temporarily disable verification to isolate issue

### Performance Issues

**Problem**: Webhook processing is slow

**Solutions**:
1. Move signature verification before heavy processing
2. Use Redis for idempotency cache (instead of in-memory)
3. Implement async processing (queue system)
4. Optimize database queries
5. Add caching where appropriate

## Best Practices

1. **Never log the webhook secret** in production
2. **Rotate secrets periodically** (every 90 days)
3. **Use environment-specific secrets** (dev, staging, prod)
4. **Monitor failed attempts** and investigate patterns
5. **Keep webhook processing fast** (<500ms response time)
6. **Return appropriate HTTP status codes**
   - 200: Success
   - 400: Bad request (invalid payload)
   - 401: Unauthorized (bad signature)
   - 500: Server error (retry)
7. **Document webhook behavior** for your team
8. **Test with real Retell AI webhooks** before deploying

## References

- [OWASP Webhook Security](https://owasp.org/www-community/Webhook_Security)
- [Vercel Security Best Practices](https://vercel.com/docs/security)
- [HMAC Authentication](https://en.wikipedia.org/wiki/HMAC)

---

**Status**: Implementation guide ready. Signature verification code provided above can be integrated when Retell AI webhook secret is available.

