import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rotalog/data/services/app_translations.dart';
import 'package:rotalog/main_screen.dart';
import 'package:rotalog/modules/about/about_binding.dart';
import 'package:rotalog/modules/about/about_page.dart';
import 'package:rotalog/modules/auth/loginPage.dart';
import 'package:rotalog/modules/home/home_binding.dart';
import 'package:rotalog/modules/home/home_page.dart';
import 'package:rotalog/modules/home/widgets/detalhes_page.dart';
import 'package:rotalog/modules/perfil/perfilPage.dart';
import 'package:rotalog/modules/registro/registro_binding.dart';
import 'package:rotalog/modules/registro/registro_page.dart';
import 'package:rotalog/modules/settings/settings_page.dart';

Future<void> main() async {
  await initializeDateFormatting('pt_BR', null);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  User? usuarioLogado = FirebaseAuth.instance.currentUser;
  String rotaInicial = usuarioLogado == null ? '/login' : '/main';
  runApp(MyApp(rotaInicial: rotaInicial));
}

class MyApp extends StatelessWidget {
  final String rotaInicial;
  const MyApp({super.key, required this.rotaInicial});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RotaLog - Registro de Viagens',
      debugShowCheckedModeBanner: false,
      initialRoute: rotaInicial,
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: Locale('pt_BR', 'BR'),
      themeMode: ThemeMode.system,
      getPages: [
        GetPage(
          name: '/login',
          page: () => LoginPage(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: '/main',
          page: () => MainScreen(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: '/about',
          page: () => AboutPage(),
          binding: AboutBinding(),
          transition: Transition.downToUp,
        ),
        GetPage(name: '/home', page: () => HomePage(), binding: HomeBinding()),
        GetPage(
          name: '/setting',
          page: () => SettingsPage(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: '/perfil',
          page: () => PerfilPage(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: '/detail',
          page: () {
            final dynamic args = Get.arguments;
            return DetalhesPage(
              dados: args is Map ? args : args.toMap(),
              docId: args is Map ? args['id'] : args.id,
            );
          },
          transition: Transition.rightToLeftWithFade,
        ),
        GetPage(
          name: '/registro',
          page: () => RegistroPage(),
          binding: RegistroBinding(),
        ),
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blueAccent,
        fontFamily: 'Montserrat',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Montserrat',
      ),
    );
  }
}
