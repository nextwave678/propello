-- Fix analytics tables to have proper unique constraints
-- This will add the missing unique constraints that the triggers need

-- Add unique constraint to daily_analytics on date column
ALTER TABLE public.daily_analytics 
ADD CONSTRAINT unique_daily_analytics_date UNIQUE (date);

-- Add unique constraint to weekly_analytics on week_start column
ALTER TABLE public.weekly_analytics 
ADD CONSTRAINT unique_weekly_analytics_week UNIQUE (week_start);

-- Add unique constraint to monthly_analytics on month_start column
ALTER TABLE public.monthly_analytics 
ADD CONSTRAINT unique_monthly_analytics_month UNIQUE (month_start);

-- Update the trigger function to handle the constraints properly
CREATE OR REPLACE FUNCTION update_daily_analytics()
RETURNS TRIGGER AS $$
BEGIN
    -- Update daily analytics when leads are modified
    INSERT INTO public.daily_analytics (date, total_leads, new_leads, completed_leads, successful_leads, unsuccessful_leads, on_fence_leads)
    VALUES (
        CURRENT_DATE,
        (SELECT COUNT(*) FROM public.leads WHERE DATE(created_at) = CURRENT_DATE),
        (SELECT COUNT(*) FROM public.leads WHERE DATE(created_at) = CURRENT_DATE),
        (SELECT COUNT(*) FROM public.leads WHERE completion_status IS NOT NULL AND DATE(created_at) = CURRENT_DATE),
        (SELECT COUNT(*) FROM public.leads WHERE completion_status = 'successful' AND DATE(created_at) = CURRENT_DATE),
        (SELECT COUNT(*) FROM public.leads WHERE completion_status = 'unsuccessful' AND DATE(created_at) = CURRENT_DATE),
        (SELECT COUNT(*) FROM public.leads WHERE completion_status = 'on_the_fence' AND DATE(created_at) = CURRENT_DATE)
    )
    ON CONFLICT (date) DO UPDATE SET
        total_leads = EXCLUDED.total_leads,
        new_leads = EXCLUDED.new_leads,
        completed_leads = EXCLUDED.completed_leads,
        successful_leads = EXCLUDED.successful_leads,
        unsuccessful_leads = EXCLUDED.unsuccessful_leads,
        on_fence_leads = EXCLUDED.on_fence_leads;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Recreate the trigger
DROP TRIGGER IF EXISTS update_daily_analytics_trigger ON public.leads;
CREATE TRIGGER update_daily_analytics_trigger
    AFTER INSERT OR UPDATE OR DELETE ON public.leads
    FOR EACH ROW EXECUTE FUNCTION update_daily_analytics();
