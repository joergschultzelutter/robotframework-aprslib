# Receive a single message with msgno, send an ack and send a response to the user
# This is a VERY simplified test which fails if you send unconfirmed 
# messages OR messages with the more modern ack/rej schema to it
#
# REQUIRES ROBOT FRAMEWORK 5.0 or greater
#
# Author: Joerg Schultze-Lutter, DF1JSL
# https://www.github.com/joergschultzelutter

*** Settings ***
Library						AprsLibrary.py
Library						String

Suite Setup					Open APRS-IS Connection
Suite Teardown					Close APRS-IS Connection

*** Variables ***

# This is your APRS-IS call sign. Replace this value with your personal call sign
${callsign}					YOURCALLSIGN

# APRS-IS server filter, see http://www.aprs-is.net/javAPRSFilter.aspx
${filter}					g/${callsign}*

*** Test Cases ***
RF5 APRS Receive-and-Respond
	[Documentation]			Our 'master receiver' task

	# Set to $FALSE if we want to abort the loop in a controlled way
	Set Suite Variable		${PROCESS_MESSAGES}	${True}
	WHILE	${PROCESS_MESSAGES}
		Receive Packet From APRS-IS
	END
	Log To Console			Have a nice day

*** Keywords ***

Receive packet from APRS-IS
	[Documentation]			VERY simplified ack-and-respond-to-message test case. Sends ack & msg to user, then terminates the test

	# Get the packet from APRS-IS
	Log				Receive message from APRS-IS
	${packet} =			Receive APRS Packet

	Log To Console			Receive complete

	# check what we have received so far
	${format_string}=		Get Format Value From APRS Packet			${packet}

	# and handle response/message formats
	Run Keyword If			'${format_string}' == 'response'			Process APRS Response	MYPACKET=${packet}
	Run Keyword If			'${format_string}' == 'message'				Process APRS Message	MYPACKET=${packet}

	Log To Console			And we're done

Send Acknowledgment
	[Documentation]			Send an acknowledgement in case the incoming message 
	[Arguments]			${MYPACKET}

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
	Sleep				5sec

Process APRS Message
	[Documentation]			Process an APRS Message (format type: 'messsage')
	[Arguments]			${MYPACKET}

	Log To Console			Processing an APRS 'message' packet

	# show the user what we have received 
	Log To Console			I have received '${MYPACKET}' from APRS-IS

	# Send an acknowledgment in case we have received a message containing a message number
	${msgno_present}=		Check If APRS Packet Contains Message Number	${MYPACKET}
	Log To Console			Message contains a message number: ${msgno_present}

	Run Keyword If			'${msgno_present}' == '${True}' 			Send Acknowledgment		MYPACKET=${MYPACKET}

	# Extract some fields from the original message
	${from_string}=			Get From Value From APRS Packet				${MYPACKET}
	${adresse_string}=		Get Adresse Value From APRS Packet			${MYPACKET}

	${msgtxt_present}=		Check If APRS Packet Contains Message Text		${MYPACKET}
	Log To Console			Message contains message text: ${msgtxt_present}
	Run Keyword If			'${msgtxt_present}' == '${False}' 			Pass Execution		Not an APRS Message with Message Text

	${message_text}=		Get Message Text Value From APRS Packet			${MYPACKET}
	Log To Console			Received message text ${message_text}
	${message_text}=		Convert To Upper Case					${message_text}

	# Check if we are supposed to terminate the test after processing this message
	# crude but effective :)
	# returning a ${False} will terminate the outer loop while returning a ${True}
	# will keep it active
	${exit_from_loop}=		Set Variable If		'${message_text}' == 'QRT'	${False}	${True}
	Set Suite Variable		${PROCESS_MESSAGES}	${exit_from_loop}

	# Send the response message
	# Get a new message number from the library
	${mymsgno}=			Get APRS MsgNo As Alphanumeric Value

	# Increment the library's message number (not really necessary here as we only deal with one message)
	Increment APRS MsgNo

	# build the final string
	${msg}=				Format String	{}>APRS::{:9}:{} {}{}	${adresse_string}		${from_string}	Hello	${from_string}	, your Robot Overlords send greetings!
	
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
	[Arguments]			${MYPACKET}

	# At this point, we already know that there is a response present. Normally, this can only be an ack or a rej
	# but let's be sure about that and check the value
	${response_string}		Get Response Value from APRS Packet			${MYPACKET}

	# If we have received an ack or a rej, we simply ignore the message and start anew
	Run Keyword If			'${response_string}' == 'ack'				Pass Execution	Ignoring ack, start new loop
	Run Keyword If			'${response_string}' == 'rej'				Pass Execution	Ignoring rej, start new loop


Send Packet to APRS-IS
	[Documentation]			Send packet to APRS-IS
	[arguments]			${message}
	Log				Send Packet to APRS-IS
	Send APRS Packet		${message}

Open APRS-IS Connection
	[Documentation]			Establishes a connection to APRS-IS
	${passcode}=			Calculate APRS-IS Passcode	${callsign}

	Set APRS-IS Callsign		${callsign}
	Set APRS-IS Passcode		${passcode}
	Set APRS-IS Filter		${filter}

	Log				Connecting to APRS-IS
	Connect to APRS-IS

Close APRS-IS Connection
	[Documentation]			Closes an existing connection to APRS-IS
	Log				Disconnect from APRS-IS
	Disconnect from APRS-IS
