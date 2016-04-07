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
#	ea_hostnameTestAdLocal.sh
#
# SYNOPSIS - How to use
#	
# Extension attribute to validate that the local hostname of a Mac is the same as what it is bound to AD with.
# You can make a smart group where the contents are like "Mismatch" to find all computers needing attention.
# 
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
#	- Created by Douglas Worley, Senior Professional Services Engineer, JAMF Software on April 7 2016
#
####################################################################################################
clear

boundAdNameLong=`dsconfigad -show | awk '/Computer Account/ { print $4 }'`
boundAdNameShort=`echo "${boundAdNameLong%?}"`

echo "	This Mac's bound name in AD is:		$boundAdNameShort"

localHostname=`hostname -s`

echo "	This Mac's local hostname is:		$localHostname"

if [[ $boundAdNameShort == $localHostname ]]; then
echo "	The names match, all is fine"
echo "<result>$localHostname</result>"
else
echo " ALERT Then names do not match, please remediate	"
echo "<result>Mismatch - AD: $boundAdNameShort / Local: $localHostname</result>"
fi
exit $?