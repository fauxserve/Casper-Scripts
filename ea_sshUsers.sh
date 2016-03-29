#!/bin/bash
clear

theGroups=$(/usr/bin/dscl localhost -read /Local/Default/Groups/com.apple.access_ssh NestedGroups | cut -c 17-)


function readTheGroups
{
while test $# -gt 0
do
	dscl /Search -list /Groups GeneratedUID | grep $1
	shift
done
}

echo "<result>`readTheGroups $theGroups`</result>"


