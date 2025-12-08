import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../services/prefs_service.dart';

class PolicyViewerPage extends StatefulWidget {
  const PolicyViewerPage({super.key});

  @override
  State<PolicyViewerPage> createState() => _PolicyViewerPageState();
}

class _PolicyViewerPageState extends State<PolicyViewerPage> {
  String? _privacy;
  String? _terms;
  final _privacyKey = GlobalKey<_ScrollableMarkdownState>();
  final _termsKey = GlobalKey<_ScrollableMarkdownState>();

  double _privacyProgress = 0.0;
  double _termsProgress = 0.0;

  bool _agreeChecked = false;

  bool get canAccept {
    // Use a strict threshold: consider reached when progress >= 0.98
    return (_privacyProgress >= 0.98) && (_termsProgress >= 0.98);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Reset progress and agree flag while reloading
    setState(() {
      _privacyProgress = 0.0;
      _termsProgress = 0.0;
      _agreeChecked = false;
    });

    final p = await rootBundle.loadString('assets/policies/privacy_v1.md');
    final t = await rootBundle.loadString('assets/policies/terms_v1.md');
    setState(() {
      _privacy = p;
      _terms = t;
    });
  }

  void _tryAccept() async {
    if (!canAccept) return;
    final prefs = Provider.of<PrefsService>(context, listen: false);
    await prefs.setPoliciesVersionAccepted('v1');
    await prefs.setAcceptedAt(DateTime.now().toIso8601String());
    await prefs.setPrivacyReadV1(true);
    await prefs.setTermsReadV1(true);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Políticas e Consentimento')),
      body: _privacy == null || _terms == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _load,
                          child: ScrollableMarkdown(key: _privacyKey, data: _privacy!, onProgress: (p) {
                            setState(() => _privacyProgress = p);
                          }),
                        ),
                      ),
                      LinearProgressIndicator(value: _privacyProgress),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _load,
                          child: ScrollableMarkdown(key: _termsKey, data: _terms!, onProgress: (p) {
                            setState(() => _termsProgress = p);
                          }),
                        ),
                      ),
                      LinearProgressIndicator(value: _termsProgress),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CheckboxListTile(
                        value: _agreeChecked,
                        onChanged: canAccept
                            ? (v) => setState(() {
                                  _agreeChecked = v ?? false;
                                })
                            : null,
                        title: const Text('Li e concordo com as políticas do ZenBreak'),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 6),
                      ElevatedButton(
                        onPressed: (canAccept && _agreeChecked) ? _tryAccept : null,
                        child: const Text('Marcar como lido e continuar'),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}

class ScrollableMarkdown extends StatefulWidget {
  final String data;
  final void Function(double progress)? onProgress;

  const ScrollableMarkdown({super.key, required this.data, this.onProgress});

  @override
  State<ScrollableMarkdown> createState() => _ScrollableMarkdownState();
}

class _ScrollableMarkdownState extends State<ScrollableMarkdown> {
  final _controller = ScrollController();
  bool isAtBottom = false;
  double _lastProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (!_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    final pos = _controller.position.pixels;
    final progress = max <= 0 ? 1.0 : (pos / max).clamp(0.0, 1.0);
    final nowBottom = progress >= 0.98;
    if (nowBottom != isAtBottom) setState(() => isAtBottom = nowBottom);
    if ((progress - _lastProgress).abs() > 0.01) {
      _lastProgress = progress;
      widget.onProgress?.call(progress);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_check);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: widget.data,
      controller: _controller,
      selectable: true,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }
}
