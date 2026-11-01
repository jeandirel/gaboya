# GABOYA — feuille de route technique

## Existant

- FlutterFlow : `gaboya-nsii4x`, thèmes, accueil, écran de connexion non branché et scanner natif ; ne pas écraser.
- GitHub : `jeandirel/gaboya` ; le dépôt était vide puis initialisé.
- Neon : organisation existante gérée par Vercel ; création de nouveau projet refusée. **Ne pas réutiliser une base tierce**.
- Render : workspace accessible, aucun backend GABOYA déployé à ce stade.

## Ce que le code réalise réellement

Le backend gère maintenant l'OTP SMS (adaptateur Twilio Verify préparé, fournisseur local isolé pour les tests), des sessions opaques hachées et révocables, les rôles, les dossiers chauffeurs et véhicules, leur contrôle administratif auditée, des QR et des intentions de paiement pending. Les écrans FlutterFlow existants utilisent ces API.

**Non activés :** envoi SMS réel sans fournisseur, connexion Google, KYC automatisé et stockage documentaire, exécution pawaPay, webhooks financiers, ledger en partie double transactionnel, remboursements, cash-out, billetterie et déploiement cloud. Voir `local-development.md` pour le parcours local et `deployment.md` pour Render/Neon.

## Architecture et conditions de production

- L'app FlutterFlow appelle FastAPI en HTTPS. Aucun secret pawaPay dans le mobile.
- PostgreSQL/Neon dédié, migrations versionnées, contraintes d'intégrité, sauvegardes et surveillance.
- Validation stricte des autorisations serveur avant tout accès financier.
- Les SMS OTP, retraits et portefeuilles sont activés uniquement après fournisseurs/contrats, sécurité et conformité validés.
- Les codes chauffeur utilisés en public ne doivent pas être des jetons d'autorisation : seul le backend détermine l'identité du chauffeur.

## Blocage restant

Créer un projet Neon **hors organisation Vercel gérée**, dans un compte/organisation autorisé, ou choisir une autre base PostgreSQL de développement ; ne pas essayer indéfiniment la même commande refusée.
