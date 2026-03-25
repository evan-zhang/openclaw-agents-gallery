#!/bin/bash
# scrub-agent.sh - 脱敏脚本工具链 (v1.1)
# Usage: ./scripts/scrub-agent.sh [--dry-run] [--mode sharing] [--bootstrap]

CONFIG_FILE="projects/TPR-20260325-001/SCRUB_LIST.json"
REPORT_FILE="SCRUB_REPORT.md"
DRY_RUN=false
MODE="normal"
BOOTSTRAP_MODE=false
TEMPLATE_FILE="projects/TPR-20260325-001/templates/BOOTSTRAP.md"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true ;;
        --mode) MODE="$2"; shift ;;
        --bootstrap) BOOTSTRAP_MODE=true ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found."
    exit 1
fi

echo "Starting scrub process (Mode: $MODE, Dry-run: $DRY_RUN, Bootstrap: $BOOTSTRAP_MODE)..." | tee $REPORT_FILE
echo "---" >> $REPORT_FILE
echo "Timestamp: $(date)" >> $REPORT_FILE

# 1. Physical Scrubbing
echo "## 1. Physical Scrubbing" >> $REPORT_FILE
DIRS=$(jq -r '.physical_scrub.directories[]' "$CONFIG_FILE")
FILES=$(jq -r '.physical_scrub.files[]' "$CONFIG_FILE")

# Safeguard project protocol in sharing mode
if [ "$MODE" = "sharing" ]; then
    PROTECTED_PROJECT="projects/TPR-20260325-001"
    echo "Sharing mode active: Protecting project protocol ($PROTECTED_PROJECT)" >> $REPORT_FILE
fi

for dir in $DIRS; do
    echo "Processing pattern: $dir"
    # Shell expansion of the pattern
    for d in $dir; do
        d_clean=${d%/}
        if [ -e "$d_clean" ]; then
            # Check if this dir is protected in sharing mode
            if [ "$MODE" = "sharing" ] && [[ "$d_clean" == *"$PROTECTED_PROJECT"* ]]; then
                echo "Skipping protected protocol: $d_clean" | tee -a $REPORT_FILE
                continue
            fi

            if [ "$DRY_RUN" = true ]; then
                echo "DRY-RUN: Would delete $d_clean" >> $REPORT_FILE
            else
                echo "Deleting $d_clean" >> $REPORT_FILE
                rm -rf "$d_clean" 2>/dev/null
            fi
        fi
    done
done

for file in $FILES; do
    echo "Processing file pattern: $file"
    if [ "$DRY_RUN" = true ]; then
        echo "DRY-RUN: Would delete $file" >> $REPORT_FILE
    else
        find . -path "$file" -delete 2>/dev/null
        echo "Deleted matching: $file" >> $REPORT_FILE
    fi
done

# 2. Config Scrubbing (Using JQ)
echo "## 2. Config Masking" >> $REPORT_FILE
CONF_FILES=$(jq -r '.config_scrub.files[]' "$CONFIG_FILE")
MASK_KEYS=$(jq -r '.config_scrub.mask_keys | join("|")' "$CONFIG_FILE")

for cf in $CONF_FILES; do
    if [ -f "$cf" ]; then
        echo "Masking $cf"
        if [ "$DRY_RUN" = true ]; then
            echo "DRY-RUN: Would mask keys ($MASK_KEYS) in $cf" >> $REPORT_FILE
        else
            # Recursive mask using walk
            jq "walk(if type == \"object\" then with_entries(if .key | test(\"$MASK_KEYS\"; \"i\") then .value = \"[REDACTED]\" else . end) else . end)" "$cf" > "$cf.tmp" && mv "$cf.tmp" "$cf"
            echo "Masked: $cf" >> $REPORT_FILE
        fi
    fi
done

# 3. Path Replacement
echo "## 3. Path Replacement" >> $REPORT_FILE
REPS_COUNT=$(jq '.placeholder_scrub.replacements | length' "$CONFIG_FILE")
for ((i=0; i<$REPS_COUNT; i++)); do
    S=$(jq -r ".placeholder_scrub.replacements[$i].search" "$CONFIG_FILE")
    R=$(jq -r ".placeholder_scrub.replacements[$i].replace" "$CONFIG_FILE")
    echo "Replacing $S -> $R"
    if [ "$DRY_RUN" = true ]; then
        echo "DRY-RUN: Would replace $S with $R in text files" >> $REPORT_FILE
    else
        # Search and replace in all .md and .json files
        # Fixed: use sed -i '' on macOS, but wait, this script might run on Linux too. 
        # Using a safer approach: check if macOS sed
        if sed --version 2>/dev/null | grep -q GNU; then
            find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.sh" \) -not -path "./$REPORT_FILE" -not -path "./$CONFIG_FILE" -exec sed -i "s|$S|$R|g" {} + 2>/dev/null
        else
            find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.sh" \) -not -path "./$REPORT_FILE" -not -path "./$CONFIG_FILE" -exec sed -i '' "s|$S|$R|g" {} + 2>/dev/null
        fi
        echo "Replaced $S with $R" >> $REPORT_FILE
    fi
done

# 4. Bootstrap Logic
if [ "$BOOTSTRAP_MODE" = true ]; then
    echo "## 4. Bootstrap Generation" >> $REPORT_FILE
    if [ ! -f "BOOTSTRAP.md" ]; then
        if [ -f "$TEMPLATE_FILE" ]; then
            if [ "$DRY_RUN" = true ]; then
                echo "DRY-RUN: Would copy $TEMPLATE_FILE to BOOTSTRAP.md" >> $REPORT_FILE
            else
                cp "$TEMPLATE_FILE" "BOOTSTRAP.md"
                echo "Generated BOOTSTRAP.md from template." | tee -a $REPORT_FILE
            fi
        else
            echo "Warning: Template $TEMPLATE_FILE not found. Creating a generic one." >> $REPORT_FILE
            echo "# BOOTSTRAP.md" > BOOTSTRAP.md
        fi
    else
        echo "BOOTSTRAP.md already exists, skipping." >> $REPORT_FILE
    fi
fi

echo "Scrub process complete." | tee -a $REPORT_FILE
