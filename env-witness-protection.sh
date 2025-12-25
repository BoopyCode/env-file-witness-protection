#!/bin/bash
# .env Witness Protection Program
# Because your secrets deserve a second chance at life

# Colors for dramatic effect (like witness protection should have)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color (like a safe house)

# The safe house for .env files
SAFE_HOUSE="${HOME}/.env_witness_protection"

# Create safe house if it doesn't exist (witnesses need shelter)
mkdir -p "$SAFE_HOUSE"

# Function to extract a .env file from Git's clutches
extract_env() {
    local env_file="${1:-.env}"
    
    # Check if file exists (can't protect what doesn't exist)
    if [[ ! -f "$env_file" ]]; then
        echo -e "${RED}ERROR:${NC} Witness '$env_file' not found. Did they already flee?"
        return 1
    fi
    
    # Generate witness's new identity (timestamp + random)
    local new_identity="env_$(date +%s)_${RANDOM}.safe"
    local safe_path="${SAFE_HOUSE}/${new_identity}"
    
    # Move witness to safe house
    mv "$env_file" "$safe_path"
    
    # Remove from git (erase all evidence)
    git rm --cached "$env_file" 2>/dev/null
    
    # Create new .env.example with same structure but fake data
    echo -e "${YELLOW}Creating decoy...${NC}"
    sed 's/=.*/=YOUR_SECRET_HERE/' "$safe_path" > "$env_file.example"
    
    echo -e "${GREEN}SUCCESS:${NC} Witness '$env_file' is now safe at '$safe_path'"
    echo -e "  Decoy file created: $env_file.example (for the bad guys to find)"
    echo -e "  Don't forget to add ${YELLOW}$env_file${NC} to your ${YELLOW}.gitignore${NC}!"
}

# Function to check if any .env files are trying to escape
detect_fugitives() {
    echo -e "${YELLOW}Scanning for fugitive .env files...${NC}"
    
    # Check git status for any .env files trying to escape
    if git status 2>/dev/null | grep -q '\.env'; then
        echo -e "${RED}ALERT:${NC} Fugitive .env files detected in staging area!"
        git status | grep '\.env'
        echo -e "\nRun: ${GREEN}./env-witness-protection.sh protect${NC} to extract them"
        return 1
    fi
    
    # Check for any .env files not in .gitignore
    if [[ -f ".env" ]] && ! grep -q "^\.env$" .gitignore 2>/dev/null; then
        echo -e "${YELLOW}WARNING:${NC} .env file exists but isn't in .gitignore"
        echo -e "  Your secrets are living dangerously!"
        return 2
    fi
    
    echo -e "${GREEN}All clear:${NC} No fugitive .env files detected"
    return 0
}

# Main witness protection logic
case "${1}" in
    "protect"|"extract")
        extract_env "${2:-.env}"
        ;;
    "detect"|"scan")
        detect_fugitives
        ;;
    "safehouse")
        echo -e "Safe house location: ${YELLOW}${SAFE_HOUSE}${NC}"
        echo "Protected witnesses:"
        ls -la "$SAFE_HOUSE" 2>/dev/null || echo "  (No witnesses yet - it's a quiet safe house)"
        ;;
    *)
        echo -e "${YELLOW}.env Witness Protection Program${NC}"
        echo "Usage:"
        echo "  $0 protect [env-file]  - Extract .env to safe house"
        echo "  $0 detect             - Scan for fugitive .env files"
        echo "  $0 safehouse          - Show protected witnesses"
        echo -e "\n${YELLOW}Remember:${NC} A committed secret is a dead secret"
        ;;
esac
