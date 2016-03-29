#!/bin/bash
 
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
#	sshAccess.sh
#
# SYNOPSIS - How to use
#	
# Run this script locally in a shell with sudo privileges or with a JAMF Policy
# 
# DESCRIPTION
# 	
# This script looks for parameters or locally saved variables to define user/group accounts to include
# into the ssh access list.
#
#
# USAGE
# 
# Run this script manually in a shell or via a Casper Policy. 
# Parameters can pass in sshUser and sshGroup values in policies.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#	- Created by Douglas Worley, Professional Services Engineer, JAMF Software on August 21, 2014
#
####################################################################################################

# Global variables
sshUser=""
sshGroup=""

# check for parameters to use later
if [ "$4" != "" ] && [ "$sshUser" == "" ]; then
    sshUser=$4
fi
if [ "$5" != "" ] && [ "$sshGroup" == "" ]; then
    sshGroup=$5
fi

# Add the required minimum users and group to the ssh access group in Directory Services. These are hard coded by use of the "hardCodedUser" and "hardCodedGroup" values
# dseditgroup -o edit -n /Local/Default -a "hardCodedUser" -t user com.apple.access_ssh
# dseditgroup -o edit -n /Local/Default -a admin -t "hardCodedGroup" com.apple.access_ssh

# Pass in additional users and groups via populated parameters from a policy
dseditgroup -o edit -n /Local/Default -a $sshUser -t user com.apple.access_ssh
dseditgroup -o edit -n /Local/Default -a $sshGroup -t group com.apple.access_ssh
