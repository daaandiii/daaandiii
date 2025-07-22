#!/bin/bash

# 🎯 GitHub Contribution Backfill Script (macOS Compatible)
# ⚠️  Use responsibly and ethically!

echo "🤖 Starting GitHub contribution backfill..."

# Configuration
START_DATE="2024-07-01"  # Start from this date
END_DATE="2025-07-21"    # End at this date (today)
COMMITS_PER_DAY=2        # Number of commits per day

# Commit message arrays for variety
PREFIXES=("feat" "fix" "docs" "style" "refactor" "test" "chore")
ACTIVITIES=("update" "improve" "optimize" "enhance" "maintain" "sync" "add")
EMOJIS=("🚀" "✨" "🔧" "📝" "🎯" "⚡" "🌟" "💡" "🔄" "📊" "🛠️" "🎨")

# Function to generate random commit message
generate_commit_message() {
    local prefix=${PREFIXES[$RANDOM % ${#PREFIXES[@]}]}
    local activity=${ACTIVITIES[$RANDOM % ${#ACTIVITIES[@]}]}
    local emoji=${EMOJIS[$RANDOM % ${#EMOJIS[@]}]}
    echo "$prefix: $emoji $activity"
}

# Function to generate random time
generate_random_time() {
    local hour=$((RANDOM % 12 + 8))  # 8 AM to 8 PM
    local minute=$((RANDOM % 60))
    local second=$((RANDOM % 60))
    printf "%02d:%02d:%02d" $hour $minute $second
}

# Function to add days to date (macOS compatible)
add_days_to_date() {
    local base_date=$1
    local days_to_add=$2
    
    # Use date command with -v option (macOS BSD date)
    date -j -v+${days_to_add}d -f "%Y-%m-%d" "$base_date" "+%Y-%m-%d"
}

# Create logs directory if it doesn't exist
mkdir -p logs

echo "📅 Backfilling from $START_DATE to $END_DATE"
echo "🎯 $COMMITS_PER_DAY commits per day (NO SKIPS - WAJIB COMMIT)"
echo ""

# Initialize counter
total_commits=0
day_counter=0

current_date="$START_DATE"

# Loop until we reach end date
while [[ "$current_date" < "$END_DATE" ]] || [[ "$current_date" == "$END_DATE" ]]; do
    echo "📝 Processing $current_date..."
    
    # Generate commits for this day (WAJIB - no skipping)
    for ((i=1; i<=$COMMITS_PER_DAY; i++)); do
        # Generate random time for this commit
        random_time=$(generate_random_time)
        commit_datetime="$current_date $random_time"
        
        # Generate commit message
        commit_msg=$(generate_commit_message)
        
        # Create activity file in logs folder
        activity_file="logs/activity-$current_date-$i.log"
        echo "Activity on $commit_datetime" > "$activity_file"
        echo "Commit #$i for $current_date" >> "$activity_file"
        echo "Generated at: $(date)" >> "$activity_file"
        
        # Add and commit with specific date
        git add "$activity_file"
        
        # Commit with backdated timestamp using --date flag
        git commit --date="$commit_datetime" -m "$commit_msg" --quiet
        
        if [ $? -eq 0 ]; then
            echo "  ✅ Commit $i: $commit_msg ($random_time)"
            ((total_commits++))
        else
            echo "  ❌ Failed to commit $i"
        fi
        
        # Small delay between commits
        sleep 0.1
    done
    
    # Move to next day
    ((day_counter++))
    current_date=$(add_days_to_date "$START_DATE" "$day_counter")
    
    # Safety check to prevent infinite loop
    if [ $day_counter -gt 400 ]; then
        echo "⚠️  Safety break: Processed more than 400 days"
        break
    fi
done

echo ""
echo "🎉 Backfill completed!"
echo "📊 Total commits created: $total_commits"
echo "📅 Total days processed: $day_counter"
echo "📁 All activity files saved in: logs/"
echo ""
echo "🚀 To push to GitHub:"
echo "   git push origin main --force-with-lease"
echo ""
echo "⚠️  Warning: This will rewrite git history!"
echo "💡 Make sure to backup your repository first."