import '../core/network/cliente_api.dart';
import '../model/materiais.dart';

class MateriaisRepository {
  final ClienteApi cliente;

  MateriaisRepository(this.cliente);

  Future<List<Materiais>> listar() async {
    final resposta = await cliente.dio.get('/materiais');
    return (resposta.data as List)
        .map((materiais) =>
            Materiais.fromJson(materiais as Map<String, dynamic>))
        .toList();
  }

  Future<Materiais> cadastrar({
    required String nome,
    required String descricao,
    required double preco,
    required String categoria,
    String imageUrl = '',
  }) async {
    final resposta = await cliente.dio.post(
      '/materiais',
      data: {
        'nome': nome,
        'descricao': descricao,
        'preco': preco,
        'categoria': categoria,
        'imageUrl': imageUrl,
      },
    );
    return Materiais.fromJson(resposta.data as Map<String, dynamic>);
  }

  Future<Materiais> getMaterial(int materialId) async {
    final resposta = await cliente.dio.post('/materiais/$materialId');
    return Materiais.fromJson(resposta.data as Map<String, dynamic>);
  }
}
