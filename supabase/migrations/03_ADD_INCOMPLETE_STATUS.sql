-- =============================================
-- ADD 'incomplete' STATUS TO completion_status
-- =============================================
-- 
-- This migration adds 'incomplete' as a valid value for completion_status
-- This allows new leads from the webhook to have a default status
-- instead of NULL, which was causing filtering issues.
-- 
-- =============================================

-- Drop the existing CHECK constraint
ALTER TABLE public.leads 
DROP CONSTRAINT IF EXISTS leads_completion_status_check;

-- Add the new CHECK constraint with 'incomplete' included
ALTER TABLE public.leads 
ADD CONSTRAINT leads_completion_status_check 
CHECK (completion_status IN ('incomplete', 'successful', 'on_the_fence', 'unsuccessful'));

-- Set default value for completion_status to 'incomplete'
ALTER TABLE public.leads 
ALTER COLUMN completion_status SET DEFAULT 'incomplete';

-- Optionally: Update existing NULL values to 'incomplete'
-- This is commented out by default - uncomment if you want to update existing leads
-- UPDATE public.leads 
-- SET completion_status = 'incomplete' 
-- WHERE completion_status IS NULL;

-- Log completion
DO $$ 
BEGIN
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'MIGRATION COMPLETE!';
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Added "incomplete" to completion_status constraint';
    RAISE NOTICE 'Set default completion_status to "incomplete"';
    RAISE NOTICE '=============================================';
END $$;


