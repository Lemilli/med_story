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
  String get navTimeline => 'Моя история';

  @override
  String get navCapture => 'Добавить';

  @override
  String get navSummary => 'К визиту';

  @override
  String get navSettings => 'Настройки';

  @override
  String get timelineTitle => 'Хронология';

  @override
  String get timelineMessage => 'Здесь появится ваша медицинская история.';

  @override
  String get summaryTitle => 'Сводка';

  @override
  String get summaryMessage => 'Здесь будут сводки для врача и экспорт данных.';

  @override
  String get summaryHeadline => 'Подготовка к визиту';

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
  String get summaryNotReadyTitle => 'Сводки пока нет';

  @override
  String get summaryNotReadyMessage =>
      'Создайте сводку для врача из событий хронологии, когда нужно подготовиться к визиту.';

  @override
  String get summaryNarrativeTitle => 'Самое важное';

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
      other: '$count событий',
      one: '1 событие',
      zero: 'Нет событий',
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
  String get summaryAiOrganizedNote =>
      'ИИ упорядочил ваши сохранённые медицинские события. Откройте источник, чтобы проверить детали.';

  @override
  String get summarySourceAction => 'Открыть событие-источник';

  @override
  String get summarySourcesTitle => 'Источники';

  @override
  String get summaryVisitReasonLabel => 'Причина визита';

  @override
  String get summaryVisitReasonEmpty =>
      'Добавьте причину, чтобы уточнить сводку';

  @override
  String get summaryVisitReasonEdit => 'Изменить причину визита';

  @override
  String get summaryVisitReasonHint => 'Например: постоянная боль в животе';

  @override
  String get summaryVisitReasonSaveFailed =>
      'Не удалось сохранить причину визита. Проверьте соединение и попробуйте снова.';

  @override
  String get summarySectionCurrentConcerns => 'Текущие жалобы';

  @override
  String get summarySectionImportantDiagnosesAndFindings =>
      'Важные диагнозы и результаты';

  @override
  String get summarySectionCurrentMedications => 'Текущие лекарства';

  @override
  String get summarySectionImportantTestResults => 'Важные результаты анализов';

  @override
  String get summarySectionPreviousTreatmentsAndOutcomes =>
      'Предыдущее лечение и результаты';

  @override
  String get summarySectionProceduresAndHospitalizations =>
      'Процедуры и госпитализации';

  @override
  String get summarySectionKeySymptoms => 'Ключевые симптомы';

  @override
  String get summarySectionMajorDiagnoses => 'Основные диагнозы';

  @override
  String get summarySectionTreatmentHistory => 'Лечение и результаты';

  @override
  String get summarySectionImportantExaminations =>
      'Важные обследования и результаты';

  @override
  String get summarySectionRelevantMedications => 'Значимые лекарства';

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
  String get settingsAccountSectionTitle => 'Аккаунт';

  @override
  String get settingsPrivacySectionTitle => 'Конфиденциальность';

  @override
  String get settingsDataSectionTitle => 'Конфиденциальность и данные';

  @override
  String get settingsPreferencesSectionTitle => 'Предпочтения';

  @override
  String get settingsLanguageSectionTitle => 'Язык';

  @override
  String get settingsActionsSectionTitle => 'Действия с аккаунтом';

  @override
  String get settingsPrivacyNoteTitle => 'Как хранятся оригиналы';

  @override
  String get settingsPrivacySummary => 'Хранение и обработка ваших данных';

  @override
  String get settingsPrivacyNoteDescription =>
      'PDF и изображения шифруются до помещения в закрытое серверное хранилище и доступны онлайн на устройствах, где вы вошли в аккаунт. Для обработки MedStory передаёт настроенным ИИ-провайдерам только необходимые данные. Резервной копии оригиналов нет: сбой сервера или диска может привести к их безвозвратной потере. При выходе очищаются локальные кэши и временные файлы.';

  @override
  String get settingsLanguageEnglish => 'Английский';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsLocaleUpdatedMessage => 'Язык обновлён.';

  @override
  String get settingsLocaleUpdateFailedMessage =>
      'Не удалось обновить язык. Проверьте соединение и попробуйте снова.';

  @override
  String get settingsDeleteAccountTitle => 'Удалить аккаунт';

  @override
  String get settingsDeleteAccountDescription =>
      'Навсегда удалить аккаунт MedStory, оригиналы и записи на сервере.';

  @override
  String get settingsDeleteAccountAction => 'Удалить аккаунт';

  @override
  String get settingsDeleteAccountDialogTitle => 'Удалить аккаунт?';

  @override
  String get settingsDeleteAccountDialogMessage =>
      'Это навсегда удалит аккаунт, сохранённые оригиналы и записи на сервере. Отменить удаление нельзя.';

  @override
  String get settingsDeleteAccountConfirmLabel =>
      'Введите DELETE для подтверждения';

  @override
  String get settingsDeleteAccountConfirmValue => 'DELETE';

  @override
  String get settingsDeleteAccountCancelAction => 'Отмена';

  @override
  String get settingsDeleteAccountConfirmAction => 'Удалить навсегда';

  @override
  String get settingsDeleteAccountFailedMessage =>
      'Не удалось удалить аккаунт. Проверьте соединение и попробуйте снова.';

  @override
  String get settingsLogoutDescription =>
      'Выйти на этом устройстве и очистить локальный кэш медицинских данных.';

  @override
  String get settingsOrganizerNoticeTitle => 'Органайзер, не врач';

  @override
  String get settingsOrganizerNoticeDescription =>
      'MedStory помогает упорядочивать и объяснять записи. Он не ставит диагнозы, не рекомендует лечение и не заменяет врача.';

  @override
  String get settingsUsageSectionTitle => 'Лимиты';

  @override
  String get settingsLimitsTitle => 'Лимиты';

  @override
  String get settingsLimitsSummary => 'Использование ИИ и хранилища';

  @override
  String get settingsLimitsLoading => 'Проверяем текущее использование';

  @override
  String get settingsUsageLoadFailedMessage =>
      'Не удалось загрузить текущие лимиты.';

  @override
  String get settingsAiUnitsLabel => 'Осталось использований ИИ сегодня';

  @override
  String settingsAiUnitsValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count использования',
      many: '$count использований',
      few: '$count использования',
      one: '1 использование',
      zero: 'Не осталось',
    );
    return '$_temp0';
  }

  @override
  String get settingsStorageUsageLabel => 'Хранилище оригиналов';

  @override
  String settingsStorageUsageValue(int used, int limit) {
    return 'Использовано $used МБ из $limit МБ';
  }

  @override
  String get settingsUsageUnavailable => 'Недоступно';

  @override
  String get captureHeadline => 'Добавить в историю';

  @override
  String get captureSubtitle =>
      'Выберите, как добавить информацию. Перед добавлением в историю её можно проверить.';

  @override
  String get capturePrivacyNotice =>
      'Только для вас. Вы проверяете предложения перед добавлением в историю. MedStory организует вашу информацию, но не ставит диагнозы.';

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
      'Запишите короткую голосовую заметку, проверьте её и отправьте для предложенных событий хронологии.';

  @override
  String get voiceNoteTitle => 'Голосовая заметка';

  @override
  String get voiceNoteCaptureLabel => 'Голосовая заметка';

  @override
  String get medicalPhotoCaptureLabel => 'Медицинское фото';

  @override
  String get voicePermissionRequesting => 'Проверяем доступ к микрофону';

  @override
  String get voicePermissionRequestingDescription =>
      'Запись хранится временно. После успешной расшифровки она удаляется, а при ошибке остаётся локально для повтора.';

  @override
  String get voiceRecordingInProgress => 'Идёт запись';

  @override
  String voiceRecordingDuration(String duration) {
    return 'Длительность: $duration';
  }

  @override
  String get voiceStopAction => 'Остановить';

  @override
  String get voiceDiscardAction => 'Удалить';

  @override
  String get voiceReviewTitle => 'Проверить голосовую заметку';

  @override
  String voiceRecordedMetadata(String duration, String size) {
    return '$duration • $size';
  }

  @override
  String get voiceRecordAgainAction => 'Записать заново';

  @override
  String get voiceUploadAction => 'Загрузить голосовую заметку';

  @override
  String get voiceRecordingMaxDurationMessage =>
      'Запись остановлена на 4 минутах, чтобы файл оставался небольшим.';

  @override
  String get voiceFileTooLargeMessage =>
      'Запишите более короткую заметку. Аудио должно быть не больше 5 МБ.';

  @override
  String get voicePermissionDeniedMessage =>
      'Для голосовой заметки нужен доступ к микрофону. Вы всё ещё можете добавить документы или события вручную.';

  @override
  String get voiceRecordingMissingMessage =>
      'MedStory не удалось найти запись на этом устройстве.';

  @override
  String get voiceRecordingFailedMessage =>
      'Не удалось записать голосовую заметку. Попробуйте ещё раз или добавьте документ.';

  @override
  String get scanDocumentTitle => 'Сканировать документ';

  @override
  String get scanDocumentDescription =>
      'Используйте камеру для записей, отчётов, рецептов или писем.';

  @override
  String get scanDocumentSemanticHint =>
      'Открывает камеру для медицинского документа.';

  @override
  String get writeNoteTitle => 'Написать заметку';

  @override
  String get writeNoteDescription =>
      'Введите или продиктуйте мысли, симптомы или детали, которые помните.';

  @override
  String get writeNoteSemanticHint =>
      'Открывает заметку, в которую можно писать или диктовать.';

  @override
  String get addPhotoTitle => 'Добавить фото';

  @override
  String get addPhotoDescription =>
      'Выберите изображение документа из фотогалереи.';

  @override
  String get addPhotoSemanticHint =>
      'Открывает галерею для выбора изображения документа.';

  @override
  String get chooseFileTitle => 'Выбрать файл';

  @override
  String get chooseFileDescription =>
      'Выберите PDF или изображение из файлов на устройстве, до 25 МБ.';

  @override
  String get chooseFileSemanticHint =>
      'Открывает файлы на устройстве для выбора PDF или изображения.';

  @override
  String get documentSelectionEmpty =>
      'Выберите фото с камеры, изображение из галереи или PDF/изображение. MedStory сразу начнёт обработку.';

  @override
  String get documentProcessingTitle => 'Обработка файла';

  @override
  String get documentProcessingBackgroundMessage =>
      'Статус обработки показан на вкладке «Добавить».';

  @override
  String get documentProcessingDoneAction => 'Готово';

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
      'Извлекаем текст и предложенные события.';

  @override
  String get documentUploadProcessed =>
      'Обработка завершена. Можно посмотреть результат.';

  @override
  String get documentUploadFailedMessage =>
      'Не удалось обработать документ. Проверьте файл и попробуйте снова.';

  @override
  String get documentNotMedicalMessage =>
      'Похоже, это не медицинский документ.';

  @override
  String get documentUnreadableMessage =>
      'Не удалось прочитать документ. Попробуйте более чёткое фото или файл.';

  @override
  String get audioNotMedicalMessage =>
      'Похоже, в этой голосовой заметке нет медицинской информации.';

  @override
  String get audioUnreadableMessage =>
      'Мы не смогли распознать эту запись. Попробуйте записать заметку ещё раз.';

  @override
  String get medicalEventsNotFoundMessage =>
      'Мы не нашли медицинскую информацию, которую можно добавить в вашу историю.';

  @override
  String get documentFileTooLargeMessage =>
      'Общий размер файлов должен быть не больше 25 МБ.';

  @override
  String get documentUnsupportedFileMessage =>
      'На этапе 2 поддерживаются только PDF и изображения.';

  @override
  String get uploadQueueTitle => 'Обработка загрузок';

  @override
  String get uploadQueueUploading => 'Загрузка';

  @override
  String uploadQueueUploadingProgress(int progress) {
    return 'Загрузка: $progress%';
  }

  @override
  String get uploadQueueProcessing => 'Обработка';

  @override
  String get uploadQueueCompleted => 'Готово';

  @override
  String get uploadQueueFailed => 'Не удалось завершить — повторите';

  @override
  String get uploadQueueDuplicateMessage =>
      'Этот файл уже загружается или обрабатывается.';

  @override
  String get documentAlreadyProcessedMessage =>
      'Этот документ уже обработан и добавлен в вашу историю.';

  @override
  String get documentAlreadyProcessedAction => 'Открыть существующий документ';

  @override
  String get uploadQueuePhotoLabel => 'Загрузка фото';

  @override
  String get uploadQueueFileLabel => 'Загрузка файла';

  @override
  String get uploadQueueDismissAction => 'Скрыть';

  @override
  String get uploadQueueOpenResultHint => 'Открыть результат загрузки';

  @override
  String get documentProcessingFailedMessage =>
      'Обработка не удалась. Зашифрованный оригинал остаётся на сервере: обработку можно повторить или удалить документ.';

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
  String get documentLocalOnlyValue => 'Временный локальный источник';

  @override
  String get documentRemoteStorageValue => 'Зашифрованное закрытое хранилище';

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
      'Зашифрованный оригинал хранится в закрытом серверном хранилище. Для открытия или отправки нужно войти в аккаунт и быть онлайн; автоматической офлайн-копии нет.';

  @override
  String get documentDeleteAction => 'Удалить документ';

  @override
  String get documentDeleteConfirmTitle => 'Удалить этот документ?';

  @override
  String get documentDeleteConfirmMessage =>
      'Сохранённый оригинал будет удалён, а созданные из него события скрыты. Удаление только события хронологии не удаляет документ.';

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
      'Личное пространство для вашей медицинской истории.';

  @override
  String get authBoundarySemanticLabel =>
      'MedStory — органайзер, а не диагностический инструмент.';

  @override
  String get authBoundaryNote =>
      'MedStory упорядочивает и объясняет ваши записи. Он не ставит диагнозы и не рекомендует лечение.';

  @override
  String get authAccountDetailsSemanticLabel => 'Данные аккаунта';

  @override
  String get authFullNameLabel => 'Полное имя';

  @override
  String get authOptionalLabel => 'Необязательно';

  @override
  String get authFullNameHint => 'Ваше имя';

  @override
  String get authFullNameHelper =>
      'Необязательно · Используется только для персонализации аккаунта.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPasswordLabel => 'Пароль';

  @override
  String get authPasswordHint => 'Придумайте пароль';

  @override
  String get authPasswordHelper => 'Минимум 8 символов.';

  @override
  String get authShowPasswordAction => 'Показать пароль';

  @override
  String get authHidePasswordAction => 'Скрыть пароль';

  @override
  String get authEmailValidation => 'Введите корректный email.';

  @override
  String get authPasswordValidation => 'Используйте минимум 8 символов.';

  @override
  String get authCreateAccountAction => 'Создать аккаунт';

  @override
  String get authCreatingAccountAction => 'Создаём аккаунт…';

  @override
  String get authTryAgainAction => 'Попробовать снова';

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
  String get authDemoCapacityReachedMessage =>
      'Сейчас в демоверсии нет свободных мест. Попробуйте позже.';

  @override
  String get authPrivacyAiTitle => 'Конфиденциальность и ИИ';

  @override
  String get authPrivacyAiIntro =>
      'Ознакомьтесь с тем, как MedStory защищает ваши записи и использует ИИ как основную часть сервиса.';

  @override
  String get authRequiredLabel => 'ОБЯЗАТЕЛЬНО';

  @override
  String get authPrivacyConsentTitle =>
      'Я принимаю уведомление о конфиденциальности';

  @override
  String get authPrivacyConsentDescription =>
      'Необходимо для создания и защиты аккаунта.';

  @override
  String get authPrivacyConsentValidation =>
      'Примите уведомление о конфиденциальности, чтобы создать аккаунт.';

  @override
  String get authPrivacyDetailsShowAction => 'Прочитать уведомление';

  @override
  String get authPrivacyDetailsHideAction => 'Скрыть уведомление';

  @override
  String get authPrivacyDetailsTitle =>
      'Уведомление о конфиденциальности · 6 августа 2026 г.';

  @override
  String get authPrivacyDetailsMessage =>
      'Ваши медицинские записи конфиденциальны. Упорядочивание и пояснение с помощью ИИ — основные функции MedStory. Сервис передаёт настроенному ИИ-провайдеру только данные, необходимые для этих функций, и не использует ИИ для постановки диагнозов или рекомендаций по лечению.';

  @override
  String get authPrivacyDetailsSecondaryMessage =>
      'Вы решаете, что добавлять, и можете запросить доступ к своей информации или её удаление. Принятие этого уведомления обязательно для использования MedStory, поскольку обработку с помощью ИИ нельзя отключить.';

  @override
  String get authForgotPasswordAction => 'Забыли пароль?';

  @override
  String get authVerifyTitle => 'Проверьте почту';

  @override
  String authVerifySubtitle(String email) {
    return 'Введите шестизначный код, отправленный на $email. Он действует 15 минут.';
  }

  @override
  String get authVerificationCodeLabel => 'Код подтверждения';

  @override
  String get authVerificationCodeHelper => 'Шесть цифр';

  @override
  String get authVerificationCodeValidation => 'Введите шестизначный код.';

  @override
  String get authVerifyAction => 'Подтвердить email';

  @override
  String get authResendCodeAction => 'Отправить новый код';

  @override
  String get authResendingCode => 'Отправляем код…';

  @override
  String get authCodeResentMessage =>
      'Новый код отправлен. Подойдёт только самый новый код.';

  @override
  String get authVerificationInvalidMessage =>
      'Код неверен или истёк. Проверьте его или запросите новый.';

  @override
  String get authTooManyAttemptsMessage =>
      'Слишком много попыток. Подождите и попробуйте позже.';

  @override
  String get authBackToLoginAction => 'Вернуться ко входу';

  @override
  String get authResetPasswordTitle => 'Сброс пароля';

  @override
  String get authResetPasswordSubtitle =>
      'Введите email аккаунта. Если аккаунт существует, мы отправим шестизначный код сброса.';

  @override
  String authResetCodeSubtitle(String email) {
    return 'Введите код, отправленный на $email, затем придумайте новый пароль.';
  }

  @override
  String get authSendResetCodeAction => 'Отправить код сброса';

  @override
  String get authNewPasswordLabel => 'Новый пароль';

  @override
  String get authResetPasswordAction => 'Установить новый пароль';

  @override
  String get authResetCompleteTitle => 'Пароль обновлён';

  @override
  String get authResetCompleteMessage =>
      'Теперь вы можете войти с новым паролем.';

  @override
  String get authResetFailedMessage =>
      'Не удалось сбросить пароль. Проверьте код и попробуйте снова.';

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
  String get photoGroupingTitle => 'Как добавить эти фотографии?';

  @override
  String photoGroupingDescription(int count) {
    return 'Вы выбрали $count фото. Укажите, как они связаны в MedStory.';
  }

  @override
  String get photoGroupingOneTitle => 'Один документ';

  @override
  String get photoGroupingOneDescription => 'Это страницы одного документа.';

  @override
  String get photoGroupingSeparateTitle => 'Отдельные документы';

  @override
  String get photoGroupingSeparateDescription =>
      'Каждое фото должно создать отдельное событие.';

  @override
  String get photoGroupingContinueAction => 'Продолжить';

  @override
  String get documentPagesReviewTitle => 'Проверьте страницы документа';

  @override
  String documentPagesCount(int count) {
    return 'Страниц: $count';
  }

  @override
  String documentPageLabel(int number) {
    return 'Страница $number';
  }

  @override
  String get documentPageReorderHint =>
      'Удерживайте и перетащите, чтобы изменить порядок';

  @override
  String get documentPageRemoveAction => 'Удалить страницу';

  @override
  String get documentPageAddAction => 'Добавить страницу';

  @override
  String get documentPagesProcessAction => 'Обработать как один документ';

  @override
  String eventViewOriginalPagesAction(int count) {
    return 'Открыть исходные страницы: $count';
  }

  @override
  String get eventViewOriginalAction => 'Открыть оригинал';

  @override
  String eventOriginalPageIndicator(int current, int total) {
    return 'Страница $current из $total';
  }

  @override
  String get eventPreviousOriginalPage => 'Предыдущая страница';

  @override
  String get eventNextOriginalPage => 'Следующая страница';

  @override
  String get eventOriginalUnavailable =>
      'Оригинал недоступен. Проверьте соединение или попробуйте снова.';

  @override
  String get eventOriginalLocalOnly =>
      'Оригиналы загружаются из зашифрованного закрытого серверного хранилища и не кэшируются для офлайн-доступа. При скачивании или отправке создаётся копия под вашим контролем.';

  @override
  String get eventRevisionCompareTitle => 'Сравнить предложенные изменения';

  @override
  String get eventRevisionSafetyNote =>
      'Изменённое вами событие не поменяется, пока вы не примените изменения.';

  @override
  String get eventRevisionCurrent => 'Текущее событие';

  @override
  String get eventRevisionSuggested => 'Предложенная версия';

  @override
  String get eventRevisionApply => 'Применить выбранные изменения';

  @override
  String get eventRevisionKeep => 'Оставить текущее событие';

  @override
  String get eventRevisionRegenerateAction => 'Создать новое предложение';

  @override
  String get eventOriginalShareAction => 'Скачать или поделиться оригиналом';

  @override
  String get documentSingleEventValue => 'Одно событие в хронологии';

  @override
  String get documentNoEventValue => 'Событие не создано';

  @override
  String get timelineHeadline => 'MedStory';

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
  String get timelineApplyFiltersAction => 'Показать результаты';

  @override
  String get timelineClearFiltersAction => 'Сбросить все фильтры';

  @override
  String get timelineClearSearchAction => 'Очистить поиск';

  @override
  String get timelineFiltersActive => 'Фильтры применены';

  @override
  String get timelineAllTypes => 'Все типы';

  @override
  String get timelineAllYears => 'Все годы';

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
  String get eventTypeMedicalRecord => 'Медицинская запись';

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
  String get eventAiSuggestedNote =>
      'ИИ извлёк это событие из документа. При необходимости его можно изменить.';

  @override
  String get eventOriginalSourceTitle => 'Исходная заметка';

  @override
  String get eventOriginalTranscriptTitle => 'Исходная расшифровка';

  @override
  String get eventAiAnalysisTitle => 'Анализ ИИ';

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

  @override
  String get visitPrepTitle => 'Подготовка к визиту';

  @override
  String get visitPrepHint => 'Причина этого визита';

  @override
  String get visitPrepSave => 'Сохранить';

  @override
  String get visitPrepExport => 'Экспортировать сводку к визиту';

  @override
  String get visitPrepSaved => 'Причина визита сохранена.';

  @override
  String get onboardingTitle => 'Ваша медицинская история — в одном месте';

  @override
  String get onboardingBody =>
      'MedStory помогает организовать и понять ваши записи. Он не ставит диагнозы и не рекомендует лечение.';

  @override
  String get onboardingStart => 'Добавить первую запись';

  @override
  String get onboardingSkip => 'Не сейчас';

  @override
  String get timelineYear => 'Год';
}
