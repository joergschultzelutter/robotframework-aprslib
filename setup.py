#!/usr/bin/env/python

from setuptools import setup, find_packages

with open("README.md", "r") as fh:
    long_description = fh.read()
    
with open("VERSION", "r") as fh:
    VERSION = fh.read()

setup(
    name="robotframework-aprslib",
    version=VERSION,
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
    license="GNU General Public License v3 (GPLv3)",
    install_requires=["robotframework>=3.2", "aprslib>=0.7.0"],
    include_package_data=True,    
    keywords=["Ham Radio","Amateur Radio", "APRS", "Robot Framework"]
)
