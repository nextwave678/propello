import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://yzxbjcqgokzbqkiiqnar.supabase.co'
const supabaseAnonKey = process.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl6eGJqY3Fnb2t6YnFraWlxbmFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4NjUxMzEsImV4cCI6MjA3NjQ0MTEzMX0.buKrPEtLAsoNwLuc7j9hZZ7jS1S-jj8OHbFJCsE7rxk'

const supabase = createClient(supabaseUrl, supabaseAnonKey)

export default async function handler(req, res) {
  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    const { event, call } = req.body
    
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
        
        // Extract lead data from Retell webhook
        // Handle both phone_call (from_number/to_number) and web_call (custom_analysis_data)
        const customData = call.call_analysis?.custom_analysis_data || {}
        const dynamicVars = call.retell_llm_dynamic_variables || {}
        
        // Get phone number from multiple possible sources
        const phoneNumber = call.from_number || 
                           dynamicVars.customer_phone || 
                           customData.number || 
                           '000-000-0000'
        
        const leadData = {
          name: customData.name || 
                dynamicVars.customer_name || 
                'Unknown',
          phone: phoneNumber, // Required field
          email: customData.email || 
                 dynamicVars.customer_email || 
                 '',
          type: customData.type || 
                dynamicVars.lead_type || 
                'buyer',
          timeframe: customData.timeframe || 
                     dynamicVars.timeframe || 
                     'Unknown',
          property_details: customData.property_details || 
                           dynamicVars.property_details || 
                           '',
          lead_quality: customData.lead_quality || 
                       dynamicVars.lead_quality || 
                       'cold',
          call_duration: call.duration_ms ? Math.floor(call.duration_ms / 1000) : 
                         Math.floor((call.end_timestamp - call.start_timestamp) / 1000), // Convert to seconds
          call_transcript: call.transcript || '',
          status: 'new',
          agent_phone_number: customData['agent_phone-number'] || 
                             customData.agent_phone_number ||
                             call.to_number || 
                             '' // The agent's phone number
        }
        
        // Validate required fields before inserting
        if (!leadData.phone || leadData.phone === '000-000-0000') {
          console.error('Missing phone number in webhook payload:', JSON.stringify(call, null, 2))
          return res.status(400).json({ error: 'Missing required field: phone' })
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
