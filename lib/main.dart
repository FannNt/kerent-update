import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kerent/app/modules/addProduct/controllers/add_product_controller.dart';
import 'package:kerent/app/services/produk_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/controllers/auth_controller.dart';
import 'app/modules/home/views/home_view.dart';
import 'app/modules/login/controllers/login_controller.dart';
import 'app/modules/mainMenu/views/main_menu_view.dart';
import 'app/routes/app_pages.dart';
import 'app/services/auth_service.dart';
import 'app/modules/loading/loading.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Get.putAsync(() async => AuthService());
  await Get.putAsync(() async => ProductService());
  Get.lazyPut<AuthController>(() => AuthController());
  Get.lazyPut<AddProductController>(() => AddProductController());
    await Supabase.initialize(
    url: 'https://wvnyaalmcawdnkaylvso.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind2bnlhYWxtY2F3ZG5rYXlsdnNvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgzODY2NjAsImV4cCI6MjA0Mzk2MjY2MH0.BmHwEB3UBa-vshLjOFjpzQpMP_xwl2W81kmz6cWJizE',
  );

  runApp(
    GetMaterialApp(
      title: "Application",
      home: InitialScreen(),
      getPages: AppPages.routes,
    ),
  );
}
class InitialScreen extends StatelessWidget {
  final LoginController _loginController = Get.put(LoginController());

  @override
Widget build(BuildContext context) {
  return FutureBuilder(
    future: _loginController.initializeAuth(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        return Obx(() {
          if (_loginController.user.value != null) {
            return MainMenuView();
          } else {
            return const HomeView();
          }
        });
      }

      // Ganti CircularProgressIndicator dengan Custom Loading Page
      return const LoadingPage();
    },
  );
}

}
