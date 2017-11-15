
import os
import mypackage
import mock 
import pytest
from pytest_mock import mocker 
from speedcurve import SpeedCurve


class Source:
    def __init__(self, api_key):
        self.sc = SpeedCurve(api_key=api_key)

def test_e2e_dummy():
    assert True == True, "This should never happen! OMG! The universe is broken!"

def test_speedcurve(mocker): 
    source = Source(api_key='abc')
    mocker.patch.object(source.sc, 'sites', autospec=True)
    source.sc.sites.return_value = ['http://mocked']
    assert source.sc.sites()[0] == 'http://mocked'

