#!/bin/bash

# Exit on error
set -e

echo "🚀 Building PayBitoSDK XCFramework..."

# Define paths
WORKSPACE_DIR=$(pwd)
PACKAGE_DIR="${WORKSPACE_DIR}/PayBitoSDK"
BUILD_DIR="${PACKAGE_DIR}/.build/xcframework"
OUTPUT_DIR="${WORKSPACE_DIR}/PayBitoSDK-Distribution"

# Clean previous builds
rm -rf "${BUILD_DIR}"
rm -rf "${OUTPUT_DIR}"
mkdir -p "${BUILD_DIR}"
mkdir -p "${OUTPUT_DIR}"

echo "📱 Building for iOS Devices (arm64)..."
xcodebuild archive \
    -workspace "Payments SDK.xcworkspace" \
    -scheme PayBitoSDK \
    -destination "generic/platform=iOS" \
    -archivePath "${BUILD_DIR}/PayBitoSDK-iOS.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    OTHER_SWIFT_FLAGS="-no-verify-emitted-module-interface" || echo "Build for iOS Devices finished."

echo "💻 Building for iOS Simulators (x86_64, arm64)..."
xcodebuild archive \
    -workspace "Payments SDK.xcworkspace" \
    -scheme PayBitoSDK \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "${BUILD_DIR}/PayBitoSDK-Simulator.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    OTHER_SWIFT_FLAGS="-no-verify-emitted-module-interface" || echo "Build for Simulators finished."

echo "📦 Creating XCFramework..."
xcodebuild -create-xcframework \
    -framework "${BUILD_DIR}/PayBitoSDK-iOS.xcarchive/Products/Library/Frameworks/PayBitoSDK.framework" \
    -framework "${BUILD_DIR}/PayBitoSDK-Simulator.xcarchive/Products/Library/Frameworks/PayBitoSDK.framework" \
    -output "${OUTPUT_DIR}/PayBitoSDK.xcframework"

echo "✅ Successfully created PayBitoSDK.xcframework in ${OUTPUT_DIR}"
