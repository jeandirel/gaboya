from concurrent.futures import ThreadPoolExecutor
from datetime import timedelta
from sqlalchemy import select
from app.database import make_session
from app.models import Session, now


def test_concurrent_refresh_reuse_revokes_the_family_without_deadlock(client, account):
    data, _ = account()
    def refresh(_):
        return client.post('/v1/auth/refresh', json={'refresh_token': data['refresh_token']})
    with ThreadPoolExecutor(max_workers=2) as pool:
        results = list(pool.map(refresh, range(2)))
    assert sorted(result.status_code for result in results) == [200, 401]
    current = next(result.json() for result in results if result.status_code == 200)
    assert client.get('/v1/me', headers={'Authorization': 'Bearer ' + current['access_token']}).status_code == 401


def test_access_expiry_still_allows_valid_refresh(client, account):
    data, headers = account()
    with make_session()() as db:
        session = db.scalar(select(Session))
        session.access_expires_at = now() - timedelta(seconds=1)
        db.commit()
    assert client.get('/v1/me', headers=headers).status_code == 401
    assert client.post('/v1/auth/refresh', json={'refresh_token': data['refresh_token']}).status_code == 200
