import '../core/network/cliente_api.dart';
import '../model/kit.dart';

class KitRepository {
  final ClienteApi cliente;//Dio

  KitRepository(this.cliente);

  Future<Kit> buscar(int usuarioId) async {
    final resposta = await cliente.dio.get(
      '/kit?usuarioId=$usuarioId',
    );
    return Kit.fromJson(resposta.data as Map<String, dynamic>);
  }

  Future<Kit> adicionar(
    int usuarioId,
    int materialId, {
    int quantidade = 1,
  }) async {
    final resposta = await cliente.dio.post(
      '/kit',
      data: {
        'usuarioId': usuarioId,
        'materialId': materialId,
        'quantidade': quantidade,
      },
    );
    print("AAAAAAAAA");
    return Kit.fromJson(resposta.data as Map<String, dynamic>);
  }

  Future<Kit> alterarQuantidade(
    int usuarioId,
    int materialId,
    int quantidade,
  ) async {
    final resposta = await cliente.dio.patch(
      '/kit/$materialId',
      data: {'usuarioId': usuarioId, 'quantidade': quantidade},
    );
    return Kit.fromJson(resposta.data as Map<String, dynamic>);
  }

  //remover um material do kit do user
  Future<Kit> remover(int usuarioId, int materialId) async {
    final resposta = await cliente.dio.delete(
      '/kit/$materialId?usuarioId=$usuarioId',
    );
    return Kit.fromJson(resposta.data as Map<String, dynamic>);
  }

  //retirar TODOS os kit do user
  Future<Kit> limpar(int usuarioId) async {
    final resposta = await cliente.dio.delete(
      '/kit?usuarioId=$usuarioId',
    );
    return Kit.fromJson(resposta.data as Map<String, dynamic>);
  }
}
