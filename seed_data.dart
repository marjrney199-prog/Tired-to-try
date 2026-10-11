import '../models/app_language.dart';
import '../models/lesson.dart';
import '../models/lexeme.dart';

class SeedData {
  SeedData._();

  static const languages = <AppLanguage>[
    AppLanguage(code: 'en', name: 'Inglês', nativeName: 'English', ttsLocale: 'en-US', flag: '🇬🇧'),
    AppLanguage(code: 'pt', name: 'Português', nativeName: 'Português', ttsLocale: 'pt-PT', flag: '🇲🇿'),
    AppLanguage(code: 'fr', name: 'Francês', nativeName: 'Français', ttsLocale: 'fr-FR', flag: '🇫🇷'),
    AppLanguage(code: 'es', name: 'Espanhol', nativeName: 'Español', ttsLocale: 'es-ES', flag: '🇪🇸'),
    AppLanguage(code: 'de', name: 'Alemão', nativeName: 'Deutsch', ttsLocale: 'de-DE', flag: '🇩🇪'),
    AppLanguage(code: 'it', name: 'Italiano', nativeName: 'Italiano', ttsLocale: 'it-IT', flag: '🇮🇹'),
    AppLanguage(code: 'ar', name: 'Árabe', nativeName: 'العربية', ttsLocale: 'ar-SA', flag: '🇸🇦'),
    AppLanguage(code: 'zh', name: 'Chinês', nativeName: '中文', ttsLocale: 'zh-CN', flag: '🇨🇳'),
    AppLanguage(code: 'sw', name: 'Suaíli', nativeName: 'Kiswahili', ttsLocale: 'sw-KE', flag: '🇹🇿'),
  ];

  static const levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  static const levelTopics = <String, List<String>>{
    'A1': ['Saudações e apresentação', 'Palavras essenciais', 'Frases do quotidiano'],
    'A2': ['Rotina e horários', 'Pedir informações', 'Compras e serviços'],
    'B1': ['Conversas e opiniões', 'Viagens e experiências', 'Estudo e trabalho'],
    'B2': ['Comunicação profissional', 'Argumentação e debate', 'Expressões e contexto'],
    'C1': ['Nuance e precisão', 'Registos formais', 'Compreensão avançada'],
    'C2': ['Fluência e estilo', 'Expressões idiomáticas', 'Domínio da língua'],
  };

