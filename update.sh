#!/bin/sh
set -eu

VERSION=1.23.12
GOLANGCI_LINT_VERSION=v1.56.2

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

print_unsupported_platform() {
    echo "Error: unsupported platform $(uname) $(uname -m)" >&2
}

OS=""
case "$(uname)" in
    "Linux")  OS="linux" ;;
    "Darwin") OS="darwin" ;;
    *)
        print_unsupported_platform
        exit 1
        ;;
esac

ARCH=""
case "$(uname -m)" in
    "x86_64")  ARCH="amd64" ;;
    "arm64")   ARCH="arm64" ;;
    "aarch64") ARCH="arm64" ;;
    *)
        print_unsupported_platform
        exit 1
        ;;
esac

ARCHIVE="go${VERSION}.${OS}-${ARCH}.tar.gz"

mkdir -p "${SCRIPT_DIR}/bin" "${SCRIPT_DIR}/version/${VERSION}"

if [ ! -f "${SCRIPT_DIR}/version/${ARCHIVE}" ]; then
    curl -L "https://go.dev/dl/${ARCHIVE}" -o "${SCRIPT_DIR}/version/${ARCHIVE}"
fi

if [ ! -d "${SCRIPT_DIR}/version/${VERSION}/go" ]; then
    tar -xf "${SCRIPT_DIR}/version/${ARCHIVE}" -C "${SCRIPT_DIR}/version/${VERSION}/"
fi

ln -sf "${SCRIPT_DIR}/version/${VERSION}/go/bin/"* "${SCRIPT_DIR}/bin/"

if [ ! -f "${SCRIPT_DIR}/bin/golangci-lint" ]; then
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
        | sh -s -- -b "${SCRIPT_DIR}/bin" "${GOLANGCI_LINT_VERSION}"
fi
