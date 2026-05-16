import 'package:shared_preferences/shared_preferences.dart';
import '../models/report_model.dart';

class ReportService {
  static const String _storageKey = 'constraa_reports';

  // Save a report to local storage
  static Future<void> saveReport(ReportModel report) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing reports
    List<String> reportsJson = prefs.getStringList(_storageKey) ?? [];
    
    // Add new report
    reportsJson.add(report.toJson());
    
    // Save back
    await prefs.setStringList(_storageKey, reportsJson);
  }

  // Get all reports from local storage
  static Future<List<ReportModel>> getReports() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> reportsJson = prefs.getStringList(_storageKey) ?? [];
    
    return reportsJson.map((jsonStr) => ReportModel.fromJson(jsonStr)).toList().reversed.toList();
  }
  
  // Clear all reports (optional utility)
  static Future<void> clearReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
