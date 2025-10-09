import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/prefs_service.dart';

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _decideRoute();
  }

  Future<void> _decideRoute() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final prefs = Provider.of<PrefsService>(context, listen: false);
    if (!prefs.isDemoDone()) {
      Navigator.pushReplacementNamed(context, '/demo');
      return;
    }
    if (!prefs.isAccepted('v1')) {
      Navigator.pushReplacementNamed(context, '/policy-viewer');
      return;
    }
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('Zen', style: Theme.of(context).textTheme.headlineSmall),
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
