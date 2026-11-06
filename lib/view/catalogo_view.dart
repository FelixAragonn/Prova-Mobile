import 'package:flutter/material.dart';

import '../core/state/estado_tela.dart';
import '../core/theme/tema_app.dart';
import '../model/materiais.dart';
import '../model/usuario.dart';
import '../repository/kit_repository.dart';
import '../repository/login_repository.dart';
import '../repository/materiais_repository.dart';
import '../viewmodel/catalogo_viewmodel.dart';
import 'cadastro_materiais_view.dart';
import 'kit_view.dart';
import 'materiais_view.dart';
import 'login_view.dart';
import 'widgets/elementos_compartilhados.dart';

class CatalogoView extends StatefulWidget {
  final Usuario usuario;
  final LoginRepository loginRepository;
  final MateriaisRepository materiaisRepository;
  final KitRepository kitRepository;

  const CatalogoView(
      {super.key,
      required this.usuario,
      required this.loginRepository,
      required this.materiaisRepository,
      required this.kitRepository});

  @override
  State<CatalogoView> createState() => _CatalogoViewState();
}

class _CatalogoViewState extends State<CatalogoView> {
  late final CatalogoViewModel _viewModel;
  String? _categoria;
  String? _nome;

  @override
  void initState() {
    super.initState();
    _viewModel = CatalogoViewModel(
        materiaisRepository: widget.materiaisRepository,
        kitRepository: widget.kitRepository,
        usuarioId: widget.usuario.id);
    _carregar();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _carregar() => _viewModel.carregar();

  Future<void> _adicionar(Materiais material) async {
    final adicionado = await _viewModel.adicionar(material);
    if (adicionado) {
      //fecha o snackbar anterior
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${material.nome} adicionado ao Kit.'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'Ver kit', onPressed: _abrirKit),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _abrirKit() async {
    await Navigator.of(context).push<void>(MaterialPageRoute<void>(
        builder: (_) => KitView(
            repository: widget.kitRepository, usuarioId: widget.usuario.id)));
    if (!mounted) return;
    await _carregar();
  }

  Future<void> _abrirCadastro() async {
    final cadastrado = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
            builder: (_) =>
                CadastroMaterialView(repository: widget.materiaisRepository)));
    if (mounted && cadastrado == true) {
      _categoria = null;
      _nome = null;
      await _carregar();
    }
  }

  //tentei
  Future<void> _abrirMaterial(Materiais material) async {
    await Navigator.of(context).push<void>(MaterialPageRoute<void>(
        builder: (_) => MaterialView(
              repository: widget.materiaisRepository,
              kitRepository: widget.kitRepository,
              usuarioId: widget.usuario.id,
              material: material,
            )));
    if (!mounted) return;
    await _carregar();
  }

  void _sair() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
            builder: (_) => LoginView(
                loginRepository: widget.loginRepository,
                materiaisRepository: widget.materiaisRepository,
                kitRepository: widget.kitRepository)),
        (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: const Logo(),
          actions: [
            IconButton(
              tooltip: 'Kit',
              onPressed: _viewModel.estado == EstadoTela.sucesso &&
                      _viewModel.materialEmEnvio == null
                  ? _abrirKit
                  : null,
              icon: Badge(
                isLabelVisible: _viewModel.kit.quantidadeTotal > 0,
                label: Text('${_viewModel.kit.quantidadeTotal}'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
            IconButton(
                tooltip: 'Sair',
                onPressed: _viewModel.materialEmEnvio == null ? _sair : null,
                icon: const Icon(Icons.logout_rounded, size: 22)),
          ],
        ),
        body: switch (_viewModel.estado) {
          EstadoTela.inicial ||
          EstadoTela.carregando =>
            const EstadoCarregando(mensagem: 'Preparando seu catalogo...'),
          EstadoTela.erro => EstadoErro(
              mensagem:
                  _viewModel.mensagemErro ?? 'Tente novamente em instantes.',
              tentarNovamente: _carregar),
          EstadoTela.sucesso => _catalogo(),
        },
      ),
    );
  }

  Widget _catalogo() {
    final materiais = _viewModel.filtrarPorCategoria(_categoria);
    final materialNome = _viewModel.filtrarPorNome(_nome);
    return RefreshIndicator(
      onRefresh: _carregar,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(
                child: Text('Catalogo',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
              OutlinedButton.icon(
                onPressed:
                    _viewModel.materialEmEnvio == null ? _abrirCadastro : null,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Novo Material'),
              ),
            ]),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: (_categoria == null && _nome == null),
                  onSelected: (_) => setState(() => _categoria = null),
                ),
                for (final categoria in _viewModel.categorias) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(categoria),
                    selected: _categoria == categoria,
                    onSelected: (_) => setState(() => _categoria = categoria),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 16),
            if (materiais.isEmpty)
              const Text('Nenhum material nesta categoria.')
            else if (materialNome.isEmpty)
              const Text('Nenhum material nesta categoria.')
            else if (_nome == null)
              for (final material in materiais) ...[
                _CartaoKit(
                  materiais: material,
                  carregando: _viewModel.materialEmEnvio == material.id,
                  desabilitado: _viewModel.materialEmEnvio != null,
                  adicionar: () => _abrirMaterial(material),
                  //adicionar: () => _adicionar(material),
                ),
                const SizedBox(height: 16),
              ]
            else
              for (final material in materialNome) ...[
                _CartaoKit(
                  materiais: material,
                  carregando: _viewModel.materialEmEnvio == material.id,
                  desabilitado: _viewModel.materialEmEnvio != null,
                  adicionar: () => _abrirMaterial(material),
                  //adicionar: () => _adicionar(material),
                ),
                const SizedBox(height: 16),
              ],
          ],
        ),
      ),
    );
  }
}

class _CartaoKit extends StatelessWidget {
  final Materiais materiais;
  final bool carregando;
  final bool desabilitado;
  final VoidCallback adicionar;

  const _CartaoKit(
      {required this.materiais,
      required this.carregando,
      required this.desabilitado,
      required this.adicionar});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xffeee7f5)),
          boxShadow: [
            BoxShadow(
                color: roxoProfundo.withValues(alpha: 0.025),
                blurRadius: 16,
                offset: const Offset(0, 5))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IlustracaoMaterial(material: materiais),
          const SizedBox(height: 15),
          Text(materiais.categoria.toUpperCase(),
              style: const TextStyle(
                  color: Color(0xff9688a2),
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(materiais.nome,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: roxoProfundo)),
          const SizedBox(height: 4),
          Text(materiais.descricao,
              style: const TextStyle(color: Color(0xff8a7f95), fontSize: 12)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: Text(formatarPreco(materiais.preco),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: roxoVioleta))),
            Semantics(
              label: 'Adicionar ${materiais.nome}',
              button: true,
              enabled: !desabilitado,
              onTap: desabilitado ? null : adicionar,
              excludeSemantics: true,
              child: IconButton.filled(
                tooltip: 'Adicionar ${materiais.nome}',
                onPressed: desabilitado ? null : adicionar,
                icon: carregando
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.add_rounded),
              ),
            ),
          ]),
        ]),
      );
}
