# PantryPal — application mobile de gestion de garde‑manger (Flutter)

## Présentation
PantryPal est une application Flutter qui permet de gérer son inventaire alimentaire, de réduire le gaspillage (alertes d’expiration) et d’utiliser l’IA pour analyser une photo de ticket de caisse.

## Fonctionnalités
- Inventaire / Pantry : ajout, suppression, modification des quantités, statuts **expiré / bientôt expiré / frais**
- Ajout d’articles :
  - **Scan ticket (IA)** : photo → extraction d’articles → écran de revue → ajout au pantry
  - **Scan code‑barres/QR** (caméra)
  - **Ajout manuel**
- **Liste de courses**
- **Planification de repas**
- **Notifications locales** pour les produits bientôt expirés (mobile)
- **Profil utilisateur** (dont photo de profil) + persistance locale
- **Mode sombre**
- **FR/EN** (localisation)

## Technologies
- Flutter / Dart
- Firebase (initialisation + Auth)
- SharedPreferences (persistance locale)
- IA via endpoint **OpenAI‑compatible** :
  - **Groq** (par défaut)
  - **Ollama** (option locale)

## Prérequis
- Flutter SDK installé (et configuré dans le PATH)
- Android Studio (ou autre SDK Android) pour générer un APK
- (Optionnel) Compte Groq pour une clé API, ou Ollama installé en local

## Configuration (IA)
Il n’y a pas de “backend” obligatoire à lancer pour l’IA : l’app appelle directement un fournisseur.

### Option A — Groq (cloud)
1. Créez une clé API Groq.
2. Dans l’application, ouvrez **Profil / Paramètres IA** et renseignez :
   - Base URL : `https://api.groq.com/openai/v1`
   - API Key : `gsk_...`
   - Modèle : ex. `llama-3.1-8b-instant`

### Option B — Ollama (local)
1. Installez Ollama et lancez le service.
2. Téléchargez un modèle (exemple) : `ollama pull llama3.2`
3. Dans l’application, configurez :
   - Base URL : `http://localhost:11434/v1`
   - API Key : vide
   - Modèle : ex. `llama3.2`

Note : sur Android **émulateur**, “localhost” peut référer à l’émulateur. Si besoin, utilisez l’IP hôte de l’ordinateur (ou `10.0.2.2` côté émulateur).

## Exécuter le frontend (l’app Flutter)
```bash
flutter pub get

# Web (rapide)
flutter run -d chrome

# Android (émulateur ou téléphone)
flutter run
```

## Exécuter le “backend”
Il n’y a **pas** de serveur backend dédié dans ce dépôt.
- Authentification : Firebase
- IA : Groq (cloud) ou Ollama (local)

Si vous choisissez Ollama, le “backend” à lancer correspond à Ollama lui‑même (service local).

## Tests
```bash
flutter test
flutter analyze
```

## Générer un APK (Android)
```bash
flutter build apk --release
```

APK généré : `build/app/outputs/flutter-apk/app-release.apk`

## Notes plateformes
- Les notifications locales sont prévues pour mobile (Android/iOS). Sur web, certaines fonctions peuvent être désactivées ou no‑op selon les APIs disponibles.

