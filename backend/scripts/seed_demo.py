"""Create synthetic accounts through OTP and approve a driver in local tests only.

No credential is written to the public output. Never run on development/production.
"""
import json
import os
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from fastapi.testclient import TestClient
from app.config import settings
from app.database import make_session
from app.main import app
from app.models import AuditLog, RoleAssignment


def seed():
    conf = settings()
    if conf.environment != "test" or conf.sms_provider != "test":
        raise RuntimeError("Démonstration réservée au fournisseur SMS local de test")
    with TestClient(app) as client:
        def login(phone, name):
            response = client.post('/v1/auth/otp/request', json={'phone': phone})
            response.raise_for_status()
            ident = response.json()['challenge_id']
            code = (conf.test_sms_dir / f'{ident}.txt').read_text()
            response = client.post('/v1/auth/otp/verify', json={'challenge_id': ident, 'code': code, 'display_name': name})
            response.raise_for_status()
            data = response.json()
            return data, {'Authorization': 'Bearer ' + data['access_token']}

        admin, admin_headers = login('+24177100001', 'Administration de test')
        with make_session()() as db:
            if not db.get(RoleAssignment, (admin['user']['id'], 'admin')):
                db.add(RoleAssignment(user_id=admin['user']['id'], role='admin'))
                db.add(AuditLog(actor_id=admin['user']['id'], action='admin.bootstrap.test', target_id=admin['user']['id']))
                db.commit()
        _, driver_headers = login('+24177100002', 'Chauffeur de test')
        current = client.get('/v1/drivers/me', headers=driver_headers)
        if current.status_code == 404:
            current = client.post('/v1/drivers', headers=driver_headers, json={
                'display_name': 'Chauffeur de test GABOYA',
                'vehicle': {'license_plate': 'DEMO-GA-001', 'description': 'Toyota Corolla verte — TEST'}})
        current.raise_for_status()
        response = client.post(f"/v1/admin/drivers/{current.json()['driver_id']}/review", headers=admin_headers,
                               json={'status': 'approved', 'note': 'Dossier synthétique pour tests locaux uniquement'})
        response.raise_for_status()
        driver = response.json()
        output = Path(os.getenv('DEMO_OUTPUT', '.local-test/demo-public.json'))
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps({'driver_code': driver['qr_code'], 'driver_id': driver['driver_id'],
                                      'display_name': driver['display_name'], 'vehicle': driver['vehicle']}, ensure_ascii=False))
        print('Chauffeur synthétique approuvé. QR public : ' + driver['qr_code'])


if __name__ == '__main__':
    seed()
