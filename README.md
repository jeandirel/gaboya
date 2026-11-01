# GABOYA 🇬🇦

Super-app mobile pour la mobilité au Gabon : paiement taxi par QR, billetterie interurbaine, espace chauffeur/compagnie et administration.

**État : socle technique initial. AUCUN paiement réel n'est activé.**

## Architecture

- **Mobile** : projet FlutterFlow existant `gaboya-nsii4x` (non exporté ici)
- **API** : FastAPI dans `backend/`
- **Données** : PostgreSQL / Neon une fois un projet dédié autorisé
- **Paiements** : adaptateur pawaPay *désactivé tant qu'aucun compte sandbox n'est configuré*
- **Identité** : futur OTP +241 et sessions serveur (non activés à ce stade)

## Lancer l'API localement

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
pytest
```

- Santé : `GET /healthz`
- Capacités : `GET /v1/capabilities`
- Swagger : `/docs`

Le mode sans configuration de base refuse explicitement les demandes de paiement et d'identification de chauffeur au lieu de simuler des opérations réussies.

## Sécurité

- Ne jamais committer de clés, tokens, mots de passe, URLs de bases avec credentials.
- Le dépôt est **public** actuellement : changer sa visibilité dans GitHub avant de publier des données sensibles.
- Tous les flux d'argent et les OTP exigent un backend, des fournisseurs configurés et des tests de bout en bout.
- Les montants sont des entiers XAF ; l'état `succeeded` n'est pas atteignable via un simple retour du téléphone.

## Prochaines étapes

1. Raccorder un projet PostgreSQL/Neon **dédié** (l'organisation Neon actuellement gérée par Vercel empêche la création directe dans cet accès).
2. Exécuter les migrations.
3. Implémenter et tester l'identité par OTP gabonais.
4. Lier FlutterFlow aux API réelles.
5. Intégrer pawaPay sandbox et ses webhooks vérifiés, puis réconcilier les transactions.

**Ne pas connecter GABOYA aux bases d'autres projets existants.**
