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
