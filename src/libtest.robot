*** Settings ***

Library    AprsLibrary.py

*** Test Cases ***
Mein Erster Testfall
    ${b}=   Calculate APRS-IS Passcode      MPAD
    Log To Console      ${b}

    ${b}=   Parse APRS Packet       M0XER-4>APRS64,TF3RPF,WIDE2*,qAR,TF3SUT-2:!/.(M4I^C,O `DXa/A=040849|#B>@\"v90!+| 
    Log To Console      ${b}

    Set APRS-IS Server      94.33.51.3

    ${b}=   Connect To APRS-IS

    ${c}=   Get Current APRS-IS Configuration
    Log To Console  ${c}
    Log Variables

    Disconnect from APRS-IS
    ${c}=   Get Current APRS-IS Configuration
    Log To Console  ${c}
