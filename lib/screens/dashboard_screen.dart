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

  // Form Controllers & State
  String _selectedSatuan = 'Satuan';
  DateTime? _selectedDate;
  final TextEditingController _pekerjaanController = TextEditingController();
  final TextEditingController _bahanController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController(text: '0');
  final TextEditingController _pekerjaController = TextEditingController(text: '1');
  
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
  XFile? _selectedImage;
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
      _bahanController.clear();
      _volumeController.text = '0';
      _pekerjaController.text = '1';
      _selectedSatuan = 'Satuan';
      _k3Checked = List.generate(8, (_) => false);
      _updateK3Count();
      _selectedAlat.clear();
      _selectedImage = null;
    });
  }

  Future<void> _saveReport() async {
    if (_selectedDate == null || _pekerjaanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi Tanggal dan Jenis Pekerjaan!'), backgroundColor: Colors.red),
      );
      return;
    }

    final newReport = ReportModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectName: 'Pembangunan Gedung A',
      date: DateFormat('dd/MM/yyyy').format(_selectedDate!),
      jenisPekerjaan: _pekerjaanController.text,
      jenisBahan: _bahanController.text,
      volume: _volumeController.text,
      satuan: _selectedSatuan,
      jenisAlat: List.from(_selectedAlat),
      jumlahPekerja: int.tryParse(_pekerjaController.text) ?? 1,
      k3Count: _k3Count,
      imagePath: _selectedImage?.path,
    );

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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama Proyek:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    SizedBox(height: 4),
                    Text('Pembangunan Gedung A', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
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

                // Jenis Pekerjaan
                const Text('Jenis Pekerjaan', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _pekerjaanController,
                  decoration: const InputDecoration(hintText: 'Cth: Pengecoran Lantai 2'),
                ),
                const SizedBox(height: 16),

                // Jenis Bahan
                const Text('Jenis Bahan', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
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

                // Upload Foto Progres
                const Text('Upload Foto Progres', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedImage != null ? const Color(0xFF2F66A9) : Colors.grey.shade300,
                        style: BorderStyle.solid,
                        width: _selectedImage != null ? 2 : 1,
                      ),
                    ),
                    child: _selectedImage != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, color: Color(0xFF2F66A9), size: 32),
                              const SizedBox(height: 8),
                              const Text('Foto Berhasil Dipilih!', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2F66A9))),
                              Text(_selectedImage!.name, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              const Text('Ketuk untuk Memilih Foto', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                              const Text('Unggah foto progres lapangan', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
