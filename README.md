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

This default set of values will allow you to establish a read-only connection to APRS-IS. 

## Settings
