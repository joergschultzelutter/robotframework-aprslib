# This is a simple robot which connects to APRS-IS and echoes APRS messages
# 
# REQUIRES ROBOT FRAMEWORK 5.0 or greater
#
# Author: Joerg Schultze-Lutter, DF1JSL
# https://www.github.com/joergschultzelutter/robotframework/aprslib

*** Settings ***
Library						AprsLibrary.py
Library						String

Suite Setup					Open APRS-IS Connection
Suite Teardown					Close APRS-IS Connection

*** Variables ***
# This is your APRS-IS call sign. Replace this value with your personal call sign
${callsign}					YOURCALLSIGN

# APRS-IS server filter, see http://www.aprs-is.net/javAPRSFilter.aspx
${filter}					t/m

*** Test Cases ***
RF5 Echo APRS-IS Raw Traffic
	[Documentation]	Capture APRS messages from APRS-IS and display them on the console
	WHILE	${True}
		Receive Packet From APRS-IS
	END

*** Keywords ***
Open APRS-IS Connection
	# As this test suite uses RF5 keywords, check if we use the correct environment
	# and abort if necessary
	Check Robot Framework Version

	${passcode}=		Calculate APRS-IS Passcode	${callsign}

	Set APRS-IS Callsign	${callsign}
	Set APRS-IS Passcode	${passcode}
	Set APRS-IS Filter	${filter}

	Log			Connecting to APRS-IS
	Connect to APRS-IS

Close APRS-IS Connection
	Log			Disconnect from APRS-IS
	Disconnect from APRS-IS

Receive packet from APRS-IS 
	# Receive the package. By default, aprslib decodes it ...
	${packet} =		Receive APRS Packet

	# ... but for now, let's get the raw message from that decode packet
	# and display it on the console
	${packet} =		Get Raw Message Value From APRS Packet	${packet}	
	Log To Console		${packet}

Check Robot Framework Version
    [Documentation]  Checks the robotframework's version and aborts if we don't use minimum version 5.x.x
    # Get the version. Will be in x.x.x format, e.g. 4.1.2
    ${ver}=		Evaluate  (robot.version.VERSION)

    # Split up the string and get the major and minor versions, then convert the values to integer
    ${words}=		Split String	    	${ver}	     .
    ${major}=		Convert To Integer	${words[0]}
	
    # Check the version and fail the test if necessary
    Run Keyword If	'${major}' < '5' 	Fatal Error   msg=This test suite can only be run with Robot Framework 5.x.x. Present Version is '${ver}'
