import 'package:flutter/material.dart';
import 'ponto_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final PontoService _pontoService = PontoService();
  late TabController _tabController;
  
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
    var dados = await _pontoService.buscarPontos();
    setState(() {
      _pontos = dados;
      _carregando = false;
    });
  }

  // Simulação do cálculo de pontos (O algoritmo que você cita no relatório)
  void _calcularEAdicionarPontos() {
    int qtd = int.tryParse(_quantidadeController.text) ?? 1;
    int multiplicador = 10; // Padrão base

    // Simulação das estratégias por tipo de material
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
          // BANNER FIXO DE PONTUAÇÃO DO UTILIZADOR (Garante feedback visual constante)
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
          
          // CONTEÚDO DAS ABAS
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ABA 1: MAPA / LISTA DE ECOPONTOS (INTEGRAÇÃO COM BACKEND)
                _carregando 
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
                              subtitle: Text("${ponto['endereco']}\nHorário: ${ponto['horarioFuncionamento'] ?? 'Não informado'}"),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // Exibe um modal rápido com detalhes (Cumpre regras de IHC)
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
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                // ABA 2: FORMULÁRIO DE DESCARTE (SIMULAÇÃO DE REGRA DE NEGÓCIO)
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

                // ABA 3: CONTEÚDO INFORMATIVO (REQUISITO DAS ODS 12)
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
}