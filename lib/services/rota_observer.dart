import 'package:flutter/material.dart';
import 'auth_guard.dart';

class RotaObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    print('🔄 Rota: ${route.settings.name}');
    _validarRota(route.settings.name);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    print('🔄 Rota substituída: ${newRoute?.settings.name}');
    _validarRota(newRoute?.settings.name);
  }

  void _validarRota(String? rota) async {
    if (rota == null || rota == '/login') return;

    final temPermissao = await AuthGuard.temPermissao(rota);
    print('✅ Permissão para $rota: $temPermissao');

    if (!temPermissao) {
      print('❌ Acesso negado para: $rota');
    }
  }
}
