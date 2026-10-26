import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';

import 'desktop/model.dart';
import 'method.dart';

mixin CoreInterface {
  Future<CoreLifecycleResult> start();

  Future<CoreLifecycleResult> restart();

  Future<CoreLifecycleResult> stop();

  Future<CoreLifecycleResult> close();

  Future<bool> init(InitParams params);

  Future<bool> get isInit;

  Future<bool> forceGc();

  Future<String> validateConfig(String path);

  Future<List<String>> validateProxies(List<Map<String, dynamic>> proxies);

  Future<Delay?> asyncTestDelay(
    String url,
    String proxyName, {
    Duration? timeout,
  });

  Future<ProbeResult?> probe(ProbeParams params);

  /// The milliseconds a ping to [host] takes, or -1 when it goes unanswered.
  Future<int> icmpPing(String host, {Duration? timeout});

  Future<OutboundIpResult?> outboundIp(OutboundIpParams params);

  Future<List<ServiceCheckItem>> serviceCheck(ServiceCheckParams params);

  Future<String> setupConfig(SetupParams setupParams);

  Future<RouteSnapshot?> watchRoute(bool watch);

  Future<bool> startListener();

  Future<bool> stopListener();

  FutureOr<Traffic> getTraffic(bool onlyStatisticsProxy);

  FutureOr<Traffic> getTotalTraffic(bool onlyStatisticsProxy);

  FutureOr<CoreMemoryStats?> getMemoryStats();

  FutureOr<void> resetTraffic();

  FutureOr<void> startLog();

  FutureOr<void> stopLog();

  Future<bool> crash();
}

abstract class CoreHandlerInterface with CoreInterface {
  Future<T?> _invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    return await handleWatch(
      onStart: () {
        commonPrint.log(
          'Invoke method ${method.name} ${DateTime.now()} $arguments',
        );
      },
      function: () async {
        return invokeMethod<T>(
          method: method,
          arguments: arguments,
          timeout: timeout,
        );
      },
      onEnd: (result, elapsedMilliseconds) {
        commonPrint.log(
          'Invoke method ${method.name} completed in ${elapsedMilliseconds}ms',
        );
      },
    );
  }

  Future<T?> invokeMethod<T>({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  });

  Future<String> _invokeMessage({
    required CoreMethod method,
    Object? arguments,
    Duration? timeout,
  }) async {
    final message = await _invokeMethod<String>(
      method: method,
      arguments: arguments,
      timeout: timeout,
    );
    if (message == null) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${method.name}',
      );
    }
    return message;
  }

  @override
  Future<bool> init(InitParams params) async {
    return await _invokeMethod<bool>(
          method: CoreMethod.initCore,
          arguments: params.toJson(),
        ) ??
        false;
  }

  @override
  Future<bool> get isInit async {
    return await _invokeMethod<bool>(method: CoreMethod.getIsInit) ?? false;
  }

  @override
  Future<bool> forceGc() async {
    return await _invokeMethod<bool>(method: CoreMethod.forceGc) ?? false;
  }

  @override
  Future<String> validateConfig(String path) async {
    return _invokeMessage(method: CoreMethod.validateConfig, arguments: path);
  }

  @override
  Future<List<String>> validateProxies(
    List<Map<String, dynamic>> proxies,
  ) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.validateProxies,
      arguments: proxies,
    );
    if (data == null || data.length != proxies.length) {
      throw CoreMethodException(
        code: 'no_response',
        message: 'Core did not answer ${CoreMethod.validateProxies.name}',
      );
    }
    return data.map((item) => item?.toString() ?? '').toList();
  }

  @override
  Future<String> setupConfig(SetupParams setupParams) async {
    return _invokeMessage(
      method: CoreMethod.setupConfig,
      arguments: setupParams.toJson(),
    );
  }

  @override
  Future<bool> crash() async {
    return await _invokeMethod<bool>(method: CoreMethod.crash) ?? false;
  }

  @override
  Future<RouteSnapshot?> watchRoute(bool watch) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.watchRoute,
      arguments: watch,
    );
    return data == null ? null : RouteSnapshot.fromJson(data);
  }

  @override
  Future<Traffic> getTotalTraffic(bool onlyStatisticsProxy) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getTotalTraffic,
      arguments: onlyStatisticsProxy,
    );
    return data == null ? const Traffic() : Traffic.fromJson(data);
  }

  @override
  Future<Traffic> getTraffic(bool onlyStatisticsProxy) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getTraffic,
      arguments: onlyStatisticsProxy,
    );
    return data == null ? const Traffic() : Traffic.fromJson(data);
  }

  @override
  FutureOr<void> resetTraffic() {
    _invokeMethod(method: CoreMethod.resetTraffic);
  }

  @override
  FutureOr<void> startLog() {
    _invokeMethod(method: CoreMethod.startLog);
  }

  @override
  FutureOr<void> stopLog() {
    _invokeMethod<bool>(method: CoreMethod.stopLog);
  }

  @override
  Future<bool> startListener() async {
    return await _invokeMethod<bool>(method: CoreMethod.startListener) ?? false;
  }

  @override
  Future<bool> stopListener() async {
    return await _invokeMethod<bool>(method: CoreMethod.stopListener) ?? false;
  }

  @override
  Future<Delay?> asyncTestDelay(
    String url,
    String proxyName, {
    Duration? timeout,
  }) async {
    final budget = timeout ?? delayTestTimeoutDuration;
    final delayParams = {
      'proxy-name': proxyName,
      'timeout': budget.inMilliseconds,
      'test-url': url,
    };
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.asyncTestDelay,
      arguments: delayParams,
      timeout: coreGuardFor(budget.inMilliseconds),
    );
    return data == null ? null : Delay.fromJson(data);
  }

  @override
  Future<ProbeResult?> probe(ProbeParams params) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.probe,
      arguments: params.toJson(),
      timeout: probeGuardDuration(params),
    );
    return data == null ? null : ProbeResult.fromJson(data);
  }

  @override
  Future<int> icmpPing(String host, {Duration? timeout}) async {
    final budget = timeout ?? delayTestTimeoutDuration;
    return await _invokeMethod<int>(
          method: CoreMethod.icmpPing,
          arguments: {'host': host, 'timeout': budget.inMilliseconds},
          timeout: coreGuardFor(budget.inMilliseconds),
        ) ??
        -1;
  }

  @override
  Future<OutboundIpResult?> outboundIp(OutboundIpParams params) async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.outboundIp,
      arguments: params.toJson(),
      timeout: coreGuardFor(params.timeout),
    );
    return data == null ? null : OutboundIpResult.fromJson(data);
  }

  @override
  Future<List<ServiceCheckItem>> serviceCheck(ServiceCheckParams params) async {
    final data = await _invokeMethod<List<dynamic>>(
      method: CoreMethod.serviceCheck,
      arguments: params.toJson(),
      timeout: coreGuardFor(
        params.timeout,
        budgetFactor: serviceSweepBudgetFactor,
      ),
    );
    return data == null
        ? const []
        : data
              .map(
                (item) =>
                    ServiceCheckItem.fromJson(item as Map<String, dynamic>),
              )
              .toList();
  }

  @override
  Future<CoreMemoryStats?> getMemoryStats() async {
    final data = await _invokeMethod<Map<String, dynamic>>(
      method: CoreMethod.getMemoryStats,
    );
    return data == null ? null : CoreMemoryStats.fromJson(data);
  }
}
