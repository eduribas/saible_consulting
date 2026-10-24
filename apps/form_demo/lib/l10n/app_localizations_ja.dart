// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '登録デモ';

  @override
  String get privacyNotice => 'プライバシーに関するお知らせ：これはデモアプリです。ここに入力された情報は、保存、送信、共有されません。';

  @override
  String get dateOfBirthErrorRequired => '生年月日は必須です。';

  @override
  String get dateOfBirthErrorInvalid => '有効な生年月日を入力してください。';

  @override
  String dateOfBirthErrorTooEarly(String min) {
    return '生年月日は$min以降である必要があります（フォームを送信するには18歳以上であることを申告する必要があります）。';
  }

  @override
  String dateOfBirthErrorTooLate(String max) {
    return 'フォームを有効にするには18歳以上であることを申告する必要があります。$max以前の日付を選択してください。';
  }

  @override
  String get dateOfBirthLabel => '生年月日';

  @override
  String get nationalityErrorRequired => '国籍は必須です。';

  @override
  String get nationalityLabel => '国籍';

  @override
  String get countryOfResidenceErrorRequired => '居住国は必須です。';

  @override
  String get countryOfResidenceLabel => '居住国';

  @override
  String get phoneNumberErrorRequired => '電話番号は必須です。';

  @override
  String get phoneNumberErrorInvalid => '有効な電話番号を入力してください。';

  @override
  String get phoneNumberLabel => '電話番号';

  @override
  String get submitButton => 'デモフォームを送信';

  @override
  String get formValidated => 'フォームが検証されました！';

  @override
  String get dateOfBirthPrefix => '生年月日';

  @override
  String get nationalityPrefix => '国籍';

  @override
  String get countryOfResidencePrefix => '居住国';

  @override
  String get phonePrefix => '電話';

  @override
  String get languageMenuTooltip => '言語';
}
