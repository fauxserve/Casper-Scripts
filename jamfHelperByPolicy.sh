#!/bin/bash
#!/bin/sh
####################################################################################################
#
# Copyright (c) 2013, JAMF Software, LLC.  All rights reserved.
#
#       This script was written by the JAMF Software Profesional Services Team for the 
#		St. James Parish Imaging Project - May 2013
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
#	jamfHelperByPolicy.sh
#
# SYNOPSIS - How to use
#	Run via a policy to populate JAMF Helper with values to present messages to the user.
#
# DESCRIPTION
#	
# 	Populate script parameters to match the variables below. 
#   Pass in values into these parameters during a policy.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Douglas Worley, Professional Services Engineer, JAMF Software on May 10, 2013
#
####################################################################################################
# The recursively named JAMF Helper help file is accessible at:
# /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -help

windowType=""		#	[hud | utility | fs]
windowPosition=""	#	[ul | ll | ur | lr]
title=""			#	"string"
heading=""			#	"string"
description=""		#	"string"
icon=""				#	path
iconSize=""			#	pixels
timeout=""			#	seconds


[ "$4" != "" ] && [ "$windowType" == "" ] && windowType=$4
[ "$5" != "" ] && [ "$windowPosition" == "" ] && windowPosition=$5
[ "$6" != "" ] && [ "$title" == "" ] && title=$6
[ "$7" != "" ] && [ "$heading" == "" ] && heading=$7
[ "$8" != "" ] && [ "$description" == "" ] && description=$8
[ "$9" != "" ] && [ "$icon" == "" ] && icon=$9
[ "$10" != "" ] && [ "$iconSize" == "" ] && iconSize=$10
[ "$11" != "" ] && [ "$timeout" == "" ] && timeout=$11

"/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfhelper" -windowType "$windowType" -windowPosition "$windowPosition" -title "$title" -heading "$heading" -description "$description"  -icon "$icon" -iconSize "$iconSize" -button1 "Close" -defaultButton 1 -countdown "$timeout" -timeout "$timeout"