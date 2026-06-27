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
  String get authEmailAlreadyExistsMessage =>
      'Для этого email уже есть аккаунт MedStory. Войдите или используйте другой email.';

  @override
  String get authInvalidEmailMessage =>
      'Введите корректный email. Например: name@example.com';

  @override
  String get authEmailRequiredMessage =>
      'Введите email, чтобы создать аккаунт.';

  @override
  String get authPasswordNotAcceptedMessage =>
      'Выберите более надёжный пароль: минимум 8 символов, без распространённых вариантов.';

  @override
  String get authRegisterFailedMessage =>
      'Не удалось создать аккаунт. Проверьте данные и попробуйте снова.';

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

  @override
  String get timelineHeadline => 'Ваша медицинская история';

  @override
  String get timelineSubtitle =>
      'Просматривайте сохранённые события, начиная с самых новых.';

  @override
  String get timelineEmptyTitle => 'Начните с одного события';

  @override
  String get timelineEmptyMessage =>
      'Добавьте симптом, лекарство, диагноз, процедуру или заметку, которую важно помнить.';

  @override
  String get timelineNoSubjectTitle => 'Профиль не найден';

  @override
  String get timelineNoSubjectMessage =>
      'MedStory не удалось загрузить профиль для этой хронологии.';

  @override
  String get timelineAddEvent => 'Добавить';

  @override
  String get timelineSearchLabel => 'Поиск по названию или описанию';

  @override
  String get timelineFiltersAction => 'Фильтры';

  @override
  String get timelineAllTypes => 'Все типы';

  @override
  String get timelineOfflineNotice =>
      'Показаны сохранённые события. Обновите, когда подключение восстановится.';

  @override
  String get timelineLoadMore => 'Загрузить ещё';

  @override
  String get timelineRefresh => 'Обновить хронологию';

  @override
  String get subjectSwitcherLabel => 'Профиль хронологии';

  @override
  String get subjectDefaultLabel => 'Основной';

  @override
  String get eventTypeSymptom => 'Симптом';

  @override
  String get eventTypeDiagnosis => 'Диагноз';

  @override
  String get eventTypeMedication => 'Лекарство';

  @override
  String get eventTypeExamination => 'Обследование';

  @override
  String get eventTypeProcedure => 'Процедура';

  @override
  String get eventTypeHospitalization => 'Госпитализация';

  @override
  String get eventTypeTreatmentOutcome => 'Результат лечения';

  @override
  String get eventTypeNote => 'Заметка';

  @override
  String get eventNewTitle => 'Добавить событие';

  @override
  String get eventEditTitle => 'Изменить событие';

  @override
  String get eventDetailTitle => 'Сведения о событии';

  @override
  String get eventTitleLabel => 'Название';

  @override
  String get eventDescriptionLabel => 'Описание';

  @override
  String get eventTypeLabel => 'Тип события';

  @override
  String get eventDateLabel => 'Дата события';

  @override
  String get eventEndDateLabel => 'Дата окончания';

  @override
  String get eventTagsLabel => 'Теги';

  @override
  String get eventTagsHelper => 'Разделяйте теги запятыми.';

  @override
  String get eventAttributesLabel => 'Структурированные детали';

  @override
  String get eventAttributesHelper =>
      'Необязательный JSON-объект с деталями: дозой, тяжестью или результатом.';

  @override
  String get eventCreateAction => 'Сохранить событие';

  @override
  String get eventSaveAction => 'Сохранить изменения';

  @override
  String get eventEditAction => 'Изменить';

  @override
  String get eventDeleteAction => 'Удалить';

  @override
  String get eventDeleteConfirmTitle => 'Удалить это событие?';

  @override
  String get eventDeleteConfirmMessage => 'Оно исчезнет из вашей хронологии.';

  @override
  String get eventCancelAction => 'Отмена';

  @override
  String get eventRequiredValidation => 'Это поле обязательно.';

  @override
  String get eventInvalidJsonValidation =>
      'Введите корректный JSON-объект или оставьте поле пустым.';

  @override
  String get eventBoundaryNote =>
      'MedStory упорядочивает вашу информацию; он не ставит диагнозы и не рекомендует лечение.';

  @override
  String get eventUnconfirmedBadge => 'Нужно проверить';

  @override
  String get eventConfirmedBadge => 'Подтверждено';

  @override
  String get eventDetailsEmptyDescription => 'Описание не добавлено.';

  @override
  String get eventNetworkRequired =>
      'Для сохранения изменений нужно подключение к MedStory.';
}
