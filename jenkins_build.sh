#!/bin/sh

# NOTE: Do the following, if you want to build at local.
#       1. Comment in and Set VARIABLES in "Set On Jenkins".
#       2. ./jenkins_build.sh
#       3. Finally, .ipa file is created in ${WORKSPACE}/build directory.
#        ***CAUTION*** DO NOT COMMIT ${WORKSPACE}/build directory
#

#### Set On Jenkins ###

export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
WORKSPACE=`pwd`
BUILD_NUMBER=1

SCHEME=Falcon
CONFIGURATION=Debug
# PROVISIONING_NAME=iOS_Team_Provisioning_Profile_moennsnodnbfalcon
PROVISIONING_NAME=FalconAdHoc1208
IPA_FILE_NAME=develop-${BUILD_NUMBER}.ipa
iOS_SDK=iphoneos10.1

## DeployGate Configuration
#DG_USER=nnsnodnb
#DG_API_KEY=

#### Set On Jenkins ####

# Get the ProvisioningProfile UUID
echo "************** Get the ProvisioningProfile UUID ***************"
KEYCHAIN=${HOME}/Library/Keychains/login.keychain
security cms -D -k ${KEYCHAIN} -i ${PROVISIONING_NAME}.mobileprovision > mptext
plutil -extract 'UUID' xml1 mptext
MPNAME=`/usr/libexec/PlistBuddy -c "Print $UUID" mptext`
rm mptext

# Install ProvisioningProfile
cp ${PROVISIONING_NAME}.mobileprovision ${HOME}/Library/MobileDevice/Provisioning\ Profiles/${MPNAME}.mobileprovision
PROVISIONING_PATH=\"${HOME}/Library/MobileDevice/Provisioning\ Profiles/${MPNAME}.mobileprovision\"
echo $PROVISIONING_PATH

# NOTE: Copy your iPhone developer certificate from "login" keychain to "System" keychain.
# Unlock keychain
echo "************** Unlock keychain ****************"
/usr/bin/security default-keychain -d user -s ${KEYCHAIN}
/usr/bin/security unlock-keychain -p nnsnodnb ${KEYCHAIN}
/usr/bin/security find-identity -p codesigning -v

# Build project
echo "************** Build project ****************"
BUILD_DIR=${WORKSPACE}/build
/usr/bin/xcodebuild -scheme ${SCHEME} -workspace ${WORKSPACE}/Falcon/Falcon.xcworkspace -sdk ${iOS_SDK} -configuration ${CONFIGURATION} clean build CODE_SIGN_IDENTITY="iPhone Developer" PROVISIONING_PROFILE=${MPNAME} CONFIGURATION_BUILD_DIR=${BUILD_DIR}

# Create ipa
echo "************** Create ipa file ****************"
IPA_FILE=${BUILD_DIR}/${IPA_FILE_NAME}
/usr/bin/xcrun -sdk iphoneos PackageApplication -v ${BUILD_DIR}/${SCHEME}.app -o ${IPA_FILE} --embed ${PROVISIONING_PATH}

# Upload to DeployGate
echo "************** Upload ipa to DeployGate ****************"
NOTE="DEVELOP"
MESSAGE=`git log --pretty=format:%H%x0a%s%x0a%b -1`

curl -F "token=${DG_API_KEY}" \
-F "message=${GIT_BRANCH}-${MESSAGE}" \
-F "distribution_key=${DG_DISTRIBUTION_KEY}" \
-F "release_note=${NOTE}" \
-F "file=@${IPA_FILE}" \
https://deploygate.com/api/users/${DG_USER}/apps
