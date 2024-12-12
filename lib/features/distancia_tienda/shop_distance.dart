import "dart:convert";
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:location/location.dart';

class ShopDistance {
  final String HEREapi = "https://discover.search.hereapi.com/v1/discover?at=%a&q=%b&limit=3&apiKey=%c";
  final String HEREkey = "cWq-x6-p6dQ007TjTfvpfuhKsQKFyDBtzJZ8dbjEH6Y";

  Location location = Location();

  /*Future<bool> _serviceEnabled() async {
    var service = await location.serviceEnabled();
    if (!service) {
      service = await location.requestService();
      if (!service) {
        return service;
      }
    }
    return service;
  }

  Future<PermissionStatus> _permissionGranted() async{
    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied){
      permission = await location.requestPermission();
      if (permission == PermissionStatus.denied){
        return permission;
      }
    }
    return permission;
  }
*/
  String getFullUri(LocationData coords, String query){
    String s = HEREapi.replaceFirst('%a', '${coords.latitude},${coords.longitude}');
    s = s.replaceFirst('%b', query);
    s = s.replaceFirst('%c', HEREkey);
    return Uri.encodeFull(s);
  }

  Future<String> fetchLocationsAPI(String query) async {
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
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}