#!/bin/bash

# RiderMate Gamification API Test Script
# This script demonstrates how to use the gamification API endpoints

BASE_URL="http://localhost:3000/api"
USER_ID="demo_user"

echo "==================================="
echo "RiderMate Gamification API Tests"
echo "==================================="
echo ""

# Test 1: Get Global Leaderboard
echo "1. Getting global leaderboard (weekly)..."
curl -s "$BASE_URL/leaderboard/global?period=weekly" | json_pp
echo ""
echo "-----------------------------------"
echo ""

# Test 2: Get User Rank
echo "2. Getting user rank..."
curl -s "$BASE_URL/users/$USER_ID/rank?period=all_time" | json_pp
echo ""
echo "-----------------------------------"
echo ""

# Test 3: Get User Points
echo "3. Getting user points..."
curl -s "$BASE_URL/points/$USER_ID" | json_pp
echo ""
echo "-----------------------------------"
echo ""

# Test 4: Get Points History
echo "4. Getting points history..."
curl -s "$BASE_URL/points/$USER_ID/history?limit=10" | json_pp
echo ""
echo "-----------------------------------"
echo ""

# Test 5: Award Points
echo "5. Awarding points for completing a ride..."
curl -s -X POST "$BASE_URL/points/award" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "'"$USER_ID"'",
    "activityType": "COMPLETE_RIDE",
    "reason": "Completed morning ride"
  }' | json_pp
echo ""
echo "-----------------------------------"
echo ""

# Test 6: Get All Badges
echo "6. Getting all available badges..."
curl -s "$BASE_URL/badges/all" | json_pp
echo ""
echo "-----------------------------------"
echo ""

# Test 7: Get User Badges
echo "7. Getting user badges..."
curl -s "$BASE_URL/badges/$USER_ID" | json_pp
echo ""
echo "-----------------------------------"
echo ""

# Test 8: Get All Achievements
echo "8. Getting all achievements..."
curl -s "$BASE_URL/achievements/all" | json_pp
echo ""
echo "-----------------------------------"
echo ""

# Test 9: Get User Achievements
echo "9. Getting user achievements..."
curl -s "$BASE_URL/achievements/$USER_ID" | json_pp
echo ""
echo "-----------------------------------"
echo ""

# Test 10: Get Friends Leaderboard
echo "10. Getting friends leaderboard..."
curl -s "$BASE_URL/leaderboard/friends/$USER_ID?period=all_time" | json_pp
echo ""
echo "-----------------------------------"
echo ""

# Test 11: Get Safety Leaderboard
echo "11. Getting safety leaderboard..."
curl -s "$BASE_URL/leaderboard/safety" | json_pp
echo ""
echo "-----------------------------------"
echo ""

# Test 12: Get Distance Leaderboard
echo "12. Getting distance leaderboard..."
curl -s "$BASE_URL/leaderboard/distance" | json_pp
echo ""
echo "-----------------------------------"
echo ""

echo ""
echo "==================================="
echo "All tests completed!"
echo "==================================="
