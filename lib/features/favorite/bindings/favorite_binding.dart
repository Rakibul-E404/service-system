// import 'package:get/get.dart';
// import '../controllers/favorite_controller.dart';
//
// class FavoriteBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.lazyPut<FavoriteController>(
//       () => FavoriteController()
//     );
//   }
// }



import 'package:get/get.dart';
import '../controllers/favorite_controller.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoriteController>(() => FavoriteController());
  }
}