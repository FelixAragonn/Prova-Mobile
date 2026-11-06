import 'package:flutter/material.dart';
import 'package:kits/model/item_kit.dart';
import 'package:kits/model/materiais.dart';
import 'package:kits/repository/kit_repository.dart';

import '../core/state/estado_tela.dart';
import '../core/theme/tema_app.dart';
import '../repository/materiais_repository.dart';
import '../viewmodel/materiais_viewmodel.dart';
import 'widgets/elementos_compartilhados.dart';

class MaterialView extends StatefulWidget {
  final MateriaisRepository repository;
  final KitRepository kitRepository;
  final int usuarioId;
  final Materiais material;

  const MaterialView(
      {super.key,
      required this.repository,
      required this.kitRepository,
      required this.usuarioId,
      required this.material});

  @override
  State<MaterialView> createState() => _MaterialViewState();
}

class _MaterialViewState extends State<MaterialView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _camposAlterados = <String>{};

  late final MaterialViewModel _viewModel;
  late final Materiais material;
  int qtd = 1;
  late ItemKit item = new ItemKit(
      material: material, quantidade: qtd, subtotal: (qtd * material.preco));
  //String _categoria = 'Novidades';

  bool get _enviando => _viewModel.estado == EstadoTela.carregando;

  @override
  void initState() {
    super.initState();
    _viewModel = MaterialViewModel(
        repository: widget.repository,
        kitRepository: widget.kitRepository,
        usuarioId: widget.usuarioId);
    material = widget.material;
  }

/*
  double? _lerPreco(String? valor) =>
      double.tryParse((valor ?? '').trim().replaceAll(',', '.'));
*/
  Future<void> _salvar() async {
    //if (_enviando || !_formKey.currentState!.validate()) return;
    final tarefa = _viewModel.adicionar(material, qtd);
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

  Widget _Materials() {
    final materiais = material;
    //final bool desabilitado = _viewModel.materialEmEnvio != null;
    final bool carregando = _viewModel.materialEmEnvio == materiais.id;
    final VoidCallback adicionar = () => _salvar;
    String? dropval = "1";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xffeee7f5)),
        boxShadow: [
          BoxShadow(
              color: roxoProfundo.withValues(alpha: 0.04),
              blurRadius: 30,
              offset: const Offset(0, 12))
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
                      color: Color.fromARGB(255, 0, 0, 0)))),
          DropdownButton<String>(
            value: dropval,
            items: varios()
                .map((String categoria) => DropdownMenuItem(
                    value: categoria, child: Text(categoria.toString())))
                .toList(),
            onChanged: (value) => setState(() {
              qtd = value == null ? 1 : int.parse(value); //altera qtd certinho
              dropval =
                  value!; //deveria alterar o valor no Dropdown, mas não o faz
            }),
          ),
          FilledButton(
            onPressed: _enviando
                ? null
                : adicionar, //não faz nada quando aperta, n sei pq, era pra adicionar ao kit
            child: _enviando
                ? const RotuloEnvio(texto: 'Adicionando...')
                : const Text('Adicionar'),
          ),
        ]),
      ]),
    );
  }

  List<String> varios() {
    List<String> a = new List.empty(growable: true);
    for (int i = 1; i < 100; i++) {
      a.add(i.toString());
    }
    return a;
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
              child: _ItemKit(
                item: item,
                desabilitado: false,
                aumentar: () => setState(() {}),
                diminuir: () => setState(() {}),
                salvar: _salvar,
              ),
              /*Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [_Materials()]),
              ),*/
            ),
          ),
        ),
      );
}

class _ItemKit extends StatelessWidget {
  final ItemKit item;
  final bool desabilitado;
  final VoidCallback aumentar;
  final VoidCallback diminuir;
  final VoidCallback salvar;

  const _ItemKit(
      {required this.item,
      required this.desabilitado,
      required this.aumentar,
      required this.diminuir,
      required this.salvar});

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
          const SizedBox(width: 15),
          IconButton(
              tooltip:
                  'Salvar quantidade de ${item.material.nome} ${item.quantidade}',
              onPressed: desabilitado || item.quantidade <= 1 ? null : salvar,
              icon: const Icon(Icons.check, size: 19),
              visualDensity: VisualDensity.compact),
        ]),
      );
}
