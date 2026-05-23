#!/bin/bash

# ============================================
# Advanced Bug Bounty Reconnaissance Script
# Created by: Yeghaneh
# Universal - Works for any target domain
# ============================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration - MODIFY THIS FOR YOUR TARGET
TARGET=${1:-"example.com"}  # Pass target as argument: ./script.sh target.com
WORK_DIR="$HOME/bugbounty_${TARGET//./_}"
LOG_FILE="$WORK_DIR/recon_$(date +%Y%m%d_%H%M%S).log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
THREADS=10
RATE_LIMIT_DELAY=0.5

# Create working directory
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Function to log messages
log_message() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to show banner
show_banner() {
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║     ██╗   ██╗███████╗ ██████╗ ██╗  ██╗ █████╗ ███╗   ██╗███████╗║
║     ╚██╗ ██╔╝██╔════╝██╔════╝ ██║  ██║██╔══██╗████╗  ██║██╔════╝║
║      ╚████╔╝ █████╗  ██║  ███╗███████║███████║██╔██╗ ██║█████╗  ║
║       ╚██╔╝  ██╔══╝  ██║   ██║██╔══██║██╔══██║██║╚██╗██║██╔══╝  ║
║        ██║   ███████╗╚██████╔╝██║  ██║██║  ██║██║ ╚████║███████╗║
║        ╚═╝   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝║
║                                                               ║
║         Advanced Bug Bounty Reconnaissance Tool              ║
║                    Created by: Yeghaneh                       ║
╚═══════════════════════════════════════════════════════════════╝
EOF
}

# Function to install Go if not present
install_go() {
    log_message "${BLUE}[*] Checking Go installation...${NC}"
    if ! command_exists go; then
        log_message "${YELLOW}[!] Go not found. Installing Go...${NC}"
        wget -q https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
        sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
        source ~/.bashrc
        export PATH=$PATH:/usr/local/go/bin
        export PATH=$PATH:$(go env GOPATH)/bin
        rm go1.21.5.linux-amd64.tar.gz
        log_message "${GREEN}[+] Go installed successfully${NC}"
    else
        log_message "${GREEN}[+] Go is already installed${NC}"
    fi
}

# Function to install basic tools
install_basic_tools() {
    log_message "${BLUE}[*] Installing basic tools...${NC}"
    sudo apt update -qq
    sudo apt install -y -qq curl wget git jq nmap dnsutils python3 python3-pip unzip masscan chromium-browser
    log_message "${GREEN}[+] Basic tools installed${NC}"
}

# Function to install Python tools
install_python_tools() {
    log_message "${BLUE}[*] Installing Python tools...${NC}"
    pip3 install --user dirsearch arjun dnspython requests shodan waybackpy metabeef
    export PATH="$HOME/.local/bin:$PATH"
    log_message "${GREEN}[+] Python tools installed${NC}"
}

# Function to install Go tools
install_go_tools() {
    log_message "${BLUE}[*] Installing Go tools (this may take a few minutes)...${NC}"
    
    mkdir -p ~/go/bin
    
    # ProjectDiscovery tools
    log_message "${YELLOW}[>] Installing subfinder...${NC}"
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    
    log_message "${YELLOW}[>] Installing httpx...${NC}"
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
    
    log_message "${YELLOW}[>] Installing nuclei...${NC}"
    go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
    
    log_message "${YELLOW}[>] Installing naabu...${NC}"
    go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
    
    log_message "${YELLOW}[>] Installing dnsx...${NC}"
    go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
    
    log_message "${YELLOW}[>] Installing chaos...${NC}"
    go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest
    
    # TomNomNom tools
    log_message "${YELLOW}[>] Installing waybackurls...${NC}"
    go install github.com/tomnomnom/waybackurls@latest
    
    log_message "${YELLOW}[>] Installing gau...${NC}"
    go install github.com/lc/gau/v2/cmd/gau@latest
    
    log_message "${YELLOW}[>] Installing ffuf...${NC}"
    go install github.com/ffuf/ffuf@latest
    
    log_message "${YELLOW}[>] Installing assetfinder...${NC}"
    go install github.com/tomnomnom/assetfinder@latest
    
    log_message "${YELLOW}[>] Installing gf...${NC}"
    go install github.com/tomnomnom/gf@latest
    
    log_message "${YELLOW}[>] Installing anew...${NC}"
    go install github.com/tomnomnom/anew@latest
    
    log_message "${YELLOW}[>] Installing qsreplace...${NC}"
    go install github.com/tomnomnom/qsreplace@latest
    
    log_message "${YELLOW}[>] Installing unfurl...${NC}"
    go install github.com/tomnomnom/unfurl@latest
    
    log_message "${YELLOW}[>] Installing meg...${NC}"
    go install github.com/tomnomnom/meg@latest
    
    # Other useful tools
    log_message "${YELLOW}[>] Installing httprobe...${NC}"
    go install github.com/tomnomnom/httprobe@latest
    
    log_message "${YELLOW}[>] Installing kxss...${NC}"
    go install github.com/tomnomnom/kxss@latest
    
    log_message "${YELLOW}[>] Installing github-subdomains...${NC}"
    go install github.com/gwen001/github-subdomains@latest
    
    log_message "${YELLOW}[>] Installing getJS...${NC}"
    go install github.com/003random/getJS@latest
    
    log_message "${YELLOW}[>] Installing linkfinder...${NC}"
    go install github.com/tomnomnom/linkfinder@latest
    
    log_message "${GREEN}[+] Go tools installed${NC}"
}

