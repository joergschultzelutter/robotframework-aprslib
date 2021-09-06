# Send a single message to WXBOT, wait for a response message and display it on the console. 
#
# Author: Joerg Schultze-Lutter, DF1JSL
# https://www.github.com/joergschultzelutter

*** Settings ***
Library						AprsLibrary.py

Suite Setup					Open APRS-IS Connection
Suite Teardown				Close APRS-IS Connection

*** Variables ***

# This is your APRS-IS call sign. Replace this value with your personal call sign
${callsign}					YOURCALLSIGN

# This is the message that we will send out to WXBOT
${message}					${callsign}>APRS::WXBOT${SPACE}${SPACE}${SPACE}${SPACE}:tomorrow

# APRS-IS server filter, see http://www.aprs-is.net/javAPRSFilter.aspx
${filter}					g/WXBOT/${callsign}*

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
