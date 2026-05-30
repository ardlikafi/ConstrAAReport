import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_model.dart';

class ReportService {
  static final _supabase = Supabase.instance.client;

  // Save a report to Supabase, associated with the current user's ID
  static Future<void> saveReport(ReportModel report) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      final map = report.toMap();
      if (userId != null) {
        map['user_id'] = userId;
      }
      await _supabase.from('reports').insert(map);
    } catch (e) {
      throw Exception('Gagal menyimpan laporan: $e');
    }
  }

  // Get only the reports belonging to the currently logged-in user
  static Future<List<ReportModel>> getReports() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }
      
      final data = await _supabase
          .from('reports')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
          
      return data.map((item) => ReportModel.fromMap(item)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil laporan: $e');
    }
  }
}
