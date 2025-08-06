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
  List<Map<String, dynamic>> _logs = []; //logs kayıtlarını tutacak liste
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();//sayfa açıldığında çağırılır
  }

  Future<void> _fetchLogs() async {
    final logs = await _logRepository.getAllLogs();//firestoredaki verileri çeker
    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

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
          onPressed: () {
            context.go('/admin/home');
          },
          )
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(child: Text('Henüz kayıt yok.'))
              : ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
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
    );
  }
}
