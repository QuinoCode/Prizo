import "dart:convert";
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:map_launcher/map_launcher.dart';
import 'package:location/location.dart';

class ShopDistance {
  final String HEREapi = "https://discover.search.hereapi.com/v1/discover?at=%a&q=%b&limit=30&radius=50000&apiKey=%c";
  final String HEREkey = "cWq-x6-p6dQ007TjTfvpfuhKsQKFyDBtzJZ8dbjEH6Y";

  Location location = Location();

  String getFullUri(LocationData coords, String query){
    String s = HEREapi.replaceFirst('%a', '${coords.latitude},${coords.longitude}');
    s = s.replaceFirst('%b', query);
    s = s.replaceFirst('%c', HEREkey);
    return Uri.encodeFull(s);
  }

  Future<Map<String, dynamic>?> fetchLocationsAPI(String query) async {
    try {
      //_serviceEnabled();
      //_permissionGranted();
      HttpOverrides.global = MyHttpOverrides();
      final coords = await location.getLocation();
      final url = getFullUri(coords, query);
      print(url);
      var response = await http.get(Uri.parse(url), headers:{"Accept":"application/json", "Accept-Encoding":"gzip"});
      if (response. statusCode == 200) {
        final jsonResp = json.decode(response.body);
        return jsonResp;
      } else {
        throw Exception("Failed to get location");
      }
    } catch (e) {
      print("Error fetching location: $e");
      return null;
    }
  }

  Future<int> fetchDistanceAPI(String query) async {
    try {
      final jsonMap = await fetchLocationsAPI(query);
      int toReturn = jsonMap?["items"][0]["distance"];
      if (jsonMap != null){
        return toReturn;
      }
      return toReturn;
    }catch (e) {
      print("Error fetching location: $e");
      return 0;
    }
  }

  void launchMapQuery (String query) async{
    Map<String, dynamic>? jsonMap = await fetchLocationsAPI(query);
    final availableMaps = await MapLauncher.installedMaps;
    final coords = Coords(jsonMap?["items"][0]["position"]["lat"],jsonMap?["items"][0]["position"]["lng"]);
    if(jsonMap != null){
      await MapLauncher.showDirections(mapType: availableMaps.first.mapType, destination: coords);
    }
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}