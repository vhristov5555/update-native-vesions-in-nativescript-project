# !/bin/bash

function usage() {
    echo "Update native versions in nativescript application script..."
    echo "Update native versions in nativescript application script..."
}

function generateVersion() {
    # get epoch time 
    local version=`date +%s`
    echo $version
}

function updateAndroidversionCode() {
    echo "update android version code"
    androidManifestFile="./app/App_Resources/Android/src/main/AndroidManifest.xml"
    value=`cat ${androidManifestFile}`
    androidRegex="versionCode\=\"([0-9]+)\""
    if [[ $value =~ $androidRegex ]]; then
    androidVersionCode="${BASH_REMATCH[1]}"
    fi
    androidOldValue="versionCode=\"${androidVersionCode}\""
    androidNewValue="versionCode=\"${1}\""

    echo "new version code: ${androidNewValue}"
    `sed -i "" "s/${androidOldValue}/${androidNewValue}/g" ${androidManifestFile}`
}

function updateVersionName() {
    echo "update android version name"
    androidManifestFile="./app/App_Resources/Android/src/main/AndroidManifest.xml"
    value=`cat ${androidManifestFile}`
    androidRegex="versionName\=\"([0-9]+).([0-9]+)\""
    if [[ $value =~ $androidRegex ]]; then
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    fi
    androidOldValue="versionName=\"${major}.${minor}\""
    androidNewValue=""
    regexWithTwoVersions="([0-9]+)\.([0-9]+)"
    if [[ ${1} =~ $regexWithTwoVersions ]]; then
        major="${BASH_REMATCH[1]}"
        minor="${BASH_REMATCH[2]}"
        androidNewValue="versionName=\"${major}.${minor}\""
    else
        androidNewValue="versionName=\"${major}.${1}\""
    fi
    echo "new version name: ${androidNewValue}"
    `sed -i "" "s/${androidOldValue}/${androidNewValue}/g" ${androidManifestFile}`
}

function updateIOSCFBundleVersion() {
    echo "update ios CFBundleVersion"
    iosInforPlistFile="./app/App_Resources/iOS/Info.plist"
    inforPlistValue=`cat ${iosInforPlistFile}`
    major=0
    minor=0
    build=0
    iosRegex="<key>CFBundleVersion<\/key>(.+)<string>([0-9]+).([0-9]+).([0-9]+)"
    if [[ $inforPlistValue =~ $iosRegex ]]; then
    major="${BASH_REMATCH[2]}"
    minor="${BASH_REMATCH[3]}"
    build="${BASH_REMATCH[4]}"
    fi
    iosOldValue="<string>${major}.${minor}.${build}</string>"
    iosNewValue=""
    regexWithFullVersion="([0-9]+)\.([0-9]+)\.([0-9]+)"
    regexWithTwoVersions="([0-9]+)\.([0-9]+)"
    if [[ ${1} =~ $regexWithTwoVersions ]]; then
        minor="${BASH_REMATCH[1]}"
        build="${BASH_REMATCH[2]}"
        iosNewValue="<string>${major}.${minor}.${build}</string>"
        if [[ ${1} =~ $regexWithFullVersion ]]; then
            major="${BASH_REMATCH[1]}"
            minor="${BASH_REMATCH[2]}"
            build="${BASH_REMATCH[3]}"
            iosNewValue="<string>${major}.${minor}.${build}</string>"
        fi
    else
        iosNewValue="<string>${major}.${minor}.${1}</string>"
    fi
    echo "new version: ${iosNewValue}"
    `sed -i "" "s|${iosOldValue}|${iosNewValue}|g" ${iosInforPlistFile}`
}

