#!/bin/bash

# Test Webhook Routing Script
# This script tests the webhook endpoint with multiple agent phone numbers
# to verify that leads are properly routed to specific user accounts

# Configuration - Update these values
SUPABASE_URL="https://yzxbjcqgokzbqkiiqnar.supabase.co"
SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl6eGJqY3Fnb2t6YnFraWlxbmFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4NjUxMzEsImV4cCI6MjA3NjQ0MTEzMX0.buKrPEtLAsoNwLuc7j9hZZ7jS1S-jj8OHbFJCsE7rxk"
WEBHOOK_ENDPOINT="$SUPABASE_URL/rest/v1/leads"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test agent phone numbers
AGENT_PHONES=(
    "+1-555-777-7777"
    "+1-555-888-8"
    "+1-555-999-9"
)

# Test lead data templates
declare -A TEST_LEADS
TEST_LEADS["+1-555-777-7777"]='{
    "name": "Browser Test Lead",
    "phone": "+1555777777",
    "email": "browsertest@example.com",
    "type": "buyer",
    "timeframe": "immediately",
    "property_details": "3BR/2BA house, downtown area, budget $600k-$800k",
    "lead_quality": "hot",
    "call_duration": 240,
    "call_transcript": "Very interested, ready to buy within 30 days",
    "status": "new",
    "agent_phone_number": "+1-555-777-7777"
}'

TEST_LEADS["+1-555-888-8"]='{
    "name": "Sarah Test Lead",
    "phone": "+1555888888",
    "email": "sarah@example.com",
    "type": "seller",
    "timeframe": "3-6 months",
    "property_details": "4BR/3BA house in suburbs, needs appraisal",
    "lead_quality": "warm",
    "call_duration": 180,
    "call_transcript": "Considering selling, wants market analysis",
    "status": "new",
    "agent_phone_number": "+1-555-888-8"
}'

TEST_LEADS["+1-555-999-9"]='{
    "name": "Michael Test Lead",
    "phone": "+1555999999",
    "email": "michael@example.com",
    "type": "buyer",
    "timeframe": "6+ months",
    "property_details": "Just browsing, no specific requirements",
    "lead_quality": "cold",
    "call_duration": 120,
    "call_transcript": "Early stage, just gathering information",
    "status": "new",
    "agent_phone_number": "+1-555-999-9"
}'

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if required tools are installed
check_dependencies() {
    print_status $BLUE "Checking dependencies..."
    
    if ! command -v curl &> /dev/null; then
        print_status $RED "Error: curl is not installed"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        print_status $YELLOW "Warning: jq is not installed. JSON responses will not be formatted."
    fi
    
    print_status $GREEN "Dependencies check passed"
}

# Function to validate configuration
validate_config() {
    print_status $BLUE "Validating configuration..."
    
    if [[ "$SUPABASE_URL" == "https://your-project-ref.supabase.co" ]]; then
        print_status $RED "Error: Please update SUPABASE_URL with your actual Supabase project URL"
        exit 1
    fi
    
    if [[ "$SUPABASE_ANON_KEY" == "your-supabase-anon-key-here" ]]; then
        print_status $RED "Error: Please update SUPABASE_ANON_KEY with your actual Supabase anon key"
        exit 1
    fi
    
    print_status $GREEN "Configuration validation passed"
}

