# GABOYA : parcours local v�rifiable

Le mobile export� reste dans `mobile/` et FastAPI dans `backend/`. La branche
`flutterflow` est une source d'export : ne jamais la fusionner directement dans
`main`. La PR #1 a d�j� �t� fusionn�e ; les �volutions suivantes passent par une
nouvelle PR de la branche d'int�gration, avec CI backend et mobile vertes.

## PostgreSQL et API

Python 3.12 et PostgreSQL 17 sont utilis�s pour les tests. Docker est facultatif :
un serveur PostgreSQL install� localement convient aussi. Cr�er une base d�di�e
`gaboya_test`, accessible sur la boucle locale, avec un mot de passe local unique.
Avec Docker : d�finir `POSTGRES_PASSWORD` puis lancer `docker compose up -d`
depuis `backend/`. Le port est `127.0.0.1:55432`.

Installer `pip install -r requirements.lock`. D�finir dans le shell (ou un fichier
local exclu du d�p�t) :

```text
DATABASE_URL=postgresql+psycopg://<utilisateur>:<mot-de-passe>@127.0.0.1:55432/gaboya_test
APP_ENV=test
APP_SECRET=<secret al�atoire propre � cet environnement, au moins 32 caract�res>
SMS_PROVIDER=test
ALLOW_TEST_SMS=1
TEST_SMS_DIR=<chemin absolu priv� vers la bo�te SMS de test>
DEMO_OUTPUT=<chemin absolu vers demo-public.json>
```

L'API ne charge pas automatiquement `.env` : exporter les variables avant de la
lancer. Ex�cuter depuis `backend/` :

```sh
python -m alembic upgrade head
python -m alembic check
python -m pytest -q
python scripts/seed_demo.py
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

Les tests tronquent uniquement une base locale `*_test` ; ne jamais d�signer une
base contenant des donn�es � conserver. Le seed utilise les API OTP et chauffeur,
un administrateur synth�tique local et une approbation administrative audit�e.
Il produit un code QR public dans `DEMO_OUTPUT`, sans exporter les sessions.
La bo�te SMS est priv�e, n'est jamais servie par HTTP et ne doit pas �tre publi�e.
Effacer les donn�es et codes synth�tiques apr�s la d�monstration.

## Mobile existant

Installer un Flutter stable r�cent, puis depuis `mobile/` :

```sh
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter run --dart-define=GABOYA_API_BASE_URL=http://127.0.0.1:8000 --dart-define=GABOYA_ALLOW_LOCAL_HTTP=true
```

Sur l'�mulateur Android, employer `http://10.0.2.2:8000` ; l'autorisation HTTP
explicite est r�serv�e aux builds debug et aux h�tes locaux. Les builds release
exigent HTTPS. Pour le web local, ajouter l'origine exacte de la pr�visualisation
dans `CORS_ORIGINS` avant de d�marrer l'API. Ne pas ouvrir l'API de test sur le LAN.

Dans Connexion, utiliser un num�ro synth�tique +241, puis le code � six chiffres
du fichier `TEST_SMS_DIR/<challenge_id>.txt`. Le code n'appara�t jamais dans la
r�ponse HTTP. Le seed r�serve `+24177100001` et `+24177100002` aux comptes
administrateur et chauffeur ; utiliser un autre num�ro synth�tique pour le passager.
Le fichier cr�� le plus r�cemment dans la bo�te priv�e correspond � la demande.

Scanner le QR du chauffeur approuv� sur Android/iOS, ou saisir son code sur le web.
L'�cran affiche le nom et le v�hicule obtenus du serveur. Saisir un montant entier,
v�rifier le r�capitulatif et pr�parer l'intention. Le r�sultat doit rester
� paiement non effectu� �. Aucune requ�te pawaPay, aucun d�bit et aucune �criture
de r�glement ne sont activ�s.

L'ic�ne taxi de l'accueil ouvre le dossier chauffeur. La premi�re soumission ne
donne aucun r�le chauffeur : un administrateur distinct doit approuver. Toute
modification du nom ou du v�hicule d�sactive le QR et repasse en v�rification.
L'espace de contr�le n'appara�t que pour le r�le admin, v�rifi� aussi par l'API.
La premi�re attribution admin hors test exige un compte d�j� v�rifi� et la CLI
de confiance `python -m app.manage grant-admin --phone <num�ro v�rifi�>`.

Les sessions d'acc�s expirent apr�s 15 minutes, les refresh tokens apr�s 30 jours.
Le refresh est rotatif et sa r�utilisation r�voque toute la famille. Le mobile
garde l'acc�s en m�moire, le refresh dans Keychain/Keystore natif ; le web utilise
uniquement la m�moire. Aucun token dans SharedPreferences. Google est d�sactiv�
et aucune association par email n'est utilis�e.

## Test Flutter vers le vrai serveur

Apr�s migration, seed et d�marrage de l'API, ex�cuter depuis `mobile/` :

```sh
flutter test test/live_api_flow_test.dart --dart-define=GABOYA_RUN_LIVE_TESTS=true --dart-define=GABOYA_TEST_SMS_DIR=<bo�te priv�e> --dart-define=GABOYA_DEMO_FILE=<demo-public.json>
```

Ce test fait les vrais appels HTTP depuis le client Dart : demande OTP, connexion,
profil, r�solution du QR approuv� et cr�ation idempotente d'une intention pending,
puis d�connexion. Sans l'option explicite, ce test est ignor�. La CI cr�e sa propre
base PostgreSQL et sa propre bo�te locale pour ex�cuter ce parcours.
