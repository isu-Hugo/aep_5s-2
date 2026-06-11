import 'package:flutter/material.dart';
import 'ponto_service.dart';

class MapaMockScreen extends StatefulWidget {
  @override
  _MapaMockScreenState createState() => _MapaMockScreenState();
}

class _MapaMockScreenState extends State<MapaMockScreen> {
  final PontoService _pontoService = PontoService();
  List<dynamic> _pontos = [];
  bool _carregando = true;
  
  // Estado da Pontuação do Utilizador (Padrão Observer/Stateful reativo)
  int _pontosUsuario = 100; 

  @override
  void initState() {
    super.initState();
    _atualizarPontosDoServidor();
  }

  void _atualizarPontosDoServidor() async {
  try {
    // Define um tempo limite de 3 segundos para a resposta do servidor
    var pontosDoBanco = await _pontoService.buscarPontos().timeout(
      Duration(seconds: 3),
      onTimeout: () {
        print("Tempo limite de conexão esgotado!");
        return []; // Retorna lista vazia se estourar o tempo
      },
    );

    setState(() {
      _pontos = pontosDoBanco;
      _carregando = false;
    });
  } catch (e) {
    print("Erro capturado na inicialização: $e");
    setState(() {
      _carregando = false; // Desliga o carregando para mostrar a interface
    });
  }
}

  // Simulação da regra de negócio: Adicionar pontos ao coletar material
  void _realizarColetaSimulada() {
    setState(() {
      _pontosUsuario += 50; // Adiciona 50 pontos em tempo real na interface
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Coleta realizada! +50 pontos adicionados.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EcoCulture - MVP"),
        backgroundColor: Colors.green,
      ),
      body: _carregando 
        ? Center(child: CircularProgressIndicator()) 
        : Column(
            children: [
              // CARD DE PONTUAÇÃO DO UTILIZADOR
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.green.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("O Teu Saldo Ecológico:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Chip(
                      label: Text("$_pontosUsuario pts", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.green,
                    ),
                  ],
                ),
              ),

              // SIMULAÇÃO DO MAPA (Lista dinâmica vinda do Spring Boot)
              Expanded(
                child: _pontos.isEmpty 
                  ? Center(child: Text("Nenhum ecoponto encontrado no servidor."))
                  : ListView.builder(
                      itemCount: _pontos.length,
                      itemBuilder: (context, index) {
                        final ponto = _pontos[index];
                        return Card(
                          margin: EdgeInsets.all(10),
                          elevation: 4,
                          child: ListTile(
                            leading: Icon(Icons.location_on, color: Colors.green, size: 40),
                            title: Text(ponto['nomeLocal'] ?? 'Sem nome'),
                            subtitle: Text("${ponto['endereco']}\nCoordenadas: ${ponto['latitude']}, ${ponto['longitude']}"),
                            isThreeLine: true,
                            trailing: ElevatedButton(
                              onFocusChange: null, // Apenas para layout
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: Text("Coletar"),
                              onPressed: _realizarColetaSimulada, // Dispara a atualização reativa
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
    );
  }
}