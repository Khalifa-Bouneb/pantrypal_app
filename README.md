# PantryPal

Application Flutter de gestion de garde‑manger (inventaire, date d’expiration, liste de courses) avec **analyse IA d’un ticket de caisse**.

## Sommaire
- [Objectif du projet](#objectif-du-projet)
- [Fonctionnalités](#fonctionnalités)
- [Architecture (vue d’ensemble)](#architecture-vue-densemble)
- [Frontend (Flutter)](#frontend-flutter)
- [Backend (temporaire)](#backend-temporaire)
- [Configuration IA (Groq / Ollama)](#configuration-ia-groq--ollama)
- [Tests](#tests)
- [Build APK](#build-apk)
- [Limites connues](#limites-connues)

## Objectif du projet
PantryPal aide l’utilisateur à :
- Suivre ses produits (quantité, catégorie, date d’expiration)
- Réduire le gaspillage grâce aux statuts **expiré / bientôt expiré / frais** et aux notifications locales
- Gagner du temps via des ajouts rapides (manuel, code‑barres, **ticket de caisse par IA**)

## Fonctionnalités
- **Inventaire (Pantry)** : ajouter/supprimer, ajuster quantité, indicateurs d’expiration
- **Ajout d’articles** :
  - Ticket (IA) : photo → extraction → écran de revue → ajout
  - Code‑barres/QR : scan caméra
  - Manuel : formulaire complet
- **Liste de courses**
- **Planification de repas**
- **Profil utilisateur** (photo, paramètres) + persistance locale
- **Mode sombre**
- **FR/EN** (localisation)
- **Notifications locales** (mobile) pour produits bientôt expirés

## Architecture (vue d’ensemble)
Schéma simplifié :

```text
            ┌──────────────────────────┐
            │        Frontend          │
            │     Flutter (Dart)       │
            └───────────┬──────────────┘
                        │
     ┌──────────────────┼──────────────────┐
     │                  │                  │
┌────▼─────┐      ┌─────▼─────┐      ┌────▼──────────┐
│ Stockage │      │  Firebase  │      │ IA (OpenAI‑   │
│ local    │      │  Auth      │      │ compatible)   │
│ (prefs)  │      │ (login)    │      │ Groq/Ollama    │
└──────────┘      └────────────┘      └───────────────┘
```

Données (inventaire, profil, paramètres) : **persistées localement** via SharedPreferences.

## Frontend (Flutter)
### Pré-requis
- Flutter SDK (dans le PATH)
- Android Studio / Android SDK (pour Android)

### Lancer l’application
```bash
flutter pub get

# Web (démo rapide)
flutter run -d chrome

# Android (émulateur ou téléphone)
flutter run
```

### Structure du dépôt (résumé)
```text
lib/
  screens/   Écrans (home, pantry, profile, scan ticket, etc.)
  services/  Accès IA, persistance, auth, etc.
  models/    Modèles (items, profil, recettes, ...)
  widgets/   Widgets réutilisables
```

## Backend (temporaire)
Le projet utilise un **backend temporaire** pour être démontrable rapidement :
- **Firebase Auth** (service externe) pour l’authentification
- **IA** via API OpenAI‑compatible :
  - **Groq** (cloud) OU
  - **Ollama** (service local)

Important : il n’y a **pas** (pour le moment) de serveur applicatif “PantryPal” dédié (Node/Java/Python) dans ce dépôt.
La logique métier reste côté app, et les intégrations passent par des services externes.

## Configuration IA (Groq / Ollama)
Les paramètres IA se configurent dans l’application (Profil → Paramètres IA).

### Option A — Groq (cloud)
- Base URL : `https://api.groq.com/openai/v1`
- API Key : `gsk_...`
- Modèle : ex. `llama-3.1-8b-instant`

### Option B — Ollama (local)
1) Installer Ollama et démarrer le service
2) Télécharger un modèle (exemple) :
```bash
ollama pull llama3.2
```
3) Configurer dans l’app :
- Base URL : `http://localhost:11434/v1`
- API Key : vide
- Modèle : ex. `llama3.2`

Note Android émulateur : `localhost` peut viser l’émulateur. Si besoin, utiliser `10.0.2.2` (Android) ou l’IP de la machine hôte.

## Tests
```bash
flutter test
flutter analyze
```

## Build APK
```bash
flutter build apk --release
```

Sortie : `build/app/outputs/flutter-apk/app-release.apk`

## Limites connues
- Les notifications locales sont prévues pour Android/iOS ; sur web certaines actions peuvent être désactivées.
- Le “backend” est temporaire (services externes + local). Une évolution naturelle serait un backend dédié (API + base de données) pour la synchronisation multi‑appareils.

