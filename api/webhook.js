import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://yzxbjcqgokzbqkiiqnar.supabase.co'
const supabaseAnonKey = process.env.VITE_SUPABASE_ANON_KEY

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
        const leadData = {
          name: call.retell_llm_dynamic_variables?.customer_name || 'Unknown',
          phone: call.from_number,
          email: call.retell_llm_dynamic_variables?.customer_email || '',
          type: call.retell_llm_dynamic_variables?.lead_type || 'buyer',
          timeframe: call.retell_llm_dynamic_variables?.timeframe || 'Unknown',
          property_details: call.retell_llm_dynamic_variables?.property_details || '',
          lead_quality: call.retell_llm_dynamic_variables?.lead_quality || 'cold',
          call_duration: Math.floor((call.end_timestamp - call.start_timestamp) / 1000), // Convert to seconds
          call_transcript: call.transcript || '',
          status: 'new',
          agent_phone_number: call.to_number // The agent's phone number
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
