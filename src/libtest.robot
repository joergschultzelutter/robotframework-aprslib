*** Settings ***

Library    AprsLibrary.py

*** Test Cases ***
Mein Erster Testfall
    ${b}=   Calculate APRS-IS Passcode      DF1JSL-1

    Set APRS-IS Callsign    DF1JSL-1
    Set APRS-IS Passcode    ${b}
    Set APRS-IS Filter      g/MPAD/DF1JSL*

    ${b}=   Connect to APRS-IS

    ${d}=   Receive APRS Packet
    Log To Console  ${d}

    Disconnect from APRS-IS
