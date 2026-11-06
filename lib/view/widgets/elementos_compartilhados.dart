import 'package:flutter/material.dart';

import '../../core/theme/tema_app.dart';
import '../../model/materiais.dart';

String formatarPreco(double valor) =>
    'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

class Logo extends StatelessWidget {
  final bool clara;
  final double tamanho;

  const Logo({super.key, this.clara = false, this.tamanho = 24});

  @override
  Widget build(BuildContext context) {
    final cor = clara ? Colors.white : roxoProfundo;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: clara ? Colors.white.withValues(alpha: 0.14) : roxoVioleta,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.label_important,
              color: Colors.white, size: 23),
        ),
        const SizedBox(width: 10),
        Text('Kits',
            style: TextStyle(
                color: cor,
                fontSize: tamanho,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8)),
      ],
    );
  }
}

class EstadoCarregando extends StatelessWidget {
  final String mensagem;

  const EstadoCarregando({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(mensagem, style: Theme.of(context).textTheme.bodyLarge),
          ]),
        ),
      );
}

class EstadoErro extends StatelessWidget {
  final String mensagem;
  final VoidCallback tentarNovamente;

  const EstadoErro(
      {super.key, required this.mensagem, required this.tentarNovamente});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_rounded, size: 58, color: roxoVioleta),
            const SizedBox(height: 18),
            Text('Não foi possível carregar',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(mensagem, textAlign: TextAlign.center),
            const SizedBox(height: 22),
            FilledButton.icon(
                onPressed: tentarNovamente,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente')),
          ]),
        ),
      );
}

class RotuloEnvio extends StatelessWidget {
  final String texto;

  const RotuloEnvio({super.key, required this.texto});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: 19,
              height: 19,
              child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Theme.of(context).colorScheme.onPrimary)),
          const SizedBox(width: 10),
          Text(texto),
        ],
      );
}

class IlustracaoMaterial extends StatelessWidget {
  final Materiais material;
  final bool compacta;

  const IlustracaoMaterial(
      {super.key, required this.material, this.compacta = false});

  @override
  Widget build(BuildContext context) {
    final categoria = material.categoria.toLowerCase();
    final (icone, fundo, cor) = switch (categoria) {
      'escrita' => (
          Icons.note_alt_rounded,
          const Color(0xffffeed4),
          const Color(0xffc97725)
        ),
      'borracha' => (
          Icons.local_fire_department_sharp,
          const Color(0xffe0f1e8),
          const Color(0xff498968)
        ),
      'medição' => (
          Icons.horizontal_rule_rounded,
          const Color(0xfffbe5ed),
          const Color(0xffb55f85)
        ),
      'matematica' => (
          Icons.numbers,
          const Color(0xffe2eafd),
          const Color(0xff647eab)
        ),
      _ => (Icons.newspaper_sharp, const Color(0xffeadff9), roxoVioleta),
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(compacta ? 16 : 18),
      child: Container(
        height: compacta ? 74 : 150,
        width: compacta ? 74 : double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [fundo, Color.lerp(fundo, Colors.white, 0.45)!])),
        child: Stack(alignment: Alignment.center, children: [
          Positioned(
              right: compacta ? -16 : -22,
              top: compacta ? -18 : -30,
              child: Container(
                  width: compacta ? 60 : 124,
                  height: compacta ? 60 : 124,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.48)))),
          Positioned(
              left: compacta ? -20 : -25,
              bottom: compacta ? -24 : -36,
              child: Container(
                  width: compacta ? 54 : 104,
                  height: compacta ? 54 : 104,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cor.withValues(alpha: 0.07)))),
          Icon(icone, size: compacta ? 39 : 77, color: cor),
        ]),
      ),
    );
  }
}
