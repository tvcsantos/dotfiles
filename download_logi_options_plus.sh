#!/usr/bin/env bash
# =============================================================================
# download_logi_options_plus.sh
# Downloads the latest Logi Options+ installer for macOS from Logitech's CDN.
# =============================================================================

set -euo pipefail

# -- Colours ------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }

# -- Config -------------------------------------------------------------------
PRODUCT_PAGE="https://www.logitech.com/en-us/software/logi-options-plus.html"
CDN_BASE="https://software.logi.com/macos"
DOWNLOAD_DIR="${HOME}/Downloads"
FILENAME="logioptionsplus_installer.zip"
DEST="${DOWNLOAD_DIR}/${FILENAME}"

# -- Preflight checks ---------------------------------------------------------
echo -e "\n${BOLD}Logi Options+ - macOS Downloader${RESET}\n"

if [[ "$(uname)" != "Darwin" ]]; then
  error "This script targets macOS only. Detected OS: $(uname)"
  exit 1
fi

if ! command -v curl &>/dev/null; then
  error "'curl' is required but not found. Please install it first."
  exit 1
fi

mkdir -p "${DOWNLOAD_DIR}"

# -- Already installed check ---------------------------------------------------
INSTALL_PATH="/Applications/logioptionsplus.app"
BUNDLE_ID="com.logi.optionsplus"

is_installed() {
  # 1. Check the default Applications path
  [[ -d "${INSTALL_PATH}" ]] && return 0
  # 2. Fallback: ask Spotlight (catches installs in other locations)
  # save sucess result to INSTALL_PATH for user info later
  INSTALL_PATH=$(mdfind "kMDItemCFBundleIdentifier == '${BUNDLE_ID}'" 2>/dev/null | head -1)
  [[ -n "${INSTALL_PATH}" ]] && return 0
  return 1
}

if is_installed; then
  INSTALLED_VERSION=$(defaults read "${INSTALL_PATH}/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "unknown")
  warn "Logi Options+ is already installed (version ${INSTALLED_VERSION})."
  read -rp "$(echo -e "${BOLD}Download and reinstall anyway?${RESET} [y/N] ")" REINSTALL
  REINSTALL="${REINSTALL:-N}"
  if [[ ! "${REINSTALL}" =~ ^[Yy]$ ]]; then
    info "Skipping download. To launch it, open: ${INSTALL_PATH}"
    exit 0
  fi
fi

# -- Resolve download URL ------------------------------------------------------
info "Fetching latest download URL from Logitech..."

# Logitech's update manifest / product page contains the direct CDN link.
# We scrape the canonical .zip URL for macOS from the HTML.
RAW_URL=$(
  curl -fsSL --max-time 15 "${PRODUCT_PAGE}" \
    | grep -oE 'https://[^"]+logioptionsplus_installer\.zip' \
    | head -1
)

# Fallback: use the well-known stable CDN path if scraping fails
if [[ -z "${RAW_URL}" ]]; then
  warn "Could not scrape URL from product page; using known CDN path."
  RAW_URL="${CDN_BASE}/${FILENAME}"
fi

DOWNLOAD_URL="${RAW_URL}"
info "Resolved URL: ${DOWNLOAD_URL}"

# -- Download ------------------------------------------------------------------
info "Downloading to: ${DEST}"

if curl -fL \
     --progress-bar \
     --max-time 300 \
     --retry 3 \
     --retry-delay 5 \
     --output "${DEST}" \
     "${DOWNLOAD_URL}"; then
  FILE_SIZE=$(du -sh "${DEST}" | cut -f1)
  success "Download complete! (${FILE_SIZE})"
else
  error "Download failed. Check your internet connection or the URL below and try again:"
  error "  ${DOWNLOAD_URL}"
  exit 1
fi

# -- Integrity check -----------------------------------------------------------
info "Verifying archive integrity..."
if unzip -tq "${DEST}" 2>/dev/null; then
  success "Archive is valid."
else
  error "Archive appears to be corrupt. Please delete it and re-run the script."
  error "  rm '${DEST}'"
  exit 1
fi

# -- Optional: auto-open -------------------------------------------------------
echo ""
read -rp "$(echo -e "${BOLD}Open the installer now?${RESET} [Y/n] ")" OPEN_NOW
OPEN_NOW="${OPEN_NOW:-Y}"

if [[ "${OPEN_NOW}" =~ ^[Yy]$ ]]; then
  info "Unzipping and launching installer..."
  UNZIP_DIR="${DOWNLOAD_DIR}/LogiOptionsPlus_Install"
  rm -rf "${UNZIP_DIR}"

  # Extract archive quietly, then remove macOS metadata at any nesting depth.
  # unzip's -x flag doesn't support ** globbing, so we clean up after instead:
  #   __MACOSX/  - resource-fork shadow directory added by macOS zip
  #   .DS_Store  - Finder metadata files
  #   ._*        - AppleDouble resource-fork sidecar files
  unzip -q "${DEST}" -d "${UNZIP_DIR}"
  find "${UNZIP_DIR}" \( -name "__MACOSX" -o -name ".DS_Store" -o -name "._*" \) \
    -exec rm -rf {} + 2>/dev/null || true

  # Find the .pkg or .app inside the archive, skipping any macOS temp dirs
  INSTALLER=$(find "${UNZIP_DIR}" \
    \( -name "__MACOSX" -o -name ".DS_Store" -o -name "._*" \) -prune \
    -o \( -name "*.pkg" -o -name "*.app" \) -print \
    | head -1)
  if [[ -n "${INSTALLER}" ]]; then
    open "${INSTALLER}"
    success "Installer launched: ${INSTALLER}"
  else
    warn "No .pkg or .app found inside the archive. Opening the folder instead."
    open "${UNZIP_DIR}"
  fi
else
  info "You can install later by opening:"
  info "  ${DEST}"
fi

echo ""
success "All done. Enjoy Logi Options+! "
echo ""
