import 'dart:convert';

class ReportModel {
  final String id;
  final String projectName;
  final String date;
  final String jenisPekerjaan;
  final String jenisBahan;
  final String volume;
  final String satuan;
  final List<String> jenisAlat;
  final int jumlahPekerja;
  final int k3Count;
  final String? imagePath;

  ReportModel({
    required this.id,
    required this.projectName,
    required this.date,
    required this.jenisPekerjaan,
    required this.jenisBahan,
    required this.volume,
    required this.satuan,
    required this.jenisAlat,
    required this.jumlahPekerja,
    required this.k3Count,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectName': projectName,
      'date': date,
      'jenisPekerjaan': jenisPekerjaan,
      'jenisBahan': jenisBahan,
      'volume': volume,
      'satuan': satuan,
      'jenisAlat': jenisAlat,
      'jumlahPekerja': jumlahPekerja,
      'k3Count': k3Count,
      'imagePath': imagePath,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id'],
      projectName: map['projectName'],
      date: map['date'],
      jenisPekerjaan: map['jenisPekerjaan'],
      jenisBahan: map['jenisBahan'],
      volume: map['volume'],
      satuan: map['satuan'],
      jenisAlat: List<String>.from(map['jenisAlat']),
      jumlahPekerja: map['jumlahPekerja'],
      k3Count: map['k3Count'],
      imagePath: map['imagePath'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ReportModel.fromJson(String source) => ReportModel.fromMap(json.decode(source));
}
