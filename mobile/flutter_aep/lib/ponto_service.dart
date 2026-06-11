import 'dart:convert';
import 'package:http/http.dart' as http;

class PontoService {
  // Configuração para o Emulador Android. Se for iOS ou Web, usa 'localhost:8080'
  final String apiUrl = "http://192.168.100.109:8080/api/pontos";

  Future<List<dynamic>> buscarPontos() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Converte o texto JSON que veio do Spring Boot numa lista do Dart
        return json.decode(response.body);
      } else {
        throw Exception("Erro ao carregar pontos do servidor");
      }
    } catch (e) {
      print("Erro de conexão: $e");
      return []; // Retorna lista vazia caso o back-end esteja desligado (evita crash)
    }
  }
}