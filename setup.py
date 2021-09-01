from setuptools import setup, find_packages
import re
import os

CURDIR = dirname(abspath(__file__))

with open("README.md", "r") as fh:
    long_description = fh.read()

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

with open(join(CURDIR, "src", "AprsLibrary.py"), encoding="utf-8") as f:
    VERSION = re.search('\n__version__ = "(.*)"', f.read()).group(1)

setup(
    name="robotframework-aprslib",
    version=version,
    description="Robot Framework keyword library for parsing of APRS packages and APRS-IS connection testing (send/receive)",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="Joerg Schultze-Lutter",
    author_email="joerg.schultze.lutter@gmail.com",
	license='GPLv3+',
    url="https://github.com/joergschultzelutter/robotframework-aprslib",
    packages=find_packages(),
	keywords='aprs aprslib aprs-is robot robotframework',

    classifiers=[
        "Intended Audience :: Developers",
        "Natural Language :: English",
        "Programming Language :: Python :: 3",
        'Topic :: Communications :: Ham Radio',
        'License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)',
        "Operating System :: OS Independent",
        "Development Status :: 5 - Production/Stable",
        "Framework :: Robot Framework",
    ],
    install_requires=["aprs-python>=0.6.47","robotframework >= 3.2"],
    include_package_data=True,
)
