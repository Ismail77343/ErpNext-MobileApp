import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/locale_provider.dart';
import '../../../../core/localization/localization_extensions.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  static const _languages = [
    _LanguageOption(null, 'system', Icons.phone_android_rounded),
    _LanguageOption(Locale('en'), 'en', Icons.language_rounded),
    _LanguageOption(Locale('ar'), 'ar', Icons.translate_rounded),
    _LanguageOption(Locale('ur'), 'ur', Icons.translate_rounded),
    _LanguageOption(Locale('bn'), 'bn', Icons.translate_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeProvider = context.watch<LocaleProvider>();
    final selectedCode = localeProvider.locale?.languageCode ?? 'system';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.selectLanguage)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _languages.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final option = _languages[index];
          final selected = option.code == selectedCode;
          return Card(
            color: selected ? const Color(0xFFE0F2FE) : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: selected
                    ? const Color(0xFF0E7490)
                    : const Color(0xFFE2E8F0),
                child: Icon(
                  option.icon,
                  color: selected ? Colors.white : const Color(0xFF475569),
                ),
              ),
              title: Text(
                _labelFor(context, option.code),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                option.code == 'system'
                    ? l10n.systemLanguage
                    : option.locale!.languageCode,
              ),
              trailing: selected
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF0E7490),
                    )
                  : null,
              onTap: () async {
                await context.read<LocaleProvider>().setLocale(option.locale);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.languageUpdated)),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _labelFor(BuildContext context, String code) {
    final l10n = context.l10n;
    return switch (code) {
      'system' => l10n.systemLanguage,
      'en' => l10n.english,
      'ar' => l10n.arabic,
      'ur' => l10n.urdu,
      'bn' => l10n.bengali,
      _ => code,
    };
  }
}

class _LanguageOption {
  const _LanguageOption(this.locale, this.code, this.icon);

  final Locale? locale;
  final String code;
  final IconData icon;
}
