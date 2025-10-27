-- VERIFICATION QUERY: Check RLS is working properly
-- This query will show us exactly what leads each user should see

-- Check all leads with their agent phone numbers
SELECT 
    agent_phone_number,
    name,
    email,
    lead_quality,
    status,
    COUNT(*) as count_per_phone
FROM public.leads 
WHERE agent_phone_number IN ('+1-555-888-8', '+1-555-999-9', '+1-555-777-7')
GROUP BY agent_phone_number, name, email, lead_quality, status
ORDER BY agent_phone_number, name;

-- Summary by agent phone number
SELECT 
    agent_phone_number,
    COUNT(*) as total_leads,
    COUNT(CASE WHEN lead_quality = 'hot' THEN 1 END) as hot_leads,
    COUNT(CASE WHEN lead_quality = 'warm' THEN 1 END) as warm_leads,
    COUNT(CASE WHEN lead_quality = 'cold' THEN 1 END) as cold_leads,
    COUNT(CASE WHEN completion_status IS NOT NULL THEN 1 END) as completed_leads
FROM public.leads 
WHERE agent_phone_number IN ('+1-555-888-8', '+1-555-999-9', '+1-555-777-7')
GROUP BY agent_phone_number
ORDER BY agent_phone_number;
