#!/bin/bash

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
#	openAppAsRoot.sh
#
# SYNOPSIS - How to use
#	
# Run this script locally in a shell with sudo privileges or with a JAMF Policy
# 
# DESCRIPTION
# 	
# This script reads in an application name and then preps the app to be opened with Root privileges.
#
# Example - Correct:    Safari
#           Incorrect:  Safari.app
#
#
# USAGE
# 
# $4 parameter - do not include the .app extension.
# $5 parameter - defaults to /Applications, but you can specify an alternat enclosing folder.
# 
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#	- Created by Douglas Worley, Professional Services Engineer, JAMF Software on April 7, 2014
#
####################################################################################################
clear

app=""
appPath="/Applications"

if [ "$4" != "" ] && [ "$app" == "" ]; then
     app=$4
fi 
if [ "$5" != "" ] ; then
     appPath=$5
fi 

fullAppName="$appPath/${app}.app/Contents/MacOS/${app}"
APPLICATION="$appPath/${app}.app"

echo "working with ${APPLICATION}"
chflags -R nouchg "${APPLICATION}"
	if [ "$?" == "0" ]; then
		echo "	chflags removed on ${APPLICATION}"
	else
	     echo "*	There was a problem removing chflags"
	fi 
xattr -d com.apple.quarantine "${APPLICATION}"
	if [ "$?" == "0" ]; then
		echo "	removed quarantine bit on ${APPLICATION}"
	else
	     echo "*	There was a problem removing the quarantine bit on ${APPLICATION}"
	fi 
chmod -R +x "${APPLICATION}"
	if [ "$?" == "0" ]; then
		echo "	set execute bit on ${APPLICATION}"
	else
	     echo "*	There was a problem setting the execute bit on ${APPLICATION}"
	fi 

sudo -u root "$fullAppName" &
	if [ "$?" == "0" ]; then
		echo "	opened application '${fullAppName}' at binary level as root"
	else
	     echo "*	There was a problem opening application '${fullAppName}' at binary level as root"
	fi

sleep 1

theApp="${app}"
osascript -e "tell application \"$theApp\"  to activate"
	if [ "$?" == "0" ]; then
		echo "	bringing application ${theApp} to front"
	else
	     echo "*	There was a problem bringing application ${theApp} to front"
	fi

exit 0