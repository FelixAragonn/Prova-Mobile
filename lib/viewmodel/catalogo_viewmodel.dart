import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/state/estado_tela.dart';
import '../model/kit.dart';
import '../model/materiais.dart';
import '../repository/kit_repository.dart';
import '../repository/materiais_repository.dart';

class CatalogoViewModel extends ChangeNotifier {
  final MateriaisRepository materiaisRepository;
  final KitRepository kitRepository;
  final int usuarioId;

  CatalogoViewModel({
    required this.materiaisRepository,
    required this.kitRepository,
    required this.usuarioId,
  }) : kit = Kit.vazio(usuarioId: usuarioId);

  EstadoTela estado = EstadoTela.inicial;
  String? mensagemErro;
  List<Materiais> materiais = [];
  Kit kit;
  int? materialEmEnvio;
  String? erroAcao;
  bool _descartado = false;

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }

  List<String> get categorias =>
      materiais.map((materiais) => materiais.categoria).toSet().toList();

  List<Materiais> filtrarPorCategoria(String? categoria) {
    if (categoria == null || categoria == 'Todos') return materiais;
    return materiais.where((materiais) => materiais.categoria == categoria).toList();
  }
  List<Materiais> filtrarPorNome(String? nome) {
    if (nome == null) return materiais;
    return materiais.where((materiais) => materiais.nome == nome).toList();
  }

  Future<void> carregar() async {

    if (_descartado ||
        estado == EstadoTela.carregando ||
        materialEmEnvio != null) {
      return;
    }
    estado = EstadoTela.carregando;
    mensagemErro = null;
    notifyListeners();
    try {
      final lista = await materiaisRepository.listar();
      final kitAtual = await kitRepository.buscar(usuarioId);
      materiais = lista;
      kit = kitAtual;
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
      mensagemErro = 'Não foi possível carregar o catalogo. Tente novamente.';
      estado = EstadoTela.erro;
    } finally {
      if (!_descartado) notifyListeners();
    }
  }

  Future<bool> adicionar(Materiais material) async {
    if (_descartado || materialEmEnvio != null || estado != EstadoTela.sucesso) {
      return false;
    }
    materialEmEnvio = material.id;
    erroAcao = null;
    notifyListeners();
    try {
      kit = await kitRepository.adicionar(usuarioId, material.id);
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
      erroAcao = 'Não foi possível adicionar o material. Tente novamente.';
    } finally {
      materialEmEnvio = null;
      if (!_descartado) notifyListeners();
    }
    return false;
  }
}
