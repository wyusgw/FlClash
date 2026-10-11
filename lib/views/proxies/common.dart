import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/widgets.dart';

const proxyGridSpacing = 8.0;

double getItemHeight(ProxyCardType proxyCardType) {
  final measure = globalState.measure;
  final baseHeight =
      16 + measure.bodyMediumHeight * 2 + measure.bodySmallHeight + 8 + 4;
  return switch (proxyCardType) {
    ProxyCardType.expand => baseHeight + measure.labelSmallHeight + 6,
    ProxyCardType.shrink => baseHeight,
    ProxyCardType.min => baseHeight - measure.bodyMediumHeight,
  };
}

double getRowExtent(ProxyCardType proxyCardType) =>
    getItemHeight(proxyCardType) + proxyGridSpacing;

double? selectedRowOffset({
  required List<Proxy> proxies,
  required String? selectedProxyName,
  required int columns,
  required double rowExtent,
}) {
  final index = proxies.indexWhere((proxy) => proxy.name == selectedProxyName);
  if (index < 0) {
    return null;
  }
  return (index ~/ columns) * rowExtent;
}

void animateScrollTo(ScrollController controller, double offset) {
  if (!controller.hasClients) {
    return;
  }
  final position = controller.position;
  controller.animateTo(
    offset.clamp(position.minScrollExtent, position.maxScrollExtent),
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
  );
}
