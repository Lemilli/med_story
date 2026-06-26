// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'MedStory';

  @override
  String get navTimeline => 'Хронология';

  @override
  String get navCapture => 'Запись';

  @override
  String get navSummary => 'Сводка';

  @override
  String get navSettings => 'Настройки';

  @override
  String get timelineTitle => 'Хронология';

  @override
  String get timelineMessage =>
      'Здесь появится ваша подтверждённая медицинская история.';

  @override
  String get summaryTitle => 'Сводка';

  @override
  String get summaryMessage => 'Здесь будут сводки для врача и экспорт данных.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsMessage => 'Конфиденциальность, аккаунт, профили и язык.';

  @override
  String get captureHeadline => 'Добавить в историю';

  @override
  String get captureSubtitle =>
      'Запишите то, что помните. Разложить по полочкам можно позже.';

  @override
  String get recordVoiceTitle => 'Записать голос';

  @override
  String get recordVoiceDescription =>
      'Расскажите о воспоминании, симптоме или лечении.';

  @override
  String get recordVoiceSemanticHint =>
      'Начинает голосовую запись. Перед сохранением можно прослушать.';

  @override
  String get voiceCaptureTitle => 'Голосовая запись';

  @override
  String get voiceCaptureMessage =>
      'Запись с микрофона будет подключена к контроллеру захвата.';

  @override
  String get scanDocumentTitle => 'Сканировать документ';

  @override
  String get scanDocumentDescription =>
      'Сканируйте записи, письма, отчёты или рецепты.';

  @override
  String get scanDocumentSemanticHint =>
      'Начинает захват документа. Предложения ИИ можно проверить позже.';

  @override
  String get documentScanTitle => 'Сканирование документа';

  @override
  String get documentScanMessage =>
      'Камера и захват файлов будут подключены к загрузке.';

  @override
  String get writeNoteTitle => 'Написать заметку';

  @override
  String get writeNoteDescription =>
      'Введите мысли, вопросы или детали, которые помните.';

  @override
  String get writeNoteSemanticHint => 'Открывает текстовую заметку.';

  @override
  String get textNoteTitle => 'Текстовая заметка';

  @override
  String get textNoteMessage =>
      'Ручной ввод заметок будет добавлен в этот поток.';

  @override
  String get addPhotoTitle => 'Добавить фото или файл';

  @override
  String get addPhotoDescription =>
      'Прикрепите изображения или файлы с устройства.';

  @override
  String get addPhotoSemanticHint => 'Открывает выбор фото или файла.';

  @override
  String get photoOrFileTitle => 'Фото или файл';

  @override
  String get photoOrFileMessage =>
      'Галерея и выбор файлов будут подключены далее.';

  @override
  String get privacyPanelSemanticLabel =>
      'Только для вас. Вы проверяете предложения ИИ перед добавлением в хронологию.';

  @override
  String get privacyPanelTitle => 'Только для вас';

  @override
  String get privacyPanelDescription =>
      'Вы проверяете предложения ИИ перед добавлением в хронологию.';

  @override
  String get boundaryNote =>
      'MedStory упорядочивает вашу информацию; он не ставит диагнозы.';

  @override
  String get authLoginTitle => 'С возвращением';

  @override
  String get authLoginSubtitle =>
      'Войдите, чтобы продолжить вести медицинскую историю.';

  @override
  String get authRegisterTitle => 'Создайте аккаунт';

  @override
  String get authRegisterSubtitle =>
      'Начните с личного места для вашей медицинской истории.';

  @override
  String get authBoundarySemanticLabel =>
      'MedStory — органайзер, а не диагностический инструмент.';

  @override
  String get authBoundaryNote =>
      'MedStory помогает упорядочивать и объяснять информацию. Он не ставит диагнозы и не рекомендует лечение.';

  @override
  String get authFullNameLabel => 'Полное имя';

  @override
  String get authFullNameHelper =>
      'Необязательно, используется только для персонализации аккаунта.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Пароль';

  @override
  String get authPasswordHelper => 'Используйте минимум 8 символов.';

  @override
  String get authEmailValidation => 'Введите корректный email.';

  @override
  String get authPasswordValidation => 'Введите минимум 8 символов.';

  @override
  String get authCreateAccountAction => 'Создать аккаунт';

  @override
  String get authLoginAction => 'Войти';

  @override
  String get authAlreadyHaveAccountAction => 'У меня уже есть аккаунт';

  @override
  String get authNeedAccountAction => 'Создать новый аккаунт';

  @override
  String get authLogoutAction => 'Выйти';

  @override
  String get authFailedMessage =>
      'Проверьте email и пароль, затем попробуйте снова.';

  @override
  String get networkFailedMessage =>
      'Не удалось подключиться к MedStory. Проверьте соединение и попробуйте снова.';

  @override
  String get authCheckingSession => 'Проверяем сессию';

  @override
  String get authMePanelTitle => 'Аккаунт из /me';

  @override
  String get authLocaleLabel => 'Язык';

  @override
  String get authUnnamedUser => 'Имя не указано';

  @override
  String pendingActionMessage(String title, String message) {
    return '$title: $message';
  }
}
