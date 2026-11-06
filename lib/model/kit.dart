import 'item_kit.dart';

class Kit {
  final int usuarioId;
  final List<ItemKit> itens;
  final int quantidadeTotal;
  final double total;

  const Kit({
    required this.usuarioId,
    required this.itens,
    required this.quantidadeTotal,
    required this.total,
  });

  factory Kit.vazio({required int usuarioId}) {
    return Kit(
      usuarioId: usuarioId,
      itens: const [],
      quantidadeTotal: 0,
      total: 0,
    );
  }

  factory Kit.fromJson(Map<String, dynamic> json) {
    return Kit(
      usuarioId: (json['usuarioId'] as num).toInt(),
      itens: (json['itens'] as List)
          .map((item) => ItemKit.fromJson(item as Map<String, dynamic>))
          .toList(),
      quantidadeTotal: (json['quantidadeTotal'] as num).toInt(),
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'usuarioId': usuarioId,
        'itens': itens.map((item) => item.toJson()).toList(),
        'quantidadeTotal': quantidadeTotal,
        'total': total,
      };
}
