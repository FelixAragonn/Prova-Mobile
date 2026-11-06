import 'package:flutter/material.dart';

import 'core/network/cliente_api.dart';
import 'core/theme/tema_app.dart';
import 'repository/kit_repository.dart';
import 'repository/login_repository.dart';
import 'repository/materiais_repository.dart';
import 'view/login_view.dart';

class MyApp extends StatefulWidget {
  final ClienteApi? clienteApi;

  const MyApp({super.key, this.clienteApi});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ClienteApi _clienteApi;
  late final LoginRepository _loginRepository;
  late final MateriaisRepository _produtoRepository;
  late final KitRepository _carrinhoRepository;

  @override
  void initState() {
    super.initState();
    _clienteApi = widget.clienteApi ?? ClienteApi();
    _loginRepository = LoginRepository(_clienteApi);
    _produtoRepository = MateriaisRepository(_clienteApi);
    _carrinhoRepository = KitRepository(_clienteApi);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cardápio',
      theme: temaApp,
      home: LoginView(
        loginRepository: _loginRepository,
        materiaisRepository: _produtoRepository,
        kitRepository: _carrinhoRepository,
      ),
    );
  }
}
