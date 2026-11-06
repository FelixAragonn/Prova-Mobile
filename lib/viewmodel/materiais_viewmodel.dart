import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kits/model/item_kit.dart';

import '../core/state/estado_tela.dart';
import '../model/materiais.dart';
import 'package:kits/repository/kit_repository.dart';
import '../repository/materiais_repository.dart';
import 'package:kits/model/kit.dart';

class MaterialViewModel extends ChangeNotifier {
  final MateriaisRepository repository;
  final KitRepository kitRepository;
  final int usuarioId;
  bool _descartado = false;

  MaterialViewModel({
    required this.repository,
    required this.kitRepository,
    required this.usuarioId,
  }) : kit = Kit.vazio(usuarioId: usuarioId);

  EstadoTela estado = EstadoTela.inicial;
  String? mensagemErro;
  List<Materiais> materiais = [];
  Kit kit;
  int? materialEmEnvio;
  String? erroAcao;

  Future<bool> adicionar(ItemKit item) async {
    if (_descartado ||
        estado == EstadoTela.carregando ||
        materialEmEnvio != null) return false;
    estado = EstadoTela.carregando;
    materialEmEnvio = item.material.id;
    erroAcao = null;
    notifyListeners();
    try {
      kit = await kitRepository.adicionar(usuarioId, item.material.id,
          quantidade: item.quantidade);
      estado = EstadoTela.sucesso;
      return true;
    } on DioException catch (erro) {
      estado = EstadoTela.erro;
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
      estado = EstadoTela.erro;
      erroAcao = 'Não foi possível adicionar o material. Tente novamente.';
    } finally {
      materialEmEnvio = null;
      if (!_descartado) notifyListeners();
    }
    return false;
  }
  /*
  Future<bool> cadastrar(Materiais material, int qtd) async {
    if (_descartado || estado == EstadoTela.carregando) return false;
    estado = EstadoTela.carregando;
    mensagemErro = null;
    erros = {};
    notifyListeners();
    try {
      material = await repository.getMaterial(material.id);
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
      mensagemErro = 'Não foi possível ver o material. Tente novamente.';
    } finally {
      if (!_descartado) notifyListeners();
    }
    return false;
  }*/

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
