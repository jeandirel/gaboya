# GABOYA � feuille de route technique

## Existant

- FlutterFlow : `gaboya-nsii4x`, th�mes, accueil, �cran de connexion non branch� et scanner natif ; ne pas �craser.
- GitHub : `jeandirel/gaboya` ; le d�p�t �tait vide puis initialis�.
- Neon : organisation existante g�r�e par Vercel ; cr�ation de nouveau projet refus�e. **Ne pas r�utiliser une base tierce**.
- Render : workspace accessible, aucun backend GABOYA d�ploy� � ce stade.

## Ce que le code r�alise r�ellement

Le backend g�re maintenant l'OTP SMS (adaptateur Twilio Verify pr�par�, fournisseur local isol� pour les tests), des sessions opaques hach�es et r�vocables, les r�les, les dossiers chauffeurs et v�hicules, leur contr�le administratif audit�e, des QR et des intentions de paiement pending. Les �crans FlutterFlow existants utilisent ces API.

**Non activ�s :** envoi SMS r�el sans fournisseur, connexion Google, KYC automatis� et stockage documentaire, ex�cution pawaPay, webhooks financiers, ledger en partie double transactionnel, remboursements, cash-out, billetterie et d�ploiement cloud. Voir `local-development.md` pour le parcours local et `deployment.md` pour Render/Neon.

## Architecture et conditions de production

- L'app FlutterFlow appelle FastAPI en HTTPS. Aucun secret pawaPay dans le mobile.
- PostgreSQL/Neon d�di�, migrations versionn�es, contraintes d'int�grit�, sauvegardes et surveillance.
- Validation stricte des autorisations serveur avant tout acc�s financier.
- Les SMS OTP, retraits et portefeuilles sont activ�s uniquement apr�s fournisseurs/contrats, s�curit� et conformit� valid�s.
- Les codes chauffeur utilis�s en public ne doivent pas �tre des jetons d'autorisation : seul le backend d�termine l'identit� du chauffeur.

## Blocage restant

Cr�er un projet Neon **hors organisation Vercel g�r�e**, dans un compte/organisation autoris�, ou choisir une autre base PostgreSQL de d�veloppement ; ne pas essayer ind�finiment la m�me commande refus�e.
