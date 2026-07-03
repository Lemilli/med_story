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
  String get summaryHeadline => 'Сводка для врача';

  @override
  String summarySubjectLabel(String name) {
    return 'Для $name';
  }

  @override
  String get summaryNoSubjectMessage =>
      'MedStory не удалось загрузить профиль для этой сводки.';

  @override
  String get summaryBoundaryNote =>
      'MedStory упорядочивает вашу информацию; он не ставит диагнозы и не рекомендует лечение.';

  @override
  String get summaryOfflineNotice =>
      'Показана сохраненная сводка. Обновите, когда снова будете онлайн.';

  @override
  String get summaryRefreshAction => 'Обновить сводку';

  @override
  String get summaryRegenerateAction => 'Пересоздать сводку';

  @override
  String get summaryGenerateAction => 'Создать сводку';

  @override
  String get summaryPrepareVisitAction => 'Подготовить к визиту';

  @override
  String get summaryNotReadyTitle => 'Сводки пока нет';

  @override
  String get summaryNotReadyMessage =>
      'Создайте сводку для врача из подтвержденных событий, когда нужно подготовиться к визиту.';

  @override
  String get summaryNarrativeTitle => 'Краткий текст для врача';

  @override
  String get summaryNoNarrativeMessage =>
      'Для этой сводки не вернулся краткий текст.';

  @override
  String summaryGeneratedAt(String date) {
    return 'Создано $date';
  }

  @override
  String summaryVersionLabel(int version) {
    return 'Версия $version';
  }

  @override
  String summaryEventCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подтвержденных событий',
      one: '1 подтвержденное событие',
      zero: 'Нет подтвержденных событий',
    );
    return '$_temp0';
  }

  @override
  String get summaryReturnToCurrentAction => 'Вернуться к текущей сводке';

  @override
  String get summaryVersionHistoryAction => 'История версий';

  @override
  String get summaryCurrentVersionLabel => 'Текущая';

  @override
  String get summaryHistorySearchTitle => 'Поиск по истории';

  @override
  String get summaryHistorySearchLabel => 'Искать события в таймлайне';

  @override
  String get summaryHistorySearchEmptyHint =>
      'Ищите сохраненные события, чтобы быстро проверить детали перед визитом.';

  @override
  String get summaryHistorySearchNoResults => 'Подходящих событий не найдено.';

  @override
  String get summaryHistorySearchFailedMessage =>
      'Не удалось обновить подходящие события. Сохраненные результаты могут остаться доступными.';

  @override
  String get summaryRegenerateQueuedMessage =>
      'Создание сводки началось. Потяните вниз для обновления через несколько минут.';

  @override
  String get summaryExportSharedMessage => 'Экспорт сводки готов к отправке.';

  @override
  String get summaryRegenerateFailedMessage =>
      'Не удалось запустить создание сводки. Проверьте подключение и попробуйте снова.';

  @override
  String get summaryExportFailedMessage =>
      'Не удалось подготовить экспорт сводки. Проверьте подключение и попробуйте снова.';

  @override
  String get summaryActionFailedMessage =>
      'Не удалось выполнить действие. Попробуйте снова.';

  @override
  String get summaryLoadFailedMessage => 'Не удалось загрузить эту сводку.';

  @override
  String get summarySectionKeySymptoms => 'Ключевые симптомы';

  @override
  String get summarySectionMajorDiagnoses => 'Основные диагнозы';

  @override
  String get summarySectionMedications => 'Лекарства';

  @override
  String get summarySectionProcedures => 'Процедуры';

  @override
  String get summarySectionHospitalizations => 'Госпитализации';

  @override
  String get summarySectionAllergies => 'Аллергии';

  @override
  String get summarySectionTestResults => 'Результаты анализов';

  @override
  String get summarySectionTreatmentOutcomes => 'Результаты лечения';

  @override
  String get summarySectionOpenQuestions => 'Открытые вопросы';

  @override
  String get summarySectionCareTeam => 'Команда врачей';

  @override
  String summaryUnknownSectionTitle(String name) {
    return '$name';
  }

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
  String get recordVoiceDeferredDescription =>
      'Голосовая запись появится позже. Сейчас используйте документ, фото или файл.';

  @override
  String get recordVoiceSemanticHint =>
      'Начинает голосовую запись. Перед сохранением можно прослушать.';

  @override
  String get recordVoiceDeferredSemanticHint =>
      'Голосовая запись запланирована на будущий этап.';

  @override
  String get voiceCaptureTitle => 'Голосовая запись';

  @override
  String get voiceCaptureMessage =>
      'Запись с микрофона будет подключена к контроллеру захвата.';

  @override
  String get voiceCaptureDeferredMessage =>
      'Голосовая запись отложена до этапа voice-first.';

  @override
  String get scanDocumentTitle => 'Сканировать документ';

  @override
  String get scanDocumentDescription =>
      'Используйте камеру для записей, отчётов, рецептов или писем.';

  @override
  String get scanDocumentSemanticHint =>
      'Открывает камеру для медицинского документа.';

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
  String get writeNoteDeferredDescription =>
      'Текстовые заметки пока остаются ручными. Добавляйте события на вкладке хронологии.';

  @override
  String get writeNoteSemanticHint => 'Открывает текстовую заметку.';

  @override
  String get writeNoteDeferredSemanticHint =>
      'Захват текстовых заметок запланирован на будущий этап.';

  @override
  String get textNoteTitle => 'Текстовая заметка';

  @override
  String get textNoteMessage =>
      'Ручной ввод заметок будет добавлен в этот поток.';

  @override
  String get textNoteDeferredMessage =>
      'На этапе 2 обработка документов работает с фото и файлами. Ручные заметки пока остаются событиями хронологии.';

  @override
  String get addPhotoTitle => 'Добавить фото или файл';

  @override
  String get addPhotoDescription =>
      'Выберите изображение документа из фотогалереи.';

  @override
  String get addPhotoSemanticHint =>
      'Открывает галерею для выбора изображения документа.';

  @override
  String get chooseFileTitle => 'Выбрать PDF или изображение';

  @override
  String get chooseFileDescription => 'Загрузите PDF, PNG или JPEG до 5 МБ.';

  @override
  String get chooseFileSemanticHint =>
      'Открывает выбор файла PDF или изображения.';

  @override
  String get photoOrFileTitle => 'Фото или файл';

  @override
  String get photoOrFileMessage =>
      'Галерея и выбор файлов будут подключены далее.';

  @override
  String get documentSelectionEmpty =>
      'Выберите фото с камеры, изображение из галереи или PDF/изображение. MedStory сразу начнёт обработку.';

  @override
  String get documentProcessingTitle => 'Обработка файла';

  @override
  String get documentReviewTitle => 'Выбранный документ';

  @override
  String get documentUntitledTitle => 'Документ';

  @override
  String get documentTitleLabel => 'Название документа';

  @override
  String get documentTypeLabel => 'Тип документа';

  @override
  String get documentDateLabel => 'Дата документа';

  @override
  String get documentDateAddAction => 'Добавить дату документа';

  @override
  String documentDateSelected(String date) {
    return 'Дата документа: $date';
  }

  @override
  String get documentDefaultSubject =>
      'Документ будет добавлен в основной профиль хронологии.';

  @override
  String documentSelectedSubject(String name) {
    return 'Документ будет добавлен в профиль $name.';
  }

  @override
  String documentFileMetadata(String mimeType, String size) {
    return '$mimeType • $size';
  }

  @override
  String get documentViewResultAction => 'Посмотреть результат';

  @override
  String get documentRetryAction => 'Попробовать снова';

  @override
  String get documentUploadAction => 'Загрузить и обработать';

  @override
  String get documentUploadIdle => 'Выберите файл, чтобы начать обработку.';

  @override
  String get documentUploadUploading =>
      'Сохраняем локально и отправляем на разовую обработку...';

  @override
  String get documentUploadProcessing =>
      'Извлекаем текст и предложенные события. После завершения можно уйти с экрана.';

  @override
  String get documentUploadProcessed =>
      'Обработка завершена. Можно посмотреть результат.';

  @override
  String get documentUploadFailedMessage =>
      'Не удалось обработать документ. Проверьте файл и попробуйте снова.';

  @override
  String get documentFileTooLargeMessage =>
      'Выберите файл размером не более 5 МБ.';

  @override
  String get documentUnsupportedFileMessage =>
      'На этапе 2 поддерживаются только PDF и изображения.';

  @override
  String get documentProcessingFailedMessage =>
      'Обработка не удалась. Оригинал файла остаётся на этом устройстве.';

  @override
  String get documentProcessingTimeoutMessage =>
      'Обработка занимает больше времени, чем ожидалось. Откройте документ ещё раз, чтобы обновить статус.';

  @override
  String get documentSourceMissingMessage =>
      'MedStory не удалось найти выбранный файл на этом устройстве.';

  @override
  String get documentDetailTitle => 'Сведения о документе';

  @override
  String get documentDateUnknown => 'Дата не указана';

  @override
  String get documentMimeTypeLabel => 'Тип файла';

  @override
  String get documentStorageLabel => 'Хранение';

  @override
  String get documentLocalOnlyValue =>
      'Оригинал сохранён только на этом устройстве';

  @override
  String get documentRemoteStorageValue => 'Хранится удалённо';

  @override
  String get documentExtractedTextLabel => 'Извлечённый текст';

  @override
  String get documentAvailableValue => 'Доступен';

  @override
  String get documentNotAvailableValue => 'Недоступен';

  @override
  String get documentEventCountLabel => 'Предложенные события';

  @override
  String documentEventCountValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count событий',
      one: '1 событие',
      zero: 'Нет событий',
    );
    return '$_temp0';
  }

  @override
  String get documentCreatedAtLabel => 'Создан';

  @override
  String get documentUpdatedAtLabel => 'Обновлён';

  @override
  String get documentDetailProcessingNote =>
      'Обработка ещё идёт. Потяните вниз, чтобы обновить статус.';

  @override
  String get documentDetailPrivacyNote =>
      'Оригинал документа остаётся в песочнице приложения. Бэкенд обрабатывает загруженные байты временно и возвращает только метаданные и предложенные события.';

  @override
  String get documentExplanationTitle => 'Объяснение простым языком';

  @override
  String get documentExplanationSummaryTitle => 'Кратко';

  @override
  String get documentExplanationKeyPointsTitle => 'Ключевые моменты';

  @override
  String get documentExplanationGlossaryTitle => 'Словарь';

  @override
  String get documentExplanationLoading => 'Загружаем объяснение...';

  @override
  String get documentExplanationNotReadyMessage =>
      'Объяснение ещё не готово. MedStory может создать версию простым языком из извлечённого текста.';

  @override
  String get documentExplanationBoundaryNote =>
      'Это объяснение помогает понять документ. Оно не ставит диагнозы и не рекомендует лечение.';

  @override
  String get documentExplanationGenerateAction => 'Создать объяснение';

  @override
  String get documentExplanationRegenerateAction => 'Создать заново';

  @override
  String get documentExplanationQueuedAction => 'В очереди';

  @override
  String get documentExplanationRetryAction => 'Попробовать снова';

  @override
  String get documentExplanationQueuedMessage =>
      'Создание объяснения началось. Потяните документ вниз для обновления через несколько секунд.';

  @override
  String get documentExplanationLoadFailed =>
      'Не удалось загрузить объяснение. Проверьте подключение и попробуйте снова.';

  @override
  String get documentExplanationRegenerateFailed =>
      'Не удалось начать создание объяснения. Проверьте подключение и попробуйте снова.';

  @override
  String documentExplanationGeneratedAt(String date) {
    return 'Создано: $date';
  }

  @override
  String get documentDeleteAction => 'Удалить документ';

  @override
  String get documentDeleteConfirmTitle => 'Удалить этот документ?';

  @override
  String get documentDeleteConfirmMessage =>
      'Связанные события также могут исчезнуть из хронологии.';

  @override
  String get documentOpenTimelineAction => 'Открыть хронологию';

  @override
  String get documentStatusPending => 'Ожидает';

  @override
  String get documentStatusProcessing => 'Обрабатывается';

  @override
  String get documentStatusProcessed => 'Обработан';

  @override
  String get documentStatusFailed => 'Ошибка';

  @override
  String get documentTypeMedicalRecord => 'Медицинская запись';

  @override
  String get documentTypeLabResult => 'Лабораторный результат';

  @override
  String get documentTypeReport => 'Отчёт';

  @override
  String get documentTypePrescription => 'Рецепт';

  @override
  String get documentTypeProcedureSummary => 'Сводка процедуры';

  @override
  String get documentTypeNote => 'Заметка';

  @override
  String get documentTypeImage => 'Изображение';

  @override
  String get documentTypeAudio => 'Аудио';

  @override
  String get documentTypeOther => 'Другое';

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
  String get eventConfirmAction => 'Подтвердить событие';

  @override
  String get eventConfirmedMessage => 'Событие подтверждено.';

  @override
  String get eventAiSuggestedNote =>
      'ИИ предложил это событие из документа. Проверьте его, прежде чем полагаться на него.';

  @override
  String get eventAiConfirmedNote =>
      'Вы подтвердили это событие, предложенное ИИ.';

  @override
  String get eventResultTitle => 'Результат';

  @override
  String get eventNotesTitle => 'Заметки';

  @override
  String get eventStructuredDetailsTitle => 'Детали';

  @override
  String eventConfidenceValue(String value) {
    return 'Уверенность извлечения: $value';
  }

  @override
  String get eventOpenSourceDocumentAction => 'Открыть исходный документ';

  @override
  String get eventDetailsEmptyDescription => 'Описание не добавлено.';

  @override
  String get eventNetworkRequired =>
      'Для сохранения изменений нужно подключение к MedStory.';
}
