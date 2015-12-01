#!/bin/bash
clear

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
#	osxMinimalDiskShrinker.sh
#
# SYNOPSIS - How to use
#	
# Run this script locally in a shell with sudo privileges. Do not run this script as part of a JAMF policy.
# 
# DESCRIPTION
# 	
# This script prompts the administrator to drag in a volume to thin out.
# This script deletes resources from Mac OS X that are not required for a minimal system. 
# 
# Use this for shrinking a system for use with NetBooting, USB boot disk, etc.
# Script prompts the administrator to drag in the icon of a mounted volume to shrink. 
# If the volume to be shrunk is a disk image, drag in the mounted volume - not the .dmg file.
#
# 
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#	- Created by Douglas Worley, Professional Services Engineer, JAMF Software on June 5, 2014
#
####################################################################################################

[ $EUID != 0 ] && echo "This script requires root privileges, please run \"sudo $0\"" && exit 1 

ScriptFileName=`basename $0`
ScriptName=`basename $ScriptFileName .sh`

# set -x     # DEBUG. Display commands and their arguments as they are executed
# set -v     # VERBOSE. Display shell input lines as they are read.
# set -n     # EVALUATE. Check syntax of the script but dont execute

###################
### Setup - Variables
DATE=$(date "+%Y_%m_%d")
TIME=$(date "+%H:%M")

logfilepath="/Library/MyLogs/"               # make sure the / is at the beginning and end of this path
if [ ! -d $logfilepath ]; then
     mkdir $logfilepath
     if [ "$?" = "0" ]; then
          echo "Creating directory $logfilepath"    
     else
          echo "Error - could not create directory $logfilepath"
     fi
fi    

logfile="${DATE}_${ScriptName}_${TIME}.txt"
exec 2>&1 > >(tee $logfilepath$logfile)                    # Uncomment me for full shell output to custom log
echo "" && echo ""
echo "Script name:          $ScriptName" && echo ""
echo "Log file path:          $logfilepath$logfile"
echo "Date and Time:          $DATE      $TIME"

###################
### Begin the logic for this script

echo "Drag in the volume to be shrunken:"
echo "	(this needs to be the volume, not the .dmg file)"
read targetVolume
echo ""
cd "$targetVolume"
echo "Target Volume is $targetVolume"
echo "Calculating space used - before shrinking:"
du -ch "$targetVolume" | grep total

function deleteTheFile
{
	while test $# -gt 0
	do
		# echo "	deleting file: $targetVolume$1"
		rm -rf "$targetVolume$1"
		shift
	done
}

