#!/usr/bin/env python
# project: libhar
# description: libhar
# author: Daniel Kovacs <dkovacs@ebay.com>
# file: libhar/setup.py
# file-version: 1.0
# file-origin-author: Hynek Schlawack
# file-origin-source: https://hynek.me/articles/sharing-your-labor-of-love-pypi-quick-and-dirty/
#

# ---------------------------------------------------------------------------------------
# configuration
# ---------------------------------------------------------------------------------------

NAME = "mypackage"
VERSION = "0.2"
DESCRIPTION = "HAR File Parser"
AUTHOR = "Daniel Kovacs"
AUTHOR_EMAIL = "dkovacs@ebay.com"
MAINTAINER = "Daniel Kovacs"
MAINTAINER_EMAIL = "dkovacs@ebay.com"
SCM_URL= "https://github.corp.ebay.com/GumtreeAU-Incubator/harparser"
KEYWORDS = []
CLASSIFIERS = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: Other/Proprietary License"
    "Operating System :: OS Independent",
    "Programming Language :: Python",
    "Programming Language :: Python :: 2.7",
]

# ---------------------------------------------------------------------------------------
# imports
# ---------------------------------------------------------------------------------------

import codecs
import os
import re

from setuptools import setup, find_packages
from pip.req import parse_requirements


# ---------------------------------------------------------------------------------------
# _read()
# ---------------------------------------------------------------------------------------

def _read(*parts):
    """
    Build an absolute path from *parts* and and return the contents of the
    resulting file.  Assume UTF-8 encoding.
    """
    with codecs.open(os.path.join(HOME, *parts), "rb", "utf-8") as f:
        return f.read()


# ---------------------------------------------------------------------------------------
# _get_requirement_name
# ---------------------------------------------------------------------------------------

_match_package_name = re.compile(r'.*\/([a-z]*)\.git')

def _get_requirement_name(ir):
    if ir.req:
        return str(ir.req)
    m = _match_package_name.match(str(ir.link))
    return m.group(1)

# ---------------------------------------------------------------------------------------
# internal variables
# ---------------------------------------------------------------------------------------

HOME = os.path.abspath(os.path.dirname(__file__))
PACKAGES = find_packages(where=NAME)
INSTALL_REQUIRES = [_get_requirement_name(ir) for ir in parse_requirements(os.path.join( HOME, 'requirements.txt' ), session=False)]


# ---------------------------------------------------------------------------------------
# setup()
# ---------------------------------------------------------------------------------------

if __name__ == "__main__":
    setup(
        name=NAME,
        description= "",  # EDIT THIS
        license="License :: Other/Proprietary License",
        url= SCM_URL,
        version= VERSION,
        author= AUTHOR,
        author_email= AUTHOR_EMAIL,
        maintainer= MAINTAINER,
        maintainer_email= MAINTAINER_EMAIL,
        keywords=KEYWORDS,
        long_description=_read("README.md"),
        packages=PACKAGES,
        package_dir={"": NAME},
        zip_safe=False,
        classifiers=CLASSIFIERS,
        install_requires=INSTALL_REQUIRES,
        setup_requires=[
            'pytest-runner',
        ],
        tests_require=[
            'pytest',
        ],
    )
