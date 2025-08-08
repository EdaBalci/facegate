import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignRolesScreen extends StatefulWidget {
  const AssignRolesScreen({super.key});

  @override
  State<AssignRolesScreen> createState() => _AssignRolesScreenState();
}

class _AssignRolesScreenState extends State<AssignRolesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<DocumentSnapshot> _personnel = [];
  List<DocumentSnapshot> _filteredPersonnel = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

 
  final List<String> _roles = [
    'Sunucu Odası Operatörü',
    'Veri Güvenliği Uzmanı',
  ];

  @override
  void initState() {
    super.initState();
    _fetchApprovedPersonnel();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //firestoredan onaylı personelleri getir, admin hariç
  Future<void> _fetchApprovedPersonnel() async {
    final currentUserEmail = _auth.currentUser?.email;

    final snapshot = await _firestore
        .collection('users')
        .where('isApproved', isEqualTo: true)
        .get();

    final filtered = snapshot.docs.where((doc) {
      final data = doc.data();
      return data['email'] != currentUserEmail;
    }).toList();

    setState(() {
      _personnel = filtered;
      _filteredPersonnel = filtered; 
      _isLoading = false;
    });
  }

  //Email ile filtreleme yapma
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredPersonnel = _personnel.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final email = (data['email'] ?? '').toLowerCase();
        return email.contains(query);
      }).toList();
    });
  }

  //Görevi firestoreda güncellemek için
  Future<void> _assignRole(String userId, String newRole) async {
    await _firestore.collection('users').doc(userId).update({
      'gorev': newRole,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Görev başarıyla atandı.')),
    );

    _fetchApprovedPersonnel(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Görev Atama'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/home'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Email ile ara',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredPersonnel.isEmpty
                      ? const Center(child: Text('Sonuç bulunamadı.'))
                      : ListView.builder(
                          itemCount: _filteredPersonnel.length,
                          itemBuilder: (context, index) {
                            final userDoc = _filteredPersonnel[index];
                            final userData = userDoc.data() as Map<String, dynamic>;
                            final email = userData['email'] ?? 'Bilinmeyen';
                            final currentRole = userData['gorev'] as String?;
                            final userId = userDoc.id;

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                title: Text(email),
                                subtitle: Text('Mevcut Görev: ${currentRole ?? 'Atanmadı'}'),
                                trailing: DropdownButton<String>(
                                  value: _roles.contains(currentRole) ? currentRole : null,
                                  hint: const Text('Görev ata'),
                                  items: _roles.map((role) {
                                    return DropdownMenuItem<String>(
                                      value: role,
                                      child: Text(role),
                                    );
                                  }).toList(),
                                  onChanged: (selectedRole) {
                                    if (selectedRole != null) {
                                      _assignRole(userId, selectedRole);
                                    }
                                  },
                                ),
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
