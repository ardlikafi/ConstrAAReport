import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/report_model.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2F66A9)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Detail Laporan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2F66A9),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.projectName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2F66A9)),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow('Tanggal Laporan', report.date, Icons.calendar_month),
                  _buildDetailRow('Jenis Pekerjaan', report.jenisPekerjaan, Icons.engineering),
                  _buildDetailRow('Bahan Digunakan', report.jenisBahan.contains('(') ? report.jenisBahan : '${report.jenisBahan} (${report.volume} ${report.satuan})', Icons.inventory_2),
                  if (report.cuaca.isNotEmpty) _buildDetailRow('Cuaca', report.cuaca, Icons.wb_sunny_outlined),
                  if (report.elemenBcb.isNotEmpty) _buildDetailRow('Elemen BCB', report.elemenBcb, Icons.history_edu_outlined),
                  if (report.elemenNonBcb.isNotEmpty) _buildDetailRow('Elemen Non BCB', report.elemenNonBcb, Icons.account_balance_outlined),
                  _buildDetailRow('Jumlah Pekerja', '${report.jumlahPekerja} Orang', Icons.people),
                  _buildDetailRow('Kelengkapan K3', '${report.k3Count} Item Lengkap', Icons.health_and_safety),
                  
                  if (report.jenisAlat.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Text('Alat yang Digunakan:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: report.jenisAlat.map((alat) {
                        return Chip(
                          label: Text(alat, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.blue.shade50,
                          side: BorderSide(color: Colors.blue.shade200),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ).animate().fade().slideY(begin: 0.1),
            
            if (report.imagePaths.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Foto Progres (Ketuk untuk Memperbesar)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: report.imagePaths.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final path = report.imagePaths[index];
                  return GestureDetector(
                    onTap: () => _showFullImage(context, path),
                    child: Hero(
                      tag: path,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.broken_image_outlined, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ).animate().fade(delay: 200.ms).scale(),
            ],
          ],
        ),
      ),
    );
  }

  // Beautiful Full-Screen Pinch-to-Zoom Image Viewer Dialog
  void _showFullImage(BuildContext context, String path) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9), // Elegant dark backdrop
      builder: (context) {
        return Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Hero(
                  tag: path,
                  child: Image.file(
                    File(path),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white,
                        size: 80,
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: SafeArea(
                child: Material(
                  color: Colors.white.withOpacity(0.1),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
