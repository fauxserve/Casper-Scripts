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
#	wipedisk.sh
#
# SYNOPSIS - How to use
#	
# Run this script as part of a JAMF Imaging Config
# 
# DESCRIPTION
# 	
# This script wipes the first internal hard disk (disk0) in such a way to destroy all 
# FileVault and Boot Camp data, allowing Casper Imaging to then prep for a full deployment.
#
#
# USAGE
# 
# Set the priority to "before", as well as choose the checkbox for "Erase target drive" 
# when running Casper Imaging
#
# WARNING
# 
# Before running this script, double check what the /dev/disk* path will be.
# Example - The internal hard drive shows up differently if NetBooted versus over Target Mode Imaging.
# 
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#	- Created by Douglas Worley, Professional Services Engineer, JAMF Software on August 21, 2014
#
####################################################################################################


diskutil zerodisk /dev/disk0 &
sleep 20
killall diskutil
sleep 5
diskutil partitionDisk /dev/disk0 1 GPTFormat JournaledHFS+ "Macintosh HD" 100%
sleep 5