import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel2 {
  final String? id;
  final String nome;
  final String email;
  final String placa;
  final String? modeloCaminhao;
  final String? cnhNumero;
  final DateTime? cnhValidade;
  final double totalKmAcumulado;
  final DateTime? criadoEm;
  final int nivel;
  final int xpAtual;

  UserModel2({
    this.id,
    required this.nome,
    required this.email,
    required this.placa,
    this.modeloCaminhao = "Scania R450",
    this.cnhNumero = "09344218055",
    this.cnhValidade,
    this.totalKmAcumulado = 0.0,
    this.criadoEm,
    this.nivel = 1,
    this.xpAtual = 0,
  });

  String get tituloMotorista {
    if (nivel >= 50) return "LENDA DA ESTRADA";
    if (nivel >= 40) return "REI DA RODOVIA";
    if (nivel >= 30) return "ELITE";
    if (nivel >= 25) return "INSTRUTOR";
    if (nivel >= 20) return "MESTRE";
    if (nivel >= 15) return "ESPECIALISTA";
    if (nivel >= 10) return "PROFISSIONAL";
    if (nivel >= 5) return "ENTUSIASTA";
    return "NOVATO";
  }

  Color get corDoRank {
    if (nivel >= 50) return const Color(0xFF00E5FF);
    if (nivel >= 30) return const Color(0xFFFFD700);
    if (nivel >= 15) return const Color(0xFFC0C0C0);
    return Colors.blueAccent;
  }

  String get categoriaCnh {
    if (nivel >= 15) return "E (BITREM)";
    if (nivel >= 10) return "E";
    if (nivel >= 5) return "D";
    return "C";
  }

  int get xpNecessarioParaProxNivel => nivel * 1700;

  double get progressNivel {
    if (xpNecessarioParaProxNivel <= 0) return 0.0;
    return (xpAtual / xpNecessarioParaProxNivel).clamp(0.0, 1.0);
  }

  bool get cnhVencida {
    if (cnhValidade == null) return false;
    return cnhValidade!.isBefore(DateTime.now());
  }

  factory UserModel2.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    return UserModel2(
      id: doc.id,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      placa: map['placa'] ?? 'BRA2E19',
      modeloCaminhao: map['modelo_caminhao'] ?? "Scania R450",
      cnhNumero: map['cnh_numero'] ?? "093442218055",
      cnhValidade:
          (map['cnh_validade'] as Timestamp?)?.toDate() ??
          DateTime(2034, 5, 15),
      totalKmAcumulado: (map['total_km'] ?? 0.0).toDouble(),
      criadoEm: (map['criado_em'] as Timestamp?)?.toDate(),
      nivel: map['nivel'] ?? 1,
      xpAtual: map['xp_atual'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'placa': placa,
      'modelo_caminhao': modeloCaminhao,
      'cnh_numero': cnhNumero,
      'cnh_validade': cnhValidade != null
          ? Timestamp.fromDate(cnhValidade!)
          : null,
      'total_km': totalKmAcumulado,
      'criado_em': FieldValue.serverTimestamp(),
      'nivel': nivel,
      'xp_atual': xpAtual,
    };
  }
}
