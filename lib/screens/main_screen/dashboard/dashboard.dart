import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_admin/models/banner_model.dart';
import 'package:e_commerce_admin/screens/main_screen/dashboard/components/dashboard_controller.dart';
import 'package:e_commerce_admin/utils/constants.dart';
import 'package:e_commerce_admin/widgets/dashed_rect.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:e_commerce_admin/utils/utils.dart';

class Dashboard extends StatefulWidget {
  static const routeName = '/dashboard';

  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    Get.put(DashboardController());

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Obx(() => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    selectImage(context),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: controller.loading.value
                            ? null
                            : () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: controller.endDate.value ??
                                      DateTime.now(),
                                  firstDate: controller.endDate.value ??
                                      DateTime.now(),
                                  lastDate: DateTime(
                                      (controller.endDate.value ??
                                                  DateTime.now())
                                              .year +
                                          1),
                                );

                                if (picked != null) {
                                  controller.endDate.value = picked;
                                }
                              },
                        child: const Text('Select End Date')),
                    const SizedBox(
                      height: 20,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: controller.endDate.value == null
                          ? Container()
                          : Text(DateFormat('dd-MM-yyyy')
                              .format(controller.endDate.value!)),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: controller.endDate.value == null ||
                                  controller.selectedFile.value == null ||
                                  controller.loading.value
                              ? null
                              : () async {
                                  uploadBanner();
                                },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: controller.loading.value
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                        )),
                                  )
                                : const Text('Publish Banner'),
                          )),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }

  Widget selectImage(BuildContext context) {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: controller.selectedFile.value == null
            ? InkWell(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  controller.selectedFile.value =
                      await picker.pickImage(source: ImageSource.gallery);
                },
                child: SizedBox(
                  height: 120,
                  child: DashedRect(
                    color: Get.theme.colorScheme.primary,
                    strokeWidth: 2.0,
                    gap: 3.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.image,
                          color: Colors.black45,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Select Image File',
                          style: Theme.of(context).textTheme.subtitle2,
                        )
                      ],
                    ),
                  ),
                ),
              )
            : FutureBuilder<Uint8List>(
                future: getImageUrl(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                      ),
                    );
                  }

                  if (snap.hasData) {
                    return AspectRatio(
                      aspectRatio: 2,
                      child: Image.memory(snap.data!),
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ));
  }

  Future<Uint8List> getImageUrl() async {
    return await controller.selectedFile.value!.readAsBytes();
  }

  Future<void> uploadBanner() async {
    try {
      String uniqueId = Timestamp.now().millisecondsSinceEpoch.toString();

      UploadTask? task = await uploadFile(context, uniqueId);

      if (task != null) {
        await showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: StreamBuilder<TaskSnapshot>(
                      stream: task.snapshotEvents,
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<TaskSnapshot> asyncSnapshot,
                      ) {
                        Widget subtitle = const Text('---');
                        TaskSnapshot? snapshot = asyncSnapshot.data;
                        TaskState? state = snapshot?.state;

                        if (asyncSnapshot.hasError) {
                          if (asyncSnapshot.error is FirebaseException &&
                              // ignore: cast_nullable_to_non_nullable
                              (asyncSnapshot.error as FirebaseException).code ==
                                  'canceled') {
                            subtitle = const Text('Upload canceled.');
                          } else {
                            // ignore: avoid_print
                            print(asyncSnapshot.error);
                            subtitle = const Text('Something went wrong.');
                          }
                        } else if (snapshot != null) {
                          subtitle =
                              Text('${_bytesTransferred(snapshot)} sent');
                        }

                        if (state == TaskState.success) {
                          Navigator.of(context).pop();
                        }

                        return Dismissible(
                          key: Key(task.hashCode.toString()),
                          onDismissed: (value) {},
                          child: ListTile(
                            title: const Text('Uploading your file'),
                            subtitle: subtitle,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (state == TaskState.running)
                                  IconButton(
                                    icon: const Icon(Icons.pause),
                                    onPressed: task.pause,
                                  ),
                                if (state == TaskState.running)
                                  IconButton(
                                    icon: const Icon(Icons.cancel),
                                    onPressed: task.cancel,
                                  ),
                                if (state == TaskState.paused)
                                  IconButton(
                                    icon: const Icon(Icons.file_upload),
                                    onPressed: task.resume,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                ));

        if (task.snapshot.state != TaskState.success) {
          if (mounted) {
            ScaffoldSnackbar.of(context).show('Something went wrong!!!');
          }
          log('Something went wrong!!!');
          return;
        }

        BannerModel bannerModel = BannerModel(
            id: uniqueId,
            endDate: Timestamp.fromDate(controller.endDate.value!),
            imageUrl: '');

        bannerModel.imageUrl = await _downloadLink(task.snapshot.ref);

        await db.collection('banners').doc(uniqueId).set(bannerModel.toMap());

        if (mounted) {
          ScaffoldSnackbar.of(context).show('Banner Added Successfully');
        }
      }
    } catch (e) {
      ScaffoldSnackbar.of(context).show(e.toString());
      return;
    } finally {
      controller.loading.value = false;
      controller.endDate.value = null;
      controller.selectedFile.value = null;
    }
  }

  Future<UploadTask?> uploadFile(
      BuildContext context, String uniqueString) async {
    if (controller.selectedFile.value == null) {
      ScaffoldSnackbar.of(context).show('No file was selected');
      return null;
    }

    XFile file = controller.selectedFile.value!;

    UploadTask uploadTask;

    // Create a Reference to the file
    // Using Random number so the same file name possibility will be much less (almost to no)
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('banners')
        .child('/${appName}_$uniqueString');

    final metadata = SettableMetadata(
      contentType: file.mimeType,
      customMetadata: {'picked-file-path': file.path},
    );

    if (kIsWeb) {
      uploadTask = ref.putData(await file.readAsBytes(), metadata);
    } else {
      uploadTask = ref.putFile(File(file.path), metadata);
    }

    return Future.value(uploadTask);
  }

  Future<String> _downloadLink(Reference ref) async {
    return await ref.getDownloadURL();
  }

  /// Displays the current transferred bytes of the task.
  String _bytesTransferred(TaskSnapshot snapshot) {
    return '${getFormattedSize(snapshot.bytesTransferred, 2)}/${getFormattedSize(snapshot.totalBytes, 2)}';
  }

  String getFormattedSize(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (math.log(bytes) / math.log(1024)).floor();
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
