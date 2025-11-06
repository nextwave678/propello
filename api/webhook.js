import { createClient } from '@supabase/supabase-js'

// Use environment variables for Supabase connection
const supabaseUrl = process.env.VITE_SUPABASE_URL || process.env.SUPABASE_URL
// Use service role key for admin access (bypasses RLS)
// Webhook needs admin access since it's not authenticated as a user
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl) {
  throw new Error('Missing SUPABASE_URL or VITE_SUPABASE_URL environment variable')
}

if (!supabaseServiceKey) {
  throw new Error('Missing SUPABASE_SERVICE_ROLE_KEY or VITE_SUPABASE_ANON_KEY environment variable')
}

const supabase = createClient(supabaseUrl, supabaseServiceKey)

// Validation helpers
const validateEmail = (email) => {
  if (!email) return true // Email is optional
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

const validatePhone = (phone) => {
  if (!phone) return false // Phone is required
  // Accept various phone formats
  const phoneRegex = /^[\d\s\-\+\(\)]+$/
  return phoneRegex.test(phone) && phone.replace(/\D/g, '').length >= 10
}

const normalizeValue = (value, allowedValues, defaultValue) => {
  if (!value) return defaultValue
  const normalized = value.toString().toLowerCase().trim()
  return allowedValues.includes(normalized) ? normalized : defaultValue
}

// Idempotency cache (in-memory, consider Redis for production)
const processedCalls = new Map()
const CACHE_TTL = 5 * 60 * 1000 // 5 minutes

// Clean up old cache entries periodically
setInterval(() => {
  const now = Date.now()
  for (const [key, timestamp] of processedCalls.entries()) {
    if (now - timestamp > CACHE_TTL) {
      processedCalls.delete(key)
    }
  }
}, 60 * 1000) // Every minute

export default async function handler(req, res) {
  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    const { event, call } = req.body
    
    // Validate basic structure
    if (!event || !call) {
      console.error('Invalid webhook payload: missing event or call')
      return res.status(400).json({ error: 'Invalid payload structure' })
    }
    
    console.log(`Received ${event} event for call ${call?.call_id}`)
    console.log('Full webhook payload:', JSON.stringify(req.body, null, 2))
    
    // Handle different event types
    switch (event) {
      case 'call_started':
        console.log('Call started event received', call.call_id)
        break
      case 'call_ended':
        console.log('Call ended event received', call.call_id)
        break
      case 'call_analyzed':
        console.log('Call analyzed event received', call.call_id)
        
        // Idempotency check - prevent duplicate lead creation
        const callId = call.call_id
        if (!callId) {
          console.error('Missing call_id in webhook payload')
          return res.status(400).json({ error: 'Missing call_id' })
        }
        
        if (processedCalls.has(callId)) {
          console.log('Call already processed (idempotent):', callId)
          return res.status(200).json({ message: 'Already processed', callId })
        }
        
        // Check if lead already exists in database
        const { data: existingLead } = await supabase
          .from('leads')
          .select('id')
          .eq('call_transcript', call.transcript || '')
          .limit(1)
        
        if (existingLead && existingLead.length > 0) {
          console.log('Lead already exists in database for call:', callId)
          processedCalls.set(callId, Date.now())
          return res.status(200).json({ message: 'Lead already exists', callId })
        }
        
        // Extract lead data from Retell webhook
        // Handle both phone_call (from_number/to_number) and web_call (custom_analysis_data)
        const customData = call.call_analysis?.custom_analysis_data || {}
        const dynamicVars = call.retell_llm_dynamic_variables || {}
        
        // Get phone number from multiple possible sources
        const phoneNumber = call.from_number || 
                           dynamicVars.customer_phone || 
                           customData.number || 
                           customData.phone ||
                           ''
        
        // Validate phone number
        if (!validatePhone(phoneNumber)) {
          console.error('Invalid or missing phone number:', phoneNumber)
          return res.status(400).json({ error: 'Invalid phone number format' })
        }
        
        const agentPhoneNumber = customData['agent_phone-number'] || 
                                customData.agent_phone_number ||
                                call.to_number || 
                                '' // The agent's phone number
        
        // Look up the user_id by agent_phone_number
        let userId = null
        if (agentPhoneNumber) {
          console.log('Looking up user by agent_phone_number:', agentPhoneNumber)
          const { data: userProfile, error: profileError } = await supabase
            .from('user_profiles')
            .select('user_id')
            .eq('agent_phone_number', agentPhoneNumber)
            .single()
          
          if (profileError) {
            console.warn('Could not find user profile for agent phone:', agentPhoneNumber, profileError)
          } else if (userProfile) {
            userId = userProfile.user_id
            console.log('Found user_id:', userId)
          }
        }
        
        // Extract and validate email
        const emailValue = customData.email || dynamicVars.customer_email || ''
        if (emailValue && !validateEmail(emailValue)) {
          console.warn('Invalid email format, setting to empty:', emailValue)
        }
        
        // Normalize values using helper function
        const normalizedType = normalizeValue(
          customData.type || dynamicVars.lead_type,
          ['buyer', 'seller'],
          'buyer'
        )
        
        const normalizedQuality = normalizeValue(
          customData.lead_quality || dynamicVars.lead_quality,
          ['hot', 'warm', 'cold'],
          'cold'
        )
        
        const normalizedStatus = normalizeValue(
          customData.status || dynamicVars.status,
          ['new', 'contacted', 'qualified', 'closed', 'dead'],
          'new'
        )
        
        const leadData = {
          name: (customData.name || dynamicVars.customer_name || 'Unknown').trim(),
          phone: phoneNumber.trim(),
          email: validateEmail(emailValue) ? emailValue.trim() : '',
          type: normalizedType,
          timeframe: (customData.timeframe || dynamicVars.timeframe || 'Unknown').trim(),
          property_details: (customData.property_details || dynamicVars.property_details || '').trim(),
          lead_quality: normalizedQuality,
          call_duration: call.duration_ms ? Math.floor(call.duration_ms / 1000) : 
                         (call.end_timestamp && call.start_timestamp) ? 
                         Math.floor((call.end_timestamp - call.start_timestamp) / 1000) : 0,
          call_transcript: (call.transcript || '').trim(),
          status: normalizedStatus,
          agent_phone_number: agentPhoneNumber,
          user_id: userId, // Assign the user_id for proper data isolation
          notes: [],
          tags: [],
          is_archived: false
        }
        
        if (!leadData.user_id) {
          console.warn('Could not determine user_id for lead. Agent phone:', agentPhoneNumber)
          // You may want to reject leads without a user_id
          // return res.status(400).json({ error: 'Could not route lead to user' })
        }

        console.log('Prepared lead data:', JSON.stringify(leadData, null, 2))

        // Insert lead into Supabase
        const { data, error } = await supabase
          .from('leads')
          .insert([leadData])
          .select()

        if (error) {
          console.error('Supabase error:', error)
          return res.status(500).json({ error: 'Failed to save lead', details: error.message })
        }

        // Mark call as processed
        processedCalls.set(callId, Date.now())
        
        console.log('Lead saved successfully:', data)
        break
      default:
        console.log('Received an unknown event:', event)
    }
    
    // Acknowledge the receipt of the event
    res.status(204).send()
    
  } catch (error) {
    console.error('Webhook error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
}
