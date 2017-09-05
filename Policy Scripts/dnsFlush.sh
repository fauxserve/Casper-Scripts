#!/bin/bash
clear
# set -x

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
#	dnsFlush.sh
#
# SYNOPSIS - How to use
#	
# This script will query the operating system on the Mac then choose the appropriate method to flush DNS.
# 
# You can hard code the OS for testing purposes.
# 
# 
# 
# 
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Douglas Worley, Senior Professional Services Engineer, JAMF Software on June 13 2016
#
####################################################################################################

# Taken from: https://coolestguidesontheplanet.com/clear-the-local-dns-cache-in-osx/

function myLogger (){
    # This function sends messages to stdout as well as syslog
    # Use as you would myLogger
    tee >(logger) <<< $1
}

os_full_vers=$(sw_vers -productVersion)   # full version, ex “10.10.3"
	# os_full_vers=10.10.3 #### TESTING ONLY - you can hard code the variable here. Keep this line commented most of the time
os_minor_vers=$(myLogger $os_full_vers | awk -F. '{print $2}')   # single digit identifier, ex “10"
os_point_release=$(myLogger $os_full_vers | awk -F. '{print $3}')   # single digit identifier, ex “3"


myLogger "Full OS version is: $os_full_vers"
myLogger "OS Minor version is: $os_minor_vers"
myLogger "OS Point release is: $os_point_release"
myLogger ""

if [[ "$os_minor_vers" == 10 ]]; then
	if [[ "$os_point_release" -eq 0 || "$os_point_release" -eq 1 || "$os_point_release" -eq 2 || "$os_point_release" -eq 3 ]]; then
		sudo discoveryutil mdnsflushcache

		if [ "$?" == "0" ]; then #error checking
	    	myLogger "Successfully flushed DNS with discoveryutil"
		else
	    	myLogger "There was a problem with flushing DNS with discoveryutil"
	    	exit "$?"
	    fi
	elif [[ "$os_point_release" -eq 4 ]]; then
		killall -HUP mDNSResponder

		if [ "$?" == "0" ]; then #error checking
	    	myLogger "Successfully flushed DNS with mDNSResponder"
		else
	    	myLogger "There was a problem with flushing DNS with mDNSResponder"
	    	exit "$?"
	    fi
	fi
elif [[ "$os_minor_vers" -eq 5 || "$os_minor_vers" -eq 6 ]]; then 
	dscacheutil -flushcache

	if [ "$?" == "0" ]; then #error checking
    	myLogger "Successfully flushed DNS with dscacheutil"
	else
    	myLogger "There was a problem with flushing DNS with dscacheutil"
    	exit "$?"
	fi
else
	killall -HUP mDNSResponder

	if [ "$?" == "0" ]; then #error checking
		myLogger "Successfully flushed DNS with mDNSResponder"
	else
    	myLogger "There was a problem with flushing DNS with mDNSResponder"
    	exit "$?"
	fi
fi