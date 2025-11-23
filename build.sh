#!/bin/bash

# MacAfk Lite 多架构构建脚本
# 专为 App Store 版本构建 ARM64 和 x86_64 版本

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="MacAfk"

BUILD_DIR="$PROJECT_DIR/Build"
ARCHIVE_DIR="$PROJECT_DIR/Archives"
DIST_DIR="$PROJECT_DIR/Dist"

# 获取版本号（从 git tag 或默认值）
VERSION="${VERSION:-$(git describe --tags --abbrev=0 2>/dev/null || echo "1.0.0")}"

echo "🏗️  MacAfk Lite 多架构构建脚本"
echo "================================"
echo "版本: $VERSION"
echo ""

# 清理旧的构建产物
echo "🧹 清理旧的构建产物..."
rm -rf "$BUILD_DIR"
rm -rf "$ARCHIVE_DIR"
rm -rf "$DIST_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$ARCHIVE_DIR"
mkdir -p "$DIST_DIR"

# 构建函数
build_variant() {
    local arch=$1     # arm64 或 x86_64
    
    echo ""
    echo "🚀 构建 MacAfk Lite ($arch)..."
    
    local archive_name="MacAfk-Lite-${arch}"
    local export_path="$BUILD_DIR/Lite-${arch}"
    
    # 构建 archive
    xcodebuild -scheme "$PROJECT_NAME" \
        -configuration "Release-AppStore" \
        -arch "$arch" \
        -archivePath "$ARCHIVE_DIR/${archive_name}.xcarchive" \
        archive \
        -allowProvisioningUpdates
    
    # 导出 app
    # 检查是否在 CI 环境中
    if [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ]; then
        # CI 环境使用 CI 配置（不需要签名）
        xcodebuild -exportArchive \
            -archivePath "$ARCHIVE_DIR/${archive_name}.xcarchive" \
            -exportPath "$export_path" \
            -exportOptionsPlist "$PROJECT_DIR/ExportOptions-CI.plist" \
            -allowProvisioningUpdates
    else
        # 本地环境使用 Lite 配置（会自动签名并上传到 App Store Connect）
        xcodebuild -exportArchive \
            -archivePath "$ARCHIVE_DIR/${archive_name}.xcarchive" \
            -exportPath "$export_path" \
            -exportOptionsPlist "$PROJECT_DIR/ExportOptions-Lite.plist" \
            -allowProvisioningUpdates
    fi
    
    echo "✅ MacAfk Lite ($arch) 构建完成！"
}

# 创建 DMG 函数
create_dmg() {
    local arch=$1
    local app_name=$2
    
    echo ""
    echo "📦 创建 MacAfk Lite ($arch) DMG..."
    
    local source_dir="$BUILD_DIR/Lite-${arch}"
    local dmg_name="MacAfk-Lite-${arch}-v${VERSION}.dmg"
    
    hdiutil create -volname "MacAfk Lite" \
        -srcfolder "$source_dir" \
        -ov -format UDZO \
        "$DIST_DIR/$dmg_name"
    
    echo "✅ DMG 创建完成：$dmg_name"
}

# 构建 Lite 版本
echo ""
echo "═══════════════════════════════"
echo "📦 构建 Lite 版本（App Store）"
echo "═══════════════════════════════"
echo "   - 沙盒：启用"
echo "   - 亮度控制：Gamma 调光"
echo "   - Bundle ID: com.snowywar.MacAfk.lite"

build_variant "arm64"
build_variant "x86_64"

create_dmg "arm64" "MacAfk Lite"
create_dmg "x86_64" "MacAfk Lite"

# 创建通用二进制（Universal Binary）
echo ""
echo "═══════════════════════════════"
echo "🔗 创建通用二进制版本"
echo "═══════════════════════════════"

create_universal() {
    local app_name=$1
    
    echo ""
    echo "📦 合并 Lite 版本 (arm64 + x86_64)..."
    
    local arm_app="$BUILD_DIR/Lite-arm64/${app_name}.app"
    local x86_app="$BUILD_DIR/Lite-x86_64/${app_name}.app"
    local universal_dir="$BUILD_DIR/Lite-Universal"
    local universal_app="$universal_dir/${app_name}.app"
    
    mkdir -p "$universal_dir"
    cp -R "$arm_app" "$universal_app"
    
    # 合并二进制文件
    lipo -create \
        "$arm_app/Contents/MacOS/$PROJECT_NAME" \
        "$x86_app/Contents/MacOS/$PROJECT_NAME" \
        -output "$universal_app/Contents/MacOS/$PROJECT_NAME"
    
    # 创建 Universal DMG
    local dmg_name="MacAfk-Lite-Universal-v${VERSION}.dmg"
    
    hdiutil create -volname "MacAfk Lite" \
        -srcfolder "$universal_dir" \
        -ov -format UDZO \
        "$DIST_DIR/$dmg_name"
    
    echo "✅ Universal DMG 创建完成：$dmg_name"
}

create_universal "MacAfk Lite"

# 生成校验和
echo ""
echo "🔐 生成校验和..."
cd "$DIST_DIR"
shasum -a 256 *.dmg > checksums.txt
echo "✅ 校验和已保存到 checksums.txt"

# 显示结果
echo ""
echo "================================"
echo "🎉 构建完成！"
echo ""
echo "📁 构建产物位置："
echo "   $DIST_DIR/"
echo ""
echo "📦 生成的文件："
ls -lh "$DIST_DIR"
echo ""
echo "📋 版本信息："
echo "   版本号: $VERSION"
echo "   构建时间: $(date)"
echo ""
echo "📋 下一步："
echo "   1. 使用 Xcode 或 Transporter 上传到 App Store Connect"
echo "   2. 或发布 DMG 文件到 GitHub Release"
echo "   3. 验证所有架构的 DMG 文件"
echo ""
echo "💡 提示："
echo "   - .app 文件位于: $BUILD_DIR/"
echo "   - 可以使用 Transporter 或 xcrun altool 上传 .pkg 文件"
echo ""
