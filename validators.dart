class FormValidators {
  FormValidators._();

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 2) return 'Introduza o seu nome (mínimo de 2 caracteres).';
    if (text.length > 70) return 'O nome não pode exceder 70 caracteres.';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
    if (!pattern.hasMatch(text)) return 'Introduza um endereço de e-mail válido.';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.length < 8) return 'Use pelo menos 8 caracteres.';
    if (text.length > 128) return 'A palavra-passe é demasiado longa.';
    return null;
  }

  static String? requiredText(String? value, {String label = 'Este campo'}) {
    if ((value ?? '').trim().isEmpty) return '$label é obrigatório.';
    return null;
  }
}