# Function to download comprehensive wordlists
download_wordlists() {
    log_message "${BLUE}[*] Downloading comprehensive wordlists...${NC}"
    
    mkdir -p "$WORK_DIR/wordlists"
    cd "$WORK_DIR/wordlists"
    
    # SecLists - Common paths
    if [ ! -f "common.txt" ]; then
        wget -q https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt
    fi
    
    if [ ! -f "directory-list-2.3-medium.txt" ]; then
        wget -q https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/directory-list-2.3-medium.txt
    fi
    
    if [ ! -f "subdomains-top1million-5000.txt" ]; then
        wget -q https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt
    fi
    
    # API paths
    if [ ! -f "api-words.txt" ]; then
        wget -q https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/api-words.txt
    fi
    
    # Parameters
    if [ ! -f "params.txt" ]; then
        wget -q https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/burp-parameter-names.txt
    fi
    
    # Backup extensions
    if [ ! -f "backups.txt" ]; then
        cat > backups.txt << 'EOF'
.bak
.old
.backup
.tar
.tar.gz
.zip
.7z
.rar
.sql
.dump
.db
.conf
.config
.ini
.env
.git
.svn
.hg
EOF
    fi
    
    cd "$WORK_DIR"
    log_message "${GREEN}[+] Wordlists downloaded${NC}"
}

# UNIQUE FEATURE 1: Cloud Provider Detection
detect_cloud_providers() {
    log_message "${BLUE}[*] Detecting cloud providers...${NC}"
    
    > "cloud_detection.txt"
    
    # Check AWS
    curl -s "https://$TARGET" | grep -i "aws\|amazon\|s3.amazonaws\|cloudfront\|elb" >> "cloud_detection.txt"
    dig +short "$TARGET" | grep "amazonaws.com" >> "cloud_detection.txt"
    
    # Check Google Cloud
    curl -s "https://$TARGET" | grep -i "googleusercontent\|appspot\|cloud.google" >> "cloud_detection.txt"
    
    # Check Azure
    curl -s "https://$TARGET" | grep -i "azurewebsites\|cloudapp.azure\|windows.net" >> "cloud_detection.txt"
    
    # Check Cloudflare
    curl -s -I "https://$TARGET" | grep -i "cloudflare" >> "cloud_detection.txt"
    
    log_message "${GREEN}[+] Cloud provider detection completed${NC}"
}

# UNIQUE FEATURE 2: Technology Stack Detection
detect_tech_stack() {
    log_message "${BLUE}[*] Detecting technology stack...${NC}"
    
    > "tech_stack.txt"
    
    echo "=== Technology Stack for $TARGET ===" >> "tech_stack.txt"
    echo "" >> "tech_stack.txt"
    
    # Check HTTP headers
    echo "--- HTTP Headers ---" >> "tech_stack.txt"
    curl -s -I "https://$TARGET" >> "tech_stack.txt"
    
    # Detect server
    echo "" >> "tech_stack.txt"
    echo "--- Server Detection ---" >> "tech_stack.txt"
    curl -s -I "https://$TARGET" | grep -i "server:" >> "tech_stack.txt"
    
    # Detect frameworks
    echo "" >> "tech_stack.txt"
    echo "--- Framework Detection ---" >> "tech_stack.txt"
    curl -s "https://$TARGET" | grep -i "wp-content\|wordpress" && echo "WordPress detected" >> "tech_stack.txt"
    curl -s "https://$TARGET" | grep -i "laravel\|csrf-token" && echo "Laravel detected" >> "tech_stack.txt"
    curl -s "https://$TARGET" | grep -i "django" && echo "Django detected" >> "tech_stack.txt"
    curl -s "https://$TARGET" | grep -i "rails" && echo "Ruby on Rails detected" >> "tech_stack.txt"
    curl -s "https://$TARGET" | grep -i "react" && echo "React detected" >> "tech_stack.txt"
    curl -s "https://$TARGET" | grep -i "angular" && echo "Angular detected" >> "tech_stack.txt"
    curl -s "https://$TARGET" | grep -i "vue" && echo "Vue.js detected" >> "tech_stack.txt"
    
    log_message "${GREEN}[+] Technology stack detection completed${NC}"
}

# UNIQUE FEATURE 3: Parameter Discovery with Value Detection
discover_parameters() {
    log_message "${BLUE}[*] Discovering parameters with value detection...${NC}"
    
    > "parameters_with_values.txt"
    > "unique_parameters.txt"
    
    # Common parameters to test
    COMMON_PARAMS=(
        "id" "user" "user_id" "uid" "uuid" "token" "key" "api_key"
        "page" "offset" "limit" "sort" "order" "filter" "search" "q"
        "redirect" "url" "next" "return" "callback" "jsonp" "callback"
        "file" "path" "dir" "folder" "document" "download" "upload"
        "email" "username" "password" "pass" "pwd" "auth" "login"
        "debug" "test" "admin" "config" "settings" "option"
        "cmd" "exec" "command" "run" "execute" "system" "shell"
    )
    
    for param in "${COMMON_PARAMS[@]}"; do
        echo "$param" >> "unique_parameters.txt"
    done
    
    # Test each parameter with a sample value
    for host in $(cat live_hosts.txt 2>/dev/null | head -5); do
        for param in "${COMMON_PARAMS[@]}"; do
            test_url="$host?$param=test123"
            status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$test_url")
            if [[ "$status" == "200" ]]; then
                echo "$test_url [$status]" >> "parameters_with_values.txt"
                log_message "${GREEN}[+] Parameter active: $param on $host${NC}"
            fi
        done
    done
    
    log_message "${GREEN}[+] Parameter discovery completed${NC}"
}

# UNIQUE FEATURE 4: Wayback Machine Historical Analysis
wayback_analysis() {
    log_message "${BLUE}[*] Analyzing Wayback Machine historical data...${NC}"
    
    > "wayback_urls.txt"
    > "wayback_old_urls.txt"
    
    # Get URLs from Wayback Machine
    curl -s "http://web.archive.org/cdx/search/cdx?url=*.$TARGET/*&output=json&collapse=urlkey&fl=original" | jq -r '.[1:][] | .[0]' 2>/dev/null >> "wayback_urls.txt"
    
    # Filter old URLs (older than 1 year)
    current_year=$(date +%Y)
    old_year=$((current_year - 1))
    curl -s "http://web.archive.org/cdx/search/cdx?url=*.$TARGET/*&output=json&filter=timestamp:${old_year}..." | jq -r '.[1:][] | .[0]' 2>/dev/null >> "wayback_old_urls.txt"
    
    # Extract interesting patterns from old URLs
    cat "wayback_urls.txt" | grep -E "\.(sql|bak|old|backup|conf|config|ini|env|log|txt|json|xml)$" > "wayback_sensitive.txt"
    
    log_message "${GREEN}[+] Wayback analysis completed - Found $(wc -l < wayback_urls.txt 2>/dev/null) historical URLs${NC}"
}

