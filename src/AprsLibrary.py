#!/opt/local/bin/python3
#
# Robot Framework Keyword library wrapper for
# https://github.com/rossengeorgiev/aprs-python
# Author: Joerg Schultze-Lutter, 2021
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#


from robot.api.deco import library, keyword
from robot.api.logger import librarylogger as logger
import aprslib
import re

__version__ = "0.1"

@library(scope="GLOBAL", auto_keywords=True)
class AprsLibrary:

	# These are our default APRS-IS connection parameters
	# Change these settings if you e.g. prefer to use
	# a different APRS-IS server
	DEFAULT_SERVER = "euro.aprs2.net"
	DEFAULT_PORT = 14580
	DEFAULT_CALLSIGN = "N0CALL"
	DEFAULT_PASSCODE = "-1"
	DEFAULT_FILTER = ""

	# Class-internal APRS-IS connection parameters
	__aprsis_server = None
	__aprsis_port = None
	__aprsis_callsign = None
	__aprsis_passcode = None
	__aprsis_filter = None

	# Packet received through APRS-IS connection
	__aprs_packet = None

	# the actual APRS-IS connection to the server
	__ais = None

	def __init__(
		self,
		aprsis_server: str = DEFAULT_SERVER,
		aprsis_port: int = DEFAULT_PORT,
		aprsis_callsign: str = DEFAULT_CALLSIGN,
		aprsis_passcode: int = DEFAULT_PASSCODE,
		aprsis_filter: str = DEFAULT_FILTER,
	):
		self.__aprsis_server = aprsis_server
		self.__aprsis_port = aprsis_port
		self.__aprsis_callsign = aprsis_callsign
		self.__aprsis_passcode = aprsis_passcode
		self.__aprsis_filter = aprsis_filter
		self.__ais = None
		self.__aprs_packet = None


	# Python "Getter" methods
	#
	# Note that adding an additional Robot decorator (@keyword) will not
	# cause an error but the keyword will not be recognized later on
	# Therefore, Robot-specific "getter" keywords are required
	@property
	def aprsis_server(self):
		return self.__aprsis_server

	@property
	def aprsis_port(self):
		return self.__aprsis_port

	@property
	def aprsis_callsign(self):
		return self.__aprsis_callsign

	@property
	def aprsis_passcode(self):
		return self.__aprsis_passcode

	@property
	def aprsis_filter(self):
		return self.__aprsis_filter

	@property
	def ais(self):
		return self.__ais

	@property
	def aprs_packet(self):
		return self.__aprs_packet

	# Python "Setter" methods
	#
	# Note that adding an additional Robot decorator (@keyword) will not
	# cause an error but the keyword will not be recognized later on
	# Therefore, Robot-specific "setter" keywords are required

	@aprsis_server.setter
	def aprsis_server(self, aprsis_server: str):
		if not aprsis_server:
			raise ValueError("No value for APRS-IS server has been specified")
		self.__aprsis_server = aprsis_server

	@aprsis_port.setter
	def aprsis_port(self, aprsis_port: int):
		if not aprsis_port:
			raise ValueError("No value for APRS-IS port has been specified")
		self.__aprsis_port = aprsis_port

	@aprsis_callsign.setter
	def aprsis_callsign(self, aprsis_callsign: str):
		if not aprsis_callsign:
			raise ValueError("No value for APRS-IS callsign has been specified")
		self.__aprsis_callsign = aprsis_callsign.upper()

	@aprsis_passcode.setter
	def aprsis_passcode(self, aprsis_passcode: str):
		if not aprsis_passcode:
			raise ValueError("No value for APRS-IS passcode has been specified")
		self.__aprsis_passcode = aprsis_passcode

	@aprsis_filter.setter
	def aprsis_filter(self, aprsis_filter: str):
		if not aprsis_filter:
			raise ValueError("No value for APRS-IS filter has been specified")

		# Apply a crude format filter and check if we have received something valid
		aprsis_filter = aprsis_filter.lower()
		if aprsis_filter != "":
			matches = re.findall(r"^[r|p|b|o|t|s|d|a|e|g|o|q|m|f]\/", string)
			if not matches:
				raise ValueError("Invalid APRS-IS server filter string")
		self.__aprsis_filter = aprsis_filter

	@ais.setter
	def ais(self, ais: object):
		# Value can be "None" if we reset the connection. Therefore,
		# we simply accept the value "as is"
		self.__ais = ais

	@aprs_packet.setter
	def aprs_packet(self, aprs_packet: object):
		# Value can be of type 'str' or 'dict'. Therefore,
		# we simply accept the value "as is"
		self.__aprs_packet = aprs_packet

	#
	# Robot-specific "getter" keywords
	#
	@keyword("Get APRS-IS Server")
	def get_aprsis_server(self):
		return self.aprsis_server

	@keyword("Get APRS-IS Port")
	def get_aprsis_port(self):
		return self.aprsis_port

	@keyword("Get APRS-IS Callsign")
	def get_aprsis_callsign(self):
		return self.aprsis_callsign

	@keyword("Get APRS-IS Passcode")
	def get_aprsis_passcode(self):
		return self.aprsis_passcode

	@keyword("Get APRS-IS Filter")
	def get_aprsis_filter(self):
		return self.aprsis_filter

	#
	# Robot-specific "setter" keywords
	#
	@keyword("Set APRS-IS Server")
	def set_aprsis_server(self, aprsis_server: str = None):
		self.aprsis_server = aprsis_server

	@keyword("Set APRS-IS Port")
	def set_aprsis_port(self, aprsis_port: int = None):
		self.aprsis_port = aprsis_port

	@keyword("Set APRS-IS Callsign")
	def set_aprsis_callsign(self, aprsis_callsign: str = None):
		self.aprsis_callsign = aprsis_callsign

	@keyword("Set APRS-IS Passcode")
	def set_aprsis_passcode(self, aprsis_passcode: str = None):
		self.aprsis_passcode = aprsis_passcode

	@keyword("Set APRS-IS Filter")
	def set_aprsis_filter(self, aprsis_filter: str = None):
		self.aprsis_filter = aprsis_filter

	# This is the APRS library's callback function which will receive
	# content from APRS-IS. Dependent on the user's selection parameters,
	# 'received_aprs_packet' is either of type 'dict' (when decoded) or
	# 'str' in case the packet. In any case, it simply sets the value of our
	# global variable, thus allowing the AprsLibrary class to capture it and
	# return it to the user
	def aprscallback(self,received_aprs_packet):
