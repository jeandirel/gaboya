# Render et future base Neon dédiée

`render.yaml` décrit un seul service FastAPI de développement au plan gratuit,
en région Frankfurt, source `main`, déploiement automatique désactivé.
Les identifiants PostgreSQL sont des secrets à renseigner dans Render ; aucune
création de service ni souscription n'est effectuée par ce fichier seul.

Après fusion de la PR testée, créer le service à partir du Blueprint puis fournir
`DATABASE_URL` (URL Neon pooled) et `DATABASE_URL_UNPOOLED` (URL directe pour Alembic),
avec `sslmode=require`, exclusivement pour une base GABOYA dédiée. Le secret
`APP_SECRET` est généré par Render. Renseigner les origines HTTPS exactes du mobile
web dans `CORS_ORIGINS`. `/readyz` vérifie la connexion et la table des sessions.
L'offre gratuite exécute les migrations avant Uvicorn au démarrage ; ne pas
multiplier les instances ni changer les schémas destructivement dans ce mode.
Le build et l'API utilisent `requirements.lock`. Aucun secret ne doit être placé
dans Flutter, GitHub, les journaux ou le Blueprint.

Conserver des bases, secrets, services et fournisseurs distincts en développement
et production. N'utiliser aucune base d'un autre projet. Le fournisseur local
`SMS_PROVIDER=test` refuse une base distante et l'environnement Render.
Render reste donc en `SMS_PROVIDER=disabled` jusqu'à configuration du vrai SMS.

## SMS Gabon

L'adaptateur `twilio_verify` prépare l'envoi d'une vérification SMS et son contrôle
côté Twilio. Il n'est pas activé sans `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN` et
`TWILIO_VERIFY_SERVICE_SID`. Il reste à valider les autorisations géographiques
Gabon, la délivrabilité sur les opérateurs cibles, les conditions du compte et le
budget avant tout envoi réel. Aucun abonnement ni SMS payant n'est déclenché ici.

Références officielles : [Verify](https://www.twilio.com/docs/verify/api/verification),
[Verification Check](https://www.twilio.com/docs/verify/api/verification-check),
[SMS Gabon](https://www.twilio.com/en-us/guidelines/ga/sms),
[Geo permissions](https://www.twilio.com/docs/verify/preventing-toll-fraud/verify-geo-permissions).
Le format international +241 supprime le zéro national initial : voir la
[notification ARCEP à l'UIT](https://www.itu.int/dms_pub/itu-t/opb/sp/T-SP-OB.1288-2024-OAS-PDF-F.pdf).

## Paiements

`POST /v1/payments/intents` enregistre une intention pending, réservée au passager
connecté et à un chauffeur approuvé. Les FCFA sont des entiers stricts. Une même
clé d'idempotence ne crée pas de doublon et ne peut changer le montant. Aucun
endpoint n'accepte de callback non authentifié et aucune opération ne fait passer
un paiement à succeeded. Le prestataire est `unconfigured`, `can_pay=false`.

L'exécution sandbox pawaPay, la vérification des signatures, la réconciliation et
le règlement comptable restent à implémenter et à tester après obtention des
accès. Le paiement réel reste désactivé. Airtel Money et Moov Money pourront être
ajoutés derrière la même frontière serveur ; aucun identifiant ne va au mobile.

Référence de la configuration : [Blueprint Render](https://render.com/docs/blueprint-spec).
