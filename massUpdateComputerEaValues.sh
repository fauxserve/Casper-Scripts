#!/bin/bash
#set -x
reset 
####################################################################################################
#
# Copyright (c) 2013, JAMF Software, LLC.  All rights reserved.
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
#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
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
#
# ABOUT THIS PROGRAM
#
# NAME
#	massUpdateComputerEaValues.sh
#
#   Create a CSV where: 
#		Column A is a list of serial numbers
#		Column B is the value of the Extension Attribute (must be exactly how is in JSS)
#
#	This CSV file will be passed to the "inputFile" parameter in the script.
#
# SYNOPSIS - with parameters
#	massUpdateComputerEaValues.sh <apiUser> <apiPass> <eaID> <eaName> <JSSURL> <inputFile> 
#	
#	The script will prompt for any of these parameters that are not hard coded into the file.
#
# DESCRIPTION
#	This script reads computer/client information from a CSV file and imports the data into the JSS.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#	- Inspired by Justin Ingebretson and Trey Howell, JAMF Software
#	- Created by Douglas Worley Senior PSE, JAMF Software on June 1, 2016
#
####################################################################################################


# Enter full URL and credentials to the JSS
	apiUser=""
	apiPass=""
# Enter numeric ID number of the EA 
#	(You can discover this by reading a full Computer record in the API page)
	eaID=""
# Enter the exact Display Name of the Extension Attribute (must be exactly how is in JSS)
#	(You can discover this by reading a full Computer record in the API page)
	eaName=""
# JSS URL to PUT based on Serial Number. This could be "id" or "name"
	JSSURL=""
# CSV File to that contains serials and EA values
	inputFile=""
# Temporary XML file to be used 
	tmpXmlFile="/tmp/tmp.xml"

# ####################################################################################################
#
# CODE BELOW SHOULD NOT BE MODIFIED
#
####################################################################################################

# Output results of network tests
echo "         JAMF Software - Professional Services"
echo "Mass Update Computer Extension Attributes" && echo ""


if [[ $apiUser == "" ]] 
		then
		echo "Enter API user account:"
		echo "	example: jssadmin"
		read apiUser
fi
echo ""

if [[ $apiPass == "" ]] 
		then
		echo "Enter API user account:"
		echo "	(silent input)"
		read -s apiPass
fi
echo ""

if [[ $eaID == "" ]] 
		then
		echo "Enter numeric ID for the Extension Attribute:"
		echo "	example: 3"
		read eaID
fi
echo ""

if [[ $eaName == "" ]] 
		then
		echo "Enter name for the Extension Attribute:"
		echo "	Status"
		read eaName
fi
echo ""

if [[ $JSSURL == "" ]] 
		then
		echo "Enter full JSS URL, without trailing slash:"
		echo "	https://jss.company.com:8443"
		read JSSURL
fi
echo ""

if [[ $inputFile == "" ]] 
		then
		echo "Enter path to CSV file:"
		echo "	/Users/admin/Desktop/examplecsv.csv"
		echo "	(you can drag the file into the shell)"
		read inputFile
fi
echo ""

echo "***** Running the script - this could take some time. See you in a moment... *****"
##Count the number of lines in the file so we know how many clients to submit##
count=`cat "${inputFile}" | awk 'END{print NR}'`

##Set a variable to being counting the .csv line to be submitted##
index="0"

##Loop through the .csv and submit the unique barcodes and unique asset tags based on##
##the client's unique mac address to the JSS until we've reached the end of the .csv##
while [ $index -lt ${count} ] 
do
	touch $tmpXmlFile
	##Increment our counter by 1 for each iteration##
	index=$[$index+1]
	
	##Set unique variables to read the next line in the .csv##
	serialNumber=`cat "${inputFile}" | awk -F, 'FNR == '$[$index]' {print $1}'`
    eaValue=`cat "${inputFile}" | awk -F, 'FNR == '$[$index]' {print $2}'`

echo ""
echo ""
echo "Current iteration through file: $index"
echo "Serial Number is: $serialNumber"
echo "EA Value is: $eaValue"
fullApiPath="$JSSURL/JSSResource/computers/serialnumber/$serialNumber"
echo "Full API Path is: $fullApiPath"
echo ""


cat <<EndXML > $tmpXmlFile
<?xml version="1.0" encoding="UTF-8"?>
<computer>
	<extension_attributes>
		<extension_attribute>
			<id>$eaID</id>
			<name>$eaName</name>
			<type>String</type>
			<value>$eaValue</value>
		</extension_attribute>
	</extension_attributes>
</computer>
EndXML


echo "XML file is:"
cat "$tmpXmlFile"
echo ""



##Submit the .csv data to the JSS via the JSS API##
    curl -k -v -u $apiUser:$apiPass $fullApiPath -T $tmpXmlFile -X PUT
##Clean up the temporary .xml file##
rm $tmpXmlFile
done
echo ""
echo "***** Done updating Computer Extension Attributes *****"
echo "***** Please check and verify in the JSS: $JSSURL *****"
echo ""



exit $?
