import 'package:flutter/material.dart';

import '../core/state/estado_tela.dart';
import '../core/theme/tema_app.dart';
import '../repository/materiais_repository.dart';
import '../viewmodel/cadastro_materiais_viewmodel.dart';
import 'widgets/elementos_compartilhados.dart';

class CadastroMaterialView extends StatefulWidget {
  final MateriaisRepository repository;

  const CadastroMaterialView({super.key, required this.repository});

  @override
  State<CadastroMaterialView> createState() => _CadastroMaterialViewState();
}

class _CadastroMaterialViewState extends State<CadastroMaterialView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _camposAlterados = <String>{};
  late final CadastroMaterialViewModel _viewModel;
  //String _categoria = 'Novidades';

  bool get _enviando => _viewModel.estado == EstadoTela.carregando;

  @override
  void initState() {
    super.initState();
    _viewModel = CadastroMaterialViewModel(repository: widget.repository);
  }

  double? _lerPreco(String? valor) =>
      double.tryParse((valor ?? '').trim().replaceAll(',', '.'));

  String? _erroCampo(String campo) =>
      _camposAlterados.contains(campo) ? null : _viewModel.erros[campo];

  Future<void> _salvar() async {
    if (_enviando || !_formKey.currentState!.validate()) return;
    final tarefa = _viewModel.cadastrar(
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        preco: _lerPreco(_precoController.text)!,
        categoria: _categoriaController.text.trim());
    setState(_camposAlterados.clear);
    final cadastrado = await tarefa;
    if (!mounted) return;
    if (cadastrado) Navigator.of(context).pop<bool>(true);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => Scaffold(
          appBar: AppBar(title: const Text('Novo material')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xffeee7f5))),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                                color: const Color(0xffefe5fc),
                                borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.label_important,
                                color: roxoVioleta, size: 29)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Um novo material.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              const SizedBox(height: 4),
                              const Text('Adicione uma opção ao catalogo.',
                                  style: TextStyle(color: Color(0xff786b86))),
                            ])),
                      ]),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nomeController,
                        enabled: !_enviando,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                            labelText: 'Nome',
                            hintText: 'Ex.: lapis',
                            errorText: _erroCampo('nome')),
                        onChanged: (_) =>
                            setState(() => _camposAlterados.add('nome')),
                        validator: (valor) =>
                            valor == null || valor.trim().isEmpty
                                ? 'Informe o nome do material.'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descricaoController,
                        enabled: !_enviando,
                        maxLines: 3,
                        decoration: InputDecoration(
                            labelText: 'Descrição',
                            hintText: 'pra q serve',
                            alignLabelWithHint: true,
                            errorText: _erroCampo('descricao')),
                        onChanged: (_) =>
                            setState(() => _camposAlterados.add('descricao')),
                        validator: (valor) =>
                            valor == null || valor.trim().isEmpty
                                ? 'Informe a descrição do material.'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _precoController,
                        enabled: !_enviando,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                            labelText: 'Preço (R\$)',
                            hintText: '100,50',
                            prefixIcon: const Icon(Icons.payments_outlined),
                            errorText: _erroCampo('preco')),
                        onChanged: (_) =>
                            setState(() => _camposAlterados.add('preco')),
                        onFieldSubmitted: (_) => _salvar(),
                        validator: (valor) {
                          final preco = _lerPreco(valor);
                          if (preco == null || !preco.isFinite || preco <= 0)
                            return 'Informe um preço maior que zero.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _categoriaController,
                        enabled: !_enviando,
                        maxLines: 1,
                        decoration: InputDecoration(
                            labelText: 'Categoria',
                            hintText: "Ex: Artesanato",
                            errorText: _erroCampo('categoria')),
                        onChanged: (_) =>
                            setState(() => _camposAlterados.add('categoria')),
                        validator: (valor) =>
                            valor == null || valor.trim().isEmpty
                                ? 'Informe a categoria do material.'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _enviando ? null : _salvar,
                        child: _enviando
                            ? const RotuloEnvio(texto: 'Cadastrando...')
                            : const Text('Cadastrar material'),
                      ),
                    ]),
              ),
            ),
          ),
        ),
      );
}
