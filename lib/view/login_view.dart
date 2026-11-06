import 'package:flutter/material.dart';

import '../core/state/estado_tela.dart';
import '../core/theme/tema_app.dart';
import '../repository/kit_repository.dart';
import '../repository/login_repository.dart';
import '../repository/materiais_repository.dart';
import '../viewmodel/login_viewmodel.dart';
import 'catalogo_view.dart';
import 'widgets/elementos_compartilhados.dart';

class LoginView extends StatefulWidget {
  final LoginRepository loginRepository;
  final MateriaisRepository materiaisRepository;
  final KitRepository kitRepository;

  const LoginView(
      {super.key,
      required this.loginRepository,
      required this.materiaisRepository,
      required this.kitRepository});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _camposAlterados = <String>{};
  late final LoginViewModel _viewModel;
  bool _ocultarSenha = true;

  bool get _enviando => _viewModel.estado == EstadoTela.carregando;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel(repository: widget.loginRepository);
    _emailController.text = 'ana@ifs.edu.br';
    _senhaController.text = '123456';
  }

  Future<void> _entrar() async {
    if (_enviando || !_formKey.currentState!.validate()) return;
    final login =
        _viewModel.entrar(_emailController.text.trim(), _senhaController.text);
    setState(_camposAlterados.clear);
    final entrou = await login;
    if (!mounted) return;
    if (!entrou) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => CatalogoView(
        usuario: _viewModel.usuario!,
        loginRepository: widget.loginRepository,
        materiaisRepository: widget.materiaisRepository,
        kitRepository: widget.kitRepository,
      ),
    ));
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _formulario(),
          ),
        ),
      ),
    );
  }

  Widget _formulario() {
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
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Bem-vindo.',
              style: Theme.of(context).textTheme.headlineMedium,
              selectionColor:Color(0xff022788)
          ),
          const SizedBox(height: 8),
          const Text('Entre para montar seu kit.',
              style: TextStyle(color: Color(0xff7962c4), fontSize: 16)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            enabled: !_enviando,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
                labelText: 'E-mail',
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                errorText: _camposAlterados.contains('email')
                    ? null
                    : _viewModel.erros['email']),
            onChanged: (_) => setState(() => _camposAlterados.add('email')),
            validator: (valor) {
              if (valor == null || valor.trim().isEmpty)
                return 'Informe seu e-mail.';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _senhaController,
            enabled: !_enviando,
            obscureText: _ocultarSenha,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              errorText: _camposAlterados.contains('senha')
                  ? null
                  : _viewModel.erros['senha'],
            ),
            onChanged: (_) => setState(() => _camposAlterados.add('senha')),
            onFieldSubmitted: (_) => _entrar(),
            validator: (valor) =>
                valor == null || valor.isEmpty ? 'Informe sua senha.' : null,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _enviando ? null : _entrar,
            child: _enviando
                ? const RotuloEnvio(texto: 'Entrando...')
                : const Text('Entrar'),
          ),
        ]),
      ),
    );
  }
}
