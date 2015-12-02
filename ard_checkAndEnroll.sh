#!/bin/bash
clear
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
#	ard_checkAndEnroll.sh
#
# SYNOPSIS - How to use
#	
# Run this script using Apple Remote Desktop to have the Mac check if it is managed, and if not enroll itself.
# 
# DESCRIPTION
# 	
# This script check for the existence of the jamf binary. 
# If the jamf binary is missing, the script curls and runs a reusable QuickAdd.pkg that has been hidden somewhere.
# 
#
# USAGE
#
# 1) Create a reusable QuickAdd package with Recon.app, 
# 2) Hide that QuickAdd somewehere publicly visible on the Internet. 
# 2a) A common path could be ///JSS/Tomcat/webapps/downloads/* inside your JSS.
# 3) Update the Global Variables below in the to match your download location. 
# 4) Copy and paste this script into the "Send Unix Command", and make sure to "Run command" as the root user.
# 4a) You can choose to "Save as Template..." for repeated use, and/or integrate into the ARD Task Server.
# 
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#	- Created by Douglas Worley, Professional Services Engineer, JAMF Software on August 5, 2015
#
####################################################################################################

# set -x     # DEBUG. Display commands and their arguments as they are executed
# set -v     # VERBOSE. Display shell input lines as they are read.
# set -n     # EVALUATE. Check syntax of the script but dont execute



########################
# Global Variables

downloadURL="https://jss.company.com:8443/downloads"	# The path to the web folder hosting your zipped QuickAdd.pkg (created with Recon.app)
workingPath="/tmp"										# The local path on the Mac where the zipped QuickAdd.pkg will be downloaded and worked on.
thePackage="QuickAdd_reusable.pkg"						# The name of the QuickAdd.pkg
theZipFile="QuickAdd_reusable.pkg.zip"							# The name of the zipped QuickAdd.pkg

########################

echo "Moving to working directory at $workingPath" && cd "$workingPath"


jamfBinaryStatus=`which jamf`	# Check for the presence of the jamf binary
if [ "$jamfBinaryStatus" != "" ]; then
     echo "	JAMF Binary is present."
     	jamfWorkingStatus=`jamf checkjssconnection` 	# Verify that the jamf binary actually works
			if [[ $jamfWorkingStatus == *"The JSS is available"*  ]] ; then
				echo "	The JSS is available."
			fi
     exit 0
else
     echo "The JAMF Binary is not present. Attempting to remedy this."
fi 

# clean up old versions
	if [ -e "$workingPath/$theZipFile" ];
	then
	    echo "	Old version of zip file found at $workingPath/$theZipFile, removing..."
		rm -rf "$workingPath/$theZipFile"
	else
	    echo "	Old version of zip file not found at $workingPath/$theZipFile, continuing..."
	fi

	if [ -e "$workingPath/$thePackage" ];
	then
	    echo "	Old version of pkg file found at $workingPath/$thePackage, removing..."
		rm -rf "$workingPath/$thePackage"
	else
	    echo "	Old version of pkg file not found at $workingPath/$thePackage, continuing..."
	fi

cd $workingPath

curl -O "$downloadURL/$theZipFile"	# Download the zipped QuickAdd
	if [ "$?" == "0" ]; then
	     echo "	Downloaded the zipped package at $downloadURL/$theZipFile"
	else
	     echo "	There was a problem with downloading the zipped package"
	fi 

unzip -o "$workingPath/$theZipFile" > /dev/null &	# Unzip the QuickAdd
	if [ "$?" == "0" ]; then
	     echo "	Unzipped the file to $workingPath/$theZipFile"
	else
	     echo "	There was a problem with unzipping the file at $workingPath/$theZipFile"
	fi 

installer -target / -pkg "$workingPath/$thePackage"		# Run the QuickAdd
	if [ "$?" == "0" ]; then
	     echo "	Installed the package at $workingPath/$thePackage."
	     echo "	Enrollment to the JSS was successful."
	else
	     echo "	There was a problem with installing the package at $workingPath/$thePackage"
	     echo "	There was a problem enrolling with the JSS."
	fi 

echo "Cleaning up!"
rm -rf "$workingPath/$thePackage"	# Delete the old version of the QuickAdd package
	if [ "$?" == "0" ]; then
	     echo "	Deleted the package at $workingPath/$thePackage"
	else
	     echo "	There was a problem with deleting the package at $workingPath/$thePackage"
	fi 
rm -rf "$workingPath/$theZipFile"	# Delete the old version of the Zip file
	if [ "$?" == "0" ]; then
	     echo "	Deleted the zip file at $workingPath/$theZipFile"
	else
	     echo "	There was a problem with deleting the zipfile at $workingPath/$theZipFile"
	fi 