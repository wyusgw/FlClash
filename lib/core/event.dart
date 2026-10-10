import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';

List<CoreEvent> coreEventsFromData(Object? data) {
  final items = data is List ? data : [data];
  final events = <CoreEvent>[];
  for (final item in items.whereType<Map>()) {
    try {
      events.add(CoreEvent.fromJson(Map<String, Object?>.from(item)));
    } catch (error) {
      commonPrint.log(
        'Unable to parse Core event: $error',
        logLevel: LogLevel.error,
      );
    }
  }
  return events;
}

abstract mixin class CoreEventListener {
  void onLog(Log log) {}

  void onDelay(Delay delay) {}

  void onCrash(String message) {}

  void onRouteChanged(RouteSnapshot snapshot) {}
}

class CoreEventManager {
  final _controller = StreamController<CoreEvent>();

  CoreEventManager._() {
    _controller.stream.listen((event) {
      for (final CoreEventListener listener in List.of(_listeners)) {
        try {
          switch (event.type) {
            case CoreEventType.log:
              listener.onLog(Log.fromJson(event.data));
              break;
            case CoreEventType.delay:
              listener.onDelay(Delay.fromJson(event.data));
              break;
            case CoreEventType.crash:
              listener.onCrash(event.data);
              break;
            case CoreEventType.routeChanged:
              listener.onRouteChanged(
                RouteSnapshot.fromJson(Map<String, Object?>.from(event.data)),
              );
              break;
          }
        } catch (error) {
          commonPrint.log(
            'Unable to dispatch Core event ${event.type.name}: $error',
            logLevel: LogLevel.error,
          );
        }
      }
    });
  }

  static final CoreEventManager instance = CoreEventManager._();

  final ObserverList<CoreEventListener> _listeners =
      ObserverList<CoreEventListener>();

  bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  void sendEvent(CoreEvent event) {
    _controller.add(event);
  }

  void addListener(CoreEventListener listener) {
    _listeners.add(listener);
  }

  void removeListener(CoreEventListener listener) {
    _listeners.remove(listener);
  }
}

final coreEventManager = CoreEventManager.instance;
