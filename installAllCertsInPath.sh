#!/bin/bash
function myLogger (){
	# this function sends messages to stdout as well as system.log
	# use as you would echo
	tee >(logger) <<< $1
}
[ $EUID != 0 ] && myLogger "This script requires root privileges, please run \"sudo $0\"" && exit 1
####################################################################################################
#
# Copyright (c) 2013, JAMF Software, LLC.  All rights reserved.
#
#       This script was written by the JAMF Software Profesional Services Team for the 
#		St. James Parish Imaging Project - May 2013
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
#	installAllCertsInPath.sh
#
# SYNOPSIS - How to use
#	Include in a Composer pkg project as a "preflight" script.
# 	
# USAGE - Populate these two variables: 
# 1) certPath
# 	This is the directory containing all certs to import.
# 	Do not use \, use quotes to handle spaces in the path.
# 	Make sure to include the / at the end.
# 	Example: "/var/db/my certificates/"
	certPath="/var/db/my certificates/"	
# 2) keyChain
# 	This is the full path to the Keychain file for the script to import into:
#	Example: "/Library/Keychains/System.keychain"
	keyChain="/Library/Keychains/System.keychain"
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Douglas Worley, Professional Services Engineer, JAMF Software on November 30, 2015
#
####################################################################################################


### DO NOT EDIT BELOW THIS LINE ###
cd "$certPath"
myLogger "* Working with certificates located at: `pwd`/"	
myLogger "*	Working with keychain located at: $keyChain"	

# Set up a "for loop" to find all certs in the folder and install them:
function installTheCerts (){
for cert in "$certPath"* ; do
	cert=${cert##*/} # cleans up the filename
	echo ""
	myLogger "*	Installing certificate: ${cert}"
	# myLogger "*	Full certificate path: ${certPath}${cert}"
	security add-trusted-cert -d -r trustRoot -k "$keyChain" "${certPath}${cert}" # Does the thing.
		if [ "$?" == "0" ]; then #error checking
     		myLogger "*	Successfully installed cert: ${cert}"
		else
     		myLogger "**	There was a problem with installing certificate: ${cert}"
		fi
done
}

# Do some basic error checking and install all of the certs in the specified folder
if [[ "$certPath" != "" ]]; then
	installTheCerts	#run the function above
else
	myLogger "**	Variable 'certPath' is blank. Edit the script and run again."
	exit 1
fi