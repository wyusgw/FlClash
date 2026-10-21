// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ru';

  static String m0(count, skipped) =>
      "Будет добавлено: ${count}, пропущено (уже есть): ${skipped}";

  static String m1(appName) =>
      "Если включено, ${appName} сразу после запуска пытается распознать в буфере обмена URL прокси-сервера и предлагает импортировать его.\n\nЕсли выключено, на главном экране появится отдельная кнопка вставки: нажмите её, чтобы вручную вставить и импортировать содержимое буфера обмена.";

  static String m2(code) =>
      "Windows отказалась запускать FlClashCore.exe (ошибка ${code}). Политики контроля приложений, такие как Smart App Control или AppLocker, блокируют неподписанные программы; разрешите FlClash в этой политике или отключите её и повторите попытку.";

  static String m3(name) =>
      "Приложение два раза подряд не смогло завершить запуск. Чтобы разорвать цикл, профиль ${name} снят с выбора, а автоматическая настройка пропущена. Вы можете выбрать его снова в любой момент.";

  static String m4(url) => "Создать профиль по ссылке ${url}?";

  static String m5(count) =>
      "${Intl.plural(count, one: '${count} день назад', few: '${count} дня назад', many: '${count} дней назад', other: '${count} дня назад')}";

  static String m6(label) => "Вы уверены, что хотите удалить «${label}»?";

  static String m7(label) => "Сведения: ${label}";

  static String m8(label) => "Поле «${label}» не может быть пустым";

  static String m9(label) => "«${label}» уже существует";

  static String m10(action) => "Перенесено из «${action}»";

  static String m11(modifiers) =>
      "Добавьте хотя бы одну из клавиш: ${modifiers}";

  static String m12(count) =>
      "${Intl.plural(count, one: '${count} час назад', few: '${count} часа назад', many: '${count} часов назад', other: '${count} часа назад')}";

  static String m13(count) =>
      "Импортировать эту цветовую схему (цветов: ${count})?";

  static String m14(count) =>
      "Импортировать серверные узлы из буфера обмена: ${count}?";

  static String m15(line, message) => "Строка ${line}: ${message}";

  static String m16(appName) =>
      "1. Откройте Системные настройки > Конфиденциальность и безопасность\n2. Выберите Службы геолокации\n3. Найдите и отметьте ${appName} в списке\n\nПосле настройки вернитесь в приложение и продолжайте работу. Спасибо за сотрудничество.";

  static String m17(label, max) => "«${label}» — не более ${max} символов";

  static String m18(size) => "Освобождено ${size}";

  static String m19(count) =>
      "${Intl.plural(count, one: '${count} минуту назад', few: '${count} минуты назад', many: '${count} минут назад', other: '${count} минуты назад')}";

  static String m20(count) =>
      "${Intl.plural(count, one: '${count} месяц назад', few: '${count} месяца назад', many: '${count} месяцев назад', other: '${count} месяца назад')}";

  static String m21(detail) => "Сетевой запрос не выполнен: ${detail}";

  static String m22(label) => "Пока нет: ${label}";

  static String m23(label) => "Значение «${label}» должно быть числом";

  static String m24(appName) => "Открыть ${appName}";

  static String m25(label) =>
      "Значение «${label}» должно быть от 1024 до 49151";

  static String m26(count) => "Правил: ${count}";

  static String m27(appName) => "${appName} (Безопасный режим)";

  static String m28(count) => "Выбрано: ${count}";

  static String m29(time) => "Проверено в ${time}";

  static String m30(label) => "«${label}» — только одно значение";

  static String m31(label) => "Значение «${label}» должно быть URL";

  static String m32(count) =>
      "${Intl.plural(count, one: '${count} год назад', few: '${count} года назад', many: '${count} лет назад', other: '${count} года назад')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("О программе"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Контроль доступа"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Через VPN проходят только выбранные приложения",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Выбор приложений, использующих прокси",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "Контроль доступа приложений отключён",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Выбранные приложения исключаются из VPN",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Настройки контроля доступа",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Аккаунт"),
    "acknowledgements": MessageLookupByLibrary.simpleMessage("Благодарности"),
    "action": MessageLookupByLibrary.simpleMessage("Действие"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage(
      "Проверить все задержки",
    ),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("Прямой режим"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage(
      "Глобальный режим",
    ),
    "actionMode": MessageLookupByLibrary.simpleMessage("Переключить режим"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("Режим правил"),
    "actionStart": MessageLookupByLibrary.simpleMessage("Старт/Стоп"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage(
      "Обновить профили",
    ),
    "actionView": MessageLookupByLibrary.simpleMessage("Показать/Скрыть"),
    "add": MessageLookupByLibrary.simpleMessage("Добавить"),
    "addNode": MessageLookupByLibrary.simpleMessage("Добавить узел"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Добавить профиль"),
    "addRule": MessageLookupByLibrary.simpleMessage("Добавить правило"),
    "addRuleSet": MessageLookupByLibrary.simpleMessage("Добавить набор правил"),
    "addRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "Оставьте URL пустым, чтобы создать пустой набор и добавлять правила вручную. Файл или URL принимают правила маршрутизации Xray: весь конфиг, объект routing или список правил.",
    ),
    "addServer": MessageLookupByLibrary.simpleMessage("Добавить сервер"),
    "addSsid": MessageLookupByLibrary.simpleMessage("Добавить SSID"),
    "addSuccess": MessageLookupByLibrary.simpleMessage("Добавлено"),
    "addWidget": MessageLookupByLibrary.simpleMessage("Добавить виджет"),
    "address": MessageLookupByLibrary.simpleMessage("Адрес"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("Адрес сервера WebDAV"),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Введите корректный адрес WebDAV",
    ),
    "advanced": MessageLookupByLibrary.simpleMessage("Дополнительно"),
    "algorithm": MessageLookupByLibrary.simpleMessage("Алгоритм"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Разрешить приложениям обходить VPN",
    ),
    "allowInsecure": MessageLookupByLibrary.simpleMessage(
      "Разрешить небезопасные",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("Разрешить LAN"),
    "answers": MessageLookupByLibrary.simpleMessage("Ответы"),
    "app": MessageLookupByLibrary.simpleMessage("Приложение"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Контроль доступа приложений",
    ),
    "appIconDesign": MessageLookupByLibrary.simpleMessage(
      "Дизайн значка приложения",
    ),
    "appearance": MessageLookupByLibrary.simpleMessage("Оформление"),
    "applyTo": MessageLookupByLibrary.simpleMessage("Применить к"),
    "archive": MessageLookupByLibrary.simpleMessage("Архив"),
    "archiveDesc": MessageLookupByLibrary.simpleMessage(
      "Каждый запуск ядра сохраняется здесь после его завершения.",
    ),
    "archiveEmpty": MessageLookupByLibrary.simpleMessage("В архиве пока пусто"),
    "archiveStats": MessageLookupByLibrary.simpleMessage("Вести архив"),
    "authentication": MessageLookupByLibrary.simpleMessage("Аутентификация"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "Требовать учётные данные для локального порта прокси, чтобы другие приложения не могли использовать его",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Не применяется, пока включена аутентификация",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Разрешить"),
    "authorized": MessageLookupByLibrary.simpleMessage("Разрешено"),
    "auto": MessageLookupByLibrary.simpleMessage("Авто"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Автопроверка обновлений",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Автозапуск"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Запускаться автоматически при старте системы",
    ),
    "autoRenameNodes": MessageLookupByLibrary.simpleMessage(
      "Автопереименование",
    ),
    "autoRenameNodesDesc": MessageLookupByLibrary.simpleMessage(
      "Добавлять число к имени сервера, чтобы избежать дублей",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("Автовключение"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Включаться автоматически при открытии приложения",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Автонастройка системного DNS",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Автообновление"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал автообновления",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Назад"),
    "backup": MessageLookupByLibrary.simpleMessage("Резервное копирование"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование и восстановление",
    ),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Синхронизация данных через WebDAV или файлы",
    ),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "Резервная копия создана более новой версией приложения. Обновите приложение перед восстановлением",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage(
      "Резервная копия создана",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Основная информация"),
    "batchAdd": MessageLookupByLibrary.simpleMessage("Массовое добавление"),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage(
      "По одному значению на строку или через запятую",
    ),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage(
      "По одной записи на строку: ключ, пробел, значение",
    ),
    "batchPreviewTip": m0,
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "Чтобы приложение работало в фоне, отключите для него оптимизацию батареи. Нажмите, чтобы перейти к настройкам.",
    ),
    "batteryOptimizationStatusTip": MessageLookupByLibrary.simpleMessage(
      "Из-за системных ограничений во время работы невозможно корректно получить статус оптимизации батареи",
    ),
    "behavior": MessageLookupByLibrary.simpleMessage("Поведение"),
    "bind": MessageLookupByLibrary.simpleMessage("Привязать"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage(
      "Режим чёрного списка",
    ),
    "builtInRules": MessageLookupByLibrary.simpleMessage("Встроенные правила"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Исключённые домены"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Действует только при включённом системном прокси",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("Кэш"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Кэш повреждён. Очистить его?",
    ),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешите доступ к камере в системных настройках, чтобы сканировать QR-коды, или выберите изображение QR-кода из галереи.",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Требуется доступ к камере",
    ),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage(
      "Камера недоступна",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("Снять выделение"),
    "certSha256": MessageLookupByLibrary.simpleMessage("SHA256 сертификата"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "Не удалось переключить прокси; восстановлен предыдущий выбор",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage(
      "Важные изменения",
    ),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("Новые функции"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("Исправления"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage(
      "Производительность",
    ),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("Откаты"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage(
      "Проверять TLS-сертификаты",
    ),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "Отклонять недоверенные сертификаты. Отключение подвергает подписки и резервные копии атаке «человек посередине»",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Проверить обновления"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "У вас уже последняя версия",
    ),
    "chooseType": MessageLookupByLibrary.simpleMessage("Выберите тип"),
    "clearArchive": MessageLookupByLibrary.simpleMessage("Очистить архив"),
    "clearData": MessageLookupByLibrary.simpleMessage("Очистить данные"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Очистить поиск"),
    "clipboard": MessageLookupByLibrary.simpleMessage("Буфер обмена"),
    "clipboardDesc": m1,
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Экспорт в буфер обмена",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Импорт из буфера обмена",
    ),
    "clipboardNothingToImport": MessageLookupByLibrary.simpleMessage(
      "В буфере обмена нет URL прокси-сервера для импорта",
    ),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось скопировать в буфер обмена. Возможно, выделение слишком велико",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Закрыть"),
    "color": MessageLookupByLibrary.simpleMessage("Цвет"),
    "colorLinkInvalid": MessageLookupByLibrary.simpleMessage(
      "Не удалось прочитать эту цветовую ссылку",
    ),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("Цветовые схемы"),
    "colors": MessageLookupByLibrary.simpleMessage("Цвета"),
    "columns": MessageLookupByLibrary.simpleMessage("Столбцы"),
    "compatible": MessageLookupByLibrary.simpleMessage("Режим совместимости"),
    "configureDns": MessageLookupByLibrary.simpleMessage("Настройка DNS"),
    "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить все данные?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите принудительно завершить ядро со сбоем?",
    ),
    "congestionControl": MessageLookupByLibrary.simpleMessage(
      "Контроль перегрузки",
    ),
    "connectDesc": MessageLookupByLibrary.simpleMessage(
      "Проверка URL-запроса через прокси-сервер.",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Подключено"),
    "connectedTime": MessageLookupByLibrary.simpleMessage("Время работы"),
    "connecting": MessageLookupByLibrary.simpleMessage("Подключение…"),
    "connection": MessageLookupByLibrary.simpleMessage("Соединение"),
    "connections": MessageLookupByLibrary.simpleMessage("Соединения"),
    "connectivity": MessageLookupByLibrary.simpleMessage("Подключение: "),
    "connectivityTest": MessageLookupByLibrary.simpleMessage("Проверка связи"),
    "content": MessageLookupByLibrary.simpleMessage("Содержимое"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Контентная"),
    "copy": MessageLookupByLibrary.simpleMessage("Копировать"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Копировать адрес"),
    "copyColorLink": MessageLookupByLibrary.simpleMessage("Копировать ссылку"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Копировать переменные окружения",
    ),
    "copyJson": MessageLookupByLibrary.simpleMessage("Копировать JSON"),
    "copyLink": MessageLookupByLibrary.simpleMessage("Копировать ссылку"),
    "copyName": MessageLookupByLibrary.simpleMessage("Копировать имя"),
    "copyScheme": MessageLookupByLibrary.simpleMessage(
      "Нажмите на схему, чтобы скопировать её.",
    ),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Скопировано"),
    "core": MessageLookupByLibrary.simpleMessage("Ядро"),
    "coreBlockedByPolicyTip": m2,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Smart App Control в Windows заблокировал неподписанный FlClashCore.exe. Откройте Безопасность Windows → Управление приложениями и браузером → Параметры Smart App Control, выберите «Выкл.» и снова запустите FlClash. Повторно включить Smart App Control без переустановки Windows нельзя.",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Статус ядра"),
    "country": MessageLookupByLibrary.simpleMessage("Регион"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Обнаружен сбой"),
    "crashDetectedTip": m3,
    "crashTest": MessageLookupByLibrary.simpleMessage("Тест сбоя"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("Аналитика сбоев"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "При включении в случае сбоя приложения автоматически загружаются логи сбоя без конфиденциальной информации",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Создать"),
    "createProfileFromUrlTip": m4,
    "custom": MessageLookupByLibrary.simpleMessage("Вручную"),
    "cut": MessageLookupByLibrary.simpleMessage("Вырезать"),
    "dark": MessageLookupByLibrary.simpleMessage("Тёмная"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Панель"),
    "data": MessageLookupByLibrary.simpleMessage("Данные"),
    "dataCollectionContent": MessageLookupByLibrary.simpleMessage(
      "Это приложение использует Firebase Crashlytics для сбора информации о сбоях, чтобы повысить стабильность.\nСобираемые данные включают сведения об устройстве и подробности сбоя и не содержат личных конфиденциальных данных.\nЭту функцию можно отключить в настройках.",
    ),
    "dataCollectionTip": MessageLookupByLibrary.simpleMessage(
      "Уведомление о сборе данных",
    ),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Не удалось сохранить изменение; оно отменено",
    ),
    "daysAgo": m5,
    "defaultText": MessageLookupByLibrary.simpleMessage("По умолчанию"),
    "delay": MessageLookupByLibrary.simpleMessage("Задержка"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Тест задержки"),
    "delayTestMethod": MessageLookupByLibrary.simpleMessage(
      "Способ проверки задержки",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "deleteAllNodes": MessageLookupByLibrary.simpleMessage("Удалить все узлы"),
    "deleteAllNodesTip": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите удалить?",
    ),
    "deleteRuleSet": MessageLookupByLibrary.simpleMessage("Удалить конфиг"),
    "deleteSuccess": MessageLookupByLibrary.simpleMessage("Удалено"),
    "deleteTip": m6,
    "desc": MessageLookupByLibrary.simpleMessage(
      "Многоплатформенный прокси-клиент на основе Xray-core: простой и удобный, с открытым исходным кодом и без рекламы.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Назначение"),
    "details": m7,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Использует сторонний API; только для справки",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Режим разработчика"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Режим разработчика включён.",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Прямой"),
    "directDns": MessageLookupByLibrary.simpleMessage("Прямой DNS"),
    "directDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Для доменов материкового Китая и адресов самих узлов; запросы идут напрямую. Первые в списке используются в первую очередь.",
    ),
    "directModeDesc": MessageLookupByLibrary.simpleMessage(
      "Не использовать прокси для трафика",
    ),
    "disabled": MessageLookupByLibrary.simpleMessage("Выключено"),
    "disconnected": MessageLookupByLibrary.simpleMessage("Отключено"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "Доступна новая версия",
    ),
    "distribution": MessageLookupByLibrary.simpleMessage("Распределение"),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("Перехват DNS"),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS-запросы"),
    "dnsServer": MessageLookupByLibrary.simpleMessage("DNS-сервер"),
    "dnsServerTip": MessageLookupByLibrary.simpleMessage(
      "Введите IP-адрес (можно с портом), localhost или адрес вида https://, tcp://, quic+local://",
    ),
    "docked": MessageLookupByLibrary.simpleMessage("Закреплённая"),
    "domain": MessageLookupByLibrary.simpleMessage("Домен"),
    "done": MessageLookupByLibrary.simpleMessage("Готово"),
    "download": MessageLookupByLibrary.simpleMessage("Загрузка"),
    "downloadSpeed": MessageLookupByLibrary.simpleMessage(
      "Скорость загрузки (Мбит/с)",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
    "editPlainText": MessageLookupByLibrary.simpleMessage(
      "Редактировать как текст",
    ),
    "editRuleSet": MessageLookupByLibrary.simpleMessage("Изменить конфиг"),
    "editServer": MessageLookupByLibrary.simpleMessage("Изменить сервер"),
    "editSsid": MessageLookupByLibrary.simpleMessage("Изменить SSID"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Редактор недоступен",
    ),
    "emptyTip": m8,
    "en": MessageLookupByLibrary.simpleMessage("Английский"),
    "enabled": MessageLookupByLibrary.simpleMessage("Включено"),
    "encryption": MessageLookupByLibrary.simpleMessage("Шифрование"),
    "entries": MessageLookupByLibrary.simpleMessage(" записей"),
    "error": MessageLookupByLibrary.simpleMessage("Ошибка"),
    "exclude": MessageLookupByLibrary.simpleMessage("Скрыть из недавних задач"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "Скрывать приложение из недавних задач, когда оно в фоне",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("Исключённые SSID"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "При подключении к Wi-Fi с исключённым SSID состояние работы приложения переключается автоматически",
    ),
    "existsTip": m9,
    "exit": MessageLookupByLibrary.simpleMessage("Выход"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage(
      "Выйти из полноэкранного режима",
    ),
    "expand": MessageLookupByLibrary.simpleMessage("Стандартный"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Срок действия"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Экспорт файла"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Экспорт логов"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Экспорт выполнен"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Экспрессивная"),
    "externalLink": MessageLookupByLibrary.simpleMessage("Внешняя ссылка"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("Очень крупный"),
    "fade": MessageLookupByLibrary.simpleMessage("Растворение"),
    "feedback": MessageLookupByLibrary.simpleMessage("Обратная связь"),
    "feedbackDesc": MessageLookupByLibrary.simpleMessage(
      "FlClash — это только инструмент для прокси и он не предоставляет прокси-серверы. По вопросам работы сервера или продления подписки обращайтесь к вашему поставщику.",
    ),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("Точная передача"),
    "file": MessageLookupByLibrary.simpleMessage("Файл"),
    "fileDesc": MessageLookupByLibrary.simpleMessage(
      "Загрузить файл профиля напрямую",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("Фильтр"),
    "fingerprint": MessageLookupByLibrary.simpleMessage("Отпечаток"),
    "flag": MessageLookupByLibrary.simpleMessage("Флаг"),
    "floating": MessageLookupByLibrary.simpleMessage("Плавающая"),
    "flow": MessageLookupByLibrary.simpleMessage("Flow"),
    "followSystem": MessageLookupByLibrary.simpleMessage("Как в системе"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Шрифт"),
    "fontSize": MessageLookupByLibrary.simpleMessage("Размер"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите принудительно перезапустить ядро?",
    ),
    "format": MessageLookupByLibrary.simpleMessage("Формат"),
    "fragment": MessageLookupByLibrary.simpleMessage("Фрагментация"),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("Фруктовый микс"),
    "general": MessageLookupByLibrary.simpleMessage("Общие"),
    "geoRegion": MessageLookupByLibrary.simpleMessage(
      "Определять страну сервера",
    ),
    "geoRegionDesc": MessageLookupByLibrary.simpleMessage(
      "Запрашивает у GeoIP-сервиса страну сервера, чтобы показать флаг. Адрес сервера отправляется этому сервису.",
    ),
    "global": MessageLookupByLibrary.simpleMessage("Глобальный"),
    "globalModeDesc": MessageLookupByLibrary.simpleMessage(
      "Пересылать весь трафик через прокси",
    ),
    "globalRouting": MessageLookupByLibrary.simpleMessage(
      "Глобальная маршрутизация",
    ),
    "go": MessageLookupByLibrary.simpleMessage("Перейти"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Скачать"),
    "handshake": MessageLookupByLibrary.simpleMessage("Рукопожатие"),
    "hapticFeedback": MessageLookupByLibrary.simpleMessage("Тактильный отклик"),
    "hapticFeedbackDesc": MessageLookupByLibrary.simpleMessage(
      "Вибрация при включении и выключении прокси, переключении страниц на нижней панели и перетаскивании полосы прокрутки",
    ),
    "headerType": MessageLookupByLibrary.simpleMessage("Тип заголовка"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Служба Helper недоступна, поэтому TUN-режим включить нельзя. Переустановите FlClash.",
    ),
    "hideIp": MessageLookupByLibrary.simpleMessage("Скрыть IP"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("Скрыть пароль"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "Скрывать узлы с таймаутом",
    ),
    "hideTimeoutProxiesDesc": MessageLookupByLibrary.simpleMessage(
      "Не показывать узлы, у которых последний тест задержки завершился таймаутом",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Главная"),
    "host": MessageLookupByLibrary.simpleMessage("Хост"),
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Глобальные горячие клавиши работают, даже когда окно скрыто. Нажмите на действие, чтобы записать сочетание клавиш.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("Горячие клавиши"),
    "hotkeyMovedFrom": m10,
    "hotkeyNeedsModifier": m11,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("Не задано"),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "Не зарегистрировано: сочетание может быть занято другим приложением",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("часов"),
    "hoursAgo": m12,
    "icon": MessageLookupByLibrary.simpleMessage("Значок"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("История значков"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Стиль значков"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("С подложкой"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("Скрыто"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("Без подложки"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("URL значка"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Игнорировать оптимизацию батареи",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Импорт"),
    "importColorsTip": m13,
    "importEllipsis": MessageLookupByLibrary.simpleMessage("Импорт…"),
    "importFile": MessageLookupByLibrary.simpleMessage("Импорт из файла"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("Импорт из URL"),
    "importNodesFromClipboardTip": m14,
    "inbound": MessageLookupByLibrary.simpleMessage("Входящие"),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Бессрочно"),
    "init": MessageLookupByLibrary.simpleMessage("Инициализация"),
    "installedAppsPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Разрешение на список приложений отклонено, поэтому установленные приложения недоступны. Предоставьте его вручную в системных настройках.",
    ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Эта система не выдаёт список установленных приложений без разрешения. Предоставьте его, чтобы настроить прокси для отдельных приложений.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Требуется разрешение на список приложений",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("Умный выбор"),
    "internet": MessageLookupByLibrary.simpleMessage("Интернет"),
    "interval": MessageLookupByLibrary.simpleMessage("Интервал"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Внутренний IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Недопустимый файл резервной копии",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "Этот QR-код не содержит ссылку на профиль",
    ),
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP-адрес"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("Злоупотребления"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("Прокси"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("Метки"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("Организация"),
    "ipPurity": MessageLookupByLibrary.simpleMessage("Чистота"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось определить тип IP",
    ),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("Хороший"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("Уровень"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("Обычный"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage("Проверить снова"),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("Рискованный"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("Источник ответа"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("Источники"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage(
      "Другой исходящий IP",
    ),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("Тип не определён"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage(
      "Лимит запросов",
    ),
    "ipType": MessageLookupByLibrary.simpleMessage("Тип"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("Бизнес"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("Дата-центр"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("Мобильная сеть"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("Домашний"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "При включении можно принимать трафик IPv6",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить входящий IPv6",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("Японский"),
    "justNow": MessageLookupByLibrary.simpleMessage("Только что"),
    "key": MessageLookupByLibrary.simpleMessage("Ключ"),
    "language": MessageLookupByLibrary.simpleMessage("Язык"),
    "large": MessageLookupByLibrary.simpleMessage("Крупный"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("Последнее обновление"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "Запуск не завершён",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "В прошлый раз приложение неожиданно завершилось во время запуска. Автоматическая настройка для этого запуска пропущена; вы можете запустить её вручную.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Макет"),
    "light": MessageLookupByLibrary.simpleMessage("Светлая"),
    "lineIssueTip": m15,
    "lineWrap": MessageLookupByLibrary.simpleMessage("Перенос строк"),
    "list": MessageLookupByLibrary.simpleMessage("Список"),
    "listen": MessageLookupByLibrary.simpleMessage("Прослушивание"),
    "loading": MessageLookupByLibrary.simpleMessage("Загрузка…"),
    "local": MessageLookupByLibrary.simpleMessage("Локально"),
    "localFiles": MessageLookupByLibrary.simpleMessage("Локальные файлы"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "Доступ к локальной сети запрещён: используется стек gvisor, локальная сеть недоступна.",
    ),
    "localProfile": MessageLookupByLibrary.simpleMessage("Локальные серверы"),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Разрешение на геолокацию",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Разрешение на геолокацию отклонено, поэтому невозможно получить имя текущей сети Wi-Fi. Включите разрешение на геолокацию вручную в системных настройках.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "По требованию системы для получения имени сети Wi-Fi необходимо разрешение на геолокацию. На Android выберите «Разрешить всегда», иначе имя сети Wi-Fi нельзя получить, пока приложение в фоне.",
    ),
    "locationPermissionGuide": m16,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Требуется разрешение на геолокацию",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Лог"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Уровень логов"),
    "logcat": MessageLookupByLibrary.simpleMessage("Захват логов"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "При отключении раздел логов будет скрыт",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Логи"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Логи и диагностика",
    ),
    "logsTest": MessageLookupByLibrary.simpleMessage("Тест логов"),
    "loopback": MessageLookupByLibrary.simpleMessage(
      "Снятие ограничения loopback для UWP",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Свободный"),
    "manual": MessageLookupByLibrary.simpleMessage("Вручную"),
    "matchDomain": MessageLookupByLibrary.simpleMessage("Полный домен"),
    "matchDomainSuffix": MessageLookupByLibrary.simpleMessage("Суффикс домена"),
    "matchKeyword": MessageLookupByLibrary.simpleMessage(
      "Ключевое слово домена",
    ),
    "matchRegexp": MessageLookupByLibrary.simpleMessage(
      "Регулярное выражение домена",
    ),
    "maxLengthTip": m17,
    "maximize": MessageLookupByLibrary.simpleMessage("Развернуть"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage(
      "Резидентная память",
    ),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage(
      "Приложение и общая",
    ),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage(
      "Свободная куча",
    ),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage(
      "Используемая куча",
    ),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage(
      "Ядро не запущено",
    ),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage(
      "Накладные расходы среды",
    ),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage("Стеки горутин"),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "Оценка по резидентной памяти процессов; может отличаться от данных системы.",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "Ядро работает в процессе приложения. Его доля оценивается по статистике среды выполнения, остальное относится к приложению и общей памяти.",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Память"),
    "memoryReleased": MessageLookupByLibrary.simpleMessage(
      "Память освобождена",
    ),
    "memoryReleasedSize": m18,
    "menuBar": MessageLookupByLibrary.simpleMessage("Строка меню"),
    "menuBarEmbedded": MessageLookupByLibrary.simpleMessage("Встроенный"),
    "menuBarStandalone": MessageLookupByLibrary.simpleMessage("Отдельный"),
    "messageTest": MessageLookupByLibrary.simpleMessage("Тест сообщения"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("Это сообщение."),
    "min": MessageLookupByLibrary.simpleMessage("Минимальный"),
    "minimize": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "Сворачивать при выходе",
    ),
    "minutesAgo": m19,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Смешанный порт"),
    "mode": MessageLookupByLibrary.simpleMessage("Режим"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Монохром"),
    "monthsAgo": m20,
    "more": MessageLookupByLibrary.simpleMessage("Ещё"),
    "multiMode": MessageLookupByLibrary.simpleMessage("Мультирежим"),
    "multiplexing": MessageLookupByLibrary.simpleMessage("Мультиплексирование"),
    "name": MessageLookupByLibrary.simpleMessage("Название"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("Нижняя панель"),
    "network": MessageLookupByLibrary.simpleMessage("Сеть"),
    "networkAccessDeniedError": MessageLookupByLibrary.simpleMessage(
      "Сервер запретил доступ. Возможно, ссылка устарела или учётные данные неверны",
    ),
    "networkBadResponseError": MessageLookupByLibrary.simpleMessage(
      "Сервер отклонил запрос",
    ),
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "Запрос отменён",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Не удалось подключиться к серверу. Проверьте подключение к сети или настройки прокси",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage("Проверка сети"),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "Не удалось определить адрес сервера. Проверьте правильность URL и работу DNS",
    ),
    "networkNotFoundError": MessageLookupByLibrary.simpleMessage(
      "По этому адресу ничего не найдено. Проверьте правильность URL",
    ),
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Слишком много запросов. Подождите немного и повторите попытку",
    ),
    "networkRequestFailed": m21,
    "networkServerError": MessageLookupByLibrary.simpleMessage(
      "На сервере произошла ошибка. Повторите попытку позже",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Скорость сети"),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "Время ожидания запроса истекло. Проверьте сеть или прокси и повторите попытку",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "Не удалось установить защищённое соединение. Сертификат сервера может быть недействителен, или соединение перехватывается",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("Тип сети"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Нейтральная"),
    "newConfig": MessageLookupByLibrary.simpleMessage("Новая конфигурация"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Следующее совпадение"),
    "no": MessageLookupByLibrary.simpleMessage("Нет"),
    "noData": MessageLookupByLibrary.simpleMessage("Нет данных"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Нет информации"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "Больше не напоминать",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Нет сети"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("Приложения без сети"),
    "noRules": MessageLookupByLibrary.simpleMessage("Правил пока нет"),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "Ничего не найдено",
    ),
    "noUsableNodes": MessageLookupByLibrary.simpleMessage(
      "Не найдено ни одного пригодного узла. Проверьте ссылку или содержимое файла либо обратитесь к поставщику услуги.",
    ),
    "nodeInvalid": MessageLookupByLibrary.simpleMessage(
      "Эти значения не образуют рабочий сервер.",
    ),
    "none": MessageLookupByLibrary.simpleMessage("Нет"),
    "notConnected": MessageLookupByLibrary.simpleMessage("Не подключено"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Текущую группу прокси нельзя выбрать",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Добавьте профиль, чтобы начать",
    ),
    "nullTip": m22,
    "numberTip": m23,
    "obfsPassword": MessageLookupByLibrary.simpleMessage("Пароль обфускации"),
    "off": MessageLookupByLibrary.simpleMessage("Выкл."),
    "on": MessageLookupByLibrary.simpleMessage("Вкл."),
    "onDemand": MessageLookupByLibrary.simpleMessage("По условию"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "Настройте состояние работы приложения для определённых сценариев",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Учитывать только трафик прокси",
    ),
    "openApp": m24,
    "optional": MessageLookupByLibrary.simpleMessage("Необязательно"),
    "options": MessageLookupByLibrary.simpleMessage("Опции"),
    "other": MessageLookupByLibrary.simpleMessage("Другое"),
    "outboundMode": MessageLookupByLibrary.simpleMessage(
      "Режим исходящего трафика",
    ),
    "override": MessageLookupByLibrary.simpleMessage("Переопределение"),
    "overwriteExisting": MessageLookupByLibrary.simpleMessage(
      "Перезаписывать существующие",
    ),
    "overwriteExistingDesc": MessageLookupByLibrary.simpleMessage(
      "Заменять существующий сервер при совпадении имени",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("Палитра"),
    "password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "paste": MessageLookupByLibrary.simpleMessage("Вставить"),
    "path": MessageLookupByLibrary.simpleMessage("Путь"),
    "permissions": MessageLookupByLibrary.simpleMessage("Разрешения"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("Выбрать из галереи"),
    "pinWindow": MessageLookupByLibrary.simpleMessage(
      "Закрепить поверх всех окон",
    ),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Привяжите WebDAV",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Загрузите корректный QR-код",
    ),
    "policyBlock": MessageLookupByLibrary.simpleMessage("Блокировать"),
    "policyDirect": MessageLookupByLibrary.simpleMessage("Напрямую"),
    "policyProxy": MessageLookupByLibrary.simpleMessage("Прокси"),
    "port": MessageLookupByLibrary.simpleMessage("Порт"),
    "portHopping": MessageLookupByLibrary.simpleMessage("Смена портов"),
    "portTip": m25,
    "prerequisites": MessageLookupByLibrary.simpleMessage(
      "Предварительные условия",
    ),
    "presetAds": MessageLookupByLibrary.simpleMessage("Реклама"),
    "presetForeign": MessageLookupByLibrary.simpleMessage("Зарубежные сайты"),
    "presetLan": MessageLookupByLibrary.simpleMessage("Локальная сеть"),
    "presetMainlandChina": MessageLookupByLibrary.simpleMessage(
      "Материковый Китай",
    ),
    "presetWinSpy": MessageLookupByLibrary.simpleMessage("Телеметрия Windows"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Нажмите сочетание клавиш",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Предпросмотр"),
    "previousMatch": MessageLookupByLibrary.simpleMessage(
      "Предыдущее совпадение",
    ),
    "process": MessageLookupByLibrary.simpleMessage("Процесс"),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("Введите корректный интервал"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("Введите интервал автообновления"),
    "profileInUseTip": MessageLookupByLibrary.simpleMessage(
      "Галочка отмечает используемый профиль.",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите название профиля",
    ),
    "profileType": MessageLookupByLibrary.simpleMessage("Тип"),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите корректный URL профиля",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите URL профиля",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Профили"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Сортировка профилей"),
    "project": MessageLookupByLibrary.simpleMessage("Проект"),
    "providers": MessageLookupByLibrary.simpleMessage("Внешние ресурсы"),
    "proxies": MessageLookupByLibrary.simpleMessage("Прокси"),
    "proxyDns": MessageLookupByLibrary.simpleMessage("DNS через прокси"),
    "proxyDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Для доменов, идущих через прокси; запросы идут через узел. Первые в списке используются в первую очередь.",
    ),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Группа прокси"),
    "proxyNode": MessageLookupByLibrary.simpleMessage("Прокси-узел"),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Провайдеры прокси"),
    "proxyVia": MessageLookupByLibrary.simpleMessage("Через прокси"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Очистить кэш"),
    "publicKey": MessageLookupByLibrary.simpleMessage("Публичный ключ"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("Чисто чёрный"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Чисто чёрный режим"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR-код"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Сканируйте QR-код, чтобы получить профиль",
    ),
    "quickConfig": MessageLookupByLibrary.simpleMessage("Новая конфигурация"),
    "quickConfigDesc": MessageLookupByLibrary.simpleMessage(
      "Отметьте правила и добавьте их в существующую конфигурацию или в новую. Они ставятся перед собственными правилами конфигурации и имеют приоритет при совпадении. Если ничего не отмечать, создаётся пустая конфигурация, правила в которую вы добавляете вручную.",
    ),
    "quitFromMenuBar": MessageLookupByLibrary.simpleMessage(
      "Выйти из строки меню",
    ),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Радуга"),
    "redo": MessageLookupByLibrary.simpleMessage("Повторить"),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("Освободить память"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage(
      "Не удалось освободить память",
    ),
    "remainingTraffic": MessageLookupByLibrary.simpleMessage("Остаток трафика"),
    "remote": MessageLookupByLibrary.simpleMessage("Удалённо"),
    "remove": MessageLookupByLibrary.simpleMessage("Убрать"),
    "rename": MessageLookupByLibrary.simpleMessage("Переименовать"),
    "replace": MessageLookupByLibrary.simpleMessage("Заменить"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Заменить все"),
    "request": MessageLookupByLibrary.simpleMessage("Запрос"),
    "requests": MessageLookupByLibrary.simpleMessage("Запросы"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Запросы и обновления",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Обязательно"),
    "reset": MessageLookupByLibrary.simpleMessage("Сброс"),
    "resetColors": MessageLookupByLibrary.simpleMessage("Сбросить цвета"),
    "resetCoreSettings": MessageLookupByLibrary.simpleMessage(
      "Сбросить настройки ядра",
    ),
    "resetCoreSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Возвращает настройки ядра, сети и VPN к значениям по умолчанию. Часто помогает при сбоях подключения и проблемах VPN.",
    ),
    "resetHotkeys": MessageLookupByLibrary.simpleMessage(
      "Сбросить горячие клавиши",
    ),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "На этой странице есть изменения. Вы уверены, что хотите выполнить сброс?",
    ),
    "resetStatistics": MessageLookupByLibrary.simpleMessage(
      "Сбросить статистику",
    ),
    "resetSuccess": MessageLookupByLibrary.simpleMessage("Сброс выполнен"),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите выполнить сброс?",
    ),
    "resetUserSettings": MessageLookupByLibrary.simpleMessage(
      "Сбросить пользовательские настройки",
    ),
    "resetUserSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Удаляет все сохранённые настройки и профили, чтобы устранить сбои и неожиданное поведение. По завершении приложение закроется.",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Ресурсы"),
    "restart": MessageLookupByLibrary.simpleMessage("Перезапустить"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите перезапустить ядро?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Восстановить"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage(
      "Восстановить все данные",
    ),
    "restoreDefaultRules": MessageLookupByLibrary.simpleMessage(
      "Восстановить конфиг по умолчанию",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Восстановить только профили",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage(
      "Стратегия восстановления",
    ),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage(
      "Совместимость",
    ),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage(
      "Перезапись",
    ),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage(
      "Восстановление выполнено",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Повторить"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Адреса маршрутов"),
    "routeMode": MessageLookupByLibrary.simpleMessage("Режим маршрутизации"),
    "routeModeBypassPrivate": MessageLookupByLibrary.simpleMessage(
      "Обходить частные адреса",
    ),
    "routeModeConfig": MessageLookupByLibrary.simpleMessage(
      "Использовать конфигурацию",
    ),
    "ru": MessageLookupByLibrary.simpleMessage("Русский"),
    "rule": MessageLookupByLibrary.simpleMessage("Правило"),
    "ruleCount": m26,
    "ruleMatch": MessageLookupByLibrary.simpleMessage("Условие"),
    "ruleModeDesc": MessageLookupByLibrary.simpleMessage(
      "Пересылать трафик по правилам маршрутизации",
    ),
    "rulePolicy": MessageLookupByLibrary.simpleMessage("Политика"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Провайдеры правил"),
    "ruleSets": MessageLookupByLibrary.simpleMessage("Наборы правил"),
    "ruleValue": MessageLookupByLibrary.simpleMessage("Значение"),
    "ruleValueHint": MessageLookupByLibrary.simpleMessage(
      "Несколько значений — через запятую",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("Правила"),
    "rulesFooter": MessageLookupByLibrary.simpleMessage(
      "Правила действуют в режиме правил. Трафик, не подошедший ни под одно правило, идёт через прокси.",
    ),
    "rulesInvalid": MessageLookupByLibrary.simpleMessage(
      "Правила маршрутизации Xray не найдены",
    ),
    "rulesLegend": MessageLookupByLibrary.simpleMessage(
      "Точка отмечает конфиг по умолчанию, галочка — используемый.",
    ),
    "runTime": MessageLookupByLibrary.simpleMessage("Время работы"),
    "safeMode": MessageLookupByLibrary.simpleMessage("Безопасный режим"),
    "safeModeAppTitle": m27,
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Сохранить изменения?"),
    "saveSuccess": MessageLookupByLibrary.simpleMessage("Сохранено"),
    "schemeAdd": MessageLookupByLibrary.simpleMessage("Добавить сервер"),
    "schemeRoute": MessageLookupByLibrary.simpleMessage(
      "Переключить маршрутизацию",
    ),
    "schemeServer": MessageLookupByLibrary.simpleMessage("Переключить сервер"),
    "schemeStart": MessageLookupByLibrary.simpleMessage(
      "Запустить VPN-туннель",
    ),
    "schemeStop": MessageLookupByLibrary.simpleMessage(
      "Остановить VPN-туннель",
    ),
    "schemeToggle": MessageLookupByLibrary.simpleMessage(
      "Переключить VPN-туннель",
    ),
    "schemeUpdateProfiles": MessageLookupByLibrary.simpleMessage(
      "Обновить подписки",
    ),
    "script": MessageLookupByLibrary.simpleMessage("Скрипт"),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Прокрутить к выбранному",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Поиск"),
    "seconds": MessageLookupByLibrary.simpleMessage("секунд"),
    "security": MessageLookupByLibrary.simpleMessage("Безопасность"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Выбрать всё"),
    "selected": MessageLookupByLibrary.simpleMessage("Выбрано"),
    "selectedCountTitle": m28,
    "server": MessageLookupByLibrary.simpleMessage("Сервер"),
    "serverName": MessageLookupByLibrary.simpleMessage("Имя сервера (SNI)"),
    "serverNodes": MessageLookupByLibrary.simpleMessage("Серверные узлы"),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Доступен"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Заблокировано"),
    "serviceCheck": MessageLookupByLibrary.simpleMessage("Проверить"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("Проверить все"),
    "serviceCheckedAt": m29,
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("Скоро появится"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage(
      "Недопустимый провайдер",
    ),
    "serviceFailed": MessageLookupByLibrary.simpleMessage("Ошибка проверки"),
    "serviceManage": MessageLookupByLibrary.simpleMessage(
      "Управление сервисами",
    ),
    "serviceName": MessageLookupByLibrary.simpleMessage("Имя службы"),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage(
      "Только оригиналы",
    ),
    "servicePending": MessageLookupByLibrary.simpleMessage("Не проверено"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage(
      "Доступ ограничен",
    ),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("Состояние сервисов"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("Недоступен"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage(
      "Регион не поддерживается",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "shortId": MessageLookupByLibrary.simpleMessage("Short ID"),
    "show": MessageLookupByLibrary.simpleMessage("Показать"),
    "showLess": MessageLookupByLibrary.simpleMessage("Свернуть"),
    "showMore": MessageLookupByLibrary.simpleMessage("Развернуть"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Кнопка остановки в уведомлении",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Показать пароль"),
    "shrink": MessageLookupByLibrary.simpleMessage("Компактный"),
    "sidebar": MessageLookupByLibrary.simpleMessage("Боковая панель"),
    "sidebarBlur": MessageLookupByLibrary.simpleMessage(
      "Размытие боковой панели",
    ),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "Показывать сквозь боковую панель размытый рабочий стол за окном",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Тихий запуск"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Запускаться без показа окна",
    ),
    "singleAdd": MessageLookupByLibrary.simpleMessage("По одному"),
    "singleValueTip": m30,
    "size": MessageLookupByLibrary.simpleMessage("Размер"),
    "slide": MessageLookupByLibrary.simpleMessage("Сдвиг"),
    "sort": MessageLookupByLibrary.simpleMessage("Сортировка"),
    "source": MessageLookupByLibrary.simpleMessage("Источник"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage(
      "Статистика скорости",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("Список SSID пуст"),
    "standard": MessageLookupByLibrary.simpleMessage("Стандартный"),
    "starOnGithub": MessageLookupByLibrary.simpleMessage(
      "Поставить звезду на GitHub",
    ),
    "start": MessageLookupByLibrary.simpleMessage("Старт"),
    "startTime": MessageLookupByLibrary.simpleMessage("Время запуска"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Запуск VPN…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage(
      "Запуск и фоновая работа",
    ),
    "statistics": MessageLookupByLibrary.simpleMessage("Статистика"),
    "status": MessageLookupByLibrary.simpleMessage("Статус"),
    "stop": MessageLookupByLibrary.simpleMessage("Стоп"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Остановка VPN…"),
    "strategy": MessageLookupByLibrary.simpleMessage("Стратегия"),
    "style": MessageLookupByLibrary.simpleMessage("Стиль"),
    "subRule": MessageLookupByLibrary.simpleMessage("Подправило"),
    "submit": MessageLookupByLibrary.simpleMessage("Отправить"),
    "subscribe": MessageLookupByLibrary.simpleMessage("Подписка"),
    "subscribeDesc": MessageLookupByLibrary.simpleMessage(
      "URL подписки или Xray JSON",
    ),
    "subscriptionFoldTip": MessageLookupByLibrary.simpleMessage(
      "Нажмите на подписку, чтобы свернуть или развернуть её узлы.",
    ),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Информация о подписке",
    ),
    "subscriptionUrlError": MessageLookupByLibrary.simpleMessage(
      "Проблема с URL сервера. Повторите попытку позже. Если проблема не исчезнет, отключите VPN и попробуйте снова или обратитесь к поставщику прокси-сервиса.",
    ),
    "suspended": MessageLookupByLibrary.simpleMessage("Приостановлено…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("Сменить профиль"),
    "sync": MessageLookupByLibrary.simpleMessage("Синхронизация"),
    "system": MessageLookupByLibrary.simpleMessage("Система"),
    "systemApp": MessageLookupByLibrary.simpleMessage("Системные приложения"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "tab": MessageLookupByLibrary.simpleMessage("Вкладки"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Анимация вкладок"),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage(
      "Нажмите, чтобы разрешить",
    ),
    "tcpFastOpen": MessageLookupByLibrary.simpleMessage("TCP Fast Open"),
    "test": MessageLookupByLibrary.simpleMessage("Тест"),
    "testRules": MessageLookupByLibrary.simpleMessage("Проверить правила"),
    "testRulesGeoNote": MessageLookupByLibrary.simpleMessage(
      "Записи GeoSite и GeoIP проверяет только ядро, здесь они пропускаются.",
    ),
    "testRulesHint": MessageLookupByLibrary.simpleMessage("Домен или IP"),
    "testRulesMatched": MessageLookupByLibrary.simpleMessage(
      "Сработавшее правило",
    ),
    "testRulesNoMatch": MessageLookupByLibrary.simpleMessage(
      "Ни одно правило не подошло, трафик идёт через прокси",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("URL для теста"),
    "testUrlDesc": MessageLookupByLibrary.simpleMessage("URL для проверки."),
    "textScale": MessageLookupByLibrary.simpleMessage("Масштаб текста"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage(
      "Так будет выглядеть текст в приложении",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Тема"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Цвет темы"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Тёмный режим и настройка цветов",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Режим темы"),
    "tight": MessageLookupByLibrary.simpleMessage("Плотный"),
    "time": MessageLookupByLibrary.simpleMessage("Время"),
    "timeout": MessageLookupByLibrary.simpleMessage("Тайм-аут"),
    "timeoutDesc": MessageLookupByLibrary.simpleMessage(
      "Если проверка не завершится до таймаута, она будет прервана.",
    ),
    "tip": MessageLookupByLibrary.simpleMessage("Подсказка"),
    "toggle": MessageLookupByLibrary.simpleMessage("Переключить"),
    "toggleSpeedView": MessageLookupByLibrary.simpleMessage(
      "Переключить показ скорости",
    ),
    "tolerance": MessageLookupByLibrary.simpleMessage("Допуск"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("Тональный акцент"),
    "tools": MessageLookupByLibrary.simpleMessage("Инструменты"),
    "torch": MessageLookupByLibrary.simpleMessage("Фонарик"),
    "total": MessageLookupByLibrary.simpleMessage("Всего"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Общий трафик"),
    "traffic": MessageLookupByLibrary.simpleMessage("Трафик"),
    "trafficAll": MessageLookupByLibrary.simpleMessage("Всего"),
    "trafficProxy": MessageLookupByLibrary.simpleMessage("Прокси"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Статистика трафика"),
    "transportMethod": MessageLookupByLibrary.simpleMessage("Транспорт"),
    "transportMode": MessageLookupByLibrary.simpleMessage("Транспорт"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "Работает только в режиме администратора",
    ),
    "tunnel": MessageLookupByLibrary.simpleMessage("Туннель"),
    "turnOff": MessageLookupByLibrary.simpleMessage("Выключить"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Включить"),
    "udpRelay": MessageLookupByLibrary.simpleMessage("Ретрансляция UDP"),
    "undo": MessageLookupByLibrary.simpleMessage("Отменить"),
    "unknown": MessageLookupByLibrary.simpleMessage("Неизвестно"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Неизвестная сетевая ошибка",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("Свернуть в окно"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Без названия"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("Открепить окно"),
    "update": MessageLookupByLibrary.simpleMessage("Обновить"),
    "updateAll": MessageLookupByLibrary.simpleMessage("Обновить все"),
    "updateSuccess": MessageLookupByLibrary.simpleMessage("Обновлено"),
    "uploadSpeed": MessageLookupByLibrary.simpleMessage(
      "Скорость отправки (Мбит/с)",
    ),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage("Получить профиль по URL"),
    "urlSchemes": MessageLookupByLibrary.simpleMessage("URL-схемы"),
    "urlTestSettings": MessageLookupByLibrary.simpleMessage(
      "Настройки проверки URL",
    ),
    "urlTip": m31,
    "usedDownloadTraffic": MessageLookupByLibrary.simpleMessage(
      "Использовано при загрузке",
    ),
    "usedTraffic": MessageLookupByLibrary.simpleMessage(
      "Использованный трафик",
    ),
    "usedUploadTraffic": MessageLookupByLibrary.simpleMessage(
      "Использовано при отдаче",
    ),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "username": MessageLookupByLibrary.simpleMessage("Имя пользователя"),
    "uuid": MessageLookupByLibrary.simpleMessage("UUID"),
    "value": MessageLookupByLibrary.simpleMessage("Значение"),
    "version": MessageLookupByLibrary.simpleMessage("Версия"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Яркая"),
    "view": MessageLookupByLibrary.simpleMessage("Просмотр"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "Обнаружено изменение настроек VPN",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматически направляет весь системный трафик через VpnService",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Изменения вступят в силу после перезапуска VPN",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "Настройка WebDAV",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage(
      "Режим белого списка",
    ),
    "yearsAgo": m32,
    "zhCN": MessageLookupByLibrary.simpleMessage("Упрощённый китайский"),
    "zhTW": MessageLookupByLibrary.simpleMessage("Традиционный китайский"),
  };
}
