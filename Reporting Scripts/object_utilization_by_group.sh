#!/bin/sh
# v0.5 - in progress
# set -x
reset
####################################################################################################
#
# Copyright (c) 2015, JAMF Software, LLC.  All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are met:
#               * Redistributions of source code must retain the above copyright
#                 notice, this list of conditions and the following disclaimer.
#               * Redistributions in binary form must reproduce the above copyright
#                 notice, this list of conditions and the following disclaimer in the
#                 documentation and/or other materials provided with the distribution.
#               * Neither the name of the JAMF Software, LLC nor the
#                 names of its contributors may be used to endorse or promote products
#                 derived from this software without specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
####################################################################################################

########## Description ##########
##
#

##
########## End Description ##########


########## Usage ##########
##
#
# This script has three options for providing the required variables:
# 	1: Pass the variables in as shell parameters in line. (This requires quotes)
# 	2: Be prompted for the variables during shell execution (Do not include quotes)
#	3: Hard code variables into this script file
#
#
# How To Use:
# 	1)	To pass the variables in with script parameters in one line, keep the variables below blank.
# 		Then, provide the path to the script with the URL, user & resource in one line separated by spaces. 
#		If the Group contains spaces, please include the whole group in quotes.
# 		Example:
# 			./object_utilization_by_group.sh https://jamf.company.com:8443 ladmin "All Managed Clients"
# 		For security reasons, the password will need to be provided separately.
#
# 	2)	To be prompted for the variables, just run the unmodified script by itself and the shell will do the rest.
#
# 	3) 	To hard code variables you can fill them in under the Customization section. 
#		This option is not recommended.
#
##
########## End Usage ##########


### If the values are left blank here, they will be prompted for during execution, or can be passed in as parameters. 
### This option is not recommended. See Usage above.
# JSS URL
	jssUrl=""
# Full URL and credentials to the JSS. 
	apiUser=""
	apiPass=""
# Computer Group - What we are reporting on. These groups should not have commas in the name.
	apiComputerGroup=""
##
########## End Customization ##########



########## BODY OF SCRIPT - DO NOT MODIFY BELOW ##########
##

CurrentUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
CurrentUserHome=$(dscl . -read /Users/$CurrentUser NFSHomeDirectory 2>/dev/null | awk '{ print $2 }')
echo ""

# read parameters
	if [[ $jssUrl == "" ]]; then
		jssUrl=$1
	fi
	if [[ $apiUser == "" ]]; then
		apiUser=$2
	fi
	if [[ $apiComputerGroup == "" ]]; then
		apiComputerGroup=$3
	fi


	if [[ $jssUrl == "" ]]; then
		echo "Enter your full Jamf Pro Server address:"
		echo "	Example: https://jamf.company.com:8443"
		echo "	Example: https://company.jamfcloud.com"
		read jssUrl
	fi

	if [[ $apiUser == "" ]]; then
		echo "Enter valid API username:"
		read apiUser
	fi

	if [[ $apiPass == "" ]]; then
		echo ""
		echo "Enter valid API user password:"
		echo "(silent input)"
		read -s apiPass
	fi
	if [[ $apiComputerGroup == "" ]]; then
		echo "What JSS Computer Group do you want to report on?"
		echo "	Note: This must be spelled exactly as it is in the JSS."
		echo "	Note: Do not include quotes"
		echo "	Example: All Managed Clients"
		read apiComputerGroup
	fi
	echo ""
	echo ""


theDATE=$(date "+%Y_%m_%d")
theTIME=$(date "+%H_%M")
echo "The Date is: $theDATE"
echo "The Time is: $theTIME"
echo "" 
echo "Working parameters:"
echo "	local user: $CurrentUser"
echo "	local user home: $CurrentUserHome"
echo "	JSS URL: $jssUrl"
echo "	API username: $apiUser"
echo "	JSS Computer Group: \"$apiComputerGroup\""
echo ""
echo ""
echo ""
# File paths - Please do not modify
folderPath="$CurrentUserHome/Desktop/apiScript"
scratchFolderPath="$folderPath/Scratch"
file1="$folderPath/peripheralName.xml" # File used to create computer name variables
csvFile="$folderPath/Report_Utilization_of_Computer_Group_${apiComputerGroup}--${theDATE}--${theTIME}.csv" # CSV file used as our counter and computer name variable for our CURL loop
xmlPath="$folderPath/apiGET.xml" # File path to write our API GET.  This will be the computer information by ID
file2="$folderPath/report.txt" # Path to our final report.  Use txt as the file format please

