import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DashboardController extends GetxController {
  Rx<XFile?> selectedFile = Rx(null);
  Rx<DateTime?> endDate = Rx(null);
  RxBool loading = false.obs;
}
