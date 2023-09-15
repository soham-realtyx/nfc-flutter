import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'api_helper.dart';
import 'helper.dart';

class MyController extends GetxController {
  late NfcTag myTag;
  Rx<String> selectedGroup = 'NFC'.obs;
  final TextEditingController messageController = TextEditingController();
  Rx<bool> isReadMode = true.obs;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  bool isQrInitialized = false;
  Rx<bool> isNFCSupported = false.obs;
  MyController() {
    checkNFCAvailable();
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void changeReadWriteMode() {
    isReadMode.value = !isReadMode.value;
    isReadMode.refresh();
  }

  Future<void> setData({required String message}) async {
    try {
      Ndef? ndef = Ndef.from(myTag);
      NdefMessage message = NdefMessage([
        NdefRecord.createExternal('android.com', 'pkg',
            Uint8List.fromList(messageController.text.codeUnits))
      ]);
      await ndef!.write(message);
      Helper.showSnackBar(
          context: Get.context!, message: 'Data written successfully');
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> checkNFCAvailable() async {
    try {
      await NfcManager.instance.isAvailable().then((value) async {
        isNFCSupported.value = value;
        if (value) {
          await NfcManager.instance.startSession(
            alertMessage: 'NFC Service Started',
            onDiscovered: (NfcTag tag) async {
              myTag = tag;
              if (isReadMode.value == true) {
                print(tag.data);

                List<int> binaryData =
                    tag.data['ndef']['cachedMessage']['records'][0]['payload'];
                List<int> trimmedAsciiValues = List.from(binaryData);
                Helper.showSnackBar(
                    context: Get.context!,
                    message: String.fromCharCodes(trimmedAsciiValues));
                // nfcTagData = String.fromCharCodes(trimmedAsciiValues);
                await ApiHelper.postData(isJsonData: true, data: {}, url: '');
              } else {
                await setData(message: '');
              }
            },
          );
        }
      });
    } catch (e) {}
  }

  Future<void> stopNfc() async {
    await NfcManager.instance.stopSession();
  }

  void changeSelection({required String option}) async {
    selectedGroup.value = option;

    if (selectedGroup.value == 'CAMERA') {
      // await stopNfc();
    } else {
      //  await checkNFCAvailable();
    }
  }
}
