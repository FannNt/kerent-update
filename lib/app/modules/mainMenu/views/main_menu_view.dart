import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kerent/app/controllers/auth_controller.dart';
import 'package:kerent/app/data/models/product.dart';
import 'package:kerent/app/modules/CheckOut/views/check_out_view.dart';
import 'package:kerent/app/modules/mainMenu/controllers/main_menu_controller.dart';
import '../../../../navbar.dart';
import '../../inbox/views/inbox_view.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../searchResult/views/search_result_view.dart';
import '../../searchResult/controllers/search_result_controller.dart';

class MainMenuView extends GetView<MainMenuController> {
  MainMenuView({super.key}) {
    final _auth = Get.find<AuthController>();
    _auth.loadUserData(); // Load user data when view is created
  }
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      body: SafeArea(
        child: Obx(() => controller.isLoading.value 
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF8225),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildSearchBar(),
                  _buildCarousel(),
                  _buildLatestItems(),
                  _buildCategoryFilter(),
                  _buildProdukList(context),
                  _buildForYouSection(context),
                ],
              ),
            ),
        ),
      ),
      currentIndex: 0,
    );
  }

  Widget _buildHeader(BuildContext context) {
    final _auth = Get.put(AuthController());
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                'Hai, ${_auth.displayName.value}!', 
                style: const TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.w800, 
                  color: Color(0xffF8F8F8), 
                  fontFamily: 'Plus Jakarta Sans'
                )
              )),
              const Opacity(
                opacity: 0.50,
                child: Text(
                  'Siap untuk merental?', 
                  style: TextStyle(
                    color: Color(0xffF8F8F8), 
                    fontSize: 13, 
                    fontFamily: 'Plus Jakarta Sans', 
                    fontWeight: FontWeight.w600
                  )
                ),
              )
            ],
          ),
          
          // Profile section
          Row(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const InboxPage(), transition: Transition.rightToLeft);
                    },
                    child: const Icon(
                      Icons.notifications_sharp,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('rentRequests')
                        .where('productOwnerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                        .where('status', isEqualTo: 'Pending')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        return Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${snapshot.data!.docs.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: controller.navigateToProfile,
                child: Obx(() => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8225),
                    shape: BoxShape.circle,
                    image: _auth.image.value.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(_auth.image.value),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _auth.image.value.isEmpty
                      ? Center(
                          child: Text(
                            _auth.displayName.value.isNotEmpty 
                                ? _auth.displayName.value[0].toUpperCase()
                                : '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : null,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () => Get.to(
          () => const SearchResultView(),
          arguments: {'searchQuery': ''},
          binding: BindingsBuilder(() {
            Get.put(SearchResultController());
          }),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          margin: const EdgeInsets.only(top: 20),
          height: 53,
          decoration: BoxDecoration(
            color: const Color(0xFF272829),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 20),
              const Text(
                "Search on Ke'rent",
                style: TextStyle(
                  color: Color(0xFFF8F8F8),
                  fontSize: 13,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Banner Style
  Widget _buildCarousel() {
    return Obx(() => Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
        child: SizedBox(
          height: 200,
          child: PageView.builder(
            controller: controller.pageController,
            itemCount: controller.banners.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (context, index) {
              return _buildCarouselItem(
                context,
                controller.banners[index].title,
                controller.banners[index].subtitle,
                controller.banners[index].image,
                controller.banners[index].color,
                index,
              );
            },
          ),
        ),
    ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            controller.banners.length,
            (index) => _buildDotIndicator(index),
          ),
        ),
      ],
    )
  );
 }

Widget _buildCarouselItem(BuildContext context, String title, String subtitle, String image, Color color, int index) {
  return Card(
    margin: const EdgeInsets.all(16),
    color: color,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 5),
                child: Text(title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101014),
                      fontFamily: 'Plus Jakarta Sans',
                    )),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF101014),
                    fontSize: 10,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffff101014),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(77, 28),
                ),
                child: const Text(
                  'Rent Now',
                  style: TextStyle(
                    color: Color(0xFFF8F8F8),
                    fontSize: 10,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Image.asset(
              image
            ),
          ),
        ],
      ),
    ),
  );
}


  //Indikator Banner
  Widget _buildDotIndicator(int index) {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: controller.currentPage.value == index
            ? Colors.white
            : Colors.grey,
      ),
    ));
  }

  

  Widget _buildLatestItems() {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, top: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Category Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Plus Jakarta Sans', color: Color(0xFFF8F8F8),)),
            ],
          ),
        ),
      ],
    );
  }
  
  

  Widget _buildProdukList(BuildContext context) {
    return Obx(() {
      if (controller.filteredProducts.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No products available in this category',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: controller.filteredProducts.map((item) {
            return _buildProduct(
              context, 
              item.name, 
              item.price, 
              item.images,
              controller.filteredProducts.indexOf(item)
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _buildProduct(BuildContext context, String name, double price, String? images, int index) {
    final formattedPrice = NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(price);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => CheckoutPage(
              produk: controller.filteredProducts[index]
            ),
          ),
        );
      },
      child: Card(
        color: const Color(0xFF31363F),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 153,
                    height: 133,
                    decoration: ShapeDecoration(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image(
                        image: NetworkImage(images ?? ''),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF8225),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (!controller.filteredProducts[index].isAvailable)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'Unavailable',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                    name.length > 20 ? '${name.substring(0, 20)}...' : name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF8F8F8),
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    formattedPrice.length > 20 ? '${formattedPrice.substring(0, 20)}...' : formattedPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Color(0xFFF8F8F8),
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              const SizedBox(height: 4),
              RatingBarIndicator(
                rating: controller.filteredProducts[index].rating,
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Color(0xFFFF8225),
                ),
                itemCount: 5,
                itemSize: 16,
                unratedColor: Colors.grey[700],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Obx(() => ChoiceChip(
              label: Text(category),
              selected: controller.selectedCategory.value == category,
              onSelected: (selected) {
                if (selected) {
                  controller.selectCategory(category);
                }
              },
              backgroundColor: const Color(0xFF272829),
              selectedColor: const Color(0xFFFF8225),
              labelStyle: TextStyle(
                color: controller.selectedCategory.value == category
                    ? Colors.white
                    : Colors.grey,
              ),
            )),
          );
        },
      )),
    );
  }

