import 'package:facegate/widgets/translate_switcher.dart';
import 'package:flutter/material.dart';
import 'package:facegate/repositories/log_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:facegate/l10n/locale_keys.g.dart';
import 'package:lottie/lottie.dart';

class LogListScreen extends StatefulWidget {
  const LogListScreen({super.key});

  @override
  State<LogListScreen> createState() => _LogListScreenState();
}

class _LogListScreenState extends State<LogListScreen> {
  final LogRepository _logRepository = LogRepository();

  // Firestore'dan gelen tüm log kayıtlarını tutar
  List<Map<String, dynamic>> _logs = [];
  // Email ve tarihe göre filtrelenmiş loglar
  List<Map<String, dynamic>> _filteredLogs = [];

  // Veriler yüklenirken loading spinner gösterilecek
  bool _isLoading = true;

  // Arama kutusu kontrolü
  final TextEditingController _searchController = TextEditingController();
  // Filtreleme alanı gösterilsin mi?
  bool _showFilters = false;
  // Seçilen tarih (tarih filtresi için)
  DateTime? _selectedDate;

  //Tek noktadan kullanılacak Lottie loader helper'ı
  Widget _lottieLoader({double size = 120}) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/animations/loader.json', 
        repeat: true,
        animate: true,
        fit: BoxFit.contain,
      ),
    );
  }

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
      lastDate: DateTime.now(),
      cancelText: LocaleKeys.common_cancel.tr(), // i18n

    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _onSearchChanged(); // Tarih seçildiğinde filtreyi güncelle
    }
  }

  // Firestore'dan gelen timestamp verisini locale'e duyarlı formatlı stringe çevirir
  String _formatTimestamp(BuildContext context, dynamic timestamp) {
    if (timestamp == null) return LocaleKeys.logs_empty.tr();
    final dt = timestamp.toDate();
    final locale = context.locale.toString(); // 'tr' | 'en'
    return DateFormat('dd.MM.yyyy HH:mm', locale).format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.logs_title.tr()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/admin/home'); // fallback
            }
          },
        ),
        actions:  [          translate(context),
        ],
      ),
      body: _isLoading
          ? Center(child: _lottieLoader(size: 140)) // Veri yüklenirken animasyon
          : Column(
              children: [
                Text(LocaleKeys.logs_filter.tr()),
                // Filtreleme alanını açıp kapatma butonu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
                      label: Text(
                        _showFilters
                            ? LocaleKeys.logs_close_filter.tr()
                            : LocaleKeys.logs_filter.tr(),
                      ),
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;

                          // Filtre kapatılıyorsa tüm filtreleri sıfırla
                          if (!_showFilters) {
                            _searchController.clear(); // Arama kutusunu temizle
                            _selectedDate = null; // Tarih filtresini sıfırla
                            _filteredLogs = _logs; // Tüm logları tekrar göster
                          }
                        });
                      },
                    ),
                  ),
                ),

                // Filtreleme kutuları (sadece _showFilters true ise görünür)
                if (_showFilters) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: LocaleKeys.logs_search_by_email.tr(),
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: InkWell(
                      onTap: () => _pickDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: LocaleKeys.logs_pick_date.tr(),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? LocaleKeys.logs_no_date_selected.tr()
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
                      ? Center(child: Text(LocaleKeys.logs_no_results.tr()))
                      : ListView.builder(
                          itemCount: _filteredLogs.length,
                          itemBuilder: (context, index) {
                            final log = _filteredLogs[index];
                            final actionIsEntry = log['action'] == 'entry';
                            final email = (log['email'] as String?)?.trim();
                            final when = _formatTimestamp(context, log['timestamp']);

                            return ListTile(
                              leading: Icon(
                                actionIsEntry ? Icons.login : Icons.logout,
                                color: actionIsEntry ? Colors.green : Colors.red,
                              ),
                              title: Text(
                                email?.isNotEmpty == true
                                    ? email!
                                    : LocaleKeys.logs_unknown_email.tr(),
                              ),
                              subtitle: Text(
                                '${actionIsEntry ? LocaleKeys.logs_entry.tr() : LocaleKeys.logs_exit.tr()} • $when',
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
