# Synchronisation FlutterFlow → dépôt GABOYA

## Branches

- `main` : version canonique du backend et intégration approuvée.
- `flutterflow` : export **jetable / régénérable** envoyé par FlutterFlow. Ne jamais fusionner cette branche telle quelle dans `main`.
- `integration/flutterflow-mobile-20261101` : copie de l'export FlutterFlow sous `mobile/`, sans supprimer le backend.

## Procédure de mise à jour

1. Dans FlutterFlow, continuer à pousser uniquement vers `flutterflow` (cela peut supprimer les autres fichiers **sur cette branche**).
2. À chaque export, synchroniser le **nouvel arbre Git de `flutterflow` sous `mobile/` sur une branche issue de `main`**, en laissant le reste du dépôt intact.
3. Vérifier que les chemins `backend/`, `docs/`, `.github/` sont inchangés.
4. Exécuter les tests backend et une analyse/compilation Flutter avec une version compatible du SDK.
5. Ouvrir une pull request séparée de la branche d'intégration vers `main` et la fusionner **après validation**.
6. Ne pas développer de fonctions personnalisées directement dans `flutterflow` : une synchronisation pourrait les effacer. Placer les personnalisations maintenues dans le code d'intégration et les reporter dans FlutterFlow lorsque nécessaire.

## État de cette intégration

Source mobile : export FlutterFlow commit `246a7d0f7fc2e6bc092a3e01c5c6a84f8a0571e2`.

Source backend : branche `main` au commit `035fa7d3e75b68b24d143cc0427c938cf9b8dfdd`.

Aucun test de compilation Flutter n'est encore confirmé. L'authentification OTP et le paiement pawaPay ne sont pas connectés. Ne pas afficher de paiement réussi sans confirmation serveur.
