import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:khanbank/size_config.dart';
import 'package:khanbank/style/style.dart';
// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

Future<String> getAudioFilePath() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  print('${appDocDir.path}/audio.wav');
  return '${appDocDir.path}/audio.wav';
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isRecording = false; // Track the recording state
  String displayedText = 'Text end garna';
  final recorder = FlutterSoundRecorder();
  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await recorder.openRecorder();
  }

  Future record() async {
    String filePath = await getAudioFilePath();
    await recorder.startRecorder(toFile: filePath);
    setState(() {
      isRecording = true;
    });
  }

  Future stop() async {
    await recorder.stopRecorder();
    setState(() {
      isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal! * 7),
            child: Column(
              children: [
                //hereglegchiin heseg
                UserInfo(),
                Gap(20),
                AccountData(),
                Gap(20),
                Text(
                  '$displayedText',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                Gap(320),
                Center(
                    child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white10, padding: EdgeInsets.all(24)),
                  onPressed: () async {
                    if (recorder.isRecording) {
                      String filePath = await getAudioFilePath();
                      await stop();
                      await sendAudioToApi(File(filePath));
                    } else {
                      {
                        await record();
                      }
                      ;
                    }
                    setState(() {});
                  },
                  child: Icon(
                    isRecording ? Icons.stop_circle : Icons.mic,
                    color: Colors.white,
                    size: 48,
                  ),
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendAudioToApi(File audioFile) async {
    var uri = Uri.parse('https://api.chimege.com/v1.2/transcribe');
    String authToken =
        '5e64de0f3c3d0351507ebad51f9aad043a72623f8ea1faad20f2f753c207cad4'; // Replace with actual authentication token

    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $authToken'
      ..files.add(await http.MultipartFile.fromPath('audio', audioFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var transcription = parseTranscription(responseBody);
      setState(() {
        displayedText = transcription;
      });
    } else {
      print('Failed to send audio. Status code: ${response.statusCode}');
    }
  }
}

class UserInfo extends StatelessWidget {
  UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Padding(
        padding: EdgeInsets.only(bottom: 7),
        child: const Text(
          "👋 Сайн уу!",
          style: TextStyle(color: Colors.white),
        ),
      ),
      subtitle: Text(
        "Н.Тэмүүлэн",
        style: Theme.of(context)
            .textTheme
            .headlineSmall!
            .copyWith(fontWeight: FontWeight.w700, color: Colors.white),
      ),
      trailing: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(AppStyle.profile), fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              height: 18.0,
              width: 18.0,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppStyle.primarySwatch,
                  border: Border.all(
                      color: Colors.white,
                      width: 3.0,
                      style: BorderStyle.solid)),
            )
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class AccountData extends StatelessWidget {
  AccountData({super.key});
  String cardNumber = '2456231156541234';
  String expiryDate = '12/24';
  String cardHolderName = 'Temuulen Norovpel';
  String cvvCode = '678';
  bool isCvvFocused = false;
  bool useGlassMorphism = true;

  @override
  Widget build(BuildContext context) {
    return CreditCardWidget(
      customCardTypeIcons: [
        CustomCardTypeIcon(
            cardType: CardType.visa,
            cardImage: Image.asset("assets/images/logo.png"))
      ],
      isHolderNameVisible: true,
      bankName: 'Khanbank',
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      cardHolderName: cardHolderName,
      cvvCode: cvvCode,
      showBackView: isCvvFocused,
      // ignore: avoid_types_as_parameter_names
      onCreditCardWidgetChange: (CreditCardBrand) {},
      glassmorphismConfig: Glassmorphism.defaultConfig(),
    );
  }
}

parseTranscription(String responseBody) {
  return responseBody;
}
