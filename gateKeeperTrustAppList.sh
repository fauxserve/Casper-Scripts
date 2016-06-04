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
#   gateKeeperTrustAppList.sh
#
# SYNOPSIS - How to use
#   Update the array below in your favorite text editor, then run the script in a shell or in a policy.
#   
# USAGE -  Populate two values:
# 
#   gatekeeperLabel
#       This is the value to be appended to each app, then trusted by Gatekeeper as a whole.
#       Example:
#            gatekeeperLabel="MyApprovedApps"
#
# 
#   allOfTheApps
#       This is an array containing the absolute path of each application, one per line. 
#       Each app path can contain spaces, and needs to be enclosed in "double quotes".
#       Example:
#           allOfTheApps=(
#                "/Applications/HandBrake.app"
#                "/Applications/Sublime Text.app"
#           )
# 
# ##################################################################################################
#
# HISTORY
#
#   Version: 1.0
#
#   - Created by Douglas Worley, Professional Services Engineer, JAMF Software on November 30, 2015
#
####################################################################################################


### Specify the label to be allowed, and all of the above apps to be added to:
gatekeeperLabel="MyApprovedApps"


### Input all full application paths, one per line, each path enclosed inside quotes. 
### It doesn't matter if the app is not installed on the Mac, logic below will only only approve the app if it exists.
allOfTheApps=(
	"/Applications/HandBrake.app"
    "/Applications/Sublime Text.app"
	)

###### DO NOT MODIFY CODE BELOW THIS LINE #######


### Set global Gatekeeper settings
spctl --master-enable
	if [ "$?" == "0" ]; then #error checking
	     echo "	Set Gatekeeper to only allow trusted applications"
	else
	     echo "ALERT - There was a problem with setting GateKeeper to allow only trusted applications"
	     exit "$?"
	fi

### Run through each of the apps in the list at the top, and take action on them, but only they exist on the Mac.
IFS=""
for eachApp in ${allOfTheApps[*]}
	do 
		if [ -e "${eachApp}" ]; then
			echo " 	- Approving application: ${eachApp}"
			spctl --add --label "$gatekeeperLabel" "${eachApp}"
				if [ "$?" == "0" ]; then #error checking
				     echo "		Set Gatekeeper to trust ${eachApp}"
				else
				     echo "ALERT - There was a problem with setting GateKeeper to trust ${eachApp}"
				fi
			chown root:wheel "${eachApp}"
				if [ "$?" == "0" ]; then #error checking
				     echo "		Set ownership for ${eachApp}"
				else
				     echo "ALERT - There was a problem with setting ownership for ${eachApp}"
				fi
		fi
	done

### enable the label for use by GateKeeper
spctl --enable --label "$gatekeeperLabel"
	if [ "$?" == "0" ]; then #error checking
	     echo "	Enabled Gatekeeper label: $gatekeeperLabel"
	else
	     echo "ALERT - There was a problem with enabling GateKeeper label: $gatekeeperLabel"
	     exit "$?"
	fi

### Pretty clean up to the operator of the script:
echo ""
echo "***** GateKeeper Status ****"
spctl --status
echo ""
