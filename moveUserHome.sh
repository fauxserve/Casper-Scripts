#!/bin/bash
clear
#set -x
####################################################################################################
#
# Copyright (c) 2013, JAMF Software, LLC.  All rights reserved.
#
#       This script was written by the JAMF Software Profesional Services Team
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
#	userHomeFix.sh
#
# SYNOPSIS - How to use
#
# Run this script by hand, do not run in a policy.
#
# Verify that the "companyDomainName" variable populates properly with whatever your domain name is.
# If the script below does not properly read your domain name, you can hard code it.
# 					 
# 
############################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Douglas Worley, Senior Professional Services Engineer, JAMF Software on March 23 2016
#
############################################################################################

# companyDomainFullName=""
# companyDomainShortName=""

companyDomainFullName=`dsconfigad -show | awk '/Active Directory Domain/ {print $5}'`
companyDomainShortName=`dscl /Search/Contacts -read / CSPSearchPath SearchPolicy | grep Active | cut -c 20- | rev | cut -c 13- | rev`
if [[ $companyDomainFullName == "" ]]; then
	echo " Error 
	This computer is not bound. Please bind to AD and retry."
	exit $?
fi


function getUsersDirView() {
	usersDirList=`ls -alh /Users`
}
getUsersDirView

echo "***********************************************************
		 Before View 

$usersDirList"
echo "
***********************************************************
*** Choose home folder to migrate (you can copy/paste): ***"
read homeFolder
echo "	Step 1 - Operator chose home folder: '$homeFolder'	"
echo "" & echo ""
echo "*** Enter $companyDomainFullName domain user account to assign to the home folder: ***"
read userName
echo "	Step 2 - Operator chose domain user: '$userName'	"
echo ""

mv "/Users/$homeFolder" "/Users/$userName"
	if [[ $? == "0" ]]; then
		echo " Successfully changed name of /Users/$userName"
	else
		echo " Error 
		There was a problem changing name of /Users/$userName"
		exit $?
	fi
chown -R "$userName:$companyDomainShortName\Domain Users" "/Users/$userName"
	if [[ $? == "0" ]]; then
		echo " Successfully changed permissions on /Users/$userName"
	else
		echo " Error 
		There was a problem changing permissions on /Users/$userName."
		exit $?
	fi

/usr/bin/find /Applications -uid $userName -exec chown "$userName:$companyDomainShortName\Domain Users" {} \;
	if [[ $? == "0" ]]; then
		echo " Successfully changed permissions of Applications owned by $userName"
	else
		echo " Error 
		There was a problem changing permissions on Applications owned by $userName."
		exit $?
	fi

getUsersDirView
userHomePerms=`ls -alh /Users/ | grep $userName | awk '{print $3}'`

echo "

***********************************************************
		 Result 

Home folder for '$userName' is now owned by user: '$userHomePerms'.
Does this look correct?

***********************************************************
		 After View 
$usersDirList

Please verify that the name of the home folder matches the ownership.
Please verify that there are no errors above.

***********************************************************
"