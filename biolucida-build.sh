#!/bin/bash

# # # build the MBF app and deploy via adhoc + octopress

build_number=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ./Biolucida-Info.plist)
version_number=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ./Biolucida-Info.plist)

archive_path=$(printf "/Users/stonerri/Dropbox/WholeSlide/opensourcePlan/application/Biolucida/build/Biolucida-Adhoc-%s-%s.xcarchive" ${version_number//"."/"-"} $build_number)


echo $archive_path
echo $build_number

xcodebuild\
 -workspace "Biolucida.xcworkspace"\
 -scheme "Biolucida Adhoc"\
 archive -archivePath $archive_path

xcodebuild\
 -exportArchive -exportFormat ipa \
 -archivePath $archive_path \
 -exportPath "/Users/stonerri/Dropbox/WholeSlide/opensourcePlan/application/Biolucida/build/Biolucida-Adhoc-${version_number//"."/_}-$build_number.ipa" \
 -exportWithOriginalSigningIdentity

project_name="Biolucida-Adhoc-${version_number//"."/_}-$build_number"
artifacts_url="http://wholeslide.com/biolucida"
octopress_path="/Users/stonerri/Dropbox/WholeSlide/opensourcePlan/octopress/source/biolucida/"

# # # create plist file

cd "build"

/usr/libexec/PlistBuddy -c "Add :items array" $project_name.plist
/usr/libexec/PlistBuddy -c "Delete :items: dict" $project_name.plist
/usr/libexec/PlistBuddy -c "Add :items: dict" $project_name.plist
/usr/libexec/PlistBuddy -c "Add :items:0:assets array" $project_name.plist
/usr/libexec/PlistBuddy -c "Add :items:0:assets:0 dict" $project_name.plist
/usr/libexec/PlistBuddy -c "Add :items:0:assets:0:kind string" $project_name.plist
/usr/libexec/PlistBuddy -c "Set :items:0:assets:0:kind software-package" $project_name.plist
/usr/libexec/PlistBuddy -c "Add :items:0:assets:0:url string" $project_name.plist
/usr/libexec/PlistBuddy -c "Set :items:0:assets:0:url $artifacts_url/$project_name.ipa" $project_name.plist
/usr/libexec/PlistBuddy -c "Add :items:0:metadata dict" $project_name.plist
/usr/libexec/PlistBuddy -c "Add :items:0:metadata:bundle-identifier string" $project_name.plist
/usr/libexec/PlistBuddy -c "Set :items:0:metadata:bundle-identifier com.wholeslide.open" $project_name.plist
/usr/libexec/PlistBuddy -c "Add :items:0:metadata:bundle-version string" $project_name.plist
/usr/libexec/PlistBuddy -c "Set :items:0:metadata:bundle-version $build_number" $project_name.plist
/usr/libexec/PlistBuddy -c "Add :items:0:metadata:kind string" $project_name.plist
/usr/libexec/PlistBuddy -c "Set :items:0:metadata:kind software" $project_name.plist
/usr/libexec/PlistBuddy -c "Add :items:0:metadata:title string" $project_name.plist
/usr/libexec/PlistBuddy -c "Set :items:0:metadata:title $project_name" $project_name.plist

cp -v $project_name.ipa $octopress_path 
cp -v $project_name.plist $octopress_path

cd ..

