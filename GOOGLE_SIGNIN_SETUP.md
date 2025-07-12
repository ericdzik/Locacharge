# Configuration Google Sign-In

## Problème résolu
Les erreurs Google Sign-In ont été corrigées en modifiant le service d'authentification pour éviter l'initialisation automatique qui causait des erreurs.

## Configuration complète (optionnelle)

Si vous souhaitez utiliser Google Sign-In dans votre application, suivez ces étapes :

### 1. Configuration Firebase Console
1. Allez sur [Firebase Console](https://console.firebase.google.com)
2. Sélectionnez votre projet
3. Allez dans "Authentication" > "Sign-in method"
4. Activez "Google" comme méthode de connexion
5. Configurez les domaines autorisés

### 2. Obtenir le Client ID
1. Allez sur [Google Cloud Console](https://console.cloud.google.com)
2. Sélectionnez votre projet
3. Allez dans "APIs & Services" > "Credentials"
4. Créez ou utilisez un "OAuth 2.0 Client ID" pour le web
5. Copiez le Client ID

### 3. Mettre à jour web/index.html
Remplacez `YOUR_GOOGLE_CLIENT_ID` dans `web/index.html` par votre vrai Client ID :

```html
<meta name="google-signin-client_id" content="123456789-abcdef.apps.googleusercontent.com">
```

### 4. Configuration Android (si nécessaire)
Pour Android, ajoutez dans `android/app/build.gradle` :

```gradle
defaultConfig {
    // ... autres configurations
    resValue "string", "default_web_client_id", "YOUR_WEB_CLIENT_ID"
}
```

## État actuel
- ✅ Erreurs de déconnexion corrigées
- ✅ Application fonctionne sans Google Sign-In
- ⚠️ Google Sign-In désactivé par défaut (configuration manuelle requise)

## Utilisation
L'application fonctionne maintenant avec :
- Connexion par email/mot de passe ✅
- Déconnexion sans erreur ✅
- Analytics avec gestion d'erreurs ✅ 