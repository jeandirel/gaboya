# Render et future base Neon d�di�e

`render.yaml` d�crit un seul service FastAPI de d�veloppement au plan gratuit,
en r�gion Frankfurt, source `main`, d�ploiement automatique d�sactiv�.
Les identifiants PostgreSQL sont des secrets � renseigner dans Render ; aucune
cr�ation de service ni souscription n'est effectu�e par ce fichier seul.

Apr�s fusion de la PR test�e, cr�er le service � partir du Blueprint puis fournir
`DATABASE_URL` (URL Neon pooled) et `DATABASE_URL_UNPOOLED` (URL directe pour Alembic),
avec `sslmode=require`, exclusivement pour une base GABOYA d�di�e. Le secret
`APP_SECRET` est g�n�r� par Render. Renseigner les origines HTTPS exactes du mobile
web dans `CORS_ORIGINS`. `/readyz` v�rifie la connexion et la table des sessions.
L'offre gratuite ex�cute les migrations avant Uvicorn au d�marrage ; ne pas
multiplier les instances ni changer les sch�mas destructivement dans ce mode.
Le build et l'API utilisent `requirements.lock`. Aucun secret ne doit �tre plac�
dans Flutter, GitHub, les journaux ou le Blueprint.

Conserver des bases, secrets, services et fournisseurs distincts en d�veloppement
et production. N'utiliser aucune base d'un autre projet. Le fournisseur local
`SMS_PROVIDER=test` refuse une base distante et l'environnement Render.
Render reste donc en `SMS_PROVIDER=disabled` jusqu'� configuration du vrai SMS.

## SMS Gabon

L'adaptateur `twilio_verify` pr�pare l'envoi d'une v�rification SMS et son contr�le
c�t� Twilio. Il n'est pas activ� sans `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN` et
`TWILIO_VERIFY_SERVICE_SID`. Il reste � valider les autorisations g�ographiques
Gabon, la d�livrabilit� sur les op�rateurs cibles, les conditions du compte et le
budget avant tout envoi r�el. Aucun abonnement ni SMS payant n'est d�clench� ici.

R�f�rences officielles : [Verify](https://www.twilio.com/docs/verify/api/verification),
[Verification Check](https://www.twilio.com/docs/verify/api/verification-check),
[SMS Gabon](https://www.twilio.com/en-us/guidelines/ga/sms),
[Geo permissions](https://www.twilio.com/docs/verify/preventing-toll-fraud/verify-geo-permissions).
Le format international +241 supprime le z�ro national initial : voir la
[notification ARCEP � l'UIT](https://www.itu.int/dms_pub/itu-t/opb/sp/T-SP-OB.1288-2024-OAS-PDF-F.pdf).

## Paiements

`POST /v1/payments/intents` enregistre une intention pending, r�serv�e au passager
connect� et � un chauffeur approuv�. Les FCFA sont des entiers stricts. Une m�me
cl� d'idempotence ne cr�e pas de doublon et ne peut changer le montant. Aucun
endpoint n'accepte de callback non authentifi� et aucune op�ration ne fait passer
un paiement � succeeded. Le prestataire est `unconfigured`, `can_pay=false`.

L'ex�cution sandbox pawaPay, la v�rification des signatures, la r�conciliation et
le r�glement comptable restent � impl�menter et � tester apr�s obtention des
acc�s. Le paiement r�el reste d�sactiv�. Airtel Money et Moov Money pourront �tre
ajout�s derri�re la m�me fronti�re serveur ; aucun identifiant ne va au mobile.

R�f�rence de la configuration : [Blueprint Render](https://render.com/docs/blueprint-spec).