# UNIQUE FEATURE 5: Email and Employee Discovery
discover_emails() {
    log_message "${BLUE}[*] Discovering email addresses...${NC}"
    
    > "emails_found.txt"
    
    # Extract from certificates
    curl -s "https://crt.sh/?q=%25.$TARGET&output=json" | jq -r '.[].name_value' 2>/dev/null | grep "@" >> "emails_found.txt"
    
    # Extract from web pages (limited to avoid aggressive crawling)
    for host in $(cat live_hosts.txt 2>/dev/null | head -3); do
        curl -s "https://$host" | grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b" >> "emails_found.txt"
    done
    
    # Try to find common employee email patterns
    echo "admin@$TARGET" >> "emails_found.txt"
    echo "webmaster@$TARGET" >> "emails_found.txt"
    echo "postmaster@$TARGET" >> "emails_found.txt"
    echo "support@$TARGET" >> "emails_found.txt"
    echo "contact@$TARGET" >> "emails_found.txt"
    echo "info@$TARGET" >> "emails_found.txt"
    echo "security@$TARGET" >> "emails_found.txt"
    echo "abuse@$TARGET" >> "emails_found.txt"
    
    sort -u "emails_found.txt" -o "emails_found.txt"
    log_message "${GREEN}[+] Found $(wc -l < emails_found.txt) email addresses${NC}"
}

# UNIQUE FEATURE 6: Subdomain Takeover Check
check_subdomain_takeover() {
    log_message "${BLUE}[*] Checking for potential subdomain takeovers...${NC}"
    
    > "takeover_candidates.txt"
    
    # Common takeover patterns
    while read host; do
        if [[ -n "$host" ]]; then
            # Check for dangling CNAME records
            cname=$(dig +short "$host" | head -1)
            if [[ "$cname" == *"amazonaws"* ]] || [[ "$cname" == *"github"* ]] || [[ "$cname" == *"heroku"* ]] || [[ "$cname" == *"azure"* ]]; then
                # Check if the CNAME resolves
                if ! dig +short "$cname" | grep -q .; then
                    echo "$host -> $cname (Potential takeover!)" >> "takeover_candidates.txt"
                    log_message "${RED}[!] Potential takeover: $host -> $cname${NC}"
                fi
            fi
            
            # Check for 404 responses
            status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "https://$host")
            if [[ "$status" == "404" ]]; then
                echo "$host - 404 Not Found (Possible takeover)" >> "takeover_candidates.txt"
            fi
        fi
    done < "subdomains_resolved.txt"
    
    log_message "${GREEN}[+] Subdomain takeover check completed${NC}"
}

# UNIQUE FEATURE 7: CORS Misconfiguration Scanner
scan_cors_misconfig() {
    log_message "${BLUE}[*] Scanning for CORS misconfigurations...${NC}"
    
    > "cors_vulnerable.txt"
    
    for host in $(cat live_hosts.txt 2>/dev/null | head -10); do
        # Test with arbitrary origin
        response=$(curl -s -I -H "Origin: https://evil-$RANDOM.com" "$host")
        if echo "$response" | grep -q "Access-Control-Allow-Origin: https://evil-"; then
            echo "$host - Reflects arbitrary origin!" >> "cors_vulnerable.txt"
            log_message "${RED}[!] CORS misconfiguration on $host${NC}"
        elif echo "$response" | grep -q "Access-Control-Allow-Origin: null"; then
            echo "$host - Allows null origin!" >> "cors_vulnerable.txt"
            log_message "${YELLOW}[!] Null origin allowed on $host${NC}"
        elif echo "$response" | grep -q "Access-Control-Allow-Origin: \*"; then
            echo "$host - Allows wildcard origin!" >> "cors_vulnerable.txt"
            log_message "${YELLOW}[!] Wildcard origin on $host${NC}"
        fi
    done
    
    log_message "${GREEN}[+] CORS scanning completed${NC}"
}

# UNIQUE FEATURE 8: Open Redirect Finder
find_open_redirects() {
    log_message "${BLUE}[*] Hunting for open redirects...${NC}"
    
    > "open_redirects.txt"
    
    REDIRECT_PAYLOADS=(
        "https://evil.com"
        "//evil.com"
        "///evil.com"
        "https:evil.com"
        "https://evil.com/@$TARGET"
        "evil.com"
        "%68%74%74%70%73%3A%2F%2F%65%76%69%6C%2E%63%6F%6D"
    )
    
    for host in $(cat live_hosts.txt 2>/dev/null); do
        for param in "url" "redirect" "next" "return" "goto" "out" "view" "dir" "show" "page" "return_to"; do
            for payload in "${REDIRECT_PAYLOADS[@]}"; do
                test_url="$host?$param=$payload"
                location=$(curl -s -I "$test_url" | grep -i "location:" | head -1)
                if echo "$location" | grep -qi "evil.com"; then
                    echo "$test_url" >> "open_redirects.txt"
                    log_message "${RED}[!] Open redirect found: $test_url${NC}"
                fi
            done
        done
    done
    
    log_message "${GREEN}[+] Open redirect scanning completed${NC}"
}

