import 'dart:convert';

class ReportModel {
  final String? id;
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
  final String cuaca;
  final String elemenBcb;
  final String elemenNonBcb;

  ReportModel({
    this.id,
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
    this.cuaca = '',
    this.elemenBcb = '',
    this.elemenNonBcb = '',
  });

  // Getter to retrieve a list of photo paths if multiple photos are stored
  List<String> get imagePaths {
    if (imagePath == null || imagePath!.isEmpty) return [];
    if (imagePath!.contains('|')) {
      return imagePath!.split('|');
    }
    return [imagePath!];
  }

  Map<String, dynamic> toMap() {
    return {
      'project_name': projectName,
      'date': date,
      'jenis_pekerjaan': jenisPekerjaan,
      'jenis_bahan': jenisBahan,
      'volume': volume,
      'satuan': satuan,
      'jenis_alat': jenisAlat,
      'jumlah_pekerja': jumlahPekerja,
      'k3_count': k3Count,
      'image_path': imagePath,
      'cuaca': cuaca,
      'elemen_bcb': elemenBcb,
      'elemen_non_bcb': elemenNonBcb,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['id']?.toString(),
      projectName: map['project_name'] ?? map['projectName'] ?? '',
      date: map['date'] ?? '',
      jenisPekerjaan: map['jenis_pekerjaan'] ?? map['jenisPekerjaan'] ?? '',
      jenisBahan: map['jenis_bahan'] ?? map['jenisBahan'] ?? '',
      volume: map['volume']?.toString() ?? '',
      satuan: map['satuan'] ?? '',
      jenisAlat: map['jenis_alat'] != null 
          ? List<String>.from(map['jenis_alat']) 
          : (map['jenisAlat'] != null ? List<String>.from(map['jenisAlat']) : []),
      jumlahPekerja: map['jumlah_pekerja'] ?? map['jumlahPekerja'] ?? 1,
      k3Count: map['k3_count'] ?? map['k3Count'] ?? 0,
      imagePath: map['image_path'] ?? map['imagePath'],
      cuaca: map['cuaca'] ?? '',
      elemenBcb: map['elemen_bcb'] ?? map['elemenBcb'] ?? '',
      elemenNonBcb: map['elemen_non_bcb'] ?? map['elemenNonBcb'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ReportModel.fromJson(String source) => ReportModel.fromMap(json.decode(source));
}