##		global __aprs_packet
		self.aprs_packet = received_aprs_packet

	# aprslib specific keywords
	@keyword("Calculate APRS-IS Passcode")
	def calculate_aprsis_passcode(self, aprsis_callsign: str = None):
		if not aprsis_callsign:
			return aprslib.passcode(self.aprsis_callsign)
		else:
			return aprslib.passcode(aprsis_callsign)

	@keyword("Parse APRS Packet")
	def parse_aprs_packet(self, aprs_packet: str = None):
		if not aprs_packet:
			raise ValueError("No input APRS packet specified")
		try:
			packet = aprslib.parse(aprs_packet)
		except (aprslib.ParseError):
			raise ValueError("This APRS packet is invalid")
		except (aprslib.UnknownFormat):
			raise ValueError("Unknown APRS format")
		return packet

	@keyword("Connect To APRS-IS")
	def connect_aprsis(self):
		# Enforce default passcode if we're dealing with a read-only request
		if self.aprsis_callsign == "N0CALL":
			logger.debug(
				msg="Callsign is N0CALL; resetting APRS-IS passcode to default value"
			)
			self.aprsis_passcode = "-1"

		if self.ais:
			raise ValueError(
				"An APRS-IS connection is still open; please close it first"
			)

		# Create the connection
		self.ais = aprslib.IS(
			callsign=self.aprsis_callsign,
			passwd=self.aprsis_passcode,
			host=self.aprsis_server,
			port=self.aprsis_port,
		)

		# Set the filter if the string is not empty
		if self.aprsis_filter != "":
			self.ais.set_filter(self.aprsis_filter)

		# Finally, connect to APRS-IS
		self.ais.connect(blocking=True)

		if not self.ais._connected:
			disconnect_aprsis(self)
			raise ConnectionError(
				f"Cannot connect to APRS-IS with server {self.aprsis_server} port {self.aprsis_port} callsign {self.aprsis_callsign}"
			)

		logger.debug(msg="Successfully connected to APRS-IS")
		return self.ais

	@keyword("Disconnect from APRS-IS")
	def disconnect_aprsis(self):
		if self.ais:
			self.ais.close()
			self.ais = None

	@keyword("Get Current APRS-IS Configuration")
	def get_aprs_configuration(self):
		myvalues = {
			"server": self.aprsis_server,
			"port": self.aprsis_port,
			"user": self.aprsis_callsign,
			"passcode": self.aprsis_passcode,
			"filter": self.aprsis_filter,
			"ais": self.ais,
		}
		return myvalues

	@keyword("Send APRS Packet")
	def send_aprs_packet(self, packet:str, simulate_send:bool = False):
		if not simulate_send:
			# Are we connected?
			if not self.ais:
				raise ConnectionError("Not connected to APRS-IS; cannot send packet")
			logger.debug(msg=f"Sending message '{packet}' to APRS-IS")
			
			# Try to send data to the socket
			try:
				self.ais.sendall(packet)
			except:
				raise ConnectionError(f"Error while sending message '{packet}' to APRS-IS"
		else:
			# just pretend that we send something to the socket
			logger.debug(msg=f"Simulate message 'Send' of message '{packet}'")
		   
	@keyword("Receive APRS Packet")
	def receive_aprs_packet(self, immortal: bool = True, raw: bool = False):
		# Are we connected?
		if not self.ais:
				raise ConnectionError("Not connected to APRS-IS")
		logger.debug(msg="Start the APRS-IS consumer")
		# Start the consumer. We do not use the 'blocking' option as we cannot handle the
		# callback's data in Robot AND this library at the same time. Instead, the 'receive'
		# method will receive one (1) record and return it back to the Robot Framework
        # So if you want to receive more than one record, you need to re-call this keyword
        # from your Robot Framework script
		self.ais.consumer(callback=aprscallback, blocking=False, immortal=immortal, raw=raw)


if __name__ == "__main__":
	mytest = AprsLibrary()
	mytest.calculate_aprsis_passcode("DF1JSL")
	print(mytest.connect_aprsis())