# UNIQUE FEATURE 9: Security Headers Analyzer with Score
analyze_security_headers() {
    log_message "${BLUE}[*] Analyzing security headers with scoring...${NC}"
    
    > "security_headers_score.txt"
    
    echo "# Security Headers Analysis for $TARGET" >> "security_headers_score.txt"
    echo "Generated: $(date)" >> "security_headers_score.txt"
    echo "" >> "security_headers_score.txt"
    
    for host in $(cat live_hosts.txt 2>/dev/null); do
        echo "## Host: $host" >> "security_headers_score.txt"
        headers=$(curl -s -I "https://$host" 2>/dev/null)
        
        score=0
        total=12
        
        # Check each security header
        echo "$headers" | grep -qi "Strict-Transport-Security" && { echo "✅ HSTS Present" >> "security_headers_score.txt"; score=$((score+1)); } || echo "❌ HSTS Missing" >> "security_headers_score.txt"
        
        echo "$headers" | grep -qi "Content-Security-Policy" && { echo "✅ CSP Present" >> "security_headers_score.txt"; score=$((score+1)); } || echo "❌ CSP Missing" >> "security_headers_score.txt"
        
        echo "$headers" | grep -qi "X-Frame-Options" && { echo "✅ X-Frame-Options Present" >> "security_headers_score.txt"; score=$((score+1)); } || echo "❌ X-Frame-Options Missing" >> "security_headers_score.txt"
        
        echo "$headers" | grep -qi "X-Content-Type-Options" && { echo "✅ X-Content-Type-Options Present" >> "security_headers_score.txt"; score=$((score+1)); } || echo "❌ X-Content-Type-Options Missing" >> "security_headers_score.txt"
        
        echo "$headers" | grep -qi "X-XSS-Protection" && { echo "✅ X-XSS-Protection Present" >> "security_headers_score.txt"; score=$((score+1)); } || echo "❌ X-XSS-Protection Missing" >> "security_headers_score.txt"
        
        echo "$headers" | grep -qi "Referrer-Policy" && { echo "✅ Referrer-Policy Present" >> "security_headers_score.txt"; score=$((score+1)); } || echo "❌ Referrer-Policy Missing" >> "security_headers_score.txt"
        
        echo "$headers" | grep -qi "Permissions-Policy" && { echo "✅ Permissions-Policy Present" >> "security_headers_score.txt"; score=$((score+1)); } || echo "❌ Permissions-Policy Missing" >> "security_headers_score.txt"
        
        echo "" >> "security_headers_score.txt"
        percentage=$((score * 100 / total))
        echo "**Score: $score/$total ($percentage%)**" >> "security_headers_score.txt"
        echo "" >> "security_headers_score.txt"
        
        if [ $percentage -lt 50 ]; then
            log_message "${RED}[!] Poor security headers on $host ($percentage%)${NC}"
        elif [ $percentage -lt 80 ]; then
            log_message "${YELLOW}[!] Average security headers on $host ($percentage%)${NC}"
        else
            log_message "${GREEN}[+] Good security headers on $host ($percentage%)${NC}"
        fi
    done
    
    log_message "${GREEN}[+] Security headers analysis completed${NC}"
}

# UNIQUE FEATURE 10: Backup File Discovery
find_backup_files() {
    log_message "${BLUE}[*] Searching for backup and sensitive files...${NC}"
    
    > "backup_files.txt"
    
    BACKUP_EXTENSIONS=(
        ".bak" ".old" ".backup" ".orig" ".save" ".tmp"
        ".sql" ".dump" ".db" ".sqlite" ".mysql"
        ".tar" ".tar.gz" ".tgz" ".zip" ".7z" ".rar"
        ".conf" ".config" ".ini" ".cnf" ".cfg"
        ".env" ".env.prod" ".env.local"
        ".log" ".logs" ".debug" ".error"
        ".pem" ".key" ".crt" ".p12" ".pfx"
        ".csv" ".xls" ".xlsx" ".pdf" ".doc" ".docx"
    )
    
    BACKUP_NAMES=(
        "backup" "old" "orig" "save" "temp" "tmp"
        "database" "db" "sql" "dump"
        "config" "configuration" "settings" "setup"
        "wp-config" "wp-config-backup"
        ".git" ".svn" ".hg" ".idea"
        "robots.txt" "sitemap.xml" "crossdomain.xml"
        "phpinfo.php" "info.php" "test.php" "debug.php"
    )
    
    for host in $(cat live_hosts.txt 2>/dev/null); do
        # Test extensions
        for ext in "${BACKUP_EXTENSIONS[@]}"; do
            for name in "${BACKUP_NAMES[@]}"; do
                url="$host/$name$ext"
                status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$url")
                if [[ "$status" == "200" ]] || [[ "$status" == "301" ]] || [[ "$status" == "302" ]]; then
                    echo "$url [$status]" >> "backup_files.txt"
                    log_message "${RED}[!] Backup file found: $url ($status)${NC}"
                    
                    # Try to get size (don't download full file)
                    size=$(curl -s -I "$url" | grep -i "content-length" | awk '{print $2}')
                    if [[ -n "$size" ]]; then
                        echo "  Size: $size bytes" >> "backup_files.txt"
                    fi
                fi
            done
        done
        
        # Also test common backup directories
        BACKUP_DIRS=("/backup" "/backups" "/old" "/temp" "/tmp" "/bak" "/saved" "/archives")
        for dir in "${BACKUP_DIRS[@]}"; do
            url="$host$dir"
            status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$url")
            if [[ "$status" == "200" ]] || [[ "$status" == "301" ]] || [[ "$status" == "302" ]]; then
                echo "$url/ [$status] (Directory listing?)" >> "backup_files.txt"
                log_message "${YELLOW}[!] Backup directory found: $url/ ($status)${NC}"
            fi
        done
    done
    
    log_message "${GREEN}[+] Backup file search completed${NC}"
}