function updateIOSCFBundleShortVersionString() {
    echo "update ios CFBundleShortVersionString"
    iosInforPlistFile="./app/App_Resources/iOS/Info.plist"
    inforPlistValue=`cat ${iosInforPlistFile}`
    major=0
    minor=0
    build=0
    iosRegex="<key>CFBundleShortVersionString<\/key>(.+)<string>([0-9]+).([0-9]+)</string>"
    if [[ $inforPlistValue =~ $iosRegex ]]; then
    major="${BASH_REMATCH[2]}"
    minor="${BASH_REMATCH[3]}"
    fi
    iosOldValue="<string>${major}.${minor}</string>"
    iosNewValue=""
    regexWithTwoVersions="([0-9]+)\.([0-9]+)"
    if [[ ${1} =~ $regexWithTwoVersions ]]; then
        major="${BASH_REMATCH[1]}"
        minor="${BASH_REMATCH[2]}"
        iosNewValue="<string>${major}.${minor}</string>"
    else
        iosNewValue="<string>${major}.${1}</string>"
    fi
    echo "new version: ${iosNewValue}"
    `sed -i "" "s|${iosOldValue}|${iosNewValue}|g" ${iosInforPlistFile}`
}

# intialize variables
args=("$@")
versionsToUpdate=""
platform=""
CFBundleShortVersionString=""
CFBundleVersion=""
versionName=""
versionCode=""

# process arguments
for (( i=0; i<=$#-1; i++ ))
  do 
    argumentLowerCase="$(tr [A-Z] [a-z] <<< "${args[i]}")"
    argument="${argumentLowerCase//-/}"
    case "$argument" in
        "help"|"h")
            usage
			;;
		"versiontoupdate")
            versionsToUpdate="$(tr [A-Z] [a-z] <<< "${args[i+1]}")"
			;;
		"platform")
            platform="$(tr [A-Z] [a-z] <<< "${args[i+1]}")"
			;;
		"cfbundleshortversionstring")
            CFBundleShortVersionString=${args[i+1]}
			;;
		"cfbundleversion")
            CFBundleVersion=${args[i+1]}
			;;
		"versionname")
            versionName=${args[i+1]}
			;;
		"versioncode")
            versionCode=${args[i+1]}
			;;
    esac
 done

# echo $versionsToUpdate
# echo $platform
# echo $CFBundleShortVersionString
# echo $CFBundleVersion
# echo $versionName
# echo $versionCode

# update versions
case "$platform" in
		"android")
            if [ "$versionsToUpdate" == 'private' ] || [ "$versionsToUpdate" == 'all' ] || [ "$versionsToUpdate" == '' ]
            then
                if [ "$versionCode" == "" ]; then
                    versionCode=$(generateVersion) 
                fi 
                updateAndroidversionCode $versionCode
            fi
            if [ "$versionsToUpdate" == 'public' ] || [ "$versionsToUpdate" == 'all' ] 
            then
                if [ "$versionName" == "" ]; then
                    versionName=$(generateVersion)
                fi 
                updateVersionName $versionName
            fi
			;;
		"ios")

            if [ "$versionsToUpdate" == 'private' ] || [ "$versionsToUpdate" == 'all' ] || [ "$versionsToUpdate" == '' ]
            then
                if [ "$CFBundleVersion" == "" ]; then
                    CFBundleVersion=$(generateVersion) 
                fi 
                updateIOSCFBundleVersion $CFBundleVersion
            fi
            if [ "$versionsToUpdate" == 'public' ] || [ "$versionsToUpdate" == 'all' ] 
            then
                if [ "$CFBundleShortVersionString" == "" ]; then
                    CFBundleShortVersionString=$(generateVersion)
                fi 
                updateIOSCFBundleShortVersionString $CFBundleShortVersionString
            fi
			;;
		"both")
            if [ "$versionsToUpdate" == 'private' ] || [ "$versionsToUpdate" == 'all' ] || [ "$versionsToUpdate" == '' ]
            then
                if [ "$versionCode" == "" ]; then
                    versionCode="$(generateVersion)"
                fi 
                if [ "$CFBundleVersion" == "" ]; then
                    CFBundleVersion=$(generateVersion) 
                fi 
                updateAndroidversionCode $versionCode
                updateIOSCFBundleVersion $CFBundleVersion
            fi
            if [ "$versionsToUpdate" == 'public' ] || [ "$versionsToUpdate" == 'all' ] 
            then
                if [ "$versionName" == "" ]; then
                    versionName=$(generateVersion)
                fi 
                if [ "$CFBundleShortVersionString" == "" ]; then
                    CFBundleShortVersionString=$(generateVersion)
                fi
                updateVersionName $versionName
                updateIOSCFBundleShortVersionString $CFBundleShortVersionString
            fi
			;;
	esac


