APP_NAME = manchor
SCHEME = manchor
PROJECT = manchor.xcodeproj

BUILD_DIR = build
DERIVED_DATA = $(BUILD_DIR)/DerivedData
APP_SRC_PATH = $(DERIVED_DATA)/Build/Products/Release/$(APP_NAME).app
APP_DST_PATH = $(BUILD_DIR)/$(APP_NAME).app
DMG_PATH = $(BUILD_DIR)/$(APP_NAME).dmg
DMG_TEMP = $(BUILD_DIR)/dmg_temp

.PHONY: all app dmg clean

all: app dmg

# Build .app using xcodebuild
app:
	@echo "🚧 Building $(APP_NAME).app ..."
	xcodebuild \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration Release \
		-derivedDataPath $(DERIVED_DATA) \
		build

	@echo "📦 Copying app to $(BUILD_DIR)/ ..."
	mkdir -p $(BUILD_DIR)
	rm -rf $(APP_DST_PATH)
	cp -R "$(APP_SRC_PATH)" "$(APP_DST_PATH)"

	@echo "✅ App build complete: $(APP_DST_PATH)"

# Build DMG using hdiutil
dmg: app
	@echo "📀 Creating DMG using hdiutil ..."

	rm -rf $(DMG_TEMP)
	mkdir -p $(DMG_TEMP)

	# Copy app into temp folder
	cp -R "$(APP_DST_PATH)" "$(DMG_TEMP)/"

	# Add Applications symlink
	ln -s /Applications "$(DMG_TEMP)/Applications"

	# Create DMG
	hdiutil create \
		-volname "$(APP_NAME)" \
		-srcfolder "$(DMG_TEMP)" \
		-ov \
		-format UDZO \
		"$(DMG_PATH)"

	@echo "🎉 DMG created: $(DMG_PATH)"

	# Cleanup temp folder
	rm -rf $(DMG_TEMP)

# Clean all build artifacts
clean:
	@echo "🧹 Cleaning build files ..."
	rm -rf $(BUILD_DIR)
	@echo "✨ Clean complete"
