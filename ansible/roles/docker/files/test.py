import testinfra

def test_package(host):
    p = host.package('docker-ce')
    assert p.is_installed

def test_service_enabled(host):
    s = host.service('docker')
    assert s.is_enabled

def test_service_running(host):
    s = host.service('docker')
    assert s.is_running
