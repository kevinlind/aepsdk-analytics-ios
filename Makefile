export EXTENSION_NAME = AEPAnalytics
PROJECT_NAME = $(EXTENSION_NAME)
SCHEME_NAME_XCFRAMEWORK = AEPAnalytics

SIMULATOR_ARCHIVE_PATH = ./build/ios_simulator.xcarchive/Products/Library/Frameworks/
IOS_ARCHIVE_PATH = ./build/ios.xcarchive/Products/Library/Frameworks/

setup:
	(pod install)

setup-tools: install-swiftlint install-githook

pod-repo-update:
	(pod repo update)

# pod repo update may fail if there is no repo (issue fixed in v1.8.4). Use pod install --repo-update instead
pod-install:
	(pod install --repo-update)

pod-update: pod-repo-update
	(pod update)

open:
	open $(PROJECT_NAME).xcworkspace

test:
	@echo "######################################################################"
	@echo "### Unit Testing iOS"
	@echo "######################################################################"
	xcodebuild test -workspace $(PROJECT_NAME).xcworkspace -scheme $(PROJECT_NAME) -destination 'platform=iOS Simulator,name=iPhone 8' -derivedDataPath build/out -enableCodeCoverage YES

install-swiftlint:
	HOMEBREW_NO_AUTO_UPDATE=1 brew install swiftlint && brew cleanup swiftlint

archive: pod-update
	xcodebuild archive -workspace $(PROJECT_NAME).xcworkspace -scheme $(PROJECT_NAME) -archivePath "./build/ios.xcarchive" -sdk iphoneos -destination="iOS" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
	xcodebuild archive -workspace $(PROJECT_NAME).xcworkspace -scheme $(SCHEME_NAME_XCFRAMEWORK) -archivePath "./build/ios_simulator.xcarchive" -sdk iphonesimulator -destination="iOS Simulator" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES	
	xcodebuild -create-xcframework -framework $(SIMULATOR_ARCHIVE_PATH)$(PROJECT_NAME).framework -framework $(IOS_ARCHIVE_PATH)$(PROJECT_NAME).framework -output ./build/$(PROJECT_NAME).xcframework

clean:
	rm -rf ./build

format:
	swiftformat . --swiftversion 5.2

lint-autocorrect:
	swiftlint autocorrect

lint:
	swiftlint lint

checkFormat:
		swiftformat . --lint --swiftversion 5.2

# release checks
check-version:
	(sh ./Script/version.sh $(VERSION))

test-SPM-integration:
	(sh ./Script/test-SPM.sh)

test-podspec:
	(sh ./Script/test-podspec.sh)

pod-lint:
	(pod lib lint --allow-warnings --verbose --swift-version=5.1)

# make bump-versions from='3\.1\.0' to=3.1.1
bump-versions:
	(LC_ALL=C find . -type f -name 'project.pbxproj' -exec sed -i '' 's/$(from)/$(to)/' {} +)
	(LC_ALL=C find . -type f -name '*.swift' -exec sed -i '' 's/$(from)/$(to)/' {} +)	
	(LC_ALL=C find . -type f -name '*.podspec' -exec sed -i '' 's/$(from)/$(to)/' {} +)