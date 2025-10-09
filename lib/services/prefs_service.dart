import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  final SharedPreferences _prefs;

  PrefsService._(this._prefs);

  static Future<PrefsService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefsService._(prefs);
  }

  bool get demoCompleted => _prefs.getBool('demo_completed') ?? false;
  Future<void> setDemoCompleted(bool v) => _prefs.setBool('demo_completed', v);

  bool get privacyReadV1 => _prefs.getBool('privacy_read_v1') ?? false;
  Future<void> setPrivacyReadV1(bool v) => _prefs.setBool('privacy_read_v1', v);

  bool get termsReadV1 => _prefs.getBool('terms_read_v1') ?? false;
  Future<void> setTermsReadV1(bool v) => _prefs.setBool('terms_read_v1', v);

  String? get policiesVersionAccepted => _prefs.getString('policies_version_accepted');
  Future<void> setPoliciesVersionAccepted(String v) => _prefs.setString('policies_version_accepted', v);

  String? get acceptedAt => _prefs.getString('accepted_at');
  Future<void> setAcceptedAt(String v) => _prefs.setString('accepted_at', v);

  bool get reminderScheduled => _prefs.getBool('reminder_scheduled') ?? false;
  Future<void> setReminderScheduled(bool v) => _prefs.setBool('reminder_scheduled', v);

  String? get reminderTime => _prefs.getString('reminder_time');
  Future<void> setReminderTime(String v) => _prefs.setString('reminder_time', v);

  Future<void> clearAll() => _prefs.clear();

  // Convenience checks
  bool isAccepted(String version) => policiesVersionAccepted == version;
  bool isDemoDone() => demoCompleted;
}