# UNIQUE FEATURE 11: API Endpoint Discovery with Version Detection
discover_api_endpoints() {
    log_message "${BLUE}[*] Discovering API endpoints...${NC}"
    
    > "api_endpoints.txt"
    
    API_PATTERNS=(
        "/api" "/v1" "/v2" "/v3" "/v4" "/api/v1" "/api/v2" "/api/v3"
        "/rest" "/restapi" "/graphql" "/gql" "/query" "/graphiql"
        "/swagger" "/swagger.json" "/swagger.yaml" "/api-docs" "/docs"
        "/openapi" "/openapi.json" "/openapi.yaml" "/spec" "/spec.json"
        "/postman" "/collection" "/api/explorer" "/api/console"
        "/admin/api" "/internal/api" "/private/api" "/public/api"
        "/user/api" "/account/api" "/payment/api" "/order/api"
        "/webservice" "/service" "/soap" "/xmlrpc" "/rpc"
    )
    
    for host in $(cat live_hosts.txt 2>/dev/null); do
        for pattern in "${API_PATTERNS[@]}"; do
            url="$host$pattern"
            status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$url")
            if [[ "$status" == "200" ]] || [[ "$status" == "301" ]] || [[ "$status" == "302" ]] || [[ "$status" == "401" ]] || [[ "$status" == "403" ]]; then
                echo "$url [$status]" >> "api_endpoints.txt"
                
                # Try to detect API type
                content=$(curl -s "$url" --max-time 3 | head -c 500)
                if echo "$content" | grep -qi "graphql"; then
                    echo "  → GraphQL API detected" >> "api_endpoints.txt"
                    log_message "${PURPLE}[+] GraphQL API: $url${NC}"
                elif echo "$content" | grep -qi "swagger"; then
                    echo "  → Swagger/OpenAPI detected" >> "api_endpoints.txt"
                    log_message "${PURPLE}[+] Swagger API: $url${NC}"
                elif echo "$content" | grep -qi "json"; then
                    echo "  → JSON API detected" >> "api_endpoints.txt"
                    log_message "${PURPLE}[+] JSON API: $url${NC}"
                else
                    log_message "${CYAN}[+] API endpoint: $url ($status)${NC}"
                fi
            fi
        done
    done
    
    log_message "${GREEN}[+] API endpoint discovery completed${NC}"
}

# UNIQUE FEATURE 12: Directory Listing Vulnerability Scanner
scan_directory_listing() {
    log_message "${BLUE}[*] Scanning for directory listing vulnerabilities...${NC}"
    
    > "directory_listing.txt"
    
    # Test directories that might have listing enabled
    LISTING_DIRS=(
        "/images" "/img" "/pics" "/photos"
        "/files" "/uploads" "/downloads" "/media"
        "/css" "/js" "/javascript" "/scripts"
        "/backup" "/backups" "/old" "/temp" "/tmp"
        "/logs" "/debug" "/trace" "/stats"
        "/admin" "/administrator" "/manage" "/control"
        "/assets" "/static" "/public" "/storage"
        "/doc" "/docs" "/documentation" "/help"
        "/wp-content" "/wp-includes" "/wp-admin"
        ".git" ".svn" ".hg" ".idea"
    )
    
    for host in $(cat live_hosts.txt 2>/dev/null); do
        for dir in "${LISTING_DIRS[@]}"; do
            url="$host$dir/"
            response=$(curl -s "$url" --max-time 5)
            
            # Check for directory listing indicators
            if echo "$response" | grep -qi "index of\|parent directory\|directory listing\|<title>Index of\|\[DIR\]"; then
                echo "$url" >> "directory_listing.txt"
                log_message "${RED}[!] Directory listing exposed: $url${NC}"
                
                # Count files listed
                file_count=$(echo "$response" | grep -c "href=")
                echo "  → $file_count files/directories exposed" >> "directory_listing.txt"
            fi
        done
    done
    
    log_message "${GREEN}[+] Directory listing scan completed${NC}"
}

# UNIQUE FEATURE 13: Information Disclosure via Error Messages
capture_error_messages() {
    log_message "${BLUE}[*] Capturing error messages for information disclosure...${NC}"
    
    > "error_messages.txt"
    
    ERROR_PAYLOADS=(
        "'" '"' "\\" "*/" "--" "#" ";" "|" "&" "$("
        "%27" "%22" "%5c" "%2f%2e%2e%2f" "%00" "%0a%0d"
        "../../../etc/passwd" "..\\..\\..\\windows\\win.ini"
        "<?php" "<script>" "{{7*7}}" "${7*7}"
        "NaN" "undefined" "null" "true" "false"
    )
    
    for host in $(cat live_hosts.txt 2>/dev/null | head -5); do
        for param in "id" "q" "search" "page" "user" "file" "path" "url"; do
            for payload in "${ERROR_PAYLOADS[@]}"; do
                url="$host?$param=$payload"
                response=$(curl -s "$url" --max-time 5)
                
                # Check for error patterns
                if echo "$response" | grep -qi "sql\|mysql\|postgresql\|oracle\|mssql\|database error"; then
                    echo "=== SQL Error at $url ===" >> "error_messages.txt"
                    echo "$response" | grep -i "error\|warning\|notice\|fatal" | head -5 >> "error_messages.txt"
                    echo "" >> "error_messages.txt"
                    log_message "${RED}[!] SQL error disclosure: $url${NC}"
                fi
                
                if echo "$response" | grep -qi "stack trace\|exception\|fatal error\|uncaught"; then
                    echo "=== Stack Trace at $url ===" >> "error_messages.txt"
                    echo "$response" | grep -i "exception\|trace\|error" | head -5 >> "error_messages.txt"
                    echo "" >> "error_messages.txt"
                    log_message "${YELLOW}[!] Stack trace disclosure: $url${NC}"
                fi
                
                if echo "$response" | grep -qi "path.*\/var\/www\|C:\\\|D:\\\|\/home\/"; then
                    echo "=== Path Disclosure at $url ===" >> "error_messages.txt"
                    echo "$response" | grep -E "\/var\/|\/home\/|C:\\|D:\\" | head -3 >> "error_messages.txt"
                    echo "" >> "error_messages.txt"
                    log_message "${YELLOW}[!] Path disclosure: $url${NC}"
                fi
            done
        done
    done
    
    log_message "${GREEN}[+] Error message capture completed${NC}"
}

