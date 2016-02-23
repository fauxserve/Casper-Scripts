#!/bin/bash
#
####################################################################################################
#
# Copyright (c) 2014, JAMF Software, LLC.  All rights reserved.
#
#       This script was written by the JAMF Software Profesional Services Team for the 
#		F5 Encompass Engagement
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
#	silentUserLogout.sh
#
# Usage - Run this script in a policy to have Mac OS X log the current user out while bypassing the 
# "Are you sure you want to quit all applications and log out now" window.
# 
# This is helpful in combination with FileVault 2 policies activated "At Next Logout"
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


CurrentUser=$(ls -l /dev/console | awk '{print $3}'); echo "$CurrentUser"

su \- "${CurrentUser}" -c osascript -e <<EOT
tell application "System Events" to keystroke "q" using {option down, shift down, command down}
EOT
