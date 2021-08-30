*** Settings ***

Library    AprsLibrary.py   aprsis_port=666  aprsis_server=www.domino.de

*** Test Cases ***
Mein Erster Testfall
    ${a}=     Get APRS-IS Port
    Log To Console      ${a}

    Set APRS-IS Port    42
    ${b}=     Get APRS-IS Port
    Log To Console      ${b}


    ${a}=     Get APRS-IS Server
    Log To Console      ${a}

    Set APRS-IS server    www.spiegel.de
    ${b}=     Get APRS-IS Server
    Log To Console      ${b}

    ${b}=   Calculate APRS-IS Passcode      MPAD
    Log To Console      ${b}

    ${b}=   Parse APRS Packet       M0XER-4>APRS64,TF3RPF,WIDE2*,qAR,TF3SUT-2:!/.(M4I^C,O `DXa/A=040849|#B>@\"v90!+| 
    Log To Console      ${b}