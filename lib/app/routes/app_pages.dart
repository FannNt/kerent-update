import 'package:get/get.dart';

import '../modules/CheckOut/bindings/check_out_binding.dart';
import '../modules/CheckOut/views/check_out_view.dart';
import '../modules/addProduct/bindings/add_product_binding.dart';
import '../modules/addProduct/views/add_product_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_list_view.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/imageCarousel/bindings/image_carousel_binding.dart';
import '../modules/imageCarousel/views/image_carousel_view.dart';
import '../modules/inbox/bindings/inbox_binding.dart';
import '../modules/inbox/views/inbox_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/mainMenu/bindings/main_menu_binding.dart';
import '../modules/mainMenu/views/main_menu_view.dart';
import '../modules/payment/bindings/payment_binding.dart';
import '../modules/payment/views/payment_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/searchResult/bindings/search_result_binding.dart';
import '../modules/searchResult/views/search_result_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const PublicProfilePage(),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: _Paths.MAIN_MENU,
      page: () => MainMenuView(),
      binding: MainMenuBinding(),
    ),
    // GetPage(
    //   name: _Paths.CHECK_OUT,
    //   page: () => const CheckOutView(),
    //   binding: CheckOutBinding(),
    // ),
    GetPage(
      name: _Paths.IMAGE_CAROUSEL,
      page: () => ImageCarousel(
        imgList: const [],
      ),
      binding: ImageCarouselBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatListView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.ADD_PRODUCT,
      page: () => AddProductView(),
      binding: AddProductBinding(),
    ),

  
    // GetPage(
    //   name: _Paths.PAYMENT,
    //   page: () => const PaymentView(),
    //   binding: PaymentBinding(),
    // ),
    GetPage(
      name: _Paths.INBOX,
      page: () => const InboxPage(),
      binding: InboxBinding(),
    ),

    GetPage(
      name: _Paths.SEARCH_RESULT,
      page: () => const SearchResultView(),
      binding: SearchResultBinding(),
    ),
  ];
}
