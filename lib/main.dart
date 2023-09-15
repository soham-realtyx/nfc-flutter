import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:nfc/my_controller.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'NFC READER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePageState(),
    );
  }
}

class MyHomePageState extends StatelessWidget {
  final MyController myController = Get.put(MyController());

  MyHomePageState({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Image.asset(
            'assets/runr_white_logo.png',
            fit: BoxFit.fitHeight,
            height: 20,
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Obx(
              () => Container(
                height: Get.height,
                width: double.infinity,
                alignment: Alignment.center,
                child: myController.selectedGroup.value != 'NFC'
                    ? getQrView(context: context)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          myController.isNFCSupported.value == false
                              ? Text(
                                  'NFC is not supported on this device',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: Helper.fontFamily,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : SizedBox(
                                  child: Image.asset(
                                    'assets/nfc.png',
                                  ),
                                ),
                        ],
                      ),
              ),
            ),
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Obx(
                          () => Theme(
                            data: Theme.of(context).copyWith(
                                unselectedWidgetColor: Colors.white,
                                disabledColor: Colors.blue),
                            child: Radio(
                                value: 'NFC',
                                groupValue: myController.selectedGroup.value,
                                activeColor:
                                    myController.selectedGroup.value == 'NFC'
                                        ? Colors.blue
                                        : Colors.white,
                                onChanged: (newVal) {
                                  myController.changeSelection(option: 'NFC');
                                }),
                          ),
                        ),
                        Obx(
                          () => Text(
                            'NFC',
                            style: TextStyle(
                                color: myController.selectedGroup.value == 'NFC'
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.w500,
                                fontFamily: Helper.fontFamily,
                                fontSize: 12),
                          ),
                        ),
                        Obx(
                          () => Radio(
                              value: 'CAMERA',
                              activeColor: Colors.blue,
                              groupValue: myController.selectedGroup.value,
                              onChanged: (newVal) {
                                myController.changeSelection(option: 'CAMERA');
                              }),
                        ),
                        Obx(
                          () => Text(
                            'CAMERA',
                            style: TextStyle(
                                color: myController.selectedGroup.value == 'NFC'
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.w500,
                                fontFamily: Helper.fontFamily,
                                fontSize: 12),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 40,
                      child: Obx(
                        () => myController.isNFCSupported.value == false ||
                                myController.selectedGroup.value != 'NFC'
                            ? const SizedBox.shrink()
                            : LiteRollingSwitch(
                                value: myController.isReadMode.value,
                                width: 100,
                                textSize: 12,
                                textOn: 'Read',
                                textOff: 'Write',
                                colorOn: Colors.green,
                                colorOff: Colors.blue,
                                iconOn: Icons.read_more,
                                iconOff: Icons.edit,
                                animationDuration:
                                    const Duration(milliseconds: 100),
                                onChanged: (bool state) {
                                  myController.changeReadWriteMode();
                                },
                                onDoubleTap: () {},
                                onSwipe: () {},
                                onTap: () {},
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => Text('Powered by',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: Helper.fontFamily,
                          color: myController.selectedGroup.value == 'NFC'
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Obx(
                      () => Image.asset(
                        'assets/runr_logo.png',
                        color: myController.selectedGroup.value == 'NFC'
                            ? Colors.black
                            : Colors.white,
                        height: 30,
                        width: 80,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(
              () => Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: myController.selectedGroup.value == 'NFC' &&
                          myController.isReadMode.value == false
                      ? Padding(
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                          ),
                          child: TextFormField(
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                fontFamily: Helper.fontFamily,
                                color: Colors.black),
                            controller: myController.messageController,
                            decoration: const InputDecoration(
                                hintText: 'Enter detail',
                                isDense: true,
                                border: OutlineInputBorder()),
                          ),
                        )
                      : SizedBox.shrink()),
            )
          ],
        ));
  }

  Widget getQrView({required BuildContext context}) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: QRView(
        overlay: QrScannerOverlayShape(
            borderColor: Colors.blue,
            borderRadius: 5,
            borderLength: 10,
            borderWidth: 5,
            cutOutSize: 1 > 0
                ? MediaQuery.of(context).size.width * 0.8
                : (MediaQuery.of(context).size.width < 400 ||
                        MediaQuery.of(context).size.height < 400)
                    ? 150.0
                    : 300.0),
        key: myController.qrKey,
        onQRViewCreated: (qrController) {
          qrController.resumeCamera();
          qrController.scannedDataStream.listen((scanData) async {
            qrController.pauseCamera();
            if (scanData.code != null) {
              try {
                await launchUrl(Uri.parse(scanData.code!),
                    mode: LaunchMode.externalApplication);
              } catch (e) {
                print(e.toString());
              }
            }
            qrController.resumeCamera();
          });
        },
      ),
    );
  }
}
