import 'package:flutter/material.dart';

import '../core/state/estado_tela.dart';
import '../core/theme/tema_app.dart';
import '../model/item_kit.dart';
import '../repository/kit_repository.dart';
import '../viewmodel/kit_viewmodel.dart';
import 'widgets/elementos_compartilhados.dart';

class KitView extends StatefulWidget {
  final KitRepository repository;
  final int usuarioId;

  const KitView(
      {super.key, required this.repository, required this.usuarioId});

  @override
  State<KitView> createState() => _KitViewState();
}

class _KitViewState extends State<KitView> {
  late final KitViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = KitViewModel(
        repository: widget.repository, usuarioId: widget.usuarioId);
    _viewModel.carregar();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _voltar() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: const Text('Seu kit'),
            actions: [
              if (_viewModel.estado == EstadoTela.sucesso &&
                  _viewModel.kit.itens.isNotEmpty)
                TextButton.icon(
                    onPressed:
                        _viewModel.atualizando ? null : _viewModel.limpar,
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                    label: const Text('Limpar')),
              const SizedBox(width: 12),
            ],
          ),
          body: switch (_viewModel.estado) {
            EstadoTela.inicial ||
            EstadoTela.carregando =>
              const EstadoCarregando(mensagem: 'Buscando seu kit...'),
            EstadoTela.erro => EstadoErro(
                mensagem:
                    _viewModel.mensagemErro ?? 'Tente novamente em instantes.',
                tentarNovamente: _viewModel.carregar),
            EstadoTela.sucesso => _viewModel.kit.itens.isEmpty
                ? _kitVazio()
                : _kit(),
          },
        ),
      );

  Widget _kitVazio() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 108,
                height: 108,
                decoration: const BoxDecoration(
                    color: Color(0xffece1fb), shape: BoxShape.circle),
                child: const Icon(Icons.shopping_bag_outlined,
                    size: 52, color: roxoVioleta)),
            const SizedBox(height: 26),
            Text('Seu kit está vazio',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            const Text('Que tal escolher algo do catalogo?',
                style: TextStyle(color: Color(0xff786b86)),
                textAlign: TextAlign.center),
            const SizedBox(height: 26),
            FilledButton.icon(
                onPressed: _voltar,
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                label: const Text('Continuar escolhendo')),
          ]),
        ),
      );

  Widget _kit() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Suas escolhas',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const SizedBox(height: 16),
            for (final item in _viewModel.kit.itens) ...[
              _ItemKit(
                item: item,
                desabilitado: _viewModel.atualizando,
                aumentar: () => _viewModel.alterarQuantidade(
                    item.material.id, item.quantidade + 1),
                diminuir: () => _viewModel.alterarQuantidade(
                    item.material.id, item.quantidade - 1),
                remover: () => _viewModel.remover(item.material.id),
              ),
              const SizedBox(height: 16),
            ],
            _resumo(),
          ],
        ),
      );

  Widget _resumo() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: const Color(0xffeee4fc),
            borderRadius: BorderRadius.circular(24)),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Resumo',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: roxoProfundo)),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Quantidade'),
            Text('${_viewModel.kit.quantidadeTotal} itens'),
          ]),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text(formatarPreco(_viewModel.kit.total),
                key: const ValueKey('total-kit'),
                style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: roxoVioleta)),
          ]),
          const SizedBox(height: 24),
          FilledButton(
              onPressed: _voltar, child: const Text('Continuar escolhendo')),
          if (_viewModel.atualizando) ...[
            const SizedBox(height: 20),
            const LinearProgressIndicator(minHeight: 3),
            const SizedBox(height: 8),
            const Text('Atualizando kit...',
                textAlign: TextAlign.center,
                style: TextStyle(color: roxoVioleta)),
          ],
        ]),
      );
}

class _ItemKit extends StatelessWidget {
  final ItemKit item;
  final bool desabilitado;
  final VoidCallback aumentar;
  final VoidCallback diminuir;
  final VoidCallback remover;

  const _ItemKit(
      {required this.item,
      required this.desabilitado,
      required this.aumentar,
      required this.diminuir,
      required this.remover});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xffeee7f5))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IlustracaoMaterial(material: item.material, compacta: true),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(item.material.nome,
                              style: const TextStyle(
                                  fontSize: 17,
                                  height: 1.2,
                                  fontWeight: FontWeight.w700,
                                  color: roxoProfundo)))),
                  SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                          padding: EdgeInsets.zero,
                          tooltip: 'Remover ${item.material.nome}',
                          onPressed: desabilitado ? null : remover,
                          icon: const Icon(Icons.close_rounded,
                              size: 20, color: Color(0xff9a8aa8)))),
                ]),
                const SizedBox(height: 2),
                Text('${formatarPreco(item.material.preco)} cada',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xff8a7f95))),
                const SizedBox(height: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    decoration: BoxDecoration(
                        color: const Color(0xfff5effd),
                        borderRadius: BorderRadius.circular(11)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                          tooltip:
                              'Diminuir quantidade de ${item.material.nome}',
                          onPressed: desabilitado || item.quantidade <= 1
                              ? null
                              : diminuir,
                          icon: const Icon(Icons.remove_rounded, size: 19),
                          visualDensity: VisualDensity.compact),
                      SizedBox(
                          width: 20,
                          child: Text('${item.quantidade}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: roxoProfundo))),
                      IconButton(
                          tooltip:
                              'Aumentar quantidade de ${item.material.nome}',
                          onPressed: desabilitado ? null : aumentar,
                          icon: const Icon(Icons.add_rounded, size: 19),
                          visualDensity: VisualDensity.compact),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  Text(formatarPreco(item.subtotal),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: roxoVioleta)),
                ]),
              ])),
        ]),
      );
}