# Function to test webhook endpoint
test_webhook() {
    local agent_phone=$1
    local lead_data=$2
    
    print_status $BLUE "Testing webhook for agent: $agent_phone"
    
    # Make the webhook request
    local response=$(curl -s -w "\n%{http_code}" \
        -X POST "$WEBHOOK_ENDPOINT" \
        -H "apikey: $SUPABASE_ANON_KEY" \
        -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
        -H "Content-Type: application/json" \
        -H "Prefer: return=representation" \
        -d "$lead_data")
    
    # Extract HTTP status code and response body
    local http_code=$(echo "$response" | tail -n1)
    local response_body=$(echo "$response" | head -n -1)
    
    # Check if request was successful
    if [[ "$http_code" -eq 200 || "$http_code" -eq 201 ]]; then
        print_status $GREEN "✓ Webhook successful (HTTP $http_code)"
        
        # Try to extract lead ID from response
        if command -v jq &> /dev/null; then
            local lead_id=$(echo "$response_body" | jq -r '.[0].id // empty')
            if [[ -n "$lead_id" ]]; then
                print_status $GREEN "  Lead ID: $lead_id"
            fi
        fi
        
        return 0
    else
        print_status $RED "✗ Webhook failed (HTTP $http_code)"
        print_status $RED "  Response: $response_body"
        return 1
    fi
}

# Function to verify lead routing
verify_routing() {
    print_status $BLUE "Verifying lead routing..."
    
    # This would require database access to verify leads were inserted correctly
    # For now, we'll just check if the webhook requests were successful
    print_status $YELLOW "Note: To fully verify lead routing, check your Propello dashboard"
    print_status $YELLOW "or run the test-webhook-routing.sql script in Supabase"
}

# Function to test authentication
test_authentication() {
    print_status $BLUE "Testing Supabase authentication..."
    
    local auth_response=$(curl -s -w "\n%{http_code}" \
        -X GET "$SUPABASE_URL/rest/v1/user_profiles?select=count" \
        -H "apikey: $SUPABASE_ANON_KEY" \
        -H "Authorization: Bearer $SUPABASE_ANON_KEY")
    
    local http_code=$(echo "$auth_response" | tail -n1)
    
    if [[ "$http_code" -eq 200 ]]; then
        print_status $GREEN "✓ Authentication successful"
        return 0
    else
        print_status $RED "✗ Authentication failed (HTTP $http_code)"
        return 1
    fi
}

# Function to run all tests
run_tests() {
    print_status $BLUE "Starting webhook routing tests..."
    echo
    
    local success_count=0
    local total_tests=${#AGENT_PHONES[@]}
    
    # Test authentication first
    if ! test_authentication; then
        print_status $RED "Authentication test failed. Please check your Supabase credentials."
        exit 1
    fi
    
    echo
    
    # Test each agent phone number
    for agent_phone in "${AGENT_PHONES[@]}"; do
        local lead_data="${TEST_LEADS[$agent_phone]}"
        
        if test_webhook "$agent_phone" "$lead_data"; then
            ((success_count++))
        fi
        
        echo
    done
    
    # Print summary
    print_status $BLUE "Test Summary:"
    print_status $GREEN "✓ Successful: $success_count/$total_tests"
    
    if [[ $success_count -eq $total_tests ]]; then
        print_status $GREEN "🎉 All tests passed!"
    else
        print_status $RED "❌ Some tests failed. Check the error messages above."
    fi
    
    echo
    
    # Verify routing
    verify_routing
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --verbose  Enable verbose output"
    echo "  -t, --test     Test specific agent phone number"
    echo
    echo "Configuration:"
    echo "  Update SUPABASE_URL and SUPABASE_ANON_KEY at the top of this script"
    echo
    echo "Examples:"
    echo "  $0                                    # Run all tests"
    echo "  $0 -t '+1-555-123-4567'             # Test specific agent"
    echo
}

# Main execution
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            -t|--test)
                if [[ -n "$2" ]]; then
                    # Test specific agent phone number
                    local test_phone="$2"
                    if [[ -n "${TEST_LEADS[$test_phone]}" ]]; then
                        validate_config
                        test_webhook "$test_phone" "${TEST_LEADS[$test_phone]}"
                    else
                        print_status $RED "Error: Unknown agent phone number: $test_phone"
                        exit 1
                    fi
                else
                    print_status $RED "Error: -t requires an agent phone number"
                    exit 1
                fi
                exit 0
                ;;
            *)
                print_status $RED "Error: Unknown option $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Run all tests
    check_dependencies
    validate_config
    run_tests
}

# Run main function
main "$@"
