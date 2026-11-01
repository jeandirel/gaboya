"""Trusted CLI only: bootstrap an administrator after their phone verification."""
import argparse
from sqlalchemy import select
from .database import make_session
from .models import AuditLog, RoleAssignment, User
from .schemas import normalize_phone


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('command', choices=['grant-admin'])
    parser.add_argument('--phone', required=True)
    args = parser.parse_args()
    phone = normalize_phone(args.phone)
    with make_session()() as db:
        user = db.scalar(select(User).where(User.phone_e164 == phone).with_for_update())
        if not user or not user.enabled:
            parser.error('Un compte actif déjà vérifié par OTP est requis')
        if not db.get(RoleAssignment, (user.id, 'admin')):
            db.add(RoleAssignment(user_id=user.id, role='admin'))
            db.add(AuditLog(actor_id=user.id, action='admin.bootstrap.cli', target_id=user.id))
            db.commit()
    print('Rôle administrateur attribué au compte vérifié (audit enregistré).')


if __name__ == '__main__':
    main()
