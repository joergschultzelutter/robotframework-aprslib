#!/usr/bin/env python

from setuptools import setup, find_packages
import re
import os
import sys

with open("README.md", "r") as fh:
    long_description = fh.read()

version_regex = r"^v(?P<version>\d*\.\d*\.\d*$)"
version = os.environ.get('CI_COMMIT_TAG', f'2.{os.environ.get("CI_COMMIT_REF_NAME","0.0")}')
full_version_match = re.fullmatch(version_regex, version)
if full_version_match:
    version = full_version_match.group('version')

setup(
    name="robotframework-aprslib",
    version=version,
    description="Robot Framework keywords for aprslib Python Library, https://github.com/rossengeorgiev/aprs-python",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="Joerg Schultze-Lutter",
    author_email="joerg.schultze.lutter@gmail.com",
    url="https://github.com/joergschultzelutter/robotframework-aprslib",
    packages=find_packages(),
    classifiers=[
        "Intended Audience :: Developers",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3",
        "Topic :: Software Development",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
        "Operating System :: OS Independent",
        "Development Status :: 4 - Beta",
        "Framework :: Robot Framework",
        "Topic :: Communications :: Ham Radio",
    ],
    license="Apache License, Version 2.0",
    install_requires=["robotframework>=3.2", "aprslib>=0.7.0"],
    include_package_data=True,
    keywords=["Ham Radio","Amateur Radio", "APRS", "Robot Framework"]
)
