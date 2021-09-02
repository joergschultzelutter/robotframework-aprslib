# robotframework-aprslib
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

Robot Framework keyword collection for the [aprslib](https://github.com/rossengeorgiev/aprs-python) Python library. This Robot library allows you to establish a connection to the APRS-IS servers and send/receive/decode APRS requests. Most (but not all) features of the original Python library are supported.

Be advised that APRS-IS write access requires you to have a valid amateur radio license. If you don't know what APRS-IS or you are not a licensed ham radio amateur, then this program is likely not for you.

## Default settings when creating new APRS-IS connection

When you initialize an APRS connection without explicitly setting parameters such as server, port, user/pass and filter, the following default values are automatically applied:
- __server__ = ``euro.aprs2.net``
- __port__ = ``14580``
- __callsign__ = ``N0CALL``
- __passcode__ = ``-1``
- __aprs-is filter__ = not set

This default set of values will allow you to establish a read-only connection to APRS-IS, assuming that the respective APRS-IS server that you intend to connect with permits such a connection.

## Change the default server / port / ...

You can either specify all parameters during the initial setup of the library or alternatively via separate keywords

### Define the parameters as part of the library definition

#### Option 1 - via position parameter

    *** Settings ***

    Library  AprsLibrary.py  server_value  port_value  user_value  passcode_value  filter_value

    *** Test Cases ***
    Mein Erster Testfall

#### Option 2 - via named parameter

    *** Settings ***

    Library  AprsLibrary.py  aprsis_server=server_value  aprsis_port=port_value  aprsis_callsign=user_value  aprsis_passcode=passcode_value  aprsis_filter=filter_value

    *** Test Cases ***
    Mein Erster Testfall

### Use Robot Keywords
| Keyword|Description|
|------- |-----------|
|``Set APRS-IS Server`` and ``Get APRS-IS Server``|Sets/Gets the APRS-IS server|
|``Set APRS-IS Port`` and ``Get APRS-IS Port``|Sets/Gets the APRS-IS port|
|``Set APRS-IS Callsign`` and ``Get APRS-IS Callsign``|Sets/Gets the APRS-IS callsign (user name)|
|``Set APRS-IS Passcode`` and ``Get APRS-IS Passcode``|Sets/Gets the APRS-IS passcode|
|``Set APRS-IS Filter`` and ``Get APRS-IS Filter``|Sets/Gets the APRS-IS server filter. Note: This option performs a (basic) sanity check on the content and will cause an error in case an invalid filter qualifier has been submitted|
|``Get Current APRS-IS Configuration``|Returns a dictionary containing all previously listed parameters and the APRS-IS connection status to the user|

## Other Robot Keywords supported by this library
| Keyword|Description|Parameter|
|------- |-----------|--|
|``Calculate APRS-IS Passcode``|Calculates the APRS-IS passcode (based on the given call sign) and returns it to the user|``aprsis_callsign``|
|``Parse APRS Packet``|Parses the given APRS packet. In case the packet is either invalid or its format is unknown, an exception will be triggered|``aprs_packet``|
|``Connect to APRS-IS``|Establishes a socket connection to the APRS-IS network| |
|``Disconnect from APRS-IS``|Disconnects from the APRS-IS network| |
|``Send APRS Packet``|Sends a raw APRS packet to APRS-IS in case an open connection to the APRS-IS network has been established|``packet`` and ``simulate_send`` (bool)|
|``Receive APRS Packet``|Receives an APRS packet to APRS-IS in case an open connection to the APRS-IS network has been established|``immortal`` and ``raw`` (both bool params)|
|``Get APRS Message ....``|various wrappers; e.g. ``Get APRS Message Raw`` will return the raw message string if it is present in the message|``aprs_packet``|
|``Get Value From APRS Message``|called by the aporementioned ``Get APRS Message ....`` functions |``aprs_packet`` and ``field_name``|
|``Check if Field exists in APRS Message ....``|Similar to ``Get Value From APRS Message`` but only returns ``True``/``False`` |``aprs_packet`` and ``field_name``|

## Known issues
- When you need to define strings which contain multiple spaces, escaping these strings won't work as Robot will try to interpret these as list values. You need to construct them as Robot-conform strings with ``${SPACE}``. Example: ``ABCD${SPACE}${SPACE}${SPACE}${SPACE}EFGH`` results in ``ABCD    EFGH`` (four blanks in the variable's value).
