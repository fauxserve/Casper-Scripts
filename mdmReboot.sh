#!/bin/sh
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
#	mdmReboot.sh
#
# SYNOPSIS - How to use
#	Run via a policy to complete a few last minute actions after Casper Imaging has completed.
#
# DESCRIPTION
#	
# 	Verifies that APNS is working, and that we see a specific Configuration Profile matching a string to look for. 
#   Run a `profiles -P -v` command to find the string you want to look for.
#   Best practices are to search for something that is scoped to All Computers.
#
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Douglas Worley, Professional Services Engineer, JAMF Software on May 10, 2013
#
####################################################################################################

configProfileString=""	# something like FileVault
	if [ "$configProfileString" == "" ]; then
		echo "The variable configProfileString is blank. Please edit the script and enter a value to search for."
		exit 1
	fi

# set up a loop until APNS pushes a loginwindow configuration profile
configProfileStatus=`profiles -P -v | grep "$configProfileString"`
	if [ "$configProfileStatus" != "" ] 
		then echo "YES, Ready!"
		else
			until [ "$configProfileStatus" != "" ]; do
				echo "Waiting for config profile matching $configProfileString from APNS..."
				sleep 5
				configProfileStatus=`profiles -P -v | grep "$configProfileString"`
			done
			echo "$configProfileString Configuration Profile exists! Continuing..." 
	fi

# Once the above loop completes and the loginwindow configuration profile exists, reboot to display the loginwindow banner
echo "rebooting gracefully and submitting logs to JSS" && jamf reboot -background -immediately