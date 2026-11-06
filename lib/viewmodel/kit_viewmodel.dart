import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/state/estado_tela.dart';
import '../model/kit.dart';
import '../repository/kit_repository.dart';

class KitViewModel extends ChangeNotifier {
  final KitRepository repository;
  final int usuarioId;

  KitViewModel({required this.repository, required this.usuarioId})
      : kit = Kit.vazio(usuarioId: usuarioId);

  EstadoTela estado = EstadoTela.inicial;
  String? mensagemErro;
  Kit kit;
  bool atualizando = false;
  String? erroAcao;
  bool _descartado = false;

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  Future<void> carregar() async {
    if (_descartado || estado == EstadoTela.carregando || atualizando) return;
    estado = EstadoTela.carregando;
    mensagemErro = null;
    notifyListeners();
    try {
      kit = await repository.buscar(usuarioId);
      estado = EstadoTela.sucesso;
    } on DioException catch (erro) {
      if (erro.response != null) {
        mensagemErro =
            'Não foi possível concluir a solicitação. Tente novamente.';
        final dados = erro.response?.data;
        if (dados is Map) {
          final mensagem = dados['message'];
          if (mensagem is String) {
            mensagemErro = mensagem;
          }
        }
      } else if (erro.type == DioExceptionType.connectionTimeout ||
          erro.type == DioExceptionType.receiveTimeout ||
          erro.type == DioExceptionType.sendTimeout) {
        mensagemErro = 'A API demorou para responder. Tente novamente.';
      } else {
        mensagemErro = 'Não foi possível conectar à API. Tente novamente.';
      }
      estado = EstadoTela.erro;
    } catch (_) {
      mensagemErro = 'Não foi possível carregar o kit. Tente novamente.';
      estado = EstadoTela.erro;
    } finally {
      if (!_descartado) notifyListeners();
    }
  }

  Future<bool> alterarQuantidade(int materialId, int quantidade) async {
    if (_descartado || atualizando || estado == EstadoTela.carregando) {
      return false;
    }
    atualizando = true;
    erroAcao = null;
    notifyListeners();
    try {
      kit =
          await repository.alterarQuantidade(usuarioId, materialId, quantidade);
      estado = EstadoTela.sucesso;
      return true;
    } on DioException catch (erro) {
      if (erro.response != null) {
        erroAcao = 'Não foi possível concluir a solicitação. Tente novamente.';
        final dados = erro.response?.data;
        if (dados is Map) {
          final mensagem = dados['message'];
          if (mensagem is String) {
            erroAcao = mensagem;
          }
        }
      } else if (erro.type == DioExceptionType.connectionTimeout ||
          erro.type == DioExceptionType.receiveTimeout ||
          erro.type == DioExceptionType.sendTimeout) {
        erroAcao = 'A API demorou para responder. Tente novamente.';
      } else {
        erroAcao = 'Não foi possível conectar à API. Tente novamente.';
      }
    } catch (_) {
      erroAcao = 'Não foi possível atualizar o kit. Tente novamente.';
    } finally {
      atualizando = false;
      if (!_descartado) notifyListeners();
    }
    return false;
  }

  Future<bool> remover(int materialId) async {
    if (_descartado || atualizando || estado == EstadoTela.carregando) {
      return false;
    }
    atualizando = true;
    erroAcao = null;
    notifyListeners();
    try {
      kit = await repository.remover(usuarioId, materialId);
      estado = EstadoTela.sucesso;
      return true;
    } on DioException catch (erro) {
      if (erro.response != null) {
        erroAcao = 'Não foi possível concluir a solicitação. Tente novamente.';
        final dados = erro.response?.data;
        if (dados is Map) {
          final mensagem = dados['message'];
          if (mensagem is String) {
            erroAcao = mensagem;
          }
        }
      } else if (erro.type == DioExceptionType.connectionTimeout ||
          erro.type == DioExceptionType.receiveTimeout ||
          erro.type == DioExceptionType.sendTimeout) {
        erroAcao = 'A API demorou para responder. Tente novamente.';
      } else {
        erroAcao = 'Não foi possível conectar à API. Tente novamente.';
      }
    } catch (_) {
      erroAcao = 'Não foi possível atualizar o kit. Tente novamente.';
    } finally {
      atualizando = false;
      if (!_descartado) notifyListeners();
    }
    return false;
  }

  Future<bool> limpar() async {
    if (_descartado || atualizando || estado == EstadoTela.carregando) {
      return false;
    }
    atualizando = true;
    erroAcao = null;
    notifyListeners();
    try {
      kit = await repository.limpar(usuarioId);
      estado = EstadoTela.sucesso;
      return true;
    } on DioException catch (erro) {
      if (erro.response != null) {
        erroAcao = 'Não foi possível concluir a solicitação. Tente novamente.';
        final dados = erro.response?.data;
        if (dados is Map) {
          final mensagem = dados['message'];
          if (mensagem is String) {
            erroAcao = mensagem;
          }
        }
      } else if (erro.type == DioExceptionType.connectionTimeout ||
          erro.type == DioExceptionType.receiveTimeout ||
          erro.type == DioExceptionType.sendTimeout) {
        erroAcao = 'A API demorou para responder. Tente novamente.';
      } else {
        erroAcao = 'Não foi possível conectar à API. Tente novamente.';
      }
    } catch (_) {
      erroAcao = 'Não foi possível atualizar o kit. Tente novamente.';
    } finally {
      atualizando = false;
      if (!_descartado) notifyListeners();
    }
    return false;
  }
}
