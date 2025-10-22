import 'package:flutter_test/flutter_test.dart';

// Classe de formatadores
class Formatadores {
  static String formatarRA(String ra) {
    final numeros = ra.replaceAll(RegExp(r'[^\d]'), '');
    if (numeros.length != 7) return ra;
    return '${numeros.substring(0, 4)}.${numeros.substring(4)}';
  }

  static String formatarTelefone(String telefone) {
    final numeros = telefone.replaceAll(RegExp(r'[^\d]'), '');
    if (numeros.length == 11) {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 7)}-${numeros.substring(7)}';
    }
    if (numeros.length == 10) {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 6)}-${numeros.substring(6)}';
    }
    return telefone;
  }

  static String formatarNota(double nota) {
    return nota.toStringAsFixed(2);
  }

  static String formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  static String formatarPorcentagem(double valor) {
    return '${valor.toStringAsFixed(1)}%';
  }

  static String formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

void main() {
  group('Formatadores - RA', () {
    test('Deve formatar RA numérico', () {
      expect(Formatadores.formatarRA('2025001'), '2025.001');
    });

    test('Deve manter RA já formatado', () {
      expect(Formatadores.formatarRA('2025.001'), '2025.001');
    });

    test('Deve retornar original se não tiver 7 dígitos', () {
      expect(Formatadores.formatarRA('123'), '123');
    });

    test('Deve remover caracteres especiais e formatar', () {
      expect(Formatadores.formatarRA('2025@001'), '2025.001');
    });
  });

  group('Formatadores - Telefone', () {
    test('Deve formatar celular (11 dígitos)', () {
      expect(Formatadores.formatarTelefone('11987654321'), '(11) 98765-4321');
    });

    test('Deve formatar telefone fixo (10 dígitos)', () {
      expect(Formatadores.formatarTelefone('1134567890'), '(11) 3456-7890');
    });

    test('Deve retornar original se não tiver 10 ou 11 dígitos', () {
      expect(Formatadores.formatarTelefone('123456'), '123456');
    });

    test('Deve remover caracteres especiais e formatar', () {
      expect(
          Formatadores.formatarTelefone('(11) 98765-4321'), '(11) 98765-4321');
    });
  });

  group('Formatadores - Nota', () {
    test('Deve formatar nota com 2 casas decimais', () {
      expect(Formatadores.formatarNota(8.5), '8.50');
      expect(Formatadores.formatarNota(10.0), '10.00');
      expect(Formatadores.formatarNota(7.123), '7.12');
    });

    test('Deve arredondar nota corretamente', () {
      expect(Formatadores.formatarNota(8.556), '8.56');
      expect(Formatadores.formatarNota(9.995), '10.00');
    });

    test('Deve formatar nota zero', () {
      expect(Formatadores.formatarNota(0.0), '0.00');
    });

    test('Deve formatar nota máxima', () {
      expect(Formatadores.formatarNota(10.0), '10.00');
    });
  });

  group('Formatadores - Data', () {
    test('Deve formatar data no formato DD/MM/YYYY', () {
      final data = DateTime(2025, 3, 5);
      expect(Formatadores.formatarData(data), '05/03/2025');
    });

    test('Deve adicionar zero à esquerda em dias/meses < 10', () {
      final data = DateTime(2025, 1, 9);
      expect(Formatadores.formatarData(data), '09/01/2025');
    });

    test('Deve formatar corretamente datas com 2 dígitos', () {
      final data = DateTime(2025, 12, 25);
      expect(Formatadores.formatarData(data), '25/12/2025');
    });

    test('Deve formatar primeiro dia do ano', () {
      final data = DateTime(2025, 1, 1);
      expect(Formatadores.formatarData(data), '01/01/2025');
    });

    test('Deve formatar último dia do ano', () {
      final data = DateTime(2025, 12, 31);
      expect(Formatadores.formatarData(data), '31/12/2025');
    });
  });

  group('Formatadores - Porcentagem', () {
    test('Deve formatar porcentagem com 1 casa decimal', () {
      expect(Formatadores.formatarPorcentagem(85.5), '85.5%');
      expect(Formatadores.formatarPorcentagem(100.0), '100.0%');
    });

    test('Deve arredondar porcentagem corretamente', () {
      expect(Formatadores.formatarPorcentagem(85.56), '85.6%');
      expect(Formatadores.formatarPorcentagem(85.54), '85.5%');
    });
  });

  group('Formatadores - Moeda', () {
    test('Deve formatar valor monetário brasileiro', () {
      expect(Formatadores.formatarMoeda(100.50), 'R\$ 100,50');
      expect(Formatadores.formatarMoeda(1000.00), 'R\$ 1000,00');
    });

    test('Deve formatar valor zero', () {
      expect(Formatadores.formatarMoeda(0.0), 'R\$ 0,00');
    });

    test('Deve formatar centavos', () {
      expect(Formatadores.formatarMoeda(0.99), 'R\$ 0,99');
    });
  });
}
