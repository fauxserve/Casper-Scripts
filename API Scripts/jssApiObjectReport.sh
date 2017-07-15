#!/bin/bash
v5
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
# This script generates a report via the API to get the count and names of each type of object.
# This is useful for comparing two various instances when doing a migration.
#
# This script requires the name of a JSS object as displayed in the JSS API documentation page:
# 	For example: https://jamf.company.com:8443/api/
#
##
########## End Description ##########


########## Usage ##########
##
#
# Description: This script has three options for providing the required variables:
# 	1: Pass the variables in as shell parameters in line
# 	2: Be prompted for the variables during shell execution
#	3: Hard code variables into this script file
#
#
# How To Use:
# 	1)	To pass the variables in with script parameters in one line, keep the variables below blank.
# 		Then, provide the path to the script with the URL, user & resource in one line separated by spaces.
# 		Example:
# 			./jssApiObjectReport.sh https://jamf.company.com:8443 ladmin scripts
# 		For security reasons, the password will need to be provided separately.
#
# 	2)	To be prompted for the variables, just run the unmodified script by itself and the shell will do the rest.
#
# 	3) 	To hard code variables you can fill them in under the Customization section. 
#		This option is not recommended.
#
##
########## End Usage ##########


########## Customization ##########
##

### If the values are left blank here, they will be prompted for during execution, or can be passed in as parameters. 
### This option is not recommended. See Usage above.
# JSS URL
	jssUrl=""
# Full URL and credentials to the JSS. 
	apiUser=""
	apiPass=""
# Resource - needs to match how JSS spells the resource. 
	apiResource=""
##
########## End Customization ##########


########## BODY OF SCRIPT - DO NOT MODIFY BELOW ##########
##

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

# Prompt the shell for variables if parameters are blank
	if [[ $jssUrl == "" ]]; then
		echo "Enter valid full JSS URL:"
		echo "example: https://jamf.company.com:8443"
		read jssUrl
	fi
	if [[ $apiUser == "" ]]; then
		echo "Enter valid API username:"
		read apiUser
	fi
	if [[ $apiPass == "" ]]; then
		echo "Enter valid API user password:"
		echo "(silent input)"
		read -s apiPass
	fi
	if [[ $apiResource == "" ]]; then
		echo "What API resource do you want to report on?"
		read apiResource
	fi

# output shell contents to log file

CurrentUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'); echo "working with user $CurrentUser"
CurrentUserHome=$(dscl . -read /Users/$CurrentUser NFSHomeDirectory 2>/dev/null | awk '{ print $2 }'); echo "working with user home: $CurrentUserHome"
theDATE=$(date "+%Y_%m_%d"); echo "theDATE is $theDATE"
theTIME=$(date "+%H:%M"); echo "theDATE is $theDATE"
jssHostName=$(echo $jssUrl | sed 's/........//' | sed 's/[/]//'| cut -f1 -d":")

logfilepath="$CurrentUserHome/Desktop/JSS_API_Report/"
logfile="$jssHostName-$apiResource.txt"
if [[ -e  "$logfilepath" ]]; then
	echo "Log path already exists at $logfilepath"
else
    mkdir -p $logfilepath
    echo "Creating log folder at $logfilepath"
fi
echo "Writing log file to $logfilepath$logfile"
# here is the magic
exec 2>&1 > >(tee $logfilepath$logfile)


# generate count of resources:
	resourceCount=$(/usr/bin/curl -sk -u $apiUser:$apiPass -H "Accept: application/xml" $jssUrl/JSSResource/$apiResource | xpath //size 2>/dev/null |  sed -e 's/\<size>//g; s/\<\/size>//g') 
# generate list of resources:
	resourceNames=$(/usr/bin/curl -sk -u $apiUser:$apiPass -H "Accept: application/xml" $jssUrl/JSSResource/$apiResource | tidy -xml 2>/dev/null | sed -n 's|<name>\(.*\)</name>|\1|p' | sort -f)

# display results to shell
echo "
##### REPORT for $apiResource on $jssUrl #####
Date: $theDATE
Time: $theTIME

	$apiResource - Count: 	
$resourceCount

	$apiResource - Names: 	
${resourceNames}
"

##
########## END BODY OF SCRIPT ##########

# Raise attention ot the log files:
# open "$logfilepath"
# qlmanage -p "$logfilepath$logfile" &