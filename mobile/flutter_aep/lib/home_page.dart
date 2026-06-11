import 'package:flutter/material.dart';
import 'ponto_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final PontoService _pontoService = PontoService();
  late TabController _tabController;

  void _abrirMapaNativo(double latitude, double longitude) async {
    // Cria o link universal de mapas suportado nativamente pelo Android e iOS
    final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    final Uri url = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication); // Dispara o GPS nativo do telemóvel
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Não foi possível abrir o mapa nativo.")),
        );
      }
    }
  }
  
  // Estados da Aplicação
  List<dynamic> _pontos = [];
  bool _carregando = true;
  int _pontosUsuario = 100; // Estado reativo da pontuação do utilizador

  // Variáveis para a simulação de descarte (Padrão Strategy)
  String _categoriaSelecionada = 'Plástico';
  final TextEditingController _quantidadeController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _buscarDadosDoBackend();
  }

  void _buscarDadosDoBackend() async {
    try {
      var dados = await _pontoService.buscarPontos().timeout(
        Duration(seconds: 3),
        onTimeout: () {
          print("Tempo limite esgotado ao conectar ao Spring Boot!");
          return [];
        },
      );
      if (mounted) {
        setState(() {
          _pontos = dados;
          _carregando = false;
        });
      }
    } catch (e) {
      print("Erro ao buscar dados: $e");
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  // Simulação do cálculo de pontos (Padrão Strategy)
  void _calcularEAdicionarPontos() {
    int qtd = int.tryParse(_quantidadeController.text) ?? 1;
    int multiplicador = 10; // Padrão base

    if (_categoriaSelecionada == 'Plástico') multiplicador = 20;
    if (_categoriaSelecionada == 'Metal') multiplicador = 30;
    if (_categoriaSelecionada == 'Vidro') multiplicador = 15;

    int pontosGanhos = qtd * multiplicador;

    setState(() {
      _pontosUsuario += pontosGanhos;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Descarte de $_categoriaSelecionada registado! +$pontosGanhos pts."),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EcoCulture Mobile"),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.map), text: "Ecopontos"),
            Tab(icon: Icon(Icons.recycling), text: "Descartar"),
            Tab(icon: Icon(Icons.info), text: "Educação ODS"),
          ],
        ),
      ),
      body: Column(
        children: [
          // BANNER FIXO DE PONTUAÇÃO DO UTILIZADOR
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
          
          // CONTEÚDO DAS ABAS (CORRIGIDO: Agora possui exatamente 3 filhos estruturados)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                
                // ================= ABA 1: ECOPONTOS (CONEXÃO BACKEND) =================
                Column(
                  children: [
                    // A barra de pesquisa agora divide o espaço corretamente dentro da coluna
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Digite o objeto (ex: lâmpada, pilha, plástico)...",
                          prefixIcon: Icon(Icons.search, color: Colors.green),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _carregando 
                        ? Center(child: CircularProgressIndicator())
                        : _pontos.isEmpty
                          ? Center(child: Text("Nenhum ecoponto ativo no servidor."))
                          : ListView.builder(
                              itemCount: _pontos.length,
                              itemBuilder: (context, index) {
                                final ponto = _pontos[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: ListTile(
                                    leading: Icon(Icons.location_on, color: Colors.green, size: 36),
                                    title: Text(ponto['nomeLocal'] ?? 'Ecoponto'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 4),
                                        Text("📍 ${ponto['endereco']}"),
                                        Text("⏰ Horário: ${ponto['horarioFuncionamento'] ?? 'Não informado'}"),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _buildOdsChip("ODS 11", Colors.orange),
                                            SizedBox(width: 5),
                                            _buildOdsChip("ODS 3", Colors.red.shade700),
                                            SizedBox(width: 5),
                                            _buildOdsChip("ODS 12", Colors.green.shade700),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) => Container(
                                          padding: EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(ponto['nomeLocal'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                                              SizedBox(height: 10),
                                              Text("📍 Endereço: ${ponto['endereco']}"),
                                              Text("⏰ Funcionamento: ${ponto['horarioFuncionamento']}"),
                                              Text("🌐 Coordenadas: ${ponto['latitude']}, ${ponto['longitude']}"),
                                              SizedBox(height: 15),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton.icon(
                                                  icon: Icon(Icons.navigation, color: Colors.white),
                                                  label: Text("Rota até o Ecoponto", style: TextStyle(color: Colors.white)),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    _abrirMapaNativo(
                                                      double.tryParse(ponto['latitude'].toString()) ?? 0.0, 
                                                      double.tryParse(ponto['longitude'].toString()) ?? 0.0
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),

                // ================= ABA 2: FORMULÁRIO DE DESCARTE =================
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Registar Nova Entrega Residencial", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      Text("Selecione o Material:"),
                      DropdownButton<String>(
                        value: _categoriaSelecionada,
                        isExpanded: true,
                        items: ['Plástico', 'Metal', 'Vidro', 'Papel'].map((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                        onChanged: (novoValor) {
                          setState(() { _categoriaSelecionada = novoValor!; });
                        },
                      ),
                      SizedBox(height: 20),
                      Text("Quantidade / Peso (Unidades ou Kg):"),
                      TextField(
                        controller: _quantidadeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: "Ex: 5"),
                      ),
                      SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: Text("Simular Descarte e Ganhar Pontos", style: TextStyle(color: Colors.white, fontSize: 16)),
                          onPressed: _calcularEAdicionarPontos,
                        ),
                      )
                    ],
                  ),
                ),

                // ================= ABA 3: CONTEÚDO INFORMATIVO =================
                ListView(
                  padding: EdgeInsets.all(12),
                  children: [
                    _buildDicaCard("Como descartar Vidro?", "Lave o recipiente e, se estiver partido, embrulhe-o em jornal ou coloque-o dentro de uma garrafa PET cortada para proteger os coletores urbanos.", Icons.gavel),
                    _buildDicaCard("Higiene dos Materiais", "Sempre remova o excesso de alimento das embalagens de plástico e metal. Isso evita mau cheiro e proliferação de vetores nos ecopontos.", Icons.clean_hands),
                    _buildDicaCard("O que NÃO vai para a reciclagem?", "Papel higiénico, fraldas descartáveis, espelhos, cerâmicas, caixas de pizza muito engorduradas e fitas adesivas.", Icons.dangerous),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDicaCard(String titulo, String descricao, IconData icone) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: Colors.green, size: 28),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                  SizedBox(height: 6),
                  Text(descricao, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOdsChip(String texto, Color cor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor, 
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        texto, 
        style: TextStyle(
          color: Colors.white, 
          fontSize: 10, 
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}