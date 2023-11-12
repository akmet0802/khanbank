import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> sendAudioToApi(File audioFile) async {
  var uri = Uri.parse('your_api_endpoint');
  var request = http.MultipartRequest('POST', uri)
    ..files.add(await http.MultipartFile.fromPath('audio', audioFile.path));

  var response = await request.send();
  if (response.statusCode == 200) {
    print('Audio sent successfully');
  } else {
    print('Failed to send audio. Status code: ${response.statusCode}');
  }
}