rm -rf $scratchFolderPath
if [ ! -e  "$scratchFolderPath" ]; then
	mkdir -p "$scratchFolderPath"	# sleep 2
fi

### This is the kicker here. Generates a space separated array of every requirex ID type to be queried. Thanks to Chris Shasse on the proper formatting.


policyIdList=$(/usr/bin/curl -sk $jssUrl/JSSResource/policies --user "$apiUser:$apiPass" -H 'Accept: application/xml' -X GET | xpath "//policy[not(contains(name,'|'))]" 2>/dev/null | tidy -xml 2>/dev/null | grep '<id>' | sed -n 's|<id>\(.*\)</id>|\1|p' | sort -n)
	# echo "policyIdList is: $policyIdList"

macapplicationsIdList=$(/usr/bin/curl -sk -u $apiUser:$apiPass -H "Accept: application/xml" $jssUrl/JSSResource/macapplications | tidy -xml 2>/dev/null | grep '<id>' | sed -n 's|<id>\(.*\)</id>|\1|p' | sort -n)
# 	echo "macapplicationsIdList is: $macapplicationsIdList"

osxconfigurationprofilesIdList=$(/usr/bin/curl -sk -u $apiUser:$apiPass -H "Accept: application/xml" $jssUrl/JSSResource/osxconfigurationprofiles | tidy -xml 2>/dev/null | grep '<id>' | sed -n 's|<id>\(.*\)</id>|\1|p' | sort -n)
	# echo "osxconfigurationprofilesIdList is: $osxconfigurationprofilesIdList"

restrictedsoftwareIdList=$(/usr/bin/curl -sk -u $apiUser:$apiPass -H "Accept: application/xml" $jssUrl/JSSResource/restrictedsoftware | tidy -xml 2>/dev/null | grep '<id>' | sed -n 's|<id>\(.*\)</id>|\1|p' | sort -n)
# 	echo "osxconfigurationprofilesIdList is: $osxconfigurationprofilesIdList"



# How to parse data from API output (XML)
# https://jamfsoftware.atlassian.net/wiki/display/SW/Pasing+XML+Data+from+the+API

###
# Each variable to be generated into the csv will have an initial value so the first dump generates the csv headers on row 1. Each variable will be cleared and regenerated below.
valueGroupName="Group Name"
valueGroupID="Group ID"
valuePoliciesScopedToGroup="Policies"
valueMacProfilesScopedToGroup="macOS Profiles"
valueRestrictedSoftwareScopedToGroup="Restricted Software"
valueMacAppStoreAppScopedToGroup="Mac App Store"


########### HERE THERE BE FUNCTIONS ###########

function CsvDump {
csvDumpContent="${valueGroupName}, ${valueGroupID}, ${valuePoliciesScopedToGroup}, ${valueMacProfilesScopedToGroup}, ${valueRestrictedSoftwareScopedToGroup}, ${valueMacAppStoreAppScopedToGroup}"
# echo $csvDumpContent
echo $csvDumpContent>>$csvFile
}
CsvDump # Put in the column headers





