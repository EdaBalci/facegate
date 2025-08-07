import 'package:flutter/material.dart';
import 'package:facegate/repositories/log_repository.dart';
import 'package:go_router/go_router.dart';


class LogListScreen extends StatefulWidget {
  const LogListScreen({super.key});

  @override
  State<LogListScreen> createState() => _LogListScreenState();
}

class _LogListScreenState extends State<LogListScreen> {
  final LogRepository _logRepository = LogRepository();

  List<Map<String, dynamic>> _logs = []; // Firestore'dan gelen tüm log kayıtlarını tutar
  List<Map<String, dynamic>> _filteredLogs = []; // Email ve tarihe göre filtrelenmiş loglar

  bool _isLoading = true; // Veriler yüklenirken loading spinner gösterilecek

  final TextEditingController _searchController = TextEditingController(); // Arama kutusu kontrolü
  bool _showFilters = false; // Filtreleme alanı gösterilsin mi?
  DateTime? _selectedDate; // Seçilen tarih (tarih filtresi için)

  @override
  void initState() {
    super.initState();
    _fetchLogs(); // Sayfa açıldığında Firestore'dan verileri al
    _searchController.addListener(_onSearchChanged); // Arama kutusuna her yazıldığında filtreleme yap
  }

  @override
  void dispose() {
    _searchController.dispose(); // Bellek sızıntılarını önlemek için controller'ı dispose et
    super.dispose();
  }

  Future<void> _fetchLogs() async {
    final logs = await _logRepository.getAllLogs(); // Firestore'dan tüm logları getir
    setState(() {
      _logs = logs;
      _filteredLogs = logs; // İlk açıldığında tüm loglar gösterilir
      _isLoading = false;
    });
  }

  // Arama kutusundaki yazıya ve seçilen tarihe göre filtreleme yapar
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase(); // Arama metnini küçük harfe çevir

    setState(() {
      _filteredLogs = _logs.where((log) {
        final email = (log['email'] ?? '').toLowerCase();
        final matchesEmail = email.contains(query); // Email arama kontrolü

        if (_selectedDate != null && log['timestamp'] != null) {
          final logDate = log['timestamp'].toDate();
          final sameDay = logDate.year == _selectedDate!.year &&
              logDate.month == _selectedDate!.month &&
              logDate.day == _selectedDate!.day;
          return matchesEmail && sameDay; // Hem email hem tarih uymalı
        }

        return matchesEmail; // Sadece email filtresi varsa
      }).toList();
    });
  }

  // Takvimden tarih seçme fonksiyonu
  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _onSearchChanged(); // Tarih seçildiğinde filtreyi güncelle
    }
  }

  // Firestore'dan gelen timestamp verisini formatlı stringe çevirir
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Zaman Yok';
    final dt = timestamp.toDate();
    return '${dt.day}.${dt.month}.${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş / Çıkış Kayıtları'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/home'), // Admin paneline geri dön
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Veri yüklenirken spinner göster
          : Column(
              children: [
                // 🔽 Filtreleme alanını açıp kapatma butonu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
                      label: Text(_showFilters ? 'Filtreyi Kapat' : 'Filtrele'),
                      onPressed: () {
                        setState(() {
                           _showFilters = !_showFilters;

                           // Filtre kapatılıyorsa tüm filtreleri sıfırla
                           if (!_showFilters) {
                              _searchController.clear();      // Arama kutusunu temizle
                              _selectedDate = null;           // Tarih filtresini sıfırla
                             _filteredLogs = _logs;          // Tüm logları tekrar göster
                          }
                       });
                    },

                    ),
                  ),
                ),

                // 🔽 Filtreleme kutuları (sadece _showFilters true ise görünür)
                if (_showFilters) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Email ile ara',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: InkWell(
                      onTap: () => _pickDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tarih seç',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'Tarih seçilmedi'
                              : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Giriş/çıkış loglarının listesi
                Expanded(
                  child: _filteredLogs.isEmpty
                      ? const Center(child: Text('Sonuç bulunamadı.')) // Arama sonucu yoksa
                      : ListView.builder(
                          itemCount: _filteredLogs.length,
                          itemBuilder: (context, index) {
                            final log = _filteredLogs[index];
                            return ListTile(
                              leading: Icon(
                                log['action'] == 'entry'
                                    ? Icons.login
                                    : Icons.logout,
                                color: log['action'] == 'entry'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(log['email'] ?? 'Bilinmeyen'),
                              subtitle: Text(
                                '${log['action'] == 'entry' ? 'Giriş' : 'Çıkış'} • ${_formatTimestamp(log['timestamp'])}',
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
