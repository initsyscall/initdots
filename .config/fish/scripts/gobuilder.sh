#!/bin/bash
set -euo pipefail 

clear

PROJECT_PATH=$(pwd)
win7_GO_COMPILER_PATH="/home/init/.Mascot/gopher/go-legacy-win7/bin/go"

echo "Starting Build At $PROJECT_PATH"
echo "Running build for all targets"

read -p "Enter Name For Your Compiled Build: " COMPILED_BUILD_NAME

function FOOTER() {
  COMPILED_PROGRAM_LIST=$(find . -maxdepth 1 -name "${COMPILED_BUILD_NAME}*" -printf "%P\n")
  echo -e "\nBuild Finished!"
  echo "Generated Binaries:"
  echo "$COMPILED_PROGRAM_LIST"
}

read -p "Do you want advance compilation (y/n): " ADVANCE_OPTION_CONFIRMATION

if [[ "$ADVANCE_OPTION_CONFIRMATION" =~ ^[Yy]$ ]]; then
  read -p "Enter Versioning String: " VERSION_STRING

  GOOS=linux GOARCH=amd64 go build -o  "${COMPILED_BUILD_NAME}_linux_x86_${VERSION_STRING}" .
  GOOS=linux GOARCH=arm64 go build -o  "${COMPILED_BUILD_NAME}_linux_arm64_${VERSION_STRING}" .

  GOOS=windows GOARCH=amd64 go build -o  "${COMPILED_BUILD_NAME}_windows_x86_${VERSION_STRING}.exe" .
  GOOS=windows GOARCH=arm64 go build -o  "${COMPILED_BUILD_NAME}_windows_arm64_${VERSION_STRING}.exe" .

  GOOS=windows GOARCH=amd64 CGO_ENABLED=0 $win7_GO_COMPILER_PATH build -ldflags="-s -w" -o "${COMPILED_BUILD_NAME}_windows_legacy_x86_${VERSION_STRING}.exe" .
  GOOS=windows GOARCH=arm64 CGO_ENABLED=0 $win7_GO_COMPILER_PATH build -ldflags="-s -w" -o "${COMPILED_BUILD_NAME}_windows_legacy_arm64_${VERSION_STRING}.exe" .

  GOOS=darwin GOARCH=arm64 go build -o   "${COMPILED_BUILD_NAME}_macos_arm64_${VERSION_STRING}" .
  FOOTER
else 
  read -p "Do you want to target win7? (y/n): " WIN7_BUILD_CONFIRMATION
  
  if [[ "$WIN7_BUILD_CONFIRMATION" =~ ^[Yy]$ ]]; then
     GOOS=windows GOARCH=amd64 CGO_ENABLED=0 $win7_GO_COMPILER_PATH build -ldflags="-s -w" -o "${COMPILED_BUILD_NAME}_windows_legacy_x86.exe" .
  fi
  GOOS=linux GOARCH=amd64 go build -o  "${COMPILED_BUILD_NAME}_linux_x86" .
  GOOS=windows GOARCH=amd64 go build -o  "${COMPILED_BUILD_NAME}_windows_x86.exe" .
  GOOS=darwin GOARCH=arm64 go build -o   "${COMPILED_BUILD_NAME}_macos_arm64" .
  FOOTER
fi
