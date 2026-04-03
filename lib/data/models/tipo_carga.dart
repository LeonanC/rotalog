class TipoCarga {
  final int? id;
  final String nome;
  final String peso;
  final double bonus;

  TipoCarga({
    required this.id,
    required this.nome,
    required this.peso,
    required this.bonus,
  });

  factory TipoCarga.fromFirestore(Map<String, dynamic> map, String id) {
    return TipoCarga(
      id: int.tryParse(id),
      nome: map['nome'] ?? '',
      peso: map['peso'] ?? '',
      bonus: (map['bonus'] ?? 0.0).toDouble(),
    );
  }
}
