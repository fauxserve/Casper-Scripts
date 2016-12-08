#!/bin/bash

fvStatus=`fdesetup status`

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


