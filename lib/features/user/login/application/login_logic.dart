import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginLogic {

  Future<(bool, String)> ableToLogin(String email, String password) async {
    try{
      if (!await _emailOnDatabase(email)) {return (false, "Email no encontrado");}
      if (!await _passwordValidForEmail(email, password)) {return (false, "Contraseña incorrecta");}
    } catch (e) {
      print("[!] This is the exception: $e}");
      return ((false,"Something went wrong with the API"));
    }
    return (true, "");
  }

  Future<bool> _emailOnDatabase(String email) async{
    final url = Uri.parse('http://192.168.1.206:5000/email');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['exists'] == true;
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error'] ?? 'Unknown error';
        print("Error checking email: $errorMessage");
        throw Exception(errorMessage);
    } catch (e) {
        print("Failed with status ${response.statusCode}, but body was not JSON: ${response.body}");
      throw Exception('Unexpected error: $e');
    }
    }
  }

  Future<bool> _passwordValidForEmail(String email, String password) async{
    final url = Uri.parse('http://192.168.1.206:5000/password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['valid'] == true;
    } else {
      throw Exception('Failed to check password');
    }  
  }
}
