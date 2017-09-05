#!/bin/sh
# v0 - in progress
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
# 		Then, provide the path to the script with the URL, user & resource in one line separated by spaces. If the Group contains spaces, please include the whole group in quotes.
# 		Example:
# 			./objects_scoped_to_named_computer_group.sh https://jamf.company.com:8443 ladmin policies "All Managed Clients"
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
# Resource - needs to match how JSS spells the resource. 
	apiResource=""
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
	if [[ $apiResource == "" ]]; then
		apiResource=$3
	fi
	if [[ $apiComputerGroup == "" ]]; then
		apiComputerGroup=$4
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
	if [[ $apiResource == "" ]]; then
		echo "What API resource do you want to report on?"
		echo "Example:"
		echo "	macapplications"
		echo "	osxconfigurationprofiles"
		echo "	policies"
		echo "	restrictedsoftware"
		read apiResource
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
echo "	JSS Object: $apiResource"
echo "	JSS Computer Group: $apiComputerGroup"
echo ""
echo ""
echo ""
# File paths - Please do not modify
folderPath="$CurrentUserHome/Desktop/apiScript"
scratchFolderPath="$folderPath/Scratch"
file1="$folderPath/peripheralName.xml" # File used to create computer name variables
csvFile="$folderPath/Report_${apiResource}_Scoped_To_Computer_Group_${apiComputerGroup}--${theDATE}--${theTIME}.csv" # CSV file used as our counter and computer name variable for our CURL loop
xmlPath="$folderPath/apiGET.xml" # File path to write our API GET.  This will be the computer information by ID
file2="$folderPath/report.txt" # Path to our final report.  Use txt as the file format please

rm -rf $scratchFolderPath
if [ ! -e  "$scratchFolderPath" ]; then
	mkdir -p "$scratchFolderPath"	# sleep 2
fi

### This is the kicker here. Generates a space separated array of every Peripheral ID to be queried. Thanks to Chris Shasse on the proper formatting.
apiResourceIdList=$(/usr/bin/curl -sk -u $apiUser:$apiPass -H "Accept: application/xml" $jssUrl/JSSResource/$apiResource | tidy -xml 2>/dev/null | grep '<id>' | sed -n 's|<id>\(.*\)</id>|\1|p' | sort -n)
# echo "apiResourceIdList is: $apiResourceIdList"

# How to parse data from API output (XML)
# https://jamfsoftware.atlassian.net/wiki/display/SW/Pasing+XML+Data+from+the+API

###
# Each variable to be generated into the csv will have an initial value so the first dump generates the csv headers on row 1. Each variable will be cleared and regenerated below.
valueApiResourceID="$apiResource ID"
valueApiResourceName="Name"
valueApiResourceScopedToGroup="Scoped To $apiComputerGroup"

########### HERE THERE BE FUNCTIONS ###########

function CsvDump {
csvDumpContent="${valueApiResourceID}, ${valueApiResourceName}, ${valueApiResourceScopedToGroup}"
# echo $csvDumpContent
echo $csvDumpContent>>$csvFile
}
CsvDump # Put in the column headers


#########

function ApiResourceLoop {
# sleep 2
echo " Working with File ID: $id "

tempFile="$folderPath/Scratch/file$id.xml"
# echo "tempFile is \"$tempFile\""

# /usr/bin/curl -sk -u $apiUser:$apiPass -H "Accept: application/xml" $jssUrl/JSSResource/$apiResource/id/$id/subset/general%26scope | xmllint --format - --xpath /name > $tempFile
/usr/bin/curl -sk -u $apiUser:$apiPass -H "Accept: application/xml" $jssUrl/JSSResource/$apiResource/id/$id | xmllint --format - --xpath /name > $tempFile

# cat $tempFile

# Each variable to be generated into the CSV file will be cleared and then re-populated by parsing the $tempFile. This ensures that the CSV headers are populated only once, as well as the row in the CSV for each $id has unique/new data.
# 2>&1

valueApiResourceName=""
	valueApiResourceName=$(cat $tempFile | xpath //general/name 2>/dev/null | sed -e 's/\<name>//g; s/\<\/name>//g')
	echo "	valueApiResourceName is \"$valueApiResourceName\""

valueApiResourceID=""
	## Even though the ID is read from the array, I'm checking the local cache file to verify that all of the data is consistent.
	valueApiResourceID=$(cat $tempFile | xpath //general/id 2>/dev/null | sed -e 's/\<id>//g; s/\<\/id>//g')
	echo "	valueApiResourceID is \"$valueApiResourceID\""

valueApiResourceScopedToGroup=""
	valueApiResourceScopedToGroup=$(cat $tempFile | xpath //scope/computer_groups/computer_group/name 2>/dev/null | sed -e 's/\<name>//g; s/\<\/name>//g')
	echo "	valueApiResourceScopedToGroup is \"$valueApiResourceScopedToGroup\""

# within one function, call another function to output the data into the CSV file
	if [[ "$valueApiResourceScopedToGroup" == *$apiComputerGroup* ]]; then
		echo "  valueApiResourceScopedToGroup MATCHES apiComputerGroup = writing $apiComputerGroup to file "
		CsvDump
	else
		echo "  valueApiResourceScopedToGroup DOES NOT match apiComputerGroup "
		echo "  $valueApiResourceScopedToGroup != $apiComputerGroup "
	fi

# rm $tempFile
}

function EchoLoop {
# This is for testing that the array is being read in the proper order.
	echo $id
}

######### Run the actual program #########

for id in ${apiResourceIdList}; do
	# EchoLoop
	ApiResourceLoop
done

# cp $csvFile $csvFileExport
# open -a /Applications/Microsoft\ Excel.app $csvFileExport
# 

# qlmanage -R "$csvFile"

echo "Done!
Please check out the report file located at: 
$csvFile"