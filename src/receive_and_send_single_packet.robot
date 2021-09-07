# Receive a single message with msgno, send an ack and send a response to the user
# This is a VERY simplified test which fails if you send unconfirmed 
# messages OR messages with the more modern ack/rej schema to it
#
# Author: Joerg Schultze-Lutter, DF1JSL
# https://www.github.com/joergschultzelutter

*** Settings ***
Library						AprsLibrary.py
Library						String

Suite Setup					Open APRS-IS Connection
Suite Teardown				Close APRS-IS Connection

*** Variables ***

# This is your APRS-IS call sign. Replace this value with your personal call sign
${callsign}					YOURCALLSIGN

# APRS-IS server filter, see http://www.aprs-is.net/javAPRSFilter.aspx
${filter}					g/${callsign}*

*** Test Cases ***
Simple Receive-and-Respond Test Case
	[Documentation]			Our 'master receiver' task
	# The current Robot Framework does not support WHILE loops. This is a still a 
	# finite loop but as our goal is only to receive a single message, this 
	# crude approach will do.
	Wait Until Keyword Succeeds		50x		0sec	Receive Packet From APRS-IS

*** Keywords ***

Receive packet from APRS-IS
	[Documentation]			VERY simplified ack-and-respond-to-message test case. Sends ack & msg to user, then terminates the test
	Log						Receive message from APRS-IS
	${packet} =				Receive APRS Packet

	${format_string}=		Get Format Value From APRS Packet			${packet}
	Run Keyword If			'${format_string}' != 'message'				Fail	msg=Packet format is not 'message'; start new loop
	
	${from_string}=			Get From Value From APRS Packet				${packet}
	${adresse_string}=		Get Adresse Value From APRS Packet			${packet}
	${msgtext_string}=		Get Message Text Value From APRS Packet		${packet}

	# The msgno might not be present for unconfirmed messsages. A failure to extract the msgno
	# simply triggers a new WUKS loop. After all, this is a VERY very simplified library demo.
	#
	# Therefore, I don't care about this case and simply expect to receive a message with a
	# msgno present. Additionally, keep in mind that alphanumeric message number qualifiers
	# are currently not parsed by the aprslib library.
	${msgno_string}=		Get Message Number Value From APRS Packet	${packet}

	# If we have received an ack or a rej, we simply ignore the message and start anew
	Run Keyword If			'${msgtext_string}' == 'ack'				Fail	msg=Ignoring ack, start new loop
	Run Keyword If			'${msgtext_string}' == 'rej'				Fail	msg=Ignoring rej, start new loop

	# show the user what we have received 
	Log To Console			I have received '${msgtext_string}'

	# Send the ack
	# build the ack based on the incoming message number
	${ackmsg} = 			Format String	{}>APRS::{:9}:ack{}		${adresse_string}	${from_string}	${msgno_string}
	# and send the ack to APRS-IS
	Log To Console			Sending acknowledgement '${ackmsg}'
	Send Packet to APRS-IS	${ackmsg}

	# do not flood the APRS-IS network
	Sleep					2sec

	# Send the actual message
	# Get a message number from the library
	${mymsgno}=				Get APRS MsgNo As Alphanumeric Value
	# Increment the library's message number (not really necessary here as we only deal with one message)
	Increment APRS MsgNo
	# build the final string
	${msg}=					Format String	{}>APRS::{:9}:{} {}{}	${adresse_string}		${from_string}	Hello	${from_string}	, your Robot Overlords send greetings!
	${msg}=					Catenate	SEPARATOR=	${msg}	{	${mymsgno}
	# and send the message to APRS-IS
	Log To Console			Sending actual message '${msg}'
	Send Packet to APRS-IS	${msg}

	Log To Console			And we're done

Send Packet to APRS-IS
	[Documentation]			Send packet to APRS-IS
	[arguments]				${message}
	Log						Send Packet to APRS-IS
	Send APRS Packet		${message}

Open APRS-IS Connection
	[Documentation]			Establishes a connection to APRS-IS
	${passcode}=			Calculate APRS-IS Passcode	${callsign}

	Set APRS-IS Callsign	${callsign}
	Set APRS-IS Passcode	${passcode}
	Set APRS-IS Filter		${filter}

	Log						Connecting to APRS-IS
	Connect to APRS-IS

Close APRS-IS Connection
	[Documentation]			Closes an existing connection to APRS-IS
	Log						Disconnect from APRS-IS
	Disconnect from APRS-IS