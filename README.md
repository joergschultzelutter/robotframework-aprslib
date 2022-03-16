# robotframework-aprslib
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black) [![CodeQL](https://github.com/joergschultzelutter/robotframework-aprslib/actions/workflows/codeql.yml/badge.svg)](https://github.com/joergschultzelutter/robotframework-aprslib/actions/workflows/codeql.yml)

```robotframework-aprslib``` is a [Robot Framework](https://www.robotframework.org) keyword collection for the [aprslib](https://github.com/rossengeorgiev/aprs-python) Python library. It allows __licensed ham radio operators__ to establish a connection to the APRS-IS servers and send/receive/decode APRS requests.

![transmit](https://github.com/joergschultzelutter/robotframework-aprslib/blob/master/img/tx.jpg?raw=true)

![robot](https://github.com/joergschultzelutter/robotframework-aprslib/blob/master/img/robot.jpg?raw=true)

![receive](https://github.com/joergschultzelutter/robotframework-aprslib/blob/master/img/robot.jpg?raw=true)

## Installation

The easiest way is to install this package is from pypi:

    pip install robotframework-aprslib

## Robot Framework Library Examples

In order to run these scripts, you need to add your call sign to the script's configuration section:

```robot
# This is your APRS-IS call sign. Replace this place holder with your personal call sign
${callsign}   YOURCALLSIGN
```

Replace the current placeholder with your call sign and you are good to go. The Robot Framework 5 examples use the new WHILE loop for an 'eternal' loop; all other code samples use finite FOR loops and will terminate after processing 10 records in a row.

- [Echo incoming APRS messages](https://github.com/joergschultzelutter/robotframework-aprslib/blob/master/tests/echo_aprsis_traffic.robot)
- [Send and receive a single APRS message](https://github.com/joergschultzelutter/robotframework-aprslib/blob/master/tests/send_and_receive_single_packet.robot)
- [Receive a message, acknowledge it if necessary and then respond to it](https://github.com/joergschultzelutter/robotframework-aprslib/blob/master/tests/receive_and_send_single_packet.robot)
- [ROBOT FRAMEWORK 5: Echo incoming APRS messages](https://github.com/joergschultzelutter/robotframework-aprslib/blob/master/tests/rf5_echo_aprsis_traffic.robot)
- [ROBOT FRAMEWORK 5: Receive a message, acknowledge it if necessary and then respond to it](https://github.com/joergschultzelutter/robotframework-aprslib/blob/master/tests/rf5_receive_and_send.robot)

## Library usage and supported keywords

### Default settings for a new APRS-IS connection via robotframework-aprslib

When you initialize an APRS connection without explicitly setting parameters such as server, port, user/pass and filter, the following default values are automatically applied:

- __server__ = ``euro.aprs2.net``
- __port__ = ``14580``
- __callsign__ = ``N0CALL``
- __passcode__ = ``-1``
- __aprs-is filter__ = not set
- __aprsis_msgno__ = ``0`` (this is equal to ``AA`` if you rather want to use the [more recent replyack scheme](http://www.aprs.org/aprs11/replyacks.txt))

This default set of values will allow you to establish a read-only connection to APRS-IS, assuming that the respective APRS-IS server that you intend to connect with permits such a connection.

### Change the server / port / etc

You can either specify all parameters during the initial setup of the library or alternatively via separate keywords

#### Option 1 - set as position parameters

```robot
*** Settings ***

Library  AprsLibrary  server_value  port_value  user_value  passcode_value  filter_value  message_value

*** Test Cases ***
My first test case
```

#### Option 2 - set as named parameters

```robot
*** Settings ***

Library  AprsLibrary  aprsis_server=server_value  aprsis_port=port_value  aprsis_callsign=user_value  aprsis_passcode=passcode_value  aprsis_filter=filter_value aprsis_msgno = msgno_value

*** Test Cases ***
My first test case
```

#### Option 3 - Use Robot Keywords

| Keyword|Description|
|------- |-----------|
|``Set APRS-IS Server`` and ``Get APRS-IS Server``|Sets/Gets the APRS-IS server|
|``Set APRS-IS Port`` and ``Get APRS-IS Port``|Sets/Gets the APRS-IS port|
|``Set APRS-IS Callsign`` and ``Get APRS-IS Callsign``|Sets/Gets the APRS-IS callsign (user name)|
|``Set APRS-IS Passcode`` and ``Get APRS-IS Passcode``|Sets/Gets the APRS-IS passcode|
|``Set APRS-IS Filter`` and ``Get APRS-IS Filter``|Sets/Gets the APRS-IS server filter. Note: This keyword performs a (basic) sanity check on the content and will cause an error in case an invalid filter qualifier has been submitted|
|``Get Current APRS-IS Configuration``|Returns a dictionary containing all previously listed parameters and the APRS-IS connection status to the user (basically a collection of all previously mentioned keywords). An AIS object whose value is different to ```None``` indicates an active connection.|


### Other Robot Keywords supported by this library

| Keyword|Description|Parameter|
|------- |-----------|--|
|``Calculate APRS-IS Passcode``|Calculates the APRS-IS passcode (based on the given call sign) and returns it to the user|``aprsis_callsign``|
|``Parse APRS Packet``|Parses the given APRS packet. In case the packet is either invalid or its format is unknown, an exception will be triggered|``aprs_packet``|
|``Connect to APRS-IS``|Establishes a socket connection to the APRS-IS network| |
|``Disconnect from APRS-IS``|Disconnects from the APRS-IS network| |
|``Send APRS Packet``|Sends a raw APRS packet to APRS-IS in case an open connection to the APRS-IS network has been established|``packet`` (string)|
|``Receive APRS Packet``|Receives an APRS packet to APRS-IS in case an open connection to the APRS-IS network has been established. The default setting uses the parameter values ``immortal`` = ``True`` and ``raw``= ``False``, meaning that aprslib will try to re-establish the connection in case it is lost and will also auto-decode APRS packets when received|``immortal`` and ``raw`` (both boolean params)|
|``Get <field name> Value from APRS Packet``|various wrappers; e.g. ``Get Message Text Value From APRS Packet`` will return the decoded message string if it is present in the message|``aprs_packet``. If you specify a field that does not exit in the packet, this keyword will cause an error. Both raw and decoded messages are supported.|
|``Get Value From APRS Packet``|called by the aforementioned ``Get <field name> Value fron APRS Packet`` functions |``aprs_packet`` and ``field_name``. If you specify a field that does not exit in the packet, this keyword will cause an error. Both raw and decoded messages are supported.|
|``Check If APRS Packet Contains <field name>``|Similar to ``Get <field name> Value From APRS Packet`` but returns ``True``/``False`` in case the field does / does not exit|``aprs_packet``.  Both raw and decoded messages are supported.|
|``Check If APRS Packet Contains``|called by the aforementioned ``Check If APRS Packet Contains <field name>`` functions |``aprs_packet`` and ``field_name``|
|``Get APRS MsgNo``, ``Set APRS MsgNo``, ``Increment APRS MsgNo`` and ``Get APRS MsgNo as Alphanumeric``| Gets and sets the MsgNo that you can use for building up your own messages (aka library-maintained counter value). The ``alphanumeric`` keyword provides the message number in a format which [supports the more recent replyack scheme](http://www.aprs.org/aprs11/replyacks.txt). An ``increment`` to the value of ``675`` (``ZZ``) will automatically reset the value to ``0`` (``AA``). Both ``Get APRS MsgNo`` methods do NOT automatically increment the message number.|``Set APRS MsgNo`` allows you to set a numeric value between 0 and 675 (equals ``AA`` to ``ZZ``). All other keywords have no parameters.|

## Known issues

- When you need to define strings which contain multiple spaces, escaping these strings won't work as Robot will try to interpret these as list values. You need to construct them as Robot-conform strings with ``${SPACE}``. Example: ``ABCD${SPACE}${SPACE}${SPACE}${SPACE}EFGH`` results in ``ABCD____EFGH`` (four blanks between the variable's value).
  
- Apart from minor helper methods for the connection setup and field check/retrieval, this Robot Framework library does not offer any additional keywords for exchanging data in a proper way. (Almost) every feature that the original [aprslib](https://github.com/rossengeorgiev/aprs-python) offers is supported by this Robot library - nothing more and nothing less.
  
- The ```Receive APRS Packet``` keyword has no timeout which means that it will only return from its code if it has found a message that is to be returned to Robot. If you depend on timeout, you may need to amend your APRS-IS filter settings and handle the filter process in your code.

- The keyword ``Send APRS Packet`` will __not__ check whether the APRS-IS connection has been establised read-only (``N0CALL`` call sign) or read-write.

## The fine print

- APRS is a registered trademark of APRS Software and Bob Bruninga, WB4APR. Thank you, Bob!
- This is a hobby project. It has no commercial background whatsoever.
- Exchanging data with APRS(-IS) __requires you to be a licensed ham radio operator__. If you don't know what APRS is, then this library is not for you. Alternatively, you may want to explore the option of getting your own amateur radio license (it's a great hobby).
