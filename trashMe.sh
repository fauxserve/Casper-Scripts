#!/bin/bash
#
####################################################################################################
#
# Copyright (c) 2013, JAMF Software, LLC.  All rights reserved.
#
#       This script was written by the JAMF Software Profesional Services Team for the 
#		 JumpStart
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
#    trashMe.com
# 
# SYNOPSIS - How to use
#
# Pass in the path of a file or folder to be moved into the current logged in user's Trash.
# This script does not empty the trash, the current logged in user must do that separately.
# 
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Douglas Worley, Professional Services Engineer, JAMF Software on August 27 2015
#
####################################################################################################

clear

theRubbish=""
[[ "$4" != "" ]] && [[ "$theRubbish" == "" ]] && "$theRubbish"="$4"

CurrentUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
userTrash="/Users/$CurrentUser/.Trash"
echo "Current user trashcan is $userTrash"

function trashTheRubbish () {
	thePieceOfRubbish=`basename "$theRubbish"`
	echo "Moving $thePieceOfRubbish to $userTrash"
	mv "$theRubbish" "$userTrash/$thePieceOfRubbish"
}

[[ -e "$theRubbish" ]] && trashTheRubbish || echo "File $theRubbish not found"