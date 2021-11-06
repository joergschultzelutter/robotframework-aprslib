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
	# Robot Framework 4.x does not support WHILE loops. This is a still a 
	# finite loop but as our goal is only to receive a single message, this 
	# crude approach will do. Keep in mind that by default, the APRSLib is 
	# queried in "blocked" mode, meaning that we don't need any retries etc.
	#
	# The current setup will accept up to 10 messages, confirm them whereas
	# necessary and send a pesonalized response. After processing these 10
	# messages, the test will stop its execution
	Wait Until Keyword Succeeds		10x		0sec	Receive Packet From APRS-IS

*** Keywords ***

Receive packet from APRS-IS
	[Documentation]			VERY simplified ack-and-respond-to-message test case. Sends ack & msg to user, then terminates the test

	# Get the packet from APRS-IS
	Log						Receive message from APRS-IS
	${packet} =				Receive APRS Packet

	Log To Console			Receive complete

	# check what we have received so far
	${format_string}=		Get Format Value From APRS Packet			${packet}

	# and handle response/message formats
	Run Keyword If			'${format_string}' == 'response'			Process APRS Response	MYPACKET=${packet}
	Run Keyword If			'${format_string}' == 'message'				Process APRS Message	MYPACKET=${packet}

	Log To Console			And we're done

Send Acknowledgment
	[Documentation]			Send an acknowledgement in case the incoming message 
	[Arguments]				${MYPACKET}

	${from_string}=			Get From Value From APRS Packet				${MYPACKET}
	${adresse_string}=		Get Adresse Value From APRS Packet			${MYPACKET}
	${msgno_string}=		Get Message Number Value From APRS Packet	${MYPACKET}

	# Send the ack
	# build the ack based on the incoming message number
	${ackmsg} = 			Format String	{}>APRS::{:9}:ack{}		${adresse_string}	${from_string}	${msgno_string}
	# and send the ack to APRS-IS
	Log To Console			Sending acknowledgement '${ackmsg}'
	Send Packet to APRS-IS	${ackmsg}

	# do not flood the APRS-IS network
	Log To Console			Sleep 5 secs
	Sleep					5sec

Process APRS Message
	[Documentation]			Process an APRS Message (format type: 'messsage')
	[Arguments]				${MYPACKET}

	Log To Console			Processing an APRS 'message' packet

	# show the user what we have received 
	Log To Console			I have received '${MYPACKET}' from APRS-IS

	# Send an acknowledgment in case we have received a message containing a message number
	${msgno_present}=		Check If APRS Packet Contains Message Number	${MYPACKET}
	Log To Console			Message contains a message number: ${msgno_present}

	Run Keyword If			'${msgno_present}' == '${True}' 				Send Acknowledgment		MYPACKET=${MYPACKET}

	# Extract some fields from the original message
	${from_string}=			Get From Value From APRS Packet				${MYPACKET}
	${adresse_string}=		Get Adresse Value From APRS Packet			${MYPACKET}

	# Send the response message
	# Get a message number from the library
	${mymsgno}=				Get APRS MsgNo As Alphanumeric Value

	# Increment the library's message number (not really necessary here as we only deal with one message)
	Increment APRS MsgNo

	# build the final string
	${msg}=					Format String	{}>APRS::{:9}:{} {}{}	${adresse_string}		${from_string}	Hello	${from_string}	, your Robot Overlords send greetings!
	
	# our response will always contain a message number, even though the incoming message had none
	# Remember that this is just a simple demo script
	${msg}=		Catenate	SEPARATOR=	${msg}	{	${mymsgno}

	# and send the message to APRS-IS
	Log To Console			Sending response message '${msg}' to APRS-IS
	Send Packet to APRS-IS	${msg}

	# Since we do not intentionally fail this command sequence, we will automatically break free from the encapsulating WUKS
	Log To Console			Process APRS Message complete.

Process APRS Response
	[Documentation]			Process an APRS Response (format type: 'response'). Causes a desired fail (thus causing another WUKS loop) in case an ack/rej has been received
	[Arguments]				${MYPACKET}

	# At this point, we already know that there is a response present. Normally, this can only be an ack or a rej
	# but let's be sure about that and check the value
	${response_string}		Get Response Value from APRS Packet			${MYPACKET}

	# If we have received an ack or a rej, we simply ignore the message and start anew
	Run Keyword If			'${response_string}' == 'ack'				Fail	msg=Ignoring ack, start new loop
	Run Keyword If			'${response_string}' == 'rej'				Fail	msg=Ignoring rej, start new loop


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