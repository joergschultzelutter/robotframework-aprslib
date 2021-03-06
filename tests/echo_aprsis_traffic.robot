# This is a simple robot which captures up to 10 APRS 'message' type messages and 
# logs their raw messages to the console. Then terminate the test
# Author: Joerg Schultze-Lutter, DF1JSL
# https://www.github.com/joergschultzelutter/robotframework/aprslib

*** Settings ***
Library						AprsLibrary

Suite Setup					Open APRS-IS Connection
Suite Teardown					Close APRS-IS Connection

*** Variables ***
# This is your APRS-IS call sign. Replace this value with your personal call sign
${callsign}					YOURCALLSIGN

# APRS-IS server filter, see http://www.aprs-is.net/javAPRSFilter.aspx
${filter}					t/m

*** Test Cases ***
Echo APRS-IS Raw Traffic to Console
	[Documentation]	Capture up to 10 APRS messages and display them on the console

	# Robot has no WHILE loop. Therefore, we need to use a FOR loop.
	FOR	${i}	IN RANGE	10
		Receive Packet From APRS-IS
	END

*** Keywords ***
Open APRS-IS Connection
	${passcode}=			Calculate APRS-IS Passcode	${callsign}

	Set APRS-IS Callsign	${callsign}
	Set APRS-IS Passcode	${passcode}
	Set APRS-IS Filter	${filter}

	Log				Connecting to APRS-IS
	Connect to APRS-IS

Close APRS-IS Connection
	Log				Disconnect from APRS-IS
	Disconnect from APRS-IS

Receive packet from APRS-IS 
	# Receive the package. By default, aprslib decodes it ...
	${packet} =			Receive APRS Packet

	# ... but for now, let's get the raw message from that decode packet
	# and display it on the console
	${packet} =			Get Raw Message Value From APRS Packet	${packet}	
	Log To Console			${packet}
