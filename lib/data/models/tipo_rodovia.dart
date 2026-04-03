class TipoRodovia {
  final String id;
  final String nome;
  final String limiteVia;

  TipoRodovia({required this.id, required this.nome, required this.limiteVia});

  factory TipoRodovia.fromFirestore(Map<String, dynamic> map, String id) {
    return TipoRodovia(
      id: id,
      nome: map['nome'] ?? '',
      limiteVia: map['limite_via'] ?? '',
    );
  }
}