# UNIQUE FEATURE 14: SSL/TLS Security Assessment
ssl_security_assessment() {
    log_message "${BLUE}[*] Performing SSL/TLS security assessment...${NC}"
    
    > "ssl_security.txt"
    
    echo "# SSL/TLS Security Assessment for $TARGET" >> "ssl_security.txt"
    echo "Generated: $(date)" >> "ssl_security.txt"
    echo "" >> "ssl_security.txt"
    
    # Check SSL certificate details
    echo "--- Certificate Details ---" >> "ssl_security.txt"
    echo | openssl s_client -servername "$TARGET" -connect "$TARGET":443 2>/dev/null | openssl x509 -text | grep -E "Subject:|Issuer:|Not Before|Not After" >> "ssl_security.txt"
    
    # Check protocols
    echo "" >> "ssl_security.txt"
    echo "--- Protocol Support ---" >> "ssl_security.txt"
    
    # Test TLS versions
    for version in "tls1" "tls1_1" "tls1_2" "tls1_3"; do
        if echo | openssl s_client -servername "$TARGET" -connect "$TARGET":443 -$version 2>/dev/null | grep -q "CONNECTED"; then
            echo "✅ $version: Supported" >> "ssl_security.txt"
        else
            echo "❌ $version: Not supported" >> "ssl_security.txt"
        fi
    done
    
    # Check for weak ciphers
    echo "" >> "ssl_security.txt"
    echo "--- Weak Cipher Check ---" >> "ssl_security.txt"
    weak_ciphers=$(echo | openssl s_client -servername "$TARGET" -connect "$TARGET":443 -cipher 'EXP:NULL:RC4:MD5' 2>/dev/null | grep -c "Cipher")
    if [ "$weak_ciphers" -gt 0 ]; then
        echo "⚠️ Weak ciphers detected!" >> "ssl_security.txt"
        log_message "${RED}[!] Weak SSL ciphers detected on $TARGET${NC}"
    else
        echo "✅ No weak ciphers detected" >> "ssl_security.txt"
    fi
    
    log_message "${GREEN}[+] SSL/TLS assessment completed${NC}"
}

# UNIQUE FEATURE 15: GraphQL Introspection Check
check_graphql_introspection() {
    log_message "${BLUE}[*] Checking for GraphQL introspection...${NC}"
    
    > "graphql_introspection.txt"
    
    # GraphQL introspection query
    INTROSPECTION_QUERY='{"query":"query { __schema { types { name fields { name } } } }"}'
    
    for host in $(cat api_endpoints.txt 2>/dev/null | grep -i graphql | cut -d' ' -f1); do
        response=$(curl -s -X POST "$host" -H "Content-Type: application/json" -d "$INTROSPECTION_QUERY" --max-time 5)
        
        if echo "$response" | grep -q "__schema"; then
            echo "$host - GraphQL introspection enabled!" >> "graphql_introspection.txt"
            log_message "${RED}[!] GraphQL introspection enabled: $host${NC}"
            
            # Save schema for analysis
            echo "$response" > "graphql_schema_$(echo $host | sed 's/[^a-zA-Z0-9]/_/g').json"
        fi
    done
    
    log_message "${GREEN}[+] GraphQL introspection check completed${NC}"
}

# Basic reconnaissance functions (kept from original)
basic_recon() {
    log_message "${BLUE}[*] Starting basic reconnaissance...${NC}"
    
    log_message "${YELLOW}[>] DNS enumeration...${NC}"
    dig +short "$TARGET" > "dns_a_records.txt"
    dig +short "www.$TARGET" >> "dns_a_records.txt"
    nslookup "$TARGET" > "dns_nslookup.txt"
    
    log_message "${YELLOW}[>] WHOIS lookup...${NC}"
    whois "$TARGET" > "whois.txt" 2>/dev/null || echo "WHOIS lookup failed" > "whois.txt"
    
    log_message "${YELLOW}[>] Certificate transparency logs...${NC}"
    curl -s "https://crt.sh/?q=%.$TARGET&output=json" | jq -r '.[].name_value' 2>/dev/null | sort -u > "crt_sh.txt"
    
    log_message "${YELLOW}[>] HTTP headers check...${NC}"
    curl -s -I "https://$TARGET" > "http_headers.txt"
    curl -s -I "http://$TARGET" >> "http_headers.txt"
    
    log_message "${GREEN}[+] Basic recon completed${NC}"
}

find_subdomains_manual() {
    log_message "${BLUE}[*] Finding subdomains...${NC}"
    
    > "subdomains_raw.txt"
    
    # Extended subdomain wordlist
    SUBDOMAINS=(
        "$TARGET" "www.$TARGET" "mail.$TARGET" "api.$TARGET" "admin.$TARGET"
        "test.$TARGET" "dev.$TARGET" "staging.$TARGET" "app.$TARGET" "login.$TARGET"
        "account.$TARGET" "dashboard.$TARGET" "portal.$TARGET" "cdn.$TARGET" "static.$TARGET"
        "assets.$TARGET" "img.$TARGET" "images.$TARGET" "files.$TARGET" "downloads.$TARGET"
        "help.$TARGET" "support.$TARGET" "docs.$TARGET" "wiki.$TARGET" "kb.$TARGET"
        "info.$TARGET" "news.$TARGET" "blog.$TARGET" "status.$TARGET" "monitor.$TARGET"
        "metrics.$TARGET" "analytics.$TARGET" "tracking.$TARGET" "events.$TARGET" "webmail.$TARGET"
        "remote.$TARGET" "vpn.$TARGET" "secure.$TARGET" "auth.$TARGET" "oauth.$TARGET"
        "sso.$TARGET" "id.$TARGET" "identity.$TARGET" "users.$TARGET" "profiles.$TARGET"
        "settings.$TARGET" "preferences.$TARGET" "search.$TARGET" "shop.$TARGET" "store.$TARGET"
        "payment.$TARGET" "checkout.$TARGET" "cart.$TARGET" "order.$TARGET" "invoice.$TARGET"
        "billing.$TARGET" "subscription.$TARGET" "partner.$TARGET" "partners.$TARGET" "affiliate.$TARGET"
        "developer.$TARGET" "developers.$TARGET" "docs.$TARGET" "documentation.$TARGET" "api-docs.$TARGET"
        "swagger.$TARGET" "graphql.$TARGET" "rest.$TARGET" "soap.$TARGET" "xmlrpc.$TARGET"
        "web.$TARGET" "www2.$TARGET" "www3.$TARGET" "m.$TARGET" "mobile.$TARGET"
        "legacy.$TARGET" "old.$TARGET" "new.$TARGET" "beta.$TARGET" "alpha.$TARGET"
        "demo.$TARGET" "sandbox.$TARGET" "playground.$TARGET" "stage.$TARGET" "prod.$TARGET"
        "internal.$TARGET" "private.$TARGET" "corp.$TARGET" "company.$TARGET" "employee.$TARGET"
        "hr.$TARGET" "finance.$TARGET" "legal.$TARGET" "security.$TARGET" "privacy.$TARGET"
        "terms.$TARGET" "cookies.$TARGET" "gdpr.$TARGET" "ccpa.$TARGET" "compliance.$TARGET"
    )
    
    for sub in "${SUBDOMAINS[@]}"; do
        echo "$sub" >> "subdomains_raw.txt"
    done
    
    log_message "${YELLOW}[>] Resolving subdomains...${NC}"
    > "resolved_subdomains.txt"
    
    while read sub; do
        if host "$sub" 2>/dev/null | grep -q "has address"; then
            host "$sub" 2>/dev/null | grep "has address" | tee -a "resolved_subdomains.txt"
        fi
    done < "subdomains_raw.txt"
    
    cat "resolved_subdomains.txt" | awk '{print $1}' | sed 's/.$//' | sort -u > "subdomains_resolved.txt"
    log_message "${GREEN}[+] Found $(wc -l < subdomains_resolved.txt) subdomains${NC}"
}

check_live_hosts() {
    log_message "${BLUE}[*] Checking live hosts...${NC}"
    
    > "live_hosts.txt"
    
    while read host; do
        if [[ -n "$host" ]]; then
            if curl -s -o /dev/null -w "%{http_code}" --max-time 5 "https://$host" | grep -q "200\|301\|302\|401\|403"; then
                echo "https://$host" >> "live_hosts.txt"
                log_message "${GREEN}[+] $host is live (HTTPS)${NC}"
            fi
            
            if curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://$host" | grep -q "200\|301\|302\|401\|403"; then
                echo "http://$host" >> "live_hosts.txt"
                log_message "${GREEN}[+] $host is live (HTTP)${NC}"
            fi
        fi
    done < "subdomains_resolved.txt"
    
    for proto in https http; do
        if curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$proto://$TARGET" | grep -q "200\|301\|302\|401\|403"; then
            echo "$proto://$TARGET" >> "live_hosts.txt"
        fi
    done
    
    sort -u "live_hosts.txt" -o "live_hosts.txt"
    log_message "${GREEN}[+] Found $(wc -l < live_hosts.txt) live hosts${NC}"
}

# Function to generate final comprehensive report
generate_report() {
    log_message "${BLUE}[*] Generating final comprehensive report...${NC}"
    
    REPORT_FILE="recon_report_${TARGET}_$TIMESTAMP.md"
    
    cat > "$REPORT_FILE" << EOF
# Bug Bounty Reconnaissance Report

**Target:** $TARGET  
**Date:** $(date)  
**Reconnaissance Tool Created by:** Yeghaneh  
**Report Generated:** $TIMESTAMP

---

## 📊 Executive Summary

| Category | Count |
|----------|-------|
| Live Hosts Found | $(wc -l < live_hosts.txt 2>/dev/null) |
| Subdomains Resolved | $(wc -l < subdomains_resolved.txt 2>/dev/null) |
| API Endpoints Found | $(wc -l < api_endpoints.txt 2>/dev/null) |
| Backup Files Found | $(wc -l < backup_files.txt 2>/dev/null) |
| Email Addresses Found | $(wc -l < emails_found.txt 2>/dev/null) |
| Open Redirects Found | $(wc -l < open_redirects.txt 2>/dev/null) |
| Directory Listings | $(wc -l < directory_listing.txt 2>/dev/null) |
| Potential Takeovers | $(wc -l < takeover_candidates.txt 2>/dev/null) |

---

## 🎯 Live Hosts

\`\`\`
$(cat live_hosts.txt 2>/dev/null)
\`\`\`

---

## 🔍 Subdomains Found

\`\`\`
$(cat subdomains_resolved.txt 2>/dev/null)
\`\`\`

---

## 🚨 Potential Subdomain Takeovers

\`\`\`
$(cat takeover_candidates.txt 2>/dev/null)
\`\`\`

---

## 🔌 API Endpoints Discovered

\`\`\`
$(cat api_endpoints.txt 2>/dev/null)
\`\`\`

---

## 💾 Backup & Sensitive Files

\`\`\`
$(cat backup_files.txt 2>/dev/null)
\`\`\`

---

## 🎯 Open Redirects

\`\`\`
$(cat open_redirects.txt 2>/dev/null)
\`\`\`

---

## 📂 Directory Listing Vulnerabilities

\`\`\`
$(cat directory_listing.txt 2>/dev/null)
\`\`\`

---

## ☁️ Cloud Provider Detection

\`\`\`
$(cat cloud_detection.txt 2>/dev/null)
\`\`\`

---

## 📧 Email Addresses Discovered

\`\`\`
$(cat emails_found.txt 2>/dev/null)
\`\`\`

---

## 🔐 CORS Misconfigurations

\`\`\`
$(cat cors_vulnerable.txt 2>/dev/null)
\`\`\`

---

## 🌐 Wayback Machine Historical URLs

**Total Historical URLs Found:** $(wc -l < wayback_urls.txt 2>/dev/null)

**Sensitive Historical Files:**
\`\`\`
$(head -20 wayback_sensitive.txt 2>/dev/null)
\`\`\`

---

## 🛡️ Security Headers Analysis

\`\`\`
$(cat security_headers_score.txt 2>/dev/null)
\`\`\`

---

## 🔓 GraphQL Introspection (if enabled)

\`\`\`
$(cat graphql_introspection.txt 2>/dev/null)
\`\`\`

---

## ⚠️ Error Messages & Information Disclosure

\`\`\`
$(head -30 error_messages.txt 2>/dev/null)
\`\`\`

---

## 🔑 Unique Parameters Found

\`\`\`
$(cat unique_parameters.txt 2>/dev/null)
\`\`\`

---

## 🖥️ Technology Stack

\`\`\`
$(cat tech_stack.txt 2>/dev/null)
\`\`\`

---

## 🔒 SSL/TLS Security Assessment

\`\`\`
$(head -30 ssl_security.txt 2>/dev/null)
\`\`\`

---

## 📁 Files Generated During Scan

| File | Description |
|------|-------------|
| live_hosts.txt | Live hosts list |
| subdomains_resolved.txt | All resolved subdomains |
| api_endpoints.txt | API endpoints found |
| backup_files.txt | Backup and sensitive files |
| emails_found.txt | Email addresses |
| open_redirects.txt | Open redirect URLs |
| directory_listing.txt | Directory listing vulns |
| takeover_candidates.txt | Potential subdomain takeovers |
| js_files.txt | JavaScript files |
| js_secrets.txt | Secrets in JavaScript |
| wayback_urls.txt | Historical URLs |
| error_messages.txt | Error messages captured |

---

## 📝 Next Steps for Manual Testing

### High Priority
- [ ] Verify subdomain takeovers manually
- [ ] Test open redirects with real payloads
- [ ] Check exposed backup files for sensitive data
- [ ] Test API endpoints for IDOR vulnerabilities

### Medium Priority
- [ ] Test parameters for injection flaws (SQLi, XSS, SSTI)
- [ ] Check authentication mechanisms
- [ ] Test for CSRF vulnerabilities
- [ ] Review error messages for sensitive data

### Low Priority
- [ ] Review SSL/TLS configuration
- [ ] Check security headers compliance
- [ ] Test rate limiting

---

## 🛠️ Tools Used in This Scan

- dig, nslookup, host (DNS enumeration)
- curl (HTTP requests)
- openssl (SSL/TLS assessment)
- jq (JSON parsing)
- Custom bash scripts by Yeghaneh

---

## ⚠️ Important Legal Notice

**This reconnaissance was performed for authorized testing only.**

- Only test targets you have explicit permission to test
- Stay within defined scope
- Do not access or modify unauthorized data
- Do not perform DoS attacks
- Report findings responsibly through proper channels

---

## 📊 Scan Statistics

- **Scan Duration:** $SECONDS seconds
- **Total Requests Made:** $(grep -c "" live_hosts.txt 2>/dev/null) host checks
- **Script Version:** 2.0
- **Created by:** Yeghaneh

---

*This report was automatically generated. Always manually verify findings before reporting.*
EOF

    log_message "${GREEN}[+] Report generated: $REPORT_FILE${NC}"
}

# Function to show summary
show_summary() {
    log_message ""
    log_message "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    log_message "${GREEN}║              SCAN COMPLETED SUCCESSFULLY                      ║${NC}"
    log_message "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    log_message ""
    log_message "${GREEN}[✓] Target: $TARGET${NC}"
    log_message "${GREEN}[✓] Results saved in: $WORK_DIR${NC}"
    log_message "${GREEN}[✓] Log file: $LOG_FILE${NC}"
    log_message ""
    log_message "${YELLOW}📊 Summary of Findings:${NC}"
    log_message "   ├─ Live Hosts: $(wc -l < live_hosts.txt 2>/dev/null)"
    log_message "   ├─ Subdomains: $(wc -l < subdomains_resolved.txt 2>/dev/null)"
    log_message "   ├─ API Endpoints: $(wc -l < api_endpoints.txt 2>/dev/null)"
    log_message "   ├─ Backup Files: $(wc -l < backup_files.txt 2>/dev/null)"
    log_message "   ├─ Emails Found: $(wc -l < emails_found.txt 2>/dev/null)"
    log_message "   ├─ Open Redirects: $(wc -l < open_redirects.txt 2>/dev/null)"
    log_message "   ├─ Directory Listings: $(wc -l < directory_listing.txt 2>/dev/null)"
    log_message "   └─ Takeover Candidates: $(wc -l < takeover_candidates.txt 2>/dev/null)"
    log_message ""
    log_message "${CYAN}📁 Key Files to Review:${NC}"
    log_message "   → $WORK_DIR/live_hosts.txt"
    log_message "   → $WORK_DIR/backup_files.txt"
    log_message "   → $WORK_DIR/api_endpoints.txt"
    log_message "   → $WORK_DIR/open_redirects.txt"
    log_message "   → $WORK_DIR/directory_listing.txt"
    log_message "   → $WORK_DIR/emails_found.txt"
    log_message ""
    log_message "${BLUE}📄 Full Report: $WORK_DIR/recon_report_${TARGET}_$TIMESTAMP.md${NC}"
    log_message ""
    log_message "${YELLOW}💡 Next Steps:${NC}"
    log_message "   1. Review all findings manually"
    log_message "   2. Prioritize high-risk findings"
    log_message "   3. Create Proof of Concepts"
    log_message "   4. Report responsibly through bug bounty platform"
    log_message ""
}

# Main execution function
main() {
    # Parse command line argument
    if [[ -n "$1" ]]; then
        TARGET="$1"
    fi
    
    show_banner
    log_message "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log_message "${GREEN}Starting Bug Bounty Reconnaissance on: $TARGET${NC}"
    log_message "${BLUE}Created by: Yeghaneh${NC}"
    log_message "${BLUE}Time: $(date)${NC}"
    log_message "${BLUE}Log file: $LOG_FILE${NC}"
    log_message "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    log_message ""
    
    # Check if we're on Linux
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        log_message "${YELLOW}⚠️  Warning: Script optimized for Linux. Some features may not work.${NC}"
    fi
    
    # Install/check tools
    install_basic_tools
    install_go
    install_python_tools
    install_go_tools
    download_wordlists
    
    # Run all reconnaissance modules
    basic_recon
    find_subdomains_manual
    check_live_hosts
    detect_cloud_providers
    detect_tech_stack
    discover_parameters
    wayback_analysis
    discover_emails
    check_subdomain_takeover
    scan_cors_misconfig
    find_open_redirects
    analyze_security_headers
    find_backup_files
    discover_api_endpoints
    scan_directory_listing
    capture_error_messages
    ssl_security_assessment
    check_graphql_introspection
    
    # Generate final output
    generate_report
    show_summary
    
    log_message "${GREEN}[✓] All tasks completed!${NC}"
}

# Run the main function with command line argument
main "$1"

# End of script