  /// Vocabulário e frases guardados no próprio dispositivo. Não é um motor de
  /// tradução automática: termos fora deste conjunto são assinalados na UI.
  static const lexemes = <Lexeme>[
    Lexeme(
      id: 'hello',
      forms: {'en': 'hello', 'pt': 'olá', 'fr': 'bonjour', 'es': 'hola', 'de': 'hallo', 'it': 'ciao', 'ar': 'مرحبا', 'zh': '你好', 'sw': 'jambo'},
      definition: 'Expressão usada para cumprimentar alguém.',
      partOfSpeech: 'interjeição',
      example: 'Hello, Maria! · Olá, Maria!',
      pronunciations: {'en': '/həˈləʊ/', 'pt': 'o-lá', 'fr': 'bõ-jur', 'es': 'ô-la'},
      synonyms: ['hi', 'hey'],
      antonyms: ['goodbye'],
    ),
    Lexeme(
      id: 'good_morning',
      forms: {'en': 'good morning', 'pt': 'bom dia', 'fr': 'bonjour', 'es': 'buenos días', 'de': 'guten Morgen', 'it': 'buongiorno', 'ar': 'صباح الخير', 'zh': '早上好', 'sw': 'habari za asubuhi'},
      definition: 'Cumprimento usado durante a manhã.',
      partOfSpeech: 'locução',
      example: 'Good morning, everyone. · Bom dia a todos.',
      synonyms: ['morning'],
    ),
    Lexeme(
      id: 'goodbye',
      forms: {'en': 'goodbye', 'pt': 'adeus', 'fr': 'au revoir', 'es': 'adiós', 'de': 'auf Wiedersehen', 'it': 'arrivederci', 'ar': 'مع السلامة', 'zh': '再见', 'sw': 'kwaheri'},
      definition: 'Expressão usada ao despedir-se.',
      partOfSpeech: 'interjeição',
      example: 'Goodbye, see you tomorrow. · Adeus, até amanhã.',
      synonyms: ['farewell', 'bye'],
      antonyms: ['hello'],
    ),
    Lexeme(
      id: 'thank_you',
      forms: {'en': 'thank you', 'pt': 'obrigado', 'fr': 'merci', 'es': 'gracias', 'de': 'danke', 'it': 'grazie', 'ar': 'شكرا', 'zh': '谢谢', 'sw': 'asante'},
      definition: 'Fórmula educada para expressar gratidão.',
      partOfSpeech: 'locução',
      example: 'Thank you for your help. · Obrigado pela sua ajuda.',
      synonyms: ['thanks', 'many thanks'],
    ),
    Lexeme(
      id: 'please',
      forms: {'en': 'please', 'pt': 'por favor', 'fr': 's’il vous plaît', 'es': 'por favor', 'de': 'bitte', 'it': 'per favore', 'ar': 'من فضلك', 'zh': '请', 'sw': 'tafadhali'},
      definition: 'Palavra usada para fazer um pedido com cortesia.',
      partOfSpeech: 'advérbio',
      example: 'A glass of water, please. · Um copo de água, por favor.',
      synonyms: ['kindly'],
    ),
    Lexeme(
      id: 'yes',
      forms: {'en': 'yes', 'pt': 'sim', 'fr': 'oui', 'es': 'sí', 'de': 'ja', 'it': 'sì', 'ar': 'نعم', 'zh': '是', 'sw': 'ndiyo'},
      definition: 'Resposta afirmativa.',
      partOfSpeech: 'advérbio',
      example: 'Yes, I understand. · Sim, compreendo.',
      synonyms: ['certainly'],
      antonyms: ['no'],
    ),
    Lexeme(
      id: 'no',
      forms: {'en': 'no', 'pt': 'não', 'fr': 'non', 'es': 'no', 'de': 'nein', 'it': 'no', 'ar': 'لا', 'zh': '不', 'sw': 'hapana'},
      definition: 'Resposta negativa.',
      partOfSpeech: 'advérbio',
      example: 'No, thank you. · Não, obrigado.',
      synonyms: ['not'],
      antonyms: ['yes'],
    ),
    Lexeme(
      id: 'how_are_you',
      forms: {'en': 'how are you?', 'pt': 'como está?', 'fr': 'comment allez-vous ?', 'es': '¿cómo está?', 'de': 'wie geht es Ihnen?', 'it': 'come sta?', 'ar': 'كيف حالك؟', 'zh': '你好吗？', 'sw': 'habari yako?'},
      definition: 'Pergunta usada para saber como alguém está.',
      partOfSpeech: 'expressão',
      example: 'Hello! How are you? · Olá! Como está?',
    ),
    Lexeme(
      id: 'help',
      forms: {'en': 'help', 'pt': 'ajuda', 'fr': 'aide', 'es': 'ayuda', 'de': 'Hilfe', 'it': 'aiuto', 'ar': 'مساعدة', 'zh': '帮助', 'sw': 'msaada'},
      definition: 'Apoio dado a alguém que precisa de assistência.',
      partOfSpeech: 'substantivo',
      example: 'I need help. · Preciso de ajuda.',
      synonyms: ['assistance', 'support'],
    ),
    Lexeme(
      id: 'water',
      forms: {'en': 'water', 'pt': 'água', 'fr': 'eau', 'es': 'agua', 'de': 'Wasser', 'it': 'acqua', 'ar': 'ماء', 'zh': '水', 'sw': 'maji'},
      definition: 'Líquido transparente essencial à vida.',
      partOfSpeech: 'substantivo',
      example: 'I would like some water. · Gostaria de água.',
    ),
    Lexeme(
      id: 'food',
      forms: {'en': 'food', 'pt': 'comida', 'fr': 'nourriture', 'es': 'comida', 'de': 'Essen', 'it': 'cibo', 'ar': 'طعام', 'zh': '食物', 'sw': 'chakula'},
      definition: 'Aquilo que se come para se alimentar.',
      partOfSpeech: 'substantivo',
      example: 'The food is delicious. · A comida está deliciosa.',
      synonyms: ['meal', 'nourishment'],
    ),
    Lexeme(
      id: 'book',
      forms: {'en': 'book', 'pt': 'livro', 'fr': 'livre', 'es': 'libro', 'de': 'Buch', 'it': 'libro', 'ar': 'كتاب', 'zh': '书', 'sw': 'kitabu'},
      definition: 'Conjunto de páginas com texto ou imagens, encadernadas.',
      partOfSpeech: 'substantivo',
      example: 'This is my book. · Este é o meu livro.',
    ),
    Lexeme(
      id: 'school',
      forms: {'en': 'school', 'pt': 'escola', 'fr': 'école', 'es': 'escuela', 'de': 'Schule', 'it': 'scuola', 'ar': 'مدرسة', 'zh': '学校', 'sw': 'shule'},
      definition: 'Instituição onde se ensina e se aprende.',
      partOfSpeech: 'substantivo',
      example: 'The school is near my house. · A escola fica perto da minha casa.',
    ),
    Lexeme(
      id: 'friend',
      forms: {'en': 'friend', 'pt': 'amigo', 'fr': 'ami', 'es': 'amigo', 'de': 'Freund', 'it': 'amico', 'ar': 'صديق', 'zh': '朋友', 'sw': 'rafiki'},
      definition: 'Pessoa com quem se mantém uma relação de amizade.',
      partOfSpeech: 'substantivo',
      example: 'My friend lives in Maputo. · O meu amigo vive em Maputo.',
      synonyms: ['companion'],
      antonyms: ['enemy'],
    ),
    Lexeme(
      id: 'house',
      forms: {'en': 'house', 'pt': 'casa', 'fr': 'maison', 'es': 'casa', 'de': 'Haus', 'it': 'casa', 'ar': 'بيت', 'zh': '房子', 'sw': 'nyumba'},
      definition: 'Edifício destinado a servir de habitação.',
      partOfSpeech: 'substantivo',
      example: 'Welcome to my house. · Bem-vindo à minha casa.',
      synonyms: ['home', 'residence'],
    ),
    Lexeme(
      id: 'hospital',
      forms: {'en': 'hospital', 'pt': 'hospital', 'fr': 'hôpital', 'es': 'hospital', 'de': 'Krankenhaus', 'it': 'ospedale', 'ar': 'مستشفى', 'zh': '医院', 'sw': 'hospitali'},
      definition: 'Estabelecimento onde se presta assistência médica.',
      partOfSpeech: 'substantivo',
      example: 'Where is the hospital? · Onde fica o hospital?',
    ),
    Lexeme(
      id: 'hotel',
      forms: {'en': 'hotel', 'pt': 'hotel', 'fr': 'hôtel', 'es': 'hotel', 'de': 'Hotel', 'it': 'hotel', 'ar': 'فندق', 'zh': '酒店', 'sw': 'hoteli'},
      definition: 'Estabelecimento que oferece alojamento temporário.',
      partOfSpeech: 'substantivo',
      example: 'I have a reservation at the hotel. · Tenho uma reserva no hotel.',
    ),
    Lexeme(
      id: 'restaurant',
      forms: {'en': 'restaurant', 'pt': 'restaurante', 'fr': 'restaurant', 'es': 'restaurante', 'de': 'Restaurant', 'it': 'ristorante', 'ar': 'مطعم', 'zh': '餐馆', 'sw': 'mkahawa'},
      definition: 'Estabelecimento onde se servem refeições.',
      partOfSpeech: 'substantivo',
      example: 'The restaurant opens at seven. · O restaurante abre às sete.',
    ),
    Lexeme(
      id: 'airport',
      forms: {'en': 'airport', 'pt': 'aeroporto', 'fr': 'aéroport', 'es': 'aeropuerto', 'de': 'Flughafen', 'it': 'aeroporto', 'ar': 'مطار', 'zh': '机场', 'sw': 'uwanja wa ndege'},
      definition: 'Local preparado para a chegada e partida de aviões.',
      partOfSpeech: 'substantivo',
      example: 'The airport is ten minutes away. · O aeroporto fica a dez minutos.',
    ),
    Lexeme(
      id: 'good',
      forms: {'en': 'good', 'pt': 'bom', 'fr': 'bon', 'es': 'bueno', 'de': 'gut', 'it': 'buono', 'ar': 'جيد', 'zh': '好', 'sw': 'nzuri'},
      definition: 'Que tem qualidade positiva ou é adequado.',
      partOfSpeech: 'adjectivo',
      example: 'Have a good day. · Tenha um bom dia.',
      synonyms: ['great', 'fine'],
      antonyms: ['bad'],
    ),
    Lexeme(
      id: 'please_help_me',
      forms: {'en': 'please help me', 'pt': 'por favor, ajude-me', 'fr': 'aidez-moi, s’il vous plaît', 'es': 'ayúdeme, por favor', 'de': 'bitte helfen Sie mir', 'it': 'mi aiuti, per favore', 'ar': 'الرجاء مساعدتي', 'zh': '请帮帮我', 'sw': 'tafadhali nisaidie'},
      definition: 'Pedido educado para receber assistência.',
      partOfSpeech: 'expressão',
      example: 'Please help me find the station. · Por favor, ajude-me a encontrar a estação.',
    ),
    Lexeme(
      id: 'where_is_the_bathroom',
      forms: {'en': 'where is the bathroom?', 'pt': 'onde fica a casa de banho?', 'fr': 'où sont les toilettes ?', 'es': '¿dónde está el baño?', 'de': 'wo ist die Toilette?', 'it': 'dov’è il bagno?', 'ar': 'أين الحمام؟', 'zh': '洗手间在哪里？', 'sw': 'choo kiko wapi?'},
      definition: 'Pergunta para localizar a casa de banho.',
      partOfSpeech: 'expressão',
      example: 'Excuse me, where is the bathroom? · Com licença, onde fica a casa de banho?',
    ),
    Lexeme(
      id: 'my_name_is',
      forms: {'en': 'my name is', 'pt': 'o meu nome é', 'fr': 'je m’appelle', 'es': 'me llamo', 'de': 'mein Name ist', 'it': 'mi chiamo', 'ar': 'اسمي', 'zh': '我的名字是', 'sw': 'jina langu ni'},
      definition: 'Estrutura usada para dizer o próprio nome.',
      partOfSpeech: 'expressão',
      example: 'My name is Ana. · O meu nome é Ana.',
    ),
    Lexeme(
      id: 'excuse_me',
      forms: {'en': 'excuse me', 'pt': 'com licença', 'fr': 'excusez-moi', 'es': 'disculpe', 'de': 'entschuldigen Sie', 'it': 'mi scusi', 'ar': 'عذرا', 'zh': '打扰一下', 'sw': 'samahani'},
      definition: 'Expressão educada para chamar a atenção ou pedir passagem.',
      partOfSpeech: 'expressão',
      example: 'Excuse me, is this seat free? · Com licença, este lugar está livre?',
      synonyms: ['pardon'],
    ),
    Lexeme(
      id: 'i_need_help',
      forms: {'en': 'I need help', 'pt': 'preciso de ajuda', 'fr': 'j’ai besoin d’aide', 'es': 'necesito ayuda', 'de': 'ich brauche Hilfe', 'it': 'ho bisogno di aiuto', 'ar': 'أحتاج إلى مساعدة', 'zh': '我需要帮助', 'sw': 'ninahitaji msaada'},
      definition: 'Frase usada para comunicar que é necessário receber assistência.',
      partOfSpeech: 'expressão',
      example: 'I need help with this form. · Preciso de ajuda com este formulário.',
    ),
  ];

