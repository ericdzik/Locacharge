// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:locacharge/firebase_options.dart';
import 'package:locacharge/app/router.dart'; // Importer le routeur
import 'package:locacharge/shared/styles/colors.dart';

// Imports pour l10n (le fichier app_localizations.dart sera généré par `flutter gen-l10n`)
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';
// Assurez-vous que le chemin d'importation correspond à l'emplacement de votre fichier généré.
// Typiquement, si l10n.yaml a output-localization-file: app_localizations.dart
// et synthetic-package: false (ou est commenté), l'import sera quelque chose comme :
// import 'generated/app_localizations.dart'; // Si généré dans lib/generated/
// Ou si output-dir est spécifié dans l10n.yaml, ajustez le chemin.
// Pour la configuration actuelle (output-localization-file: app_localizations.dart sans output-dir),
// Flutter peut le générer directement dans un package implicite.
// L'IDE devrait aider à trouver le bon import pour AppLocalizations après la génération.
// Pour l'instant, nous allons anticiper un import commun.
// Si `flutter run` échoue à cause de cet import, il faudra l'ajuster après `flutter gen-l10n`.
// Pour être sûr, on peut utiliser un placeholder d'import qui sera corrigé par l'IDE/utilisateur.
// import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Cet import est commun avec Flutter 3+

// Si l'import ci-dessus ne fonctionne pas après la génération, essayez :
// import 'package:locacharge/generated/app_localizations.dart'; // si output-dir: lib/generated
// ou directement si le fichier est à la racine de lib (moins courant)
// import 'app_localizations.dart';

// Pour cette sous-tâche, je vais utiliser un import qui est souvent correct,
// mais qui dépend de la manière dont `flutter gen-l10n` est configuré par l'IDE
// ou les versions exactes.
// Le fichier 'app_localizations.dart' est généré par l'outil.
// On va supposer qu'il sera accessible via un import standard.
// L'utilisateur devra exécuter `flutter gen-l10n` pour créer ce fichier.
// Pour que le code soit analysable, on va utiliser un import conditionnel
// ou un commentaire pour le moment si le fichier n'existe pas encore.
// Pour les besoins de la sous-tâche, nous allons supposer que l'utilisateur
// exécutera `flutter gen-l10n` et que l'import suivant fonctionnera:
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:locacharge/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LocaChargeApp());
}

class LocaChargeApp extends StatelessWidget {
  const LocaChargeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LocaCharge',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', ''),
        Locale('en', ''),
      ],
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryColor,
          primary: AppColors.primaryColor,
          secondary: AppColors.accentColor,
          background: AppColors.backgroundColor,
        ),
        scaffoldBackgroundColor: AppColors.backgroundColor,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),
        useMaterial3: true,
      ),
    );
  }
}
