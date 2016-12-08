#!/bin/bash
#
####################################################################################################
#
# Copyright (c) 2015, JAMF Software, LLC.  All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are met:
#               * Redistributions of source code must retain the above copyright
#                 notice, this list of conditions and the following disclaimer.
#               * Redistributions in binary form must reproduce the above copyright
#                 notice, this list of conditions and the following disclaimer in the
#                 documentation and/or other materials provided with the distribution.
#               * Neither the name of the JAMF Software, LLC nor the
#                 names of its contributors may be used to endorse or promote products
#                 derived from this software without specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#   fvStatusJamfHelper.sh
#
# SYNOPSIS - How to use
#   
# 
# Run this script either in Self Service or by silent policy.
# 

# 
# 
# DESCRIPTION
#   
# This script works best in policies scoped to machines that have completed a FV policy 
# but still aren’t encrypted. 
# 
# 
# 
# 
####################################################################################################
#
# HISTORY
#
#   Version: 1.0
#
#   - Created by Douglas Worley, Senior Professional Services Engineer, JAMF Software on December 7 2016
#
####################################################################################################

fvStatus=$(fdesetup status)

windowType="utility"
title="Acme IT"
heading="FileVault Encryption"
icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FileVaultIcon.icns"
description="${fvStatus}"
timeout="100"
countdown=""

if [[ "$fvStatus" == "FileVault is On." ]]; then
    description="Your disk is fully encrypted. Press \"Update Apps\" to refresh Self Service."

    button=$( "/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper" \
    -windowType "$windowType" -windowPosition "$windowPosition" -title "$title" \
    -heading "$heading" -description "$description" -countdown "$countdown" \
    -timeout "$timeout" -icon "$icon" -iconSize "$iconSize" \
    -button1 "Close" -button2 "Update Apps" -defaultButton 1  
    )
    if [[ $button = 2 ]]; then
        jamf recon &
    fi
elif [[ "$fvStatus" == *Deferred* ]]; then
    description="Your disk is prepped for encryption. Press \"Restart\" to log out and enable encryption. You will need to enter your password to continue."

    button=$( "/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper" \
    -windowType "$windowType" -windowPosition "$windowPosition" -title "$title" \
    -heading "$heading" -description "$description" -countdown "$countdown" \
    -timeout "$timeout" -icon "$icon" -iconSize "$iconSize" \
    -button1 "Close" -button2 "Restart" -defaultButton 1  
    )
    if [[ $button = 2 ]]; then
        osascript -e 'tell application "System Events" to restart'
    fi
else
    "/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper" \
    -windowType "$windowType" -windowPosition "$windowPosition" -title "$title" \
    -heading "$heading" -description "$description" -countdown "$countdown" \
    -timeout "$timeout" -icon "$icon" -iconSize "$iconSize" \
    -button1 "Close" -defaultButton 1  
fi


