# GABOYA : parcours local vérifiable

Le mobile exporté reste dans `mobile/` et FastAPI dans `backend/`. La branche
`flutterflow` est une source d'export : ne jamais la fusionner directement dans
`main`. La PR #1 a déjà été fusionnée ; les évolutions suivantes passent par une
nouvelle PR de la branche d'intégration, avec CI backend et mobile vertes.

## PostgreSQL et API

Python 3.12 et PostgreSQL 17 sont utilisés pour les tests. Docker est facultatif :
un serveur PostgreSQL installé localement convient aussi. Créer une base dédiée
`gaboya_test`, accessible sur la boucle locale, avec un mot de passe local unique.
Avec Docker : définir `POSTGRES_PASSWORD` puis lancer `docker compose up -d`
depuis `backend/`. Le port est `127.0.0.1:55432`.

Installer `pip install -r requirements.lock`. Définir dans le shell (ou un fichier
local exclu du dépôt) :

```text
DATABASE_URL=postgresql+psycopg://<utilisateur>:<mot-de-passe>@127.0.0.1:55432/gaboya_test
APP_ENV=test
APP_SECRET=<secret aléatoire propre à cet environnement, au moins 32 caractères>
SMS_PROVIDER=test
ALLOW_TEST_SMS=1
TEST_SMS_DIR=<chemin absolu privé vers la boîte SMS de test>
DEMO_OUTPUT=<chemin absolu vers demo-public.json>
```

L'API ne charge pas automatiquement `.env` : exporter les variables avant de la
lancer. Exécuter depuis `backend/` :

```sh
python -m alembic upgrade head
python -m alembic check
python -m pytest -q
python scripts/seed_demo.py
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

Les tests tronquent uniquement une base locale `*_test` ; ne jamais désigner une
base contenant des données à conserver. Le seed utilise les API OTP et chauffeur,
un administrateur synthétique local et une approbation administrative auditée.
Il produit un code QR public dans `DEMO_OUTPUT`, sans exporter les sessions.
La boîte SMS est privée, n'est jamais servie par HTTP et ne doit pas être publiée.
Effacer les données et codes synthétiques après la démonstration.

## Mobile existant

Installer un Flutter stable récent, puis depuis `mobile/` :

```sh
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter run --dart-define=GABOYA_API_BASE_URL=http://127.0.0.1:8000 --dart-define=GABOYA_ALLOW_LOCAL_HTTP=true
```

Sur l'émulateur Android, employer `http://10.0.2.2:8000` ; l'autorisation HTTP
explicite est réservée aux builds debug et aux hôtes locaux. Les builds release
exigent HTTPS. Pour le web local, ajouter l'origine exacte de la prévisualisation
dans `CORS_ORIGINS` avant de démarrer l'API. Ne pas ouvrir l'API de test sur le LAN.

Dans Connexion, utiliser un numéro synthétique +241, puis le code à six chiffres
du fichier `TEST_SMS_DIR/<challenge_id>.txt`. Le code n'apparaît jamais dans la
réponse HTTP. Le seed réserve `+24177100001` et `+24177100002` aux comptes
administrateur et chauffeur ; utiliser un autre numéro synthétique pour le passager.
Le fichier créé le plus récemment dans la boîte privée correspond à la demande.

Scanner le QR du chauffeur approuvé sur Android/iOS, ou saisir son code sur le web.
L'écran affiche le nom et le véhicule obtenus du serveur. Saisir un montant entier,
vérifier le récapitulatif et préparer l'intention. Le résultat doit rester
« paiement non effectué ». Aucune requête pawaPay, aucun débit et aucune écriture
de règlement ne sont activés.

L'icône taxi de l'accueil ouvre le dossier chauffeur. La première soumission ne
donne aucun rôle chauffeur : un administrateur distinct doit approuver. Toute
modification du nom ou du véhicule désactive le QR et repasse en vérification.
L'espace de contrôle n'apparaît que pour le rôle admin, vérifié aussi par l'API.
La première attribution admin hors test exige un compte déjà vérifié et la CLI
de confiance `python -m app.manage grant-admin --phone <numéro vérifié>`.

Les sessions d'accès expirent après 15 minutes, les refresh tokens après 30 jours.
Le refresh est rotatif et sa réutilisation révoque toute la famille. Le mobile
garde l'accès en mémoire, le refresh dans Keychain/Keystore natif ; le web utilise
uniquement la mémoire. Aucun token dans SharedPreferences. Google est désactivé
et aucune association par email n'est utilisée.

## Test Flutter vers le vrai serveur

Après migration, seed et démarrage de l'API, exécuter depuis `mobile/` :

```sh
flutter test test/live_api_flow_test.dart --dart-define=GABOYA_RUN_LIVE_TESTS=true --dart-define=GABOYA_TEST_SMS_DIR=<boîte privée> --dart-define=GABOYA_DEMO_FILE=<demo-public.json>
```

Ce test fait les vrais appels HTTP depuis le client Dart : demande OTP, connexion,
profil, résolution du QR approuvé et création idempotente d'une intention pending,
puis déconnexion. Sans l'option explicite, ce test est ignoré. La CI crée sa propre
base PostgreSQL et sa propre boîte locale pour exécuter ce parcours.
