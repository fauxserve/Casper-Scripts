#/bin/bash


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
#	aameeSerializingScript.sh
#
# SYNOPSIS - How to use
#
# A - Build the Composer Package
# 1) Use the Adobe Application Manager Enterprise Edition to create a “Serialization File" 
# 2) Use Composer.app to create a package for the two files created in step 1. Example:
#     /tmp/CS6_DWP/AdobeSerialization
#     /tmp/CS6_DWP/prov.xml
# 2a) Set ownership/permissions of these two files to root:admin, 755
# 3) Build Composer Source as DMG, upload to Casper Suite.
#
# B - Use the Script and Policy
# 1) Upload this script to the JSS, and set the following details in the script metadata:
#      - run "After" 
#      - $4 parameter = AdobeSerializationPath 
#      - $5 parameter = provXmlPath
# 2) Add the package and script into a policy 
# 3) Match the $4 and $5 parameters with the full absolute file paths of the two files from the package built in Composer above.
# 
# Relevant links:
# 	http://www.adobe.com/devnet/creativesuite/enterprisedeployment.html
# 
# 
# 
############################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Douglas Worley, Professional Services Engineer, JAMF Software on August 25 2015
#
############################################################################################

AdobeSerializationPath=""
provXmlPath=""

if [[ "$4" != "" ]] && [[ "$AdobeSerializationPath" == "" ]]; then
AdobeSerializationPath=$4
fi
if [[ "$5" != "" ]] && [[ "$provXmlPath" == "" ]]; then
provXmlPath=$5
fi

echo "AdobeSerializationPath is $AdobeSerializationPath"
echo "provXmlPath is $provXmlPath"

"${AdobeSerializationPath}" --tool=VolumeSerialize --stream -provfile="${provXmlPath}"
if [ "$?" == "0" ]; then #error checking
     echo "Successfully ran AdobeSerialization tool!"
else
     echo "ALERT - There was a problem with running the AdobeSerialization tool..."
fi 

rm $AdobeSerializationPath && rm $provXmlPath
if [ "$?" == "0" ]; then #error checking
     echo "Successfully deleted AdobeSerialization and prov.xml files"
else
     echo "ALERT - There was a problem with deleting AdobeSerialization and prov.xml files..."
fi 