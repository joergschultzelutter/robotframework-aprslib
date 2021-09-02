# This is a simple robot which captures up to 100 APRS 'message' type messages and logs them to the console.
# Author: Joerg Schultze-Lutter, DF1JSL
# https://www.github.com/joergschultzelutter

*** Settings ***
Library						AprsLibrary.py

Suite Setup					Open APRS-IS Connection
Suite Teardown				Close APRS-IS Connection

*** Variables ***
${callsign}					DF1JSL-15
${filter}					t/m

*** Test Cases ***
Monitor all APRS-IS Traffic
	[Documentation]	Capture up to 100 APRS messages and display them on the console

	# Robot has no WHILE loop. Therefore, we need to use a FOR loop.
	FOR		${i}	IN RANGE	100
		Receive Packet From APRS-IS
	END

*** Keywords ***
Open APRS-IS Connection
	${passcode}=			Calculate APRS-IS Passcode	${callsign}

	Set APRS-IS Callsign	${callsign}
	Set APRS-IS Passcode	${passcode}
	Set APRS-IS Filter		${filter}

	Log						Connecting to APRS-IS
	Connect to APRS-IS

Close APRS-IS Connection
	Log						Disconnect from APRS-IS
	Disconnect from APRS-IS

Receive packet from APRS-IS 
	${d} =					Receive APRS Packet
	Log To Console			${d}
