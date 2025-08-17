import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterLogic {

  Future<(bool, String)> ableToRegister(String email, String password, String repeated_password) async {
    try{
      if (await _emailOnDatabase(email)) {return (false, "Este email ya tiene cuenta");}
      if (!_passwordMatchesRepeatedPassword(password, repeated_password)) {return (false, "Las contraseñas no son iguales");}
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

  bool _passwordMatchesRepeatedPassword(String password, String repeated_password) {
    return password == repeated_password;
  }
  Future<bool> createAccount(String email, String password) async {
    final url = Uri.parse('http://192.168.1.206:5000/createAccount');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['inserted'] == true;
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
}
