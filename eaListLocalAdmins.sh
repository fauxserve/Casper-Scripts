#!/bin/bash
#
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
#	eaListLocalUsers.sh
#
# SYNOPSIS - How to use
#	
# Extension Attribute for Casper Suite. 
# 
# DESCRIPTION
# 	
# Will list all local users with Administrator privileges, and respond with an array up to the JSS.
# This can be used to target computers with too many local admins.
#
# You may consider inputting your known admin users into the parameters to automatically skip.
# Examples, your local standard IT user and/or the JAMF management account.
# 
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Douglas Worley, Senior Professional Services Engineer, JAMF Software on March 29 2016
#
####################################################################################################

the_group="admin"
has_admin="No"
allowedAdmin1=""
allowedAdmin2=""

[ "$4" != "" ] && [ "$allowedAdmin1" == "" ] && allowedAdmin1=$4
[ "$5" != "" ] && [ "$allowedAdmin2" == "" ] && allowedAdmin2=$5

# Check every user
rslt=$(/usr/bin/dscl . -list /Users | while read each_username
do
  if [ "${each_username}" != "root" ] && [ "${each_username}" != "$allowedAdmin1" ] && [ "${each_username}" != "$allowedAdmin2" ]; then
    member=$(/usr/bin/dsmemberutil checkmembership -U "${each_username}" -G "${the_group}" | cut -d " " -f 3)
    if [ "$member" == "a" ]; then
      if [ "$has_admin" == "No" ]; then
        has_admin="Yes"
        echo -n ${each_username}
      else
        echo -n ", ${each_username}"
      fi
    fi
  fi
done)

if [ "${rslt}" == "" ]; then
  echo "<result>None</result>"
else
  echo "<result>${rslt}</result>"
fi