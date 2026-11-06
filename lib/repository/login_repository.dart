import '../core/network/cliente_api.dart';
import '../model/usuario.dart';

class LoginRepository {
  final ClienteApi cliente;

  LoginRepository(this.cliente);

  Future<Usuario> entrar(String email, String senha) async {
    final resposta = await cliente.dio.post(
      '/login',
      data: {'email': email, 'senha': senha},
    );
    return Usuario.fromJson(resposta.data as Map<String, dynamic>);
  }
}
