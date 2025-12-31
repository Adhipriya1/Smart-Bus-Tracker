import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_bus_tracker/common/services/translation_service.dart';
import 'package:smart_bus_tracker/common/locale_provider.dart'; 

class AutoText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool translate; // Add this if you want optional translation

  const AutoText(
    this.text, {
    super.key, 
    this.style, 
    this.textAlign, 
    this.maxLines, 
    this.overflow,
    this.translate = true,
  });

  @override
  State<AutoText> createState() => _AutoTextState();
}

class _AutoTextState extends State<AutoText> {
  String _translatedText = "";
  final TranslationService _service = TranslationService();

  @override
  void initState() {
    super.initState();
    _translatedText = widget.text;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTranslation();
  }

  @override
  void didUpdateWidget(AutoText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _updateTranslation();
    }
  }

  Future<void> _updateTranslation() async {
    if (!widget.translate) {
       if (mounted) setState(() => _translatedText = widget.text);
       return;
    }

    final localeProvider = Provider.of<LocaleProvider>(context);
    final langCode = localeProvider.locale?.languageCode ?? 'en';

    if (langCode == 'en') {
      if (mounted) setState(() => _translatedText = widget.text);
      return;
    }

    final translation = await _service.translate(widget.text, langCode);
    if (mounted) setState(() => _translatedText = translation);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _translatedText,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}