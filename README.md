# robotframework-aprslib
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

```robotframework-aprslib``` is a [Robot Framework](https://www.robotframework.org) keyword collection for the [aprslib](https://github.com/rossengeorgiev/aprs-python) Python library. It allows you to establish a connection to the APRS-IS servers and send/receive/decode APRS requests. 

## Examples

### Send a single packet to APRS-IS and wait for the response

    # Send a single message to WXBOT, wait for a response message and display it on the console. 
    # Then terminate the test.
    #
    # Author: Joerg Schultze-Lutter, DF1JSL
    # https://www.github.com/joergschultzelutter/robotframework-aprslib

    *** Settings ***
    Library                     AprsLibrary.py

    Suite Setup                 Open APRS-IS Connection
    Suite Teardown              Close APRS-IS Connection

    *** Variables ***
 
    # This is your APRS-IS call sign. Replace this place holder with your personal call sign
    ${callsign}                 YOURCALLSIGN
 
    # This is the message that we will send out to WXBOT
    ${message}                  ${callsign}>APRS::WXBOT${SPACE}${SPACE}${SPACE}${SPACE}:tomorrow
 
    # APRS-IS server filter, see http://www.aprs-is.net/javAPRSFilter.aspx
    ${filter}                   g/WXBOT/${callsign}*

    *** Test Cases ***
    Send packet to APRS-IS with callsign ${callsign}
        Log                     Send Packet to APRS-IS
        Send APRS Packet        ${message}

    Receive packet from APRS-IS with callsign ${callsign}
        Log                     Receive Packet from APRS-IS
        ${packet} =             Receive APRS Packet
        Log To Console          ${packet}

    *** Keywords ***
    Open APRS-IS Connection
        ${passcode}=            Calculate APRS-IS Passcode  ${callsign}

        Set APRS-IS Callsign    ${callsign}
        Set APRS-IS Passcode    ${passcode}
        Set APRS-IS Filter      ${filter}

        Log                     Connecting to APRS-IS
        Connect to APRS-IS

    Close APRS-IS Connection
        Log                     Disconnect from APRS-IS
        Disconnect from APRS-IS

## Capture 10 APRS messages and display them in raw format

    # This is a simple robot which captures up to 10 APRS 'message' type messages and 
    # logs their raw messages to the console. Then terminate the test
    # Author: Joerg Schultze-Lutter, DF1JSL
    # https://www.github.com/joergschultzelutter/robotframework-aprslib

    *** Settings ***
    Library                     AprsLibrary.py

    Suite Setup                 Open APRS-IS Connection
    Suite Teardown              Close APRS-IS Connection

    *** Variables ***
    # This is your APRS-IS call sign. Replace this value with your personal call sign
    ${callsign}                 YOURCALLSIGN

    # APRS-IS server filter, see http://www.aprs-is.net/javAPRSFilter.aspx
    ${filter}                   t/m

    *** Test Cases ***
    Echo APRS-IS Raw Traffic to Console
        [Documentation] Capture up to 10 APRS messages and display them on the console

        # Robot has no WHILE loop. Therefore, we need to use a FOR loop.
        FOR  ${i} IN RANGE  10
            Receive Packet From APRS-IS
        END

    *** Keywords ***
    Open APRS-IS Connection
        ${passcode}=            Calculate APRS-IS Passcode  ${callsign}

        Set APRS-IS Callsign    ${callsign}
        Set APRS-IS Passcode    ${passcode}
        Set APRS-IS Filter      ${filter}

        Log                     Connecting to APRS-IS
        Connect to APRS-IS

    Close APRS-IS Connection
        Log                     Disconnect from APRS-IS
        Disconnect from APRS-IS

    Receive packet from APRS-IS 
        # Receive the package. By default, aprslib decodes it ...
        ${packet} =             Receive APRS Packet

        # ... but for now, let's get the raw message from that decode packet
        # and display it on the console
        ${packet} =             Get Raw Message Value From APRS Packet  ${packet}
        Log To Console          ${packet}

## Default settings when creating new APRS-IS connection

When you initialize an APRS connection without explicitly setting parameters such as server, port, user/pass and filter, the following default values are automatically applied:

- __server__ = ``euro.aprs2.net``
- __port__ = ``14580``
- __callsign__ = ``N0CALL``
- __passcode__ = ``-1``
- __aprs-is filter__ = not set
- __aprsis_msgno__ = ``0`` (this is equal to ``AA`` if you need to get the msgno in alphanumeric format)

This default set of values will allow you to establish a read-only connection to APRS-IS, assuming that the respective APRS-IS server that you intend to connect with permits such a connection.

## Change the server / port / etc

You can either specify all parameters during the initial setup of the library or alternatively via separate keywords

### Option 1 - set as position parameters

    *** Settings ***

    Library  AprsLibrary.py  server_value  port_value  user_value  passcode_value  filter_value  message_value

    *** Test Cases ***
    My first test case

### Option 2 - set as named parameters

    *** Settings ***

    Library  AprsLibrary.py  aprsis_server=server_value  aprsis_port=port_value  aprsis_callsign=user_value  aprsis_passcode=passcode_value  aprsis_filter=filter_value aprsis_msgno = msgno_value

    *** Test Cases ***
    My first test case

### Option 3 - Use Robot Keywords

| Keyword|Description|
|------- |-----------|
|``Set APRS-IS Server`` and ``Get APRS-IS Server``|Sets/Gets the APRS-IS server|
|``Set APRS-IS Port`` and ``Get APRS-IS Port``|Sets/Gets the APRS-IS port|
|``Set APRS-IS Callsign`` and ``Get APRS-IS Callsign``|Sets/Gets the APRS-IS callsign (user name)|
|``Set APRS-IS Passcode`` and ``Get APRS-IS Passcode``|Sets/Gets the APRS-IS passcode|
|``Set APRS-IS Filter`` and ``Get APRS-IS Filter``|Sets/Gets the APRS-IS server filter. Note: This keyword performs a (basic) sanity check on the content and will cause an error in case an invalid filter qualifier has been submitted|
|``Get Current APRS-IS Configuration``|Returns a dictionary containing all previously listed parameters and the APRS-IS connection status to the user (basically a collection of all previously mentioned keywords). An AIS object whose value is different to ```None``` indicates an active connection.|
|``Get APRS-IS MsgNo``, ``Set APRS-IS MsgNo``, ``Increment APRS-IS MsgNo`` and ``Get APRS-IS MsgNo as Alphanumeric``| Gets and sets the MsgNo. The ``alphanumeric`` keyword provides the message number in a format which [supports the more recent replyack scheme](http://www.aprs.org/aprs11/replyacks.txt). The following rules apply: a) If you want to set the value directly, a max value of 675 (equals ``ZZ``) is possible b) Setter methods only accept numeric values c) if you use the  ``Increment`` keyword, an increment to the value of 675 (``ZZ``) will automatically reset the value to ``AA``.

## Other Robot Keywords supported by this library

| Keyword|Description|Parameter|
|------- |-----------|--|
|``Calculate APRS-IS Passcode``|Calculates the APRS-IS passcode (based on the given call sign) and returns it to the user|``aprsis_callsign``|
|``Parse APRS Packet``|Parses the given APRS packet. In case the packet is either invalid or its format is unknown, an exception will be triggered|``aprs_packet``|
|``Connect to APRS-IS``|Establishes a socket connection to the APRS-IS network| |
|``Disconnect from APRS-IS``|Disconnects from the APRS-IS network| |
|``Send APRS Packet``|Sends a raw APRS packet to APRS-IS in case an open connection to the APRS-IS network has been established|``packet`` (string)|
|``Receive APRS Packet``|Receives an APRS packet to APRS-IS in case an open connection to the APRS-IS network has been established. The default setting uses the parameter values ``immortal`` = ``True`` and ``raw``= ``False``, meaning that aprslib will try to re-establish the connection in case it is lost and will also auto-decode APRS packets when received|``immortal`` and ``raw`` (both boolean params)|
|``Get <field name> Value from APRS Packet``|various wrappers; e.g. ``Get Message Text Value From APRS Packet`` will return the decoded message string if it is present in the message|``aprs_packet``. If you specify a field that does not exit in the packet, this keyword will cause an error. Both raw and decoded messages are supported.|
|``Get Value From APRS Packet``|called by the aporementioned ``Get <field name> Value fron APRS Packet`` functions |``aprs_packet`` and ``field_name``. If you specify a field that does not exit in the packet, this keyword will cause an error. Both raw and decoded messages are supported.|
|``APRS Packet Should Contain <field name>``|Similar to ``Get <field name> Value From APRS Packet`` but only returns ``True``/``False`` in case the field does / does not exit|``aprs_packet`` and ``field_name``.  Raw and decoded messages are supported.|
|``APRS Packet Should Contain``|called by the aforementioned ``APRS Packet Should Contain <field name>`` functions |``aprs_packet`` and ``field_name``|

## Known issues

- When you need to define strings which contain multiple spaces, escaping these strings won't work as Robot will try to interpret these as list values. You need to construct them as Robot-conform strings with ``${SPACE}``. Example: ``ABCD${SPACE}${SPACE}${SPACE}${SPACE}EFGH`` results in ``ABCD____EFGH`` (four blanks between the variable's value).
  
- Apart from minor helper methods for the connection setup and field check/retrieval, this Robot Framework library does not offer any additional keywords for exchanging data in a proper way. (Almost) every feature that the original [aprslib](https://github.com/rossengeorgiev/aprs-python) offers is supported by this Robot library - nothing more and nothing less. As aprslib does not [support the more recent replyack scheme](http://www.aprs.org/aprs11/replyacks.txt), this keyword library will also not decode these messages in a proper way and you may need to decode them manually. I was thinking about introducing a workaround to this library (the one that [mpad](https://github.com/joergschultzelutter/mpad) uses), but in the end this decoding should rather be done by aprslib itself.
  
- The current version of the Robot Framework does not support WHILE loops which would permit the Robot script to run endlessly (when needed). Loops can only be triggered with the help of finite FOR loops. This should be enough for testing but unless a real WHILE loop is made available for the Robot Framework, you can't build an APRS messaging server which will not terminate after a certain point in time.

- The ```Receive APRS Packet``` command has no timeout which means that it will only return back from this code if it has found a message that is to be returned back to Robot. If you depend on timeout, you may need to amend your APRS-IS filter settings and handle the filter process in your code.

## The fine print

- APRS is a registered trademark of APRS Software and Bob Bruninga, WB4APR. Thank you Bob!
- This is a hobby project. It has no commercial background whatsoever.
- Exchanging data with APRS(-IS) __requires you to be a licensed ham radio operator__. If you don't know what APRS is, then this library is not for you. Alternatively, you may want to explore the option of getting your own amateur radio license (it's a great hobby).
