import 'package:get/get.dart';

class reportscreenController extends GetxController {
  final argument = ''.obs;

  @override
  void onInit() {
    argument.value = Get.arguments as String? ?? '';
    super.onInit();
  }
}