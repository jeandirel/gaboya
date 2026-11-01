# GABOYA — feuille de route technique

## Existant

- FlutterFlow : `gaboya-nsii4x`, thèmes, accueil, écran de connexion non branché et scanner natif ; ne pas écraser.
- GitHub : `jeandirel/gaboya` ; le dépôt était vide puis initialisé.
- Neon : organisation existante gérée par Vercel ; création de nouveau projet refusée. **Ne pas réutiliser une base tierce**.
- Render : workspace accessible, aucun backend GABOYA déployé à ce stade.

## Ce que le code réalise réellement

Le backend expose un health check, la découverte des capacités, un début de recherche sécurisée de code chauffeur sur une base PostgreSQL future et refuse les paiements et OTP non configurés.

**Non livrés :** authentification OTP, JWT/session, KYC, contrôles administrateur, intégration API pawaPay, webhooks, ledger en partie double transactionnel, remboursements, cash-out, billetterie, stockage et déploiement.

## Architecture et conditions de production

- L'app FlutterFlow appelle FastAPI en HTTPS. Aucun secret pawaPay dans le mobile.
- PostgreSQL/Neon dédié, migrations versionnées, contraintes d'intégrité, sauvegardes et surveillance.
- Validation stricte des autorisations serveur avant tout accès financier.
- Les SMS OTP, retraits et portefeuilles sont activés uniquement après fournisseurs/contrats, sécurité et conformité validés.
- Les codes chauffeur utilisés en public ne doivent pas être des jetons d'autorisation : seul le backend détermine l'identité du chauffeur.

## Blocage restant

Créer un projet Neon **hors organisation Vercel gérée**, dans un compte/organisation autorisé, ou choisir une autre base PostgreSQL de développement ; ne pas essayer indéfiniment la même commande refusée.
