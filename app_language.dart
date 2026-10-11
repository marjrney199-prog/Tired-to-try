class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.ttsLocale,
    this.flag = '🌐',
  });

  final String code;
  final String name;
  final String nativeName;
  final String ttsLocale;
  final String flag;
}
