import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class ShopDistance {
  final String HEREapi = "https://discover.search.hereapi.com/v1/discover?at=%a&q=%b&apiKey=%c";
  final String HEREkey = "cWq-x6-p6dQ007TjTfvpfuhKsQKFyDBtzJZ8dbjEH6Y";

  Future<String> getCurrentPosition() async {
    const LocationSettings lS = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    return await Geolocator.getCurrentPosition(locationSettings: lS).toString();
  }

  Uri getFullUri(String coords, String query){
    String s = HEREapi.replaceFirst('%a', coords);
    s = HEREapi.replaceFirst('%b', query);
    s = HEREapi.replaceFirst('%c', HEREkey);
    return Uri.parse(s);
  }

  Future<String> fetchLocationsAPI(String query) async {
    try {
      final coords = await getCurrentPosition();
      final url = getFullUri(coords, query);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResp = json.decode(response.body);
        final locationJsonMap = jsonResp["items"];
        return locationJsonMap[0]["distance"];
      } else {
        throw Exception("Failed to get location");
      }
    } catch (e) {
      print("Error fetching location: $e");
      return "";
    }
  }

}