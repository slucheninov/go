#!/usr/bin/env bash
# Compatible with both bash and zsh
# Strict mode: exit on error, undefined variables, and pipe failures
# Note: zsh doesn't support 'set -o pipefail' by default, but we'll handle it
if [[ -n "${ZSH_VERSION:-}" ]]; then
    set -euo
    setopt PIPE_FAIL 2>/dev/null || true
else
    set -euo pipefail
fi

VERSION=1.26.0
GOLANGCI_LINT_VERSION=v2.10.1

FORCE=false
if [[ "${1:-}" == "--force" || "${1:-}" == "-f" ]]; then
    FORCE=true
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if terminal supports colors
supports_colors() {
    [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]]
}

# Color codes (only if terminal supports colors)
if supports_colors; then
    COLOR_RESET="\033[0m"
    COLOR_BOLD="\033[1m"
    COLOR_RED="\033[31m"
    COLOR_GREEN="\033[32m"
    COLOR_YELLOW="\033[33m"
    COLOR_BLUE="\033[34m"
    COLOR_MAGENTA="\033[35m"
    COLOR_CYAN="\033[36m"
    COLOR_GRAY="\033[90m"
else
    COLOR_RESET=""
    COLOR_BOLD=""
    COLOR_RED=""
    COLOR_GREEN=""
    COLOR_YELLOW=""
    COLOR_BLUE=""
    COLOR_MAGENTA=""
    COLOR_CYAN=""
    COLOR_GRAY=""
fi

# Logging helpers
log_step() {
    echo -e "${COLOR_BLUE}==>${COLOR_RESET} ${COLOR_BOLD}$1${COLOR_RESET}"
}

log_ok() {
    echo -e "  ${COLOR_GREEN}OK${COLOR_RESET} $1"
}

log_skip() {
    echo -e "  ${COLOR_GRAY}SKIP${COLOR_RESET} $1"
}

log_warn() {
    echo -e "  ${COLOR_YELLOW}WARN${COLOR_RESET} $1" >&2
}

log_error() {
    echo -e "  ${COLOR_RED}ERROR${COLOR_RESET} $1" >&2
}

# Check required dependencies
log_step "Checking dependencies"
missing=()
for cmd in curl tar; do
    if command -v "$cmd" &>/dev/null; then
        log_ok "$cmd found"
    else
        missing+=("$cmd")
        log_error "$cmd not found"
    fi
done
if [[ ${#missing[@]} -gt 0 ]]; then
    log_error "Missing required tools: ${missing[*]}"
    exit 1
fi

# Detect platform
log_step "Detecting platform"

OS=""
case "$(uname)" in
    "Linux")  OS="linux" ;;
    "Darwin") OS="darwin" ;;
    *)
        log_error "Unsupported OS: $(uname)"
        exit 1
        ;;
esac

ARCH=""
case "$(uname -m)" in
    "x86_64")  ARCH="amd64" ;;
    "arm64")   ARCH="arm64" ;;
    "aarch64") ARCH="arm64" ;;
    *)
        log_error "Unsupported architecture: $(uname -m)"
        exit 1
        ;;
esac

log_ok "${OS}/${ARCH}"

ARCHIVE="go${VERSION}.${OS}-${ARCH}.tar.gz"

# Force cleanup
if [[ "$FORCE" == true ]]; then
    log_step "Force mode: cleaning previous installation"
    rm -rf "${SCRIPT_DIR}/version/${VERSION}"
    rm -f "${SCRIPT_DIR}/version/${ARCHIVE}"
    rm -f "${SCRIPT_DIR}/bin/golangci-lint"
    log_ok "Cleaned"
fi

mkdir -p "${SCRIPT_DIR}/bin" "${SCRIPT_DIR}/version/${VERSION}"

# Download Go
log_step "Installing Go ${VERSION}"
if [[ ! -f "${SCRIPT_DIR}/version/${ARCHIVE}" ]]; then
    log_ok "Downloading ${ARCHIVE}..."
    if ! curl -fL "https://go.dev/dl/${ARCHIVE}" -o "${SCRIPT_DIR}/version/${ARCHIVE}"; then
        log_error "Failed to download Go ${VERSION}"
        rm -f "${SCRIPT_DIR}/version/${ARCHIVE}"
        exit 1
    fi
    log_ok "Downloaded"
else
    log_skip "Archive already exists"
fi

# Extract Go
if [[ ! -d "${SCRIPT_DIR}/version/${VERSION}/go" ]]; then
    log_ok "Extracting..."
    if ! tar -xf "${SCRIPT_DIR}/version/${ARCHIVE}" -C "${SCRIPT_DIR}/version/${VERSION}/"; then
        log_error "Failed to extract ${ARCHIVE}"
        exit 1
    fi
    log_ok "Extracted"
else
    log_skip "Already extracted"
fi

# Create symlinks
ln -sf "${SCRIPT_DIR}/version/${VERSION}/go/bin/"* "${SCRIPT_DIR}/bin/"
log_ok "Symlinks updated"

# Install golangci-lint
log_step "Installing golangci-lint ${GOLANGCI_LINT_VERSION}"
if [[ ! -f "${SCRIPT_DIR}/bin/golangci-lint" ]]; then
    if ! curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
        | sh -s -- -b "${SCRIPT_DIR}/bin" "${GOLANGCI_LINT_VERSION}"; then
        log_error "Failed to install golangci-lint"
        exit 1
    fi
    log_ok "Installed"
else
    log_skip "Already installed"
fi

# Summary
echo ""
log_step "Done"
log_ok "Go:             $("${SCRIPT_DIR}/bin/go" version 2>/dev/null || echo "go ${VERSION}")"
log_ok "golangci-lint:  $("${SCRIPT_DIR}/bin/golangci-lint" version --short 2>/dev/null || echo "${GOLANGCI_LINT_VERSION}")"
log_ok "Binaries:       ${SCRIPT_DIR}/bin/"
echo ""
echo -e "${COLOR_GRAY}Add to your shell profile:${COLOR_RESET}"
echo -e "  ${COLOR_CYAN}export PATH=\"${SCRIPT_DIR}/bin:\$PATH\"${COLOR_RESET}"