function PolicyAttribution {
echo ""
echo "#	macOS Policies	#"
for policyId in ${policyIdList}; do
	tempFile="$folderPath/Scratch/policy_$policyId.xml"
		/usr/bin/curl -sk -u $apiUser:$apiPass -H "Accept: application/xml" $jssUrl/JSSResource/policies/id/$policyId | xmllint --format - --xpath /name 2>/dev/null > $tempFile
		policiesScopedToGroup=$(cat $tempFile | xpath //scope/computer_groups/computer_group/name 2>/dev/null)
	if [[ $(echo $policiesScopedToGroup | grep "<name>$apiComputerGroup</name>") !=  "" ]]; then
		policyName=$(cat $tempFile | xpath //policy/general/name 2>/dev/null | sed -e 's/\<name>//g; s/\<\/name>//g')
		echo "	 	Policy ID: $policyId - \"$policyName\" - Scope CONTAINS \"$apiComputerGroup\" "
		valuePoliciesScopedToGroup=$(expr $valuePoliciesScopedToGroup + 1)
		echo "		macOS Policy count is now: $valuePoliciesScopedToGroup"
	fi
done
}


function MacProfileAttribution {
echo ""
echo "#	macOS Profiles 	#"
for macProfileId in ${osxconfigurationprofilesIdList}; do
	tempFile="$folderPath/Scratch/macProfile_$macProfileId.xml"
		/usr/bin/curl -sk -u $apiUser:$apiPass -H "Accept: application/xml" $jssUrl/JSSResource/osxconfigurationprofiles/id/$macProfileId | xmllint --format - --xpath /name 2>/dev/null > $tempFile
		macProfileScopedToGroup=$(cat $tempFile | xpath //scope/computer_groups/computer_group/name 2>/dev/null)
	if [[ $(echo $macProfileScopedToGroup | grep "<name>$apiComputerGroup</name>") !=  "" ]]; then
		macProfileName=$(cat $tempFile | xpath //os_x_configuration_profile/general/name 2>/dev/null | sed -e 's/\<name>//g; s/\<\/name>//g')
		echo "	 	macOS Profile ID: $macProfileId - \"$macProfileName\" - Scope CONTAINS \"$apiComputerGroup\" "
			valueMacProfilesScopedToGroup=$(expr $valueMacProfilesScopedToGroup + 1)
		echo "		macOS Profile count is now: $valueMacProfilesScopedToGroup"
	fi
done
}

function MacRestrictedSoftwareAttribution {
echo ""
echo "#	macOS Restricted Software 	#"
for macRestrictedSoftwareId in ${restrictedsoftwareIdList}; do
	tempFile="$folderPath/Scratch/macRestrictedSoftware_$macRestrictedSoftwareId.xml"
		/usr/bin/curl -sk -u $apiUser:$apiPass -H "Accept: application/xml" $jssUrl/JSSResource/restrictedsoftware/id/$macRestrictedSoftwareId | xmllint --format - --xpath /name 2>/dev/null > $tempFile
		macRestrictedSoftwareScopedToGroup=$(cat $tempFile | xpath //scope/computer_groups/computer_group/name 2>/dev/null)
	if [[ $(echo $macRestrictedSoftwareScopedToGroup | grep "<name>$apiComputerGroup</name>") !=  "" ]]; then
		macRestrictedSoftwareName=$(cat $tempFile | xpath //mac_application/general/name 2>/dev/null | sed -e 's/\<name>//g; s/\<\/name>//g')
		echo "	 	macOS Profile ID: $macRestrictedSoftwareId - \"macRestrictedSoftwareName\" - Scope CONTAINS \"$apiComputerGroup\" "
			valueRestrictedSoftwareScopedToGroup=$(expr $valueRestrictedSoftwareScopedToGroup + 1)
		echo "		macOS Profile count is now: $valueRestrictedSoftwareScopedToGroup"
	fi
done
}

function MacAppStoreAppAttribution {
echo ""
echo "#	macOS App Store Apps 	#"
for macAppStoreAppId in ${macapplicationsIdList}; do
	tempFile="$folderPath/Scratch/macAppStoreApp_$macAppStoreAppId.xml"
		/usr/bin/curl -sk -u $apiUser:$apiPass -H "Accept: application/xml" $jssUrl/JSSResource/macapplications/id/$macAppStoreAppId | xmllint --format - --xpath /name 2>/dev/null > $tempFile
		macAppStoreAppScopedToGroup=$(cat $tempFile | xpath //scope/computer_groups/computer_group/name 2>/dev/null)
	if [[ $(echo $macRestrictedSoftwareScopedToGroup | grep "<name>$apiComputerGroup</name>") !=  "" ]]; then
		macAppStoreAppName=$(cat $tempFile | xpath //mac_application/general/name 2>/dev/null | sed -e 's/\<name>//g; s/\<\/name>//g')
		echo "	 	macOS App Store App ID: $macAppStoreAppId - \"$macAppStoreAppName\" - Scope CONTAINS \"$apiComputerGroup\"	 "
			valueMacAppStoreAppScopedToGroup=$(expr $valueMacAppStoreAppScopedToGroup + 1)
		echo "		Mac  App Store count is now: $valueMacAppStoreAppScopedToGroup"
	fi
done
}

##########
######### Run the actual program #########
# Reset the variables
	echo ""
	echo "Running the functions for group: $apiComputerGroup"
	echo "... This may take a while ..."
	valueGroupID=$(/usr/bin/curl -sk -u $apiUser:$apiPass -H "Accept: application/xml" $jssUrl/JSSResource/computergroups/name/ExcludeMe | xpath //computer_group/id 2>/dev/null | sed -e 's/\<id>//g; s/\<\/id>//g')
	valueGroupName="$apiComputerGroup"
	valuePoliciesScopedToGroup="0"
	valueMacProfilesScopedToGroup="0"
	valueRestrictedSoftwareScopedToGroup="0"
	valueMacAppStoreAppScopedToGroup="0"

# Run the functions
	PolicyAttribution
	MacProfileAttribution
	MacRestrictedSoftwareAttribution
	MacAppStoreAppAttribution
	CsvDump

echo "Done!
Please check out the report file located at: 
$csvFile"
