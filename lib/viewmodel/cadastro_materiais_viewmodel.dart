import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/state/estado_tela.dart';
import '../model/materiais.dart';
import '../repository/materiais_repository.dart';

class CadastroMaterialViewModel extends ChangeNotifier {
  final MateriaisRepository repository;
  bool _descartado = false;

  CadastroMaterialViewModel({required this.repository});

  EstadoTela estado = EstadoTela.inicial;
  String? mensagemErro;
  Map<String, String> erros = {};
  Materiais? material;

  Future<bool> cadastrar({
    required String nome,
    required String descricao,
    required double preco,
    String categoria = 'Novidades',
  }) async {
    if (_descartado || estado == EstadoTela.carregando) return false;
    estado = EstadoTela.carregando;
    mensagemErro = null;
    erros = {};
    material = null;
    notifyListeners();
    try {
      material = await repository.cadastrar(
        nome: nome.trim(),
        descricao: descricao.trim(),
        preco: preco,
        categoria: categoria,
      );
      estado = EstadoTela.sucesso;
      return true;
    } on DioException catch (erro) {
      estado = EstadoTela.erro;
      if (erro.response != null) {
        mensagemErro =
            'Não foi possível concluir a solicitação. Tente novamente.';
        final dados = erro.response?.data;
        if (dados is Map) {
          final mensagem = dados['message'];
          if (mensagem is String) {
            mensagemErro = mensagem;
          }
          final errosApi = dados['erros'];
          if (errosApi is Map) {
            for (final campo in errosApi.keys) {
              final mensagemCampo = errosApi[campo];
              if (campo is String && mensagemCampo is String) {
                erros[campo] = mensagemCampo;
              }
            }
          }
        }
      } else if (erro.type == DioExceptionType.connectionTimeout ||
          erro.type == DioExceptionType.receiveTimeout ||
          erro.type == DioExceptionType.sendTimeout) {
        mensagemErro = 'A API demorou para responder. Tente novamente.';
      } else {
        mensagemErro = 'Não foi possível conectar à API. Tente novamente.';
      }
    } catch (_) {
      estado = EstadoTela.erro;
      mensagemErro = 'Não foi possível cadastrar o material. Tente novamente.';
    } finally {
      if (!_descartado) notifyListeners();
    }
    return false;
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
