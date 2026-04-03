import 'package:cloud_firestore/cloud_firestore.dart';

class ViagemModel {
  final String? id;
  final String motoristaId;
  final String origem;
  final String destino;
  final String carga;
  final double peso;
  final double distancia;
  final List categoria;
  final DateTime data;
  final DateTime? finalizadaEm;
  final String status;
  final String velocidadeMedia;
  final double receita;
  final List despesas; // Ex: [{'descricao': 'Pedágio A22', 'valor': 15.50}]
  final List rodovias;
  final List tiposRodovias;

  ViagemModel({
    this.id,
    required this.motoristaId,
    required this.origem,
    required this.destino,
    required this.carga,
    required this.peso,
    required this.distancia,
    required this.data,
    this.finalizadaEm,
    this.status = "Em andamento",
    this.velocidadeMedia = "0 km/h",
    this.receita = 0.0,
    this.despesas = const [],
    required this.categoria,
    required this.rodovias,
    required this.tiposRodovias,
  });

  double get lucro =>
      receita - despesas.fold(0.0, (sum, item) => sum + (item['valor'] ?? 00));

  bool get isFinalizada => status == "Finalizada" || finalizadaEm != null;

  factory ViagemModel.fromFirestore(Map<String, dynamic> map, String id) {
    DateTime? dataFinalizada = (map['finalizada_em'] as Timestamp?)?.toDate();
    return ViagemModel(
      id: id,
      motoristaId: map['motorista_id'] ?? '',
      origem: map['origem'] ?? '',
      destino: map['destino'] ?? '',
      carga: map['carga'] ?? '',
      peso: (map['peso'] ?? 0.0).toDouble(),
      distancia: (map['distancia'] ?? 0.0).toDouble(),
      categoria: map['categoria'] ?? [],
      data: (map['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
      finalizadaEm: dataFinalizada,
      status:
          map['status'] ??
          (dataFinalizada != null ? 'Finalizada' : 'Em andamento'),
      velocidadeMedia: map['velocidade_media'] ?? '0 km/h',
      receita: (map['receita'] ?? 0.0).toDouble(),
      despesas: map['despesas'] ?? [],
      rodovias: map['rodovias'] ?? [],
      tiposRodovias: map['tipos_rodovia'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'motorista_id': motoristaId,
      'origem': origem,
      'destino': destino,
      'carga': carga,
      'peso': peso,
      'distancia': distancia,
      'data': FieldValue.serverTimestamp(),
      'finalizada_em': finalizadaEm != null
          ? Timestamp.fromDate(finalizadaEm!)
          : null,
      'status': status,
      'velocidade_media': velocidadeMedia,
      'receita': receita,
      'despesas': despesas,
      'lucro_total': lucro,
      'categoria': categoria,
      'rodovias': rodovias,
      'tipos_rodovia': tiposRodovias,
    };
  }
}
