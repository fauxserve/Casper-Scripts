#!/bin/bash

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
# SUPPORT FOR THIS PROGRAM
#
#       This program is distributed "as is" by JAMF Software.
#
####################################################################################################
#
#  AUTHOR
#    Original version by Lucas Vance, October 2015
#    Modified by Douglas Worley to allow parameters, discovery of JSS settings. Feb 2016
#
####################################################################################################

####################################################################################################
#
#  HARDCODED VARIABLES
#    These values may be hard coded for your specific environment, or may be passed in by parameters
#
####################################################################################################
# Enter full URL and credentials to the JSS
	apiUser=""
	apiPass=""
# Enter ID number of the EA
	eaID=""
# Enter the exact Display Name of the Extension Attribute (must be exactly how is in JSS)
	eaName=""
# Enter desired value for the EA (must match available values in JSS)
	value=""



####################################################################################################
#
#  DO NOT MODIFY BELOW THIS LINE!
#
####################################################################################################

########## Read in parameters from the policy ##########

if [ "$4" != "" ] && [ "$apiUser" == "" ]; then
     apiUser=$4
fi
if [ "$5" != "" ] && [ "$apiPass" == "" ]; then
     apiPass=$5
fi
if [ "$6" != "" ] && [ "$eaID" == "" ]; then
     eaID=$6
fi
if [ "$7" != "" ] && [ "$eaName" == "" ]; then
     eaName=$7
fi
if [ "$8" != "" ] && [ "$value" == "" ]; then
     value=$8
fi

########## Read values from the managed Mac to pass into the API PUT ##########

jssUrl=`defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url | sed s'/.$//'`
serial=`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}'`
xmlPath='/tmp/tmp.xml'

########## Create our XML file for API PUT ##########
cat <<EndXML > $xmlPath
<?xml version="1.0" encoding="UTF-8"?>
<computer>
	<extension_attributes>
		<extension_attribute>
			<id>$eaID</id>
			<name>$eaName</name>
			<type>String</type>
			<value>$value</value>
		</extension_attribute>
	</extension_attributes>
</computer>
EndXML

########## Post XML file to JSS ##########
curl -sk -u $apiUser:$apiPass $jssUrl/JSSResource/computers/serialnumber/"${serial}"/subset/extensionattributes -T $xmlPath -X PUT

########## Clean up temp files ##########
rm -rf $xmlPath