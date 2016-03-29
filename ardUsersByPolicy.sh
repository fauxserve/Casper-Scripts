#!/bin/bash
#
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
#	ardPolicy.sh
# 
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Douglas Worley, Senior Professional Services Engineer, JAMF Software on March 26 2016
#
####################################################################################################

# HARDCODED VALUE FOR "USERNAME" IS SET HERE
users=""

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "USERNAME"
# Multiple users can be specified in a single string, separated by a comma. Example: "user1,user2"

if [ "$4" != "" ] && [ "$users" == "" ];then
    users=$4
fi




if [ "$users" != "" ]; then
	echo "Enabling Apple Remote Desktop Agent..."
	/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -allowAccessFor -specifiedUsers
	echo "Setting Remote Management Privileges for User: $users ..."
	/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -access -on -privs -all -users $users
else
	echo "Error:  The parameter 'users' is blank.  Please specify a user."
fi