# Long string here of files to delete, to be read by the function above. 
# Do not include quotation marks in file paths.
filesToDelete="/Applications/Address\ Book.app 
/Applications/Automator.app
/Applications/Calculator.app
/Applications/Calendar.app
/Applications/Chess.app
/Applications/Contacts.app
/Applications/DVD\ Player.app 
/Applications/Dashboard.app 
/Applications/Dictionary.app 
/Applications/FaceTime.app 
/Applications/Font\ Book.app 
/Applications/Game\ Center.app
/Applications/Image\ Capture.app 
/Applications/Launchpad.app
/Applications/Mail.app
/Applications/Maps.app
/Applications/Mission\ Control.app
/Applications/Notes.app
/Applications/Photo\ Booth.app
/Applications/QuickTime\ Player.app
/Applications/Reminders.app
/Applications/Stickies.app
/Applications/Time\ Machine.app
/Applications/Utilities/AirPort\ Utility.app
/Applications/Utilities/AppleScript\ Editor.app
/Applications/Utilities/Audio\ MIDI\ Setup.app
/Applications/Utilities/Bluetooth\ File\ Exchange.app 
/Applications/Utilities/Boot\ Camp\ Assistant.app
/Applications/Utilities/ColorSync\ Utility.app
/Applications/Utilities/DigitalColor\ Meter.app
/Applications/Utilities/Grab.app
/Applications/Utilities/Grapher.app
/Applications/Utilities/Migration\ Assistant.app
/Applications/Utilities/Podcast\ Capture.app
/Applications/Utilities/Podcast\ Publisher.app
/Applications/Utilities/RAID\ Utility.app
/Applications/Utilities/VoiceOver\ Utility.app
/Applications/Utilities/X11.app
/Applications/iBooks.app
/Applications/iCal.app
/Applications/iChat.app
/Applications/iTunes.app
/Library/Application\ Support/Apple/Automator
/Library/Application\ Support/Apple/Fonts
/Library/Application\ Support/Apple/Grapher
/Library/Application\ Support/Apple/Mail
/Library/Application\ Support/Apple/System\ Image\ Utility 
/Library/Application\ Support/Apple/WikiServer
/Library/Application\ Support/Apple/iChat\ Icons
/Library/Application\ Support/CrashReporter
/Library/Application\ Support/CrashReporter/* 
/Library/Application\ Support/Macromedia
/Library/Application\ Support/ProApps
/Library/Application\ Support/iLifeMediaBrowser
/Library/Audio/*
/Library/Caches/*
/Library/Desktop\ Pictures/*
/Library/Desktop\ Pictures/.DS_Store
/Library/Desktop\ Pictures/.thumbnails
/Library/Desktop\ Pictures/Abstract
/Library/Desktop\ Pictures/Aqua\ Blue.jpg
/Library/Desktop\ Pictures/Aqua\ Graphite.jpg
/Library/Desktop\ Pictures/Art
/Library/Desktop\ Pictures/Black\ \&\ White
/Library/Desktop\ Pictures/Classic\ Aqua\ Blue.jpg
/Library/Desktop\ Pictures/Classic\ Aqua\ Graphite.jpg 
/Library/Desktop\ Pictures/Flow\ 1.jpg
/Library/Desktop\ Pictures/Flow\ 2.jpg
/Library/Desktop\ Pictures/Flow\ 3.jpg
/Library/Desktop\ Pictures/Jaguar\ Aqua\ Blue.jpg
/Library/Desktop\ Pictures/Jaguar\ Aqua\ Graphite.jpg 
/Library/Desktop\ Pictures/Lines\ Blue.jpg
/Library/Desktop\ Pictures/Lines\ Graphite.jpg
/Library/Desktop\ Pictures/Lines\ Moss.jpg
/Library/Desktop\ Pictures/Lines\ Plum.jpg
/Library/Desktop\ Pictures/Nature
/Library/Desktop\ Pictures/Panther\ Aqua\ Blue.jpg
/Library/Desktop\ Pictures/Panther\ Aqua\ Graphite.jpg 
/Library/Desktop\ Pictures/Patterns
/Library/Desktop\ Pictures/Plants
/Library/Desktop\ Pictures/Ripples\ Blue.jpg
/Library/Desktop\ Pictures/Ripples\ Moss.jpg
/Library/Desktop\ Pictures/Ripples\ Purple.jpg
/Library/Desktop\ Pictures/Small\ Ripples.png
/Library/Desktop\ Pictures/Small\ Ripples\ graphite.png 
/Library/Desktop\ Pictures/Solid\ Colors
/Library/Desktop\ Pictures/Tiles\ Blue.jpg
/Library/Desktop\ Pictures/Tiles\ Pine.jpg
/Library/Desktop\ Pictures/Tiles\ Warm\ Grey.jpg
/Library/Developer/*
/Library/Dictionaries/*
/Library/Documentation/*
/Library/Fonts/*
/Library/Image\ Capture/*
/Library/Internet\ Plug-Ins/Flash\ Player.plugin
/Library/Internet\ Plug-Ins/NP-PPC-Dir-Shockwave
/Library/Internet\ Plug-Ins/flashplayer.xpt
/Library/Logs
/Library/Modem Scripts
/Library/PDF Services
/Library/Perl
/Library/Printers/*
/Library/QuickLook/iWork.qlgenerator
/Library/Receipts/*
/Library/Scripts
/Library/Spotlight
/Library/Updates/*
/Library/User\ Pictures/Animals
/Library/User\ Pictures/Flowers
/Library/User\ Pictures/Fun
/Library/User\ Pictures/Instruments
/Library/User\ Pictures/Nature
/Library/User\ Pictures/Sports/8ball.tif
/Library/User\ Pictures/Sports/Baseball.tif
/Library/User\ Pictures/Sports/Bowling.tif
/Library/User\ Pictures/Sports/Football.tif
/Library/User\ Pictures/Sports/Golf.tif
/Library/User\ Pictures/Sports/Hockey.tif
/Library/User\ Pictures/Sports/Soccer.tif
/Library/User\ Pictures/Sports/Target.tif
/Library/User\ Pictures/Sports/Tennis.tif
/Library/WebServer/*
/Library/Widgets/*
/Library/iTunes
/System/Library/Address\ Book\ Plug-Ins/*
/System/Library/Automator/*
/System/Library/Caches/*
/System/Library/CoreServices/Setup\ Assistant.app/Contents/Resources/ TransitionSection.bundle/Contents/Resources/intro-sound.mp3
/System/Library/CoreServices/Setup\ Assistant.app/Contents/Resources/ TransitionSection.bundle/Contents/Resources/intro.mov
/System/Library/CoreServices/Encodings/*
/System/Library/CoreServices/Front\ Row.app
/System/Library/CoreServices/Menu\ Extras/ExpressCard.menu
/System/Library/CoreServices/Menu\ Extras/Fax.menu
/System/Library/CoreServices/Menu\ Extras/HomeSync.menu
/System/Library/CoreServices/Menu\ Extras/Ink.menu
/System/Library/CoreServices/Menu\ Extras/IrDA.menu
/System/Library/CoreServices/Menu\ Extras/PPP.menu
/System/Library/CoreServices/Menu\ Extras/PPPoE.menu
/System/Library/CoreServices/Menu\ Extras/RemoteDesktop.menu
/System/Library/CoreServices/Menu\ Extras/Script Menu.menu
/System/Library/CoreServices/Menu\ Extras/Spaces.menu
/System/Library/CoreServices/Menu\ Extras/Sync.menu
/System/Library/CoreServices/Menu\ Extras/TextInput.menu
/System/Library/CoreServices/Menu\ Extras/TimeMachine.menu
/System/Library/CoreServices/Menu\ Extras/UniversalAccess.menu
/System/Library/CoreServices/Menu\ Extras/VPN.menu
/System/Library/CoreServices/Menu\ Extras/WWAN.menu
/System/Library/CoreServices/Menu\ Extras/iChat.menu
/System/Library/CoreServices/RawCamera.bundle
/System/Library/Fonts/AppleGothic.ttf 
/System/Library/Fonts/AquaKana.ttc 
/System/Library/Fonts/Courier.dfont
/System/Library/Fonts/LastResort.ttf 
/System/Library/Fonts/Menlo.ttc
/System/Library/Fonts/STHeiti\ Light.ttc
/System/Library/Fonts/儷黑\ Pro.ttf
/System/Library/Fonts/华⽂文⿊黑体.ttf 
/System/Library/Fonts/华⽂文细⿊黑.ttf 
/System/Library/Fonts/ヒラギノ明朝\ ProN\ W3.otf
/System/Library/Fonts/ヒラギノ角ゴ\ ProN\ W3.otf 
/System/Library/Fonts/ヒラギノ明朝\ ProN\ W6.otf 
/System/Library/Fonts/ヒラギノ角ゴ\ ProN\ W6.otf 
/System/Library/Frameworks/XgridFoundation.framework
/System/Library/Input\ Methods/50onPaletteServer.app
/System/Library/Input\ Methods/CharacterPalette.app
/System/Library/Input\ Methods/ChineseHandwriting.app
/System/Library/Input\ Methods/InkServer.app
/System/Library/Input\ Methods/KoreanIM.app
/System/Library/Input\ Methods/Kotoeri.app
/System/Library/Input\ Methods/PluginIM.app
/System/Library/Input\ Methods/SCIM.app
/System/Library/Input\ Methods/TCIM.app
/System/Library/Input\ Methods/TamilIM.app
/System/Library/Input\ Methods/VietnameseIM.app
/System/Library/PreferencePanes/Expose.prefPane
/System/Library/PreferencePanes/FibreChannel.prefPane
/System/Library/PreferencePanes/Ink.prefPane
/System/Library/PreferencePanes/Mac.prefPane
/System/Library/PreferencePanes/MobileMe.prefPane
/System/Library/PreferencePanes/Mouse.prefPane/Contents/Resources/ touchMovie.mov
/System/Library/PreferencePanes/SoftwareUpdate.prefPane
/System/Library/PreferencePanes/Spotlight.prefPane
/System/Library/PreferencePanes/TimeMachine.prefPane
/System/Library/PreferencePanes/Trackpad.prefPane/Contents/Resources/ BTTrackpad.mov
/System/Library/PreferencePanes/Trackpad.prefPane/Contents/Resources/ ButtonlessTrackpadCombo.mov
/System/Library/PreferencePanes/Trackpad.prefPane/Contents/Resources/ TrackpadCombo.mov
/System/Library/Screen\ Savers/Abstract.slideSaver
/System/Library/Screen\ Savers/Arabesque.qtz
/System/Library/Screen\ Savers/Beach.slideSaver
/System/Library/Screen\ Savers/Cosmos.slideSaver
/System/Library/Screen\ Savers/FloatingMessage.saver
/System/Library/Screen\ Savers/Forest.slideSaver
/System/Library/Screen\ Savers/Nature\ Patterns.slideSaver
/System/Library/Screen\ Savers/Paper\ Shadow.slideSaver
/System/Library/Screen\ Savers/RSS\ Visualizer.qtz
/System/Library/Screen\ Savers/Random.saver
/System/Library/Screen\ Savers/Shell.qtz
/System/Library/Screen\ Savers/Spectrum.qtz
/System/Library/Screen\ Savers/Word\ of\ the\ Day.qtz
/System/Library/Screen\ Savers/iTunes\ Artwork.saver
/System/Library/Speech/*
/System/Library/User\ Template/* 
/private/var/folders/*
/private/var/log/*
/private/var/vm/sleepimage
/private/var/vm/swapfile*
/usr/X11
/usr/bin/emacs
/usr/bin/emacs-undumped
/usr/bin/php
/usr/lib/mecab/dic
/usr/lib/podcastproducer
/usr/libexec/cups
/usr/share/cups
/usr/share/doc
/usr/share/emacs
/usr/share/gutenprint
/usr/share/man/*
/usr/share/vim"
# Make sure to close out the string here with a quote. 
# The string called filesToDelete starts waaaaay up there, and needs to terminate right here with no quotes in between.
# Any file paths with spaces need to use \ and not with quotation marks.



## here is the actual work
echo "Deleting Files Now!"
deleteTheFile $filesToDelete

echo "Calculating space used - after shrinking:"
du -ch "$targetVolume" | grep total