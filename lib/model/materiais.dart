class Materiais {
  final int id;
  final String nome;
  final String descricao;
  final String categoria;
  final double preco;
  final String? imageUrl;

  const Materiais({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.categoria,
    required this.preco,
    this.imageUrl,
  });

  factory Materiais.fromJson(Map<String, dynamic> json) {
    return Materiais(
      id: (json['id'] as num).toInt(),
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      preco: (json['preco'] as num).toDouble(),
      categoria: json['categoria'] as String,
      imageUrl: json['imagemUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'descricao': descricao,
        'preco': preco,
        'imagemUrl': imageUrl,
        'categioria': categoria,
      };
}
