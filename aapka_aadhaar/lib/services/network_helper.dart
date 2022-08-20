import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  NetworkHelper(
      {required this.startLng,
      required this.startLat,
      required this.endLng,
      required this.endLat});

  final String url = 'https://api.openrouteservice.org/v2/directions/';
  final String apiKey =
      '5b3ce3597851110001cf6248216fc70cd809493eb4dd0746e4fab19d';
  final String pathParam = 'driving-car'; // Change it if you want
  final double startLng;
  final double startLat;
  final double endLng;
  final double endLat;

  Future getData() async {
    http.Response response = await http.get(Uri.parse(
        '$url$pathParam?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat'));
    print(
        'url ${Uri.parse('$url$pathParam?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat')}');
    if (response.statusCode == 200) {
      String data = response.body;

      return jsonDecode(data);
    } else {
      print('data ${response.statusCode}');
    }
  }
}

class LineString {
  LineString(this.lineString);
  List<dynamic> lineString;
}