  static AppLanguage language(String code) => languages.firstWhere(
        (language) => language.code == code,
        orElse: () => languages.first,
      );

  static List<Lesson> lessonsFor(String languageCode, String level) {
    final selectedLanguage = language(languageCode);
    final topics = levelTopics[level] ?? levelTopics['A1']!;
    final rawLevelIndex = levels.indexOf(level);
    final levelIndex = rawLevelIndex < 0 ? 0 : rawLevelIndex;
    return List.generate(3, (lessonIndex) {
      final lexemeIndex = (levelIndex * 3 + lessonIndex) % lexemes.length;
      final term = lexemes[lexemeIndex];
      final answer = term.formFor(languageCode);
      final choices = _choicesFor(languageCode, answer, lexemeIndex);
      final promptForm = languageCode == 'pt' ? term.formFor('en') : term.formFor('pt');
      final isTrue = lessonIndex != 1;
      final falseForm = lexemes[(lexemeIndex + 1) % lexemes.length].formFor(languageCode);
      final statement = isTrue ? answer : falseForm;
      final trueFalseAnswer = isTrue ? 'Verdadeiro' : 'Falso';
      final nextTerm = lexemes[(lexemeIndex + 2) % lexemes.length];
      final nextAnswer = nextTerm.formFor(languageCode);
      final listeningChoices = _choicesFor(languageCode, nextAnswer, lexemeIndex + 3);
      final id = '${languageCode}_${level.toLowerCase()}_${lessonIndex + 1}';

      return Lesson(
        id: id,
        languageCode: languageCode,
        languageName: selectedLanguage.name,
        level: level,
        title: topics[lessonIndex],
        description: 'Aprenda expressões práticas de ${selectedLanguage.name} e pratique com cinco formatos de exercício. Conteúdo disponível neste dispositivo.',
        durationMinutes: 5 + lessonIndex,
        questions: [
          ExerciseQuestion(
            id: '${id}_q1',
            kind: ExerciseKind.multipleChoice,
            prompt: 'Como se diz “$promptForm” em ${selectedLanguage.name}?',
            answer: answer,
            choices: choices,
          ),
          ExerciseQuestion(
            id: '${id}_q2',
            kind: ExerciseKind.trueFalse,
            prompt: '“${term.formFor('en')}” em ${selectedLanguage.name} é “$statement”.',
            answer: trueFalseAnswer,
            choices: const ['Verdadeiro', 'Falso'],
          ),
          ExerciseQuestion(
            id: '${id}_q3',
            kind: ExerciseKind.fillBlank,
            prompt: 'Complete a tradução de “${term.formFor('en')}” em ${selectedLanguage.name}.',
            answer: answer,
          ),
          ExerciseQuestion(
            id: '${id}_q4',
            kind: ExerciseKind.matching,
            prompt: 'Ligue “${term.formFor('en')}” à expressão equivalente em ${selectedLanguage.name}.',
            answer: answer,
            choices: choices,
          ),
          ExerciseQuestion(
            id: '${id}_q5',
            kind: ExerciseKind.listening,
            prompt: 'Ouça a expressão e escolha o significado apresentado.',
            answer: nextAnswer,
            choices: listeningChoices,
            spokenText: nextAnswer,
          ),
        ],
      );
    });
  }

  static List<String> _choicesFor(String languageCode, String answer, int seed) {
    final candidates = lexemes
        .map((lexeme) => lexeme.formFor(languageCode))
        .where((word) => word.trim().isNotEmpty && word.toLowerCase() != answer.toLowerCase())
        .toSet()
        .toList();
    final wrong = <String>[];
    for (var offset = 0; offset < candidates.length && wrong.length < 3; offset++) {
      final candidate = candidates[(seed + offset) % candidates.length];
      if (candidate.toLowerCase() != answer.toLowerCase() && !wrong.contains(candidate)) {
        wrong.add(candidate);
      }
    }
    final options = <String>[...wrong];
    options.insert(seed % (options.length + 1), answer);
    return options;
  }
}