Widget _buildForYouSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(left: 16, top: 25, bottom: 16),
        child: Text(
          'For you',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Plus Jakarta Sans',
            color: Color(0xFFF8F8F8),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          if (controller.forYouProducts.isEmpty) {
            return const Center(
              child: Text(
                'No recommendations available',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
              
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: controller.forYouProducts.length,
                itemBuilder: (context, index) {
                  final item = controller.forYouProducts[index];
                  return _buildForYouCard(context, item, constraints);
                },
              );
            },
          );
        }),
      ),
    ],
  );
}

Widget _buildForYouCard(BuildContext context, Product product, BoxConstraints constraints) {
  final formattedPrice = NumberFormat.currency(locale: 'id', symbol: 'Rp. ', decimalDigits: 0).format(product.price);

  final isSmallScreen = constraints.maxWidth < 400;
  final isMediumScreen = constraints.maxWidth < 600;
  
  final titleFontSize = isSmallScreen ? 15.0 : (isMediumScreen ? 18.0 : 20.0);
  final priceFontSize = isSmallScreen ? 13.0 : (isMediumScreen ? 15.0 : 17.0);
  final ratingFontSize = isSmallScreen ? 11.0 : (isMediumScreen ? 12.0 : 13.0);

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: const Color(0xFF31363F),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckoutPage(produk: product),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    product.images,
                    fit: BoxFit.cover,
                  ),
                ),
                if (!product.isAvailable)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Unavailable',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.name.length > 20 ? '${product.name.substring(0, 20)}...' : product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF8F8F8),
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedPrice.length > 20 ? '${formattedPrice.substring(0, 20)}...' : formattedPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Color(0xFFF8F8F8),
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: product.rating,
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: const Color(0xFFFF8225),
                        ),
                        itemCount: 5,
                        itemSize: isSmallScreen ? 14 : 16,
                        unratedColor: Colors.grey[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: ratingFontSize,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}