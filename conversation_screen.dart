import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../services/tts_service.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key, this.initialScenarioIndex});
  final int? initialScenarioIndex;

  static const scenarios = <ConversationScenario>[
    ConversationScenario(title: 'Hotel', icon: Icons.hotel_outlined, steps: [
      ConversationStep(prompt: 'Good evening. Welcome to the hotel.', translation: 'Boa noite. Bem-vindo ao hotel.', choices: [
        ConversationChoice(text: 'Hello. I have a reservation.', translation: 'Olá. Tenho uma reserva.', reply: 'Certainly. May I have your name?', replyTranslation: 'Com certeza. Posso saber o seu nome?'),
        ConversationChoice(text: 'I need a room, please.', translation: 'Preciso de um quarto, por favor.', reply: 'How many nights will you stay?', replyTranslation: 'Quantas noites vai ficar?'),
      ]),
      ConversationStep(prompt: 'May I see your identification, please?', translation: 'Posso ver o seu documento de identificação, por favor?', choices: [
        ConversationChoice(text: 'Of course. Here it is.', translation: 'Claro. Aqui está.', reply: 'Thank you. Your room is ready.', replyTranslation: 'Obrigado. O seu quarto está pronto.'),
        ConversationChoice(text: 'Where is the lift?', translation: 'Onde fica o elevador?', reply: 'The lift is next to the reception.', replyTranslation: 'O elevador fica junto à recepção.'),
      ]),
    ]),
    ConversationScenario(title: 'Hospital', icon: Icons.local_hospital_outlined, steps: [
      ConversationStep(prompt: 'Good morning. How can I help you?', translation: 'Bom dia. Como posso ajudar?', choices: [
        ConversationChoice(text: 'I need to see a doctor.', translation: 'Preciso de consultar um médico.', reply: 'What seems to be the problem?', replyTranslation: 'Qual parece ser o problema?'),
        ConversationChoice(text: 'Where is the pharmacy?', translation: 'Onde fica a farmácia?', reply: 'It is beside the main entrance.', replyTranslation: 'Fica ao lado da entrada principal.'),
      ]),
      ConversationStep(prompt: 'Do you have any allergies?', translation: 'Tem alguma alergia?', choices: [
        ConversationChoice(text: 'No, I do not.', translation: 'Não, não tenho.', reply: 'All right. Please take a seat.', replyTranslation: 'Está bem. Por favor, sente-se.'),
        ConversationChoice(text: 'Yes, I am allergic to penicillin.', translation: 'Sim, sou alérgico à penicilina.', reply: 'Thank you for telling me.', replyTranslation: 'Obrigado por me informar.'),
      ]),
    ]),
    ConversationScenario(title: 'Restaurante', icon: Icons.restaurant_outlined, steps: [
      ConversationStep(prompt: 'Welcome. Do you have a reservation?', translation: 'Bem-vindo. Tem uma reserva?', choices: [
        ConversationChoice(text: 'A table for two, please.', translation: 'Uma mesa para duas pessoas, por favor.', reply: 'Certainly. Follow me, please.', replyTranslation: 'Com certeza. Acompanhe-me, por favor.'),
        ConversationChoice(text: 'Yes, under the name Ana.', translation: 'Sim, em nome de Ana.', reply: 'Your table is ready.', replyTranslation: 'A sua mesa está pronta.'),
      ]),
      ConversationStep(prompt: 'Would you like something to drink?', translation: 'Gostaria de beber alguma coisa?', choices: [
        ConversationChoice(text: 'Water, please.', translation: 'Água, por favor.', reply: 'Still or sparkling?', replyTranslation: 'Sem gás ou com gás?'),
        ConversationChoice(text: 'I would like the menu, please.', translation: 'Gostaria de ver o menu, por favor.', reply: 'Here is the menu. Enjoy your meal.', replyTranslation: 'Aqui está o menu. Bom apetite.'),
      ]),
    ]),
    ConversationScenario(title: 'Escola', icon: Icons.school_outlined, steps: [
      ConversationStep(prompt: 'Hello. Are you new at this school?', translation: 'Olá. É novo nesta escola?', choices: [
        ConversationChoice(text: 'Yes. My name is Paulo.', translation: 'Sim. O meu nome é Paulo.', reply: 'Nice to meet you, Paulo.', replyTranslation: 'Prazer em conhecê-lo, Paulo.'),
        ConversationChoice(text: 'Could you show me the library?', translation: 'Pode mostrar-me a biblioteca?', reply: 'Of course. It is on the first floor.', replyTranslation: 'Claro. Fica no primeiro andar.'),
      ]),
      ConversationStep(prompt: 'What subject do you enjoy?', translation: 'De que disciplina gosta?', choices: [
        ConversationChoice(text: 'I enjoy learning languages.', translation: 'Gosto de aprender idiomas.', reply: 'That is a useful skill.', replyTranslation: 'É uma competência útil.'),
        ConversationChoice(text: 'I like mathematics.', translation: 'Gosto de matemática.', reply: 'The mathematics class starts at ten.', replyTranslation: 'A aula de matemática começa às dez.'),
      ]),
    ]),
    ConversationScenario(title: 'Universidade', icon: Icons.account_balance_outlined, steps: [
      ConversationStep(prompt: 'Which course are you studying?', translation: 'Que curso está a frequentar?', choices: [
        ConversationChoice(text: 'I am studying business.', translation: 'Estou a estudar gestão.', reply: 'Which year are you in?', replyTranslation: 'Em que ano está?'),
        ConversationChoice(text: 'I am looking for the admissions office.', translation: 'Procuro o gabinete de admissões.', reply: 'It is in the administration building.', replyTranslation: 'Fica no edifício da administração.'),
      ]),
      ConversationStep(prompt: 'Would you like to join the study group?', translation: 'Gostaria de participar no grupo de estudo?', choices: [
        ConversationChoice(text: 'Yes, that would be helpful.', translation: 'Sim, isso seria útil.', reply: 'We meet every Wednesday afternoon.', replyTranslation: 'Encontramo-nos todas as quartas-feiras à tarde.'),
        ConversationChoice(text: 'I cannot today, but thank you.', translation: 'Hoje não posso, mas obrigado.', reply: 'No problem. See you in class.', replyTranslation: 'Sem problema. Até à aula.'),
      ]),
    ]),
    ConversationScenario(title: 'Aeroporto', icon: Icons.flight_outlined, steps: [
      ConversationStep(prompt: 'May I see your passport and boarding pass?', translation: 'Posso ver o seu passaporte e cartão de embarque?', choices: [
        ConversationChoice(text: 'Here they are.', translation: 'Aqui estão.', reply: 'Thank you. Your gate is number twelve.', replyTranslation: 'Obrigado. A sua porta de embarque é a número doze.'),
        ConversationChoice(text: 'Where can I check in?', translation: 'Onde posso fazer o check-in?', reply: 'The check-in desks are on your left.', replyTranslation: 'Os balcões de check-in ficam à sua esquerda.'),
      ]),
      ConversationStep(prompt: 'Are you carrying any liquids?', translation: 'Está a transportar líquidos?', choices: [
        ConversationChoice(text: 'Only a small bottle of water.', translation: 'Apenas uma garrafa pequena de água.', reply: 'Please place it in the tray.', replyTranslation: 'Por favor, coloque-a no tabuleiro.'),
        ConversationChoice(text: 'No, I am not.', translation: 'Não, não estou.', reply: 'All right. You may proceed.', replyTranslation: 'Está bem. Pode avançar.'),
      ]),
    ]),
    ConversationScenario(title: 'Negócios', icon: Icons.business_center_outlined, steps: [
      ConversationStep(prompt: 'Thank you for joining the meeting.', translation: 'Obrigado por participar na reunião.', choices: [
        ConversationChoice(text: 'Thank you for inviting me.', translation: 'Obrigado pelo convite.', reply: 'Would you like to present your proposal?', replyTranslation: 'Gostaria de apresentar a sua proposta?'),
        ConversationChoice(text: 'Could we review the agenda first?', translation: 'Podemos rever a agenda primeiro?', reply: 'Certainly. Let us begin with the first item.', replyTranslation: 'Com certeza. Vamos começar pelo primeiro ponto.'),
      ]),
      ConversationStep(prompt: 'When can you deliver the report?', translation: 'Quando pode entregar o relatório?', choices: [
        ConversationChoice(text: 'I can send it by Friday.', translation: 'Posso enviá-lo até sexta-feira.', reply: 'That works well for our team.', replyTranslation: 'Isso funciona bem para a nossa equipa.'),
        ConversationChoice(text: 'I need one more day, please.', translation: 'Preciso de mais um dia, por favor.', reply: 'Thank you for letting us know.', replyTranslation: 'Obrigado por nos avisar.'),
      ]),
    ]),
    ConversationScenario(title: 'Entrevista de emprego', icon: Icons.work_outline_rounded, steps: [
      ConversationStep(prompt: 'Tell me a little about yourself.', translation: 'Fale-me um pouco sobre si.', choices: [
        ConversationChoice(text: 'I am organised and eager to learn.', translation: 'Sou organizado e tenho vontade de aprender.', reply: 'What experience do you have?', replyTranslation: 'Que experiência tem?'),
        ConversationChoice(text: 'I have worked in customer service.', translation: 'Trabalhei no atendimento ao cliente.', reply: 'What did you enjoy most about that role?', replyTranslation: 'De que gostou mais nessa função?'),
      ]),
      ConversationStep(prompt: 'Do you have any questions for us?', translation: 'Tem alguma pergunta para nós?', choices: [
        ConversationChoice(text: 'What does a typical workday look like?', translation: 'Como é um dia de trabalho normal?', reply: 'The team works collaboratively on several projects.', replyTranslation: 'A equipa trabalha em conjunto em vários projectos.'),
        ConversationChoice(text: 'When can I expect to hear from you?', translation: 'Quando posso esperar uma resposta?', reply: 'We will contact you next week.', replyTranslation: 'Entraremos em contacto consigo na próxima semana.'),
      ]),
    ]),
  ];

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  int? _scenarioIndex;
  int _stepIndex = 0;
  bool _finished = false;
  final List<_ChatEntry> _messages = [];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialScenarioIndex;
    if (initial != null && initial >= 0 && initial < ConversationScreen.scenarios.length) {
      _startScenario(initial);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final index = _scenarioIndex;
    return Scaffold(
      appBar: AppBar(
        title: Text(index == null ? 'Conversação guiada' : ConversationScreen.scenarios[index].title),
        leading: index == null ? null : IconButton(tooltip: 'Cenários', onPressed: () => setState(() { _scenarioIndex = null; _messages.clear(); }), icon: const Icon(Icons.arrow_back_rounded)),
      ),
      body: index == null ? _scenarioList(context) : Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppConstants.gold.withValues(alpha: .14), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [const Icon(Icons.auto_awesome_outlined, color: AppConstants.gold), const SizedBox(width: 9), Expanded(child: Text('Diálogo pré-programado em inglês · sem IA · escolha uma resposta.', style: theme.textTheme.bodySmall))]),
          ),
        ),
        Expanded(child: _chatList(context)),
        _choicePanel(context),
      ]),
    );
  }

  Widget _scenarioList(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Pratique situações do quotidiano com opções guiadas e traduções de apoio.'),
          const SizedBox(height: 16),
          ...ConversationScreen.scenarios.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Theme.of(context).dividerColor)),
              child: ListTile(
                leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: AppConstants.gold.withValues(alpha: .16), borderRadius: BorderRadius.circular(13)), child: Icon(entry.value.icon, color: AppConstants.navy)),
                title: Text(entry.value.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${entry.value.steps.length} etapas · ${entry.value.steps.first.choices.length} respostas possíveis por etapa'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
                onTap: () => _startScenario(entry.key),
              ),
            ),
          )),
        ],
      );

  Widget _chatList(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return Align(
            alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78),
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: message.isUser ? AppConstants.navy : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16).copyWith(bottomRight: message.isUser ? const Radius.circular(4) : null, bottomLeft: message.isUser ? null : const Radius.circular(4)),
                border: message.isUser ? null : Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Text(message.english, style: TextStyle(color: message.isUser ? Colors.white : null, fontWeight: FontWeight.w700, height: 1.35))),
                  if (!message.isUser)
                    IconButton(visualDensity: VisualDensity.compact, constraints: const BoxConstraints(), padding: const EdgeInsets.only(left: 8), tooltip: 'Ouvir', onPressed: () => _speak(message.english), icon: const Icon(Icons.volume_up_outlined, size: 18, color: AppConstants.gold)),
                ]),
                const SizedBox(height: 4),
                Text(message.translation, style: TextStyle(color: message.isUser ? Colors.white.withValues(alpha: .77) : Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
              ]),
            ),
          );
        },
      );

  Widget _choicePanel(BuildContext context) {
    final theme = Theme.of(context);
    if (_finished) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        child: FilledButton.icon(onPressed: () => setState(() { _scenarioIndex = null; _finished = false; _messages.clear(); }), icon: const Icon(Icons.refresh_rounded), label: const Text('Escolher outro cenário'), style: FilledButton.styleFrom(backgroundColor: AppConstants.navy, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50))),
      );
    }
    final scenario = ConversationScreen.scenarios[_scenarioIndex!];
    final step = scenario.steps[_stepIndex];
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(color: theme.colorScheme.surface, border: Border(top: BorderSide(color: theme.dividerColor))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('Escolha a sua resposta', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...step.choices.map((choice) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: OutlinedButton(
              onPressed: () => _choose(choice),
              style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), side: BorderSide(color: theme.dividerColor)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(choice.text, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(choice.translation, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))]),
            ),
          )),
        ]),
      ),
    );
  }

  void _startScenario(int index) {
    final scenario = ConversationScreen.scenarios[index];
    setState(() {
      _scenarioIndex = index;
      _stepIndex = 0;
      _finished = false;
      _messages
        ..clear()
        ..add(_ChatEntry(isUser: false, english: scenario.steps.first.prompt, translation: scenario.steps.first.translation));
    });
  }

  void _choose(ConversationChoice choice) {
    final scenario = ConversationScreen.scenarios[_scenarioIndex!];
    setState(() {
      _messages.add(_ChatEntry(isUser: true, english: choice.text, translation: choice.translation));
      _messages.add(_ChatEntry(isUser: false, english: choice.reply, translation: choice.replyTranslation));
      if (_stepIndex + 1 < scenario.steps.length) {
        _stepIndex++;
        final next = scenario.steps[_stepIndex];
        _messages.add(_ChatEntry(isUser: false, english: next.prompt, translation: next.translation));
      } else {
        _finished = true;
      }
    });
  }

  Future<void> _speak(String text) async {
    try {
      await context.read<TtsService>().speak(text, 'en-US');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A voz em inglês não está disponível neste dispositivo.')));
    }
  }
}

class ConversationScenario {
  const ConversationScenario({required this.title, required this.icon, required this.steps});
  final String title;
  final IconData icon;
  final List<ConversationStep> steps;
}

class ConversationStep {
  const ConversationStep({required this.prompt, required this.translation, required this.choices});
  final String prompt;
  final String translation;
  final List<ConversationChoice> choices;
}

class ConversationChoice {
  const ConversationChoice({required this.text, required this.translation, required this.reply, required this.replyTranslation});
  final String text;
  final String translation;
  final String reply;
  final String replyTranslation;
}

class _ChatEntry {
  const _ChatEntry({required this.isUser, required this.english, required this.translation});
  final bool isUser;
  final String english;
  final String translation;
}
