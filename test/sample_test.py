
import os
import mypackage
import mock 
import pytest
from pytest_mock import mocker 
from speedcurve import SpeedCurve


@pytest.fixture()
def url_fixture():
    return ['http://mocked']

class Source:
    def __init__(self, api_key):
        self.sc = SpeedCurve(api_key=api_key)

def test_e2e_dummy():
    assert True == True, "This should never happen! OMG! The universe is broken!"

def test_speedcurve(mocker, url_fixture): 
    source = Source(api_key='abc')
    mocker.patch.object(source.sc, 'sites', autospec=True)
    source.sc.sites.return_value = url_fixture
    assert source.sc.sites()[0] == url_fixture[0]

