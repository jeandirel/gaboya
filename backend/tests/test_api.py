def test_health(client):
    assert client.get('/healthz').json()['status'] == 'up'
    assert client.get('/readyz').json()['status'] == 'ready'


def test_capabilities_never_claim_live_payments(client):
    data = client.get('/v1/capabilities').json()
    assert data['currency'] == 'XAF'
    assert data['payments_ready'] is False and data['payments_live'] is False
    assert data['google_login_enabled'] is False


def test_no_fake_payment_success(client):
    response = client.post('/v1/payments/intents', json={'driver_code': 'GBY-123456', 'amount_xaf': 500})
    assert response.status_code == 401


def test_invalid_driver_code(client, account):
    _, headers = account()
    assert client.get('/v1/drivers/resolve/INVALID', headers=headers).status_code == 422


def test_otp_is_not_faked(client, monkeypatch):
    monkeypatch.setenv('SMS_PROVIDER', 'disabled')
    response = client.post('/v1/auth/otp/request', json={'phone': '+24177123456'})
    assert response.status_code == 503
