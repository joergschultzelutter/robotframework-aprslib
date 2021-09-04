# Send a single message to WXBOt, wait for a response message and display it on the console. 
# Then terminate the test.
#
# Author: Joerg Schultze-Lutter, DF1JSL
# https://www.github.com/joergschultzelutter

*** Settings ***
Library						AprsLibrary.py

Suite Setup					Open APRS-IS Connection
Suite Teardown				Close APRS-IS Connection

*** Variables ***
${message}					${callsign}>APRS::WXBOT${SPACE}${SPACE}${SPACE}${SPACE}:sunday
${callsign}					DF1JSL-15
${filter}					g/MPAD/DF1JSL*

*** Test Cases ***
Send packet to APRS-IS with callsign ${callsign}
	Log						Send Packet to APRS-IS
	Send APRS Packet		${message}

Receive packet from APRS-IS with callsign ${callsign}
	Log						Receive Packet from APRS-IS
	${packet} =				Receive APRS Packet
	Log To Console			${packet}

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
