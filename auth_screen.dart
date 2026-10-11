import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/validators.dart';
import '../providers/auth_provider.dart';


enum AuthMode { login, register, recover }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.initialMode});
  final AuthMode initialMode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _recovery = TextEditingController();
  bool _hidePassword = true;
  bool _busy = false;
  late AuthMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _recovery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = switch (_mode) {
      AuthMode.login => 'Bem-vindo de volta',
      AuthMode.register => 'Criar conta local',
      AuthMode.recover => 'Recuperar acesso',
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(_mode == AuthMode.login ? Icons.lock_open_rounded : Icons.person_outline_rounded, size: 34, color: AppConstants.gold),
                      const SizedBox(height: 10),
                      Text(title, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(
                        _mode == AuthMode.recover
                            ? 'A recuperação é validada neste dispositivo através do código guardado no registo.'
                            : 'Os seus dados não são enviados para um servidor.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 22),
                      if (_mode == AuthMode.register) ...[
                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(labelText: 'Nome completo', prefixIcon: Icon(Icons.person_outline)),
                          validator: FormValidators.name,
                        ),
                        const SizedBox(height: 14),
                      ],
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: _mode == AuthMode.recover ? TextInputAction.next : TextInputAction.next,
                        autocorrect: false,
                        decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.alternate_email_rounded)),
                        validator: FormValidators.email,
                      ),
                      if (_mode == AuthMode.recover) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _recovery,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(labelText: 'Código de recuperação', prefixIcon: Icon(Icons.key_rounded)),
                          validator: (value) => FormValidators.requiredText(value, label: 'O código'),
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (_mode != AuthMode.recover) const SizedBox(height: 14),
                      TextFormField(
                        controller: _password,
                        obscureText: _hidePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: _mode == AuthMode.recover ? 'Nova palavra-passe' : 'Palavra-passe',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            tooltip: _hidePassword ? 'Mostrar palavra-passe' : 'Ocultar palavra-passe',
                            onPressed: () => setState(() => _hidePassword = !_hidePassword),
                            icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          ),
                        ),
                        validator: _mode == AuthMode.login ? (value) => FormValidators.requiredText(value, label: 'A palavra-passe') : FormValidators.password,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _busy ? null : _submit,
                        style: FilledButton.styleFrom(backgroundColor: AppConstants.navy, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52)),
                        child: _busy
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(switch (_mode) { AuthMode.login => 'Entrar', AuthMode.register => 'Criar conta', AuthMode.recover => 'Redefinir palavra-passe' }),
                      ),
                      const SizedBox(height: 8),
                      if (_mode == AuthMode.login)
                        TextButton(onPressed: () => setState(() => _mode = AuthMode.recover), child: const Text('Esqueci-me da palavra-passe')),
                      if (_mode != AuthMode.login)
                        TextButton(onPressed: () => setState(() => _mode = AuthMode.login), child: const Text('Voltar ao início de sessão')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final auth = context.read<AuthProvider>();
      if (_mode == AuthMode.login) {
        await auth.login(email: _email.text.trim(), password: _password.text);
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (_mode == AuthMode.register) {
        final result = await auth.register(name: _name.text, email: _email.text, password: _password.text);
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(Icons.verified_user_outlined, color: AppConstants.gold),
            title: const Text('Guarde o seu código de recuperação'),
            content: SelectableText(
              'Este código é guardado apenas por si e é necessário para redefinir a palavra-passe offline. Copie-o agora:\n\n${result.recoveryCode}',
              textAlign: TextAlign.center,
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Já guardei'))],
          ),
        );
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        await auth.recoverPassword(email: _email.text, recoveryCode: _recovery.text, newPassword: _password.text);
        if (!mounted) return;
        setState(() => _mode = AuthMode.login);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Palavra-passe redefinida neste dispositivo.')));
      }
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
