#!/bin/bash 
#
# clear
# set -x
####################################################################################################
#
# Copyright (c) 2013, JAMF Software, LLC.  All rights reserved.
#
#       This script was written by the JAMF Software Profesional Services Team for the 
#		 JumpStart
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
#####################################################################################################
#
# SUPPORT FOR THIS PROGRAM
#
#       This program is distributed "as is" by JAMF Software, Professional Services Team. For more
#       information or support for this script, please contact your JAMF Software Account Manager.
#
#####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	changeBuildingJssApi.sh
#
# SYNOPSIS - How to use
#	
# Run in a policy or by hand to update a Mac's record in the JSS. 
# All three parameters/variables must be populated in order to work.
# 
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Douglas Worley, Senior Professional Services Engineer, JAMF Software on April 7 2016
#
####################################################################################################
# Enter full URL and credentials to the JSS
	apiUser=""
	apiPass=""
	BUILDING=""

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
if [ "$6" != "" ] && [ "$BUILDING" == "" ]; then
     BUILDING=$6
fi

########## Read values from the managed Mac to pass into the API PUT ##########
# jssUrl=""
jssUrl=`defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url | sed s'/.$//'`
serial=`system_profiler SPHardwareDataType | awk '/Serial/ {print $4}'`
xmlPath='/tmp/tmp.xml'

########## Create our XML file for API PUT ##########
cat <<EndXML > $xmlPath
<?xml version="1.0" encoding="UTF-8"?>
<computer>
	<location>
		<building>$BUILDING</building>
	</location>
</computer>
EndXML

########## Post XML file to JSS ##########
curl -sk -u $apiUser:$apiPass $jssUrl/JSSResource/computers/serialnumber/"${serial}"/subset/location -T $xmlPath -X PUT
echo ""
########## Clean up temp files ##########
# cat $xmlPath
rm -rf $xmlPath