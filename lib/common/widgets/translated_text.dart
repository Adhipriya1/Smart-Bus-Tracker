import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_bus_tracker/common/services/translation_service.dart';
import 'package:smart_bus_tracker/common/locale_provider.dart'; // Imports LocaleProvider

class TranslatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(this.text, {super.key, this.style, this.textAlign, this.maxLines, this.overflow});

  @override
  State<TranslatedText> createState() => _TranslatedTextState();
}

class _TranslatedTextState extends State<TranslatedText> {
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
    _translate();
  }

  @override
  void didUpdateWidget(TranslatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _translate();
    }
  }

  Future<void> _translate() async {
    // FIXED: Reads LocaleProvider
    final langCode = Provider.of<LocaleProvider>(context).locale?.languageCode ?? 'en';
    
    if (langCode == 'en') {
      if(mounted) setState(() => _translatedText = widget.text);
      return;
    }
    
    final result = await _service.translate(widget.text, langCode);
    if (mounted) setState(() => _translatedText = result);
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