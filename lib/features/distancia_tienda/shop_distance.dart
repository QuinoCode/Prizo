import "dart:convert";
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class ShopDistance {
  final String HEREapi = "https://discover.search.hereapi.com/v1/discover?at=%a&q=%b&apiKey=%c";
  final String HEREkey = "cWq-x6-p6dQ007TjTfvpfuhKsQKFyDBtzJZ8dbjEH6Y";

  Location location = new Location();

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
  Uri getFullUri(LocationData coords, String query){
    String s = HEREapi.replaceFirst('%a', "${coords.latitude},${coords.longitude}");
    s = HEREapi.replaceFirst('%b', query);
    s = HEREapi.replaceFirst('%c', HEREkey);
    return Uri.parse(s);
  }

  Future<String> fetchLocationsAPI(String query) async {
    try {
      //_serviceEnabled();
      //_permissionGranted();
      final coords = await location.getLocation();
      final url = getFullUri(coords, query);
      print(url);
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