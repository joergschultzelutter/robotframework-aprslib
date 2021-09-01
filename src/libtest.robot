*** Settings ***

Library    AprsLibrary.py

*** Test Cases ***
Mein Erster Testfall
	${passcode}=            Calculate APRS-IS Passcode      DF1JSL-1

	Set Local Variable	    ${message}	DF1JSL-1>APRS::WXBOT${SPACE}${SPACE}${SPACE}${SPACE}:sunday{LM}AA

	Set APRS-IS Callsign    DF1JSL-1
	Set APRS-IS Passcode    ${passcode}
	Set APRS-IS Filter      g/MPAD/DF1JSL*

	Log                     Connecting to APRS-IS
	Connect to APRS-IS

	Log                     Send Packet to APRS-IS
	Send APRS Packet	    ${message}

	Log                     Receive Packet from APRS-IS
	${d}=                   Receive APRS Packet
	Log To Console          ${d}

	Log                     Disconnect from APRS-IS
	Disconnect from APRS-IS
