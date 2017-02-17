#!/bin/bash
#
####################################################################################################
#
# Copyright (c) 2014, JAMF Software, LLC.  All rights reserved.
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
#	logUserOut.sh
#
# Usage - Run this script in a policy to have Mac OS X log the current user out. 
#
# By default the script will prompt the user to log out, but if the JAMF Policy parameter passes in a YES, 
# then perform a silent logout.
# 
# This is helpful in combination with FileVault 2 policies activated "At Next Logout".
#
# If you have your FV2 policy run via Self Service, then the default "NO" setting is best.
# If you have your FV2 policy running silently, then either hardcode the variable below or use a policy parameter
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Douglas Worley, Senior Professional Services Engineer, JAMF Software on February 20 2016
#
####################################################################################################
 
silentLogoutYN="N" #yes/YES/y/Y/no/NO/n/N

# Override whatever the hardcoded selection for $silentLogoutYN with whatever comes from the JSS
[ "$4" != "" ] && silentLogoutYN=$4

#################

CurrentUser=$(ls -l /dev/console | awk '{print $3}'); echo "$CurrentUser"


## Functions ###

function myLogger (){
    tee >(logger) <<< $1
}

function SilentLogout () {
myLogger " Peforming Silent Logout"
su \- "${CurrentUser}" -c osascript -e <<EOT
tell application "System Events" to keystroke "q" using {option down, shift down, command down}
EOT
}

function PromptUserLogout () {
myLogger " Prompting User to Log Out"
su \- "${CurrentUser}" -c osascript -e <<EOT
tell application "System Events" to keystroke "q" using {shift down, command down}
EOT
}


### Determine which path to take, and run the appropriate function ###

case ${silentLogoutYN} in
	y* | Y* ) SilentLogout;;
	n* | N* ) PromptUserLogout;;
  * ) echo "Please enter a choice for whether to log out silently";;
esac