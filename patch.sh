#!/bin/bash
# ============================================================
#  D3adPhish - Hardened GoPhish Builder
#  by D3adshot (@D3adshotH8ck)
#  For authorized penetration testing engagements only.
# ============================================================

RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

banner() {
  echo -e "${PURPLE}"
  echo '██████╗ ██████╗ ███████╗ █████╗ ██████╗ ██████╗ ██╗  ██╗██╗███████╗██╗  ██╗'
  echo '██╔══██╗╚════██╗██╔════╝██╔══██╗██╔══██╗██╔══██╗██║  ██║██║██╔════╝██║  ██║'
  echo '██║  ██║ █████╔╝█████╗  ███████║██║  ██║██████╔╝███████║██║███████╗███████║'
  echo '██║  ██║ ╚═══██╗██╔══╝  ██╔══██║██║  ██║██╔═══╝ ██╔══██║██║╚════██║██╔══██║'
  echo '██████╔╝██████╔╝███████╗██║  ██║██████╔╝██║     ██║  ██║██║███████║██║  ██║'
  echo '╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝'
  echo -e "${CYAN}  Hardened GoPhish Builder — by D3adshot${NC}"
  echo -e "${RED}  For authorized security testing only.${NC}"
  echo ""
}

check_deps() {
  echo -e "${CYAN}[*] Checking dependencies...${NC}"
  for dep in git go wget unzip; do
    if ! command -v $dep &>/dev/null; then
      echo -e "${RED}[!] Missing dependency: $dep — please install it and retry.${NC}"
      exit 1
    fi
  done
  echo -e "${GREEN}[+] All dependencies satisfied.${NC}"
}

clone_gophish() {
  echo -e "${CYAN}[*] Cloning GoPhish source...${NC}"
  if [ -d "gophish-src" ]; then
    echo -e "${CYAN}[*] Source directory already exists, pulling latest...${NC}"
    cd gophish-src && git pull && cd ..
  else
    git clone https://github.com/gophish/gophish gophish-src
  fi
  echo -e "${GREEN}[+] Source ready.${NC}"
}

patch_xmailer() {
  echo -e "${CYAN}[*] Patching X-Mailer header...${NC}"
  sed -i '/msg.SetHeader("X-Mailer"/d' gophish-src/models/email_request.go
  sed -i '/msg.SetHeader("X-Gophish-Contact"/d' gophish-src/models/email_request.go
  sed -i '/if conf.ContactAddress != ""/,/}/{ /msg.SetHeader("X-Gophish-Contact"/d }' gophish-src/models/email_request.go
# Remove unused config import
  sed -i '/"github.com\/gophish\/gophish\/config"/d' gophish-src/models/email_request.go
  # Patch maillog.go as well
  sed -i '/msg.SetHeader("X-Mailer"/d' gophish-src/models/maillog.go
  sed -i '/msg.SetHeader("X-Gophish-Contact"/d' gophish-src/models/maillog.go
  sed -i '/"github.com\/gophish\/gophish\/config"/d' gophish-src/models/maillog.go
  echo -e "${GREEN}[+] X-Mailer and X-Gophish-Contact headers removed.${NC}"
}

patch_rid() {
  echo -e "${CYAN}[*] Patching RID tracking parameter...${NC}"
  sed -i 's/const RecipientParameter = "rid"/const RecipientParameter = "utm_id"/' gophish-src/models/campaign.go
  echo -e "${GREEN}[+] Tracking parameter changed: rid -> utm_id${NC}"
}

patch_servername() {
  echo -e "${CYAN}[*] Patching server name...${NC}"
  sed -i 's/const ServerName = "gophish"/const ServerName = "MSFT_MailService"/' gophish-src/config/config.go
  echo -e "${GREEN}[+] Server name patched.${NC}"
}

patch_session() {
  echo -e "${CYAN}[*] Patching session cookie name...${NC}"
  sed -i 's/Store.Get(r, "gophish")/Store.Get(r, "session")/' gophish-src/middleware/middleware.go
  echo -e "${GREEN}[+] Session cookie renamed.${NC}"
}

patch_testmail() {
  echo -e "${CYAN}[*] Patching test email body...${NC}"
  sed -i 's/your gophish\\\\nconfiguration/your mail\\nconfiguration/' gophish-src/controllers/api/util.go
  echo -e "${GREEN}[+] Test email body patched.${NC}"
}

build() {
  echo -e "${CYAN}[*] Building hardened binary...${NC}"
  cd gophish-src
  go build -buildvcs=false -o ../gophish_hardened
  cd ..
  if [ -f "gophish_hardened" ]; then
    chmod +x gophish_hardened
    echo -e "${GREEN}[+] Build successful: ./gophish_hardened${NC}"
  else
    echo -e "${RED}[!] Build failed. Check errors above.${NC}"
    exit 1
  fi
}

summary() {
  echo ""
  echo -e "${PURPLE}========================================${NC}"
  echo -e "${GREEN}  D3adPhish build complete.${NC}"
  echo -e "${PURPLE}========================================${NC}"
  echo -e "${CYAN}  Patches applied:${NC}"
  echo -e "${GREEN}  [+] X-Mailer header removed${NC}"
  echo -e "${GREEN}  [+] X-Gophish-Contact header removed${NC}"
  echo -e "${GREEN}  [+] Tracking param: rid -> utm_id${NC}"
  echo -e "${GREEN}  [+] Server name obfuscated${NC}"
  echo -e "${GREEN}  [+] Session cookie renamed${NC}"
  echo -e "${GREEN}  [+] Test email body cleaned${NC}"
  echo ""
  echo -e "${CYAN}  Run with: sudo ./gophish_hardened${NC}"
  echo -e "${RED}  Authorized use only. Stay legal.${NC}"
  echo -e "${PURPLE}========================================${NC}"
}

banner
check_deps
clone_gophish
patch_xmailer
patch_rid
patch_servername
patch_session
patch_testmail
build
summary
