import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Data State
  List<ReportModel> _reports = [];
  bool _isLoading = true;

  // Project Name state
  String _projectName = 'Pembangunan Gedung A';

  // Form Controllers & State
  DateTime? _selectedDate;
  final TextEditingController _pekerjaanController = TextEditingController();
  final List<String> _selectedPekerjaan = [];

  final TextEditingController _bahanController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController(text: '0');
  String _selectedSatuan = 'Satuan';
  final List<Map<String, String>> _addedBahan = [];

  final TextEditingController _pekerjaController = TextEditingController(text: '1');
  
  // New Controllers
  final TextEditingController _cuacaController = TextEditingController();
  final TextEditingController _elemenBcbController = TextEditingController();
  final List<String> _selectedElemenBcb = [];
  final TextEditingController _elemenNonBcbController = TextEditingController();
  final List<String> _selectedElemenNonBcb = [];

  // K3 selection state
  int _k3Count = 0;
  final List<String> k3Items = [
    'Helm Safety', 'Sepatu Safety', 'Rompi/Vest', 'Sarung Tangan',
    'Masker', 'Kacamata Safety', 'Safety Harness', 'Ear Plug'
  ];
  late List<bool> _k3Checked;
  
  // Alat selection state
  final List<String> alatChips = [
    'Excavator', 'Mixer', 'Vibrator', 'Scaffolding', 'Concrete Pump', 'Tower Crane'
  ];
  final List<String> _selectedAlat = [];
  final TextEditingController _alatController = TextEditingController();

  // Photo upload state
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _k3Checked = List.generate(8, (_) => false);
    _loadReports();
  }

  Future<void> _loadReports() async {
    final reports = await ReportService.getReports();
    setState(() {
      _reports = reports;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pekerjaanController.dispose();
    _bahanController.dispose();
    _volumeController.dispose();
    _pekerjaController.dispose();
    _alatController.dispose();
    _cuacaController.dispose();
    _elemenBcbController.dispose();
    _elemenNonBcbController.dispose();
    super.dispose();
  }

  void _updateK3Count() {
    setState(() {
      _k3Count = _k3Checked.where((element) => element).length;
    });
  }

  void _resetForm() {
    setState(() {
      _selectedDate = null;
      _pekerjaanController.clear();
      _selectedPekerjaan.clear();
      _bahanController.clear();
      _volumeController.text = '0';
      _pekerjaController.text = '1';
      _selectedSatuan = 'Satuan';
      _addedBahan.clear();
      _k3Checked = List.generate(8, (_) => false);
      _updateK3Count();
      _selectedAlat.clear();
      _selectedImages.clear();
      _cuacaController.clear();
      _elemenBcbController.clear();
      _selectedElemenBcb.clear();
      _elemenNonBcbController.clear();
      _selectedElemenNonBcb.clear();
    });
  }

  void _showEditProjectDialog() {
    final controller = TextEditingController(text: _projectName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Nama Proyek', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Masukkan nama proyek baru',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _projectName = controller.text.trim();
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveReport() async {
    final jobInput = _pekerjaanController.text.trim();
    if (_selectedDate == null || (_selectedPekerjaan.isEmpty && jobInput.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi Tanggal dan setidaknya satu Jenis Pekerjaan!'), backgroundColor: Colors.red),
      );
      return;
    }

    // Add any remaining text in the textfield to the list
    final List<String> finalJobs = List.from(_selectedPekerjaan);
    if (jobInput.isNotEmpty && !finalJobs.contains(jobInput)) {
      finalJobs.add(jobInput);
    }

    final String jobsString = finalJobs.join(', ');
    
    // Format materials list
    final List<String> formattedMaterials = _addedBahan.map((b) => "${b['nama']} (${b['volume']} ${b['satuan']})").toList();
    final remainingBahan = _bahanController.text.trim();
    if (remainingBahan.isNotEmpty) {
      formattedMaterials.add("$remainingBahan (${_volumeController.text} $_selectedSatuan)");
    }
    final String materialsString = formattedMaterials.join(', ');

    // Format Elemen BCB list
    final List<String> finalBcb = List.from(_selectedElemenBcb);
    final bcbInput = _elemenBcbController.text.trim();
    if (bcbInput.isNotEmpty && !finalBcb.contains(bcbInput)) {
      finalBcb.add(bcbInput);
    }
    final String bcbString = finalBcb.join(', ');

    // Format Elemen Non BCB list
    final List<String> finalNonBcb = List.from(_selectedElemenNonBcb);
    final nonBcbInput = _elemenNonBcbController.text.trim();
    if (nonBcbInput.isNotEmpty && !finalNonBcb.contains(nonBcbInput)) {
      finalNonBcb.add(nonBcbInput);
    }
    final String nonBcbString = finalNonBcb.join(', ');

    // Format images list
    final String imagesString = _selectedImages.map((img) => img.path).join('|');

    final newReport = ReportModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectName: _projectName,
      date: DateFormat('dd/MM/yyyy').format(_selectedDate!),
      jenisPekerjaan: jobsString,
      jenisBahan: materialsString,
      volume: _volumeController.text,
      satuan: _selectedSatuan,
      jenisAlat: List.from(_selectedAlat),
      jumlahPekerja: int.tryParse(_pekerjaController.text) ?? 1,
      k3Count: _k3Count,
      imagePath: imagesString.isNotEmpty ? imagesString : null,
      cuaca: _cuacaController.text.trim(),
      elemenBcb: bcbString,
      elemenNonBcb: nonBcbString,
    );

    try {
      await ReportService.saveReport(newReport);
      _resetForm();
      await _loadReports();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data progres berhasil disimpan!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving report: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan progres: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2F66A9), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Color(0xFF1E293B), // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2F66A9), // button text color
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              headerBackgroundColor: const Color(0xFF2F66A9),
              elevation: 4,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalPekerja = _reports.fold(0, (sum, item) => sum + item.jumlahPekerja);
    double avgK3 = _reports.isEmpty ? 0 : (_reports.fold(0, (sum, item) => sum + item.k3Count) / (_reports.length * 8)) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Title Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nama Proyek:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(_projectName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _showEditProjectDialog,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Edit Nama', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ).animate().fade(duration: 400.ms).slideX(begin: -0.1),
          const SizedBox(height: 16),

          // Metrics Grid
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildMetricCard('Total Laporan', '${_reports.length}', Icons.description_outlined, const Color(0xFF3B82F6)),
              _buildMetricCard('Total Pekerja', '$totalPekerja Org', Icons.people_outline, const Color(0xFF10B981)),
              _buildMetricCard('Jenis Pekerjaan', '${_reports.map((e)=>e.jenisPekerjaan).toSet().length}', Icons.category_outlined, const Color(0xFFA855F7)),
              _buildMetricCard('Kepatuhan K3', '${avgK3.toStringAsFixed(0)}%', Icons.health_and_safety_outlined, const Color(0xFFF97316)),
            ],
          ).animate().fade(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 24),

          // Input Form Section
          const Text(
            'Input Progres Pekerjaan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          const Text('Masukkan data pekerjaan harian', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tanggal (Premium Picker)
                const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: _selectedDate == null ? 'Pilih Tanggal' : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                        hintStyle: TextStyle(color: _selectedDate == null ? Colors.grey : Colors.black87, fontWeight: _selectedDate != null ? FontWeight.bold : FontWeight.normal),
                        suffixIcon: const Icon(Icons.calendar_month, color: Color(0xFF2F66A9)),
                        filled: true,
                        fillColor: Colors.blue.shade50.withAlpha(100),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cuaca
                const Text('Cuaca', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cuacaController,
                  decoration: const InputDecoration(
                    hintText: 'Cth: Cerah, Gerimis, Hujan Deras',
                    prefixIcon: Icon(Icons.wb_sunny_outlined, color: Color(0xFF2F66A9)),
                  ),
                ),
                const SizedBox(height: 16),

                // Elemen BCB (Multiple)
                const Text('Elemen BCB (Benda Cagar Budaya - Bisa lebih dari 1)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_selectedElemenBcb.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedElemenBcb.map((elem) {
                      return Chip(
                        label: Text(elem, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: const Color(0xFF2F66A9),
                        deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                        onDeleted: () {
                          setState(() {
                            _selectedElemenBcb.remove(elem);
                          });
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _elemenBcbController,
                        decoration: const InputDecoration(
                          hintText: 'Cth: Pembersihan dinding bata kuno',
                          prefixIcon: Icon(Icons.history_edu_outlined, color: Color(0xFF2F66A9)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_elemenBcbController.text.trim().isNotEmpty) {
                          setState(() {
                            _selectedElemenBcb.add(_elemenBcbController.text.trim());
                            _elemenBcbController.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F66A9),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      child: const Text('Tambah'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Elemen Non BCB (Multiple)
                const Text('Elemen Non BCB (Bisa lebih dari 1)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_selectedElemenNonBcb.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedElemenNonBcb.map((elem) {
                      return Chip(
                        label: Text(elem, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: const Color(0xFF2F66A9),
                        deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                        onDeleted: () {
                          setState(() {
                            _selectedElemenNonBcb.remove(elem);
                          });
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _elemenNonBcbController,
                        decoration: const InputDecoration(
                          hintText: 'Cth: Pemasangan pipa air PVC',
                          prefixIcon: Icon(Icons.account_balance_outlined, color: Color(0xFF2F66A9)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_elemenNonBcbController.text.trim().isNotEmpty) {
                          setState(() {
                            _selectedElemenNonBcb.add(_elemenNonBcbController.text.trim());
                            _elemenNonBcbController.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F66A9),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      child: const Text('Tambah'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Jenis Pekerjaan (Multiple)
                const Text('Jenis Pekerjaan (Bisa lebih dari 1)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_selectedPekerjaan.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedPekerjaan.map((job) {
                      return Chip(
                        label: Text(job, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: const Color(0xFF2F66A9),
                        deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                        onDeleted: () {
                          setState(() {
                            _selectedPekerjaan.remove(job);
                          });
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pekerjaanController,
                        decoration: const InputDecoration(hintText: 'Cth: Pengecoran Lantai 2'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_pekerjaanController.text.trim().isNotEmpty) {
                          setState(() {
                            _selectedPekerjaan.add(_pekerjaanController.text.trim());
                            _pekerjaanController.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F66A9),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      child: const Text('Tambah'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Jenis Bahan (Multiple)
                const Text('Jenis Bahan (Bisa lebih dari 1)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_addedBahan.isNotEmpty) ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _addedBahan.length,
                    itemBuilder: (context, index) {
                      final item = _addedBahan[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${item['nama']} (${item['volume']} ${item['satuan']})",
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                              onPressed: () {
                                setState(() {
                                  _addedBahan.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _bahanController,
                        decoration: const InputDecoration(hintText: 'Nama Bahan'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Vol:'),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _volumeController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSatuan,
                          items: ['Satuan', 'm³', 'kg', 'ton', 'sak', 'unit'].map((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() { _selectedSatuan = newValue!; });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_bahanController.text.trim().isNotEmpty) {
                          setState(() {
                            _addedBahan.add({
                              'nama': _bahanController.text.trim(),
                              'volume': _volumeController.text.trim(),
                              'satuan': _selectedSatuan,
                            });
                            _bahanController.clear();
                            _volumeController.text = '0';
                            _selectedSatuan = 'Satuan';
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F66A9),
                        padding: const EdgeInsets.all(12),
                        minimumSize: Size.zero,
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Jenis Alat (Functional Selectable Chips)
                const Text('Jenis Alat', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: alatChips.map((chip) {
                      final isSelected = _selectedAlat.contains(chip);
                      return FilterChip(
                        label: Text(chip, style: TextStyle(color: isSelected ? Colors.white : Colors.black87)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) { _selectedAlat.add(chip); } else { _selectedAlat.remove(chip); }
                          });
                        },
                        selectedColor: const Color(0xFF2F66A9),
                        backgroundColor: Colors.grey.shade100,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? const Color(0xFF2F66A9) : Colors.grey.shade300),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _alatController,
                        decoration: const InputDecoration(hintText: 'Alat lainnya...'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_alatController.text.trim().isNotEmpty) {
                          setState(() {
                            String newTool = _alatController.text.trim();
                            if (!alatChips.contains(newTool)) { alatChips.add(newTool); }
                            _selectedAlat.add(newTool);
                            _alatController.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F66A9),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      child: const Text('Tambah'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Jumlah Pekerja
                const Text('Jumlah Pekerja', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        controller: _pekerjaController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('Orang'),
                  ],
                ),
                const SizedBox(height: 16),

                // Kelengkapan K3 (Premium Animated Cards)
                const Row(
                  children: [
                    Icon(Icons.health_and_safety_outlined, color: Color(0xFFF97316), size: 20),
                    SizedBox(width: 8),
                    Text('Kelengkapan K3', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: k3Items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    bool isChecked = _k3Checked[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _k3Checked[index] = !isChecked;
                          _updateK3Count();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isChecked ? Colors.orange.shade50 : Colors.white,
                          border: Border.all(
                            color: isChecked ? const Color(0xFFF97316) : Colors.grey.shade300,
                            width: isChecked ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isChecked ? [
                            BoxShadow(color: const Color(0xFFF97316).withAlpha(30), blurRadius: 8, offset: const Offset(0, 4))
                          ] : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                isChecked ? Icons.check_circle : Icons.circle_outlined,
                                key: ValueKey(isChecked),
                                color: isChecked ? const Color(0xFFF97316) : Colors.grey.shade400,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                k3Items[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                                  color: isChecked ? const Color(0xFFC2410C) : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Kelengkapan Terpilih: $_k3Count / 8',
                        style: const TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Upload Foto Progres (Multiple)
                const Text('Upload Foto Progres (Bisa lebih dari 1)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_selectedImages.isNotEmpty) ...[
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        final file = _selectedImages[index];
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 100,
                          height: 100,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(file.path),
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                GestureDetector(
                  onTap: _pickImages,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 32, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        const Text('Ketuk untuk Tambah Foto', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 13)),
                        const Text('Pilih satu atau beberapa foto dari galeri', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Simpan Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveReport,
                    style: ElevatedButton.styleFrom(
                      elevation: 4,
                      shadowColor: const Color(0xFF2F66A9).withAlpha(100),
                    ),
                    child: const Text('SIMPAN PROGRES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ).animate().fade(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1),
          const SizedBox(height: 24),

          // Laporan Terbaru
          const Text(
            'Laporan Terbaru',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _reports.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rekap Progres Harian',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.hourglass_empty, size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                const Text('Belum ada data progres pekerjaan', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text('Mulai tambahkan data menggunakan form di atas', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ).animate().fade(delay: 600.ms, duration: 400.ms).slideY(begin: 0.1)
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _reports.take(3).length, // Show max 3 recent
                      itemBuilder: (context, index) {
                        final report = _reports[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.assignment_turned_in, color: Color(0xFF2F66A9)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(report.jenisPekerjaan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(report.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.people, size: 12, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text('${report.jumlahPekerja} Orang', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fade().slideX();
                      },
                    ),
        ],
      ),
    );
  }
}
