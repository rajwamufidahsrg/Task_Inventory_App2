import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'login_screen.dart';
import 'add_item_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  final UserAccount user;

  const UserDashboardScreen({super.key, required this.user});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  String _selectedCategoryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    // Filter list berdasarkan hak akses role user
    final filteredList = globalItemList.where((item) {
      // 1. Jika User Biasa, kunci kategorinya sesuai userAccess
      if (widget.user.role == 'User' && widget.user.userAccess != null) {
        return item.category == widget.user.userAccess;
      }
      // 2. Jika Super User, bisa filter bebas (Task / Inventaris / All)
      if (_selectedCategoryFilter == 'All') return true;
      return item.category == _selectedCategoryFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.user.role} Workspace',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'User: ${widget.user.username} ${widget.user.userAccess != null ? "(${widget.user.userAccess})" : ""}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFCBD5E1)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Welcome
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang, ${widget.user.username}!',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.user.role == 'Super User'
                              ? 'Akses Penuh: Anda dapat mengelola Task & Inventaris.'
                              : 'Akses Terbatas: Anda mengelola kategori ${widget.user.userAccess}.',
                          style: const TextStyle(color: Color(0xFFCCFBF1), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.analytics_rounded, size: 48, color: Colors.white30),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Filter Chips (Hanya muncul untuk Super User)
            if (widget.user.role == 'Super User') ...[
              Row(
                children: ['All', 'Task', 'Inventaris'].map((category) {
                  final isSelected = _selectedCategoryFilter == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: const Color(0xFF0F766E),
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedCategoryFilter = category;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Item Record List
            filteredList.isEmpty
                ? const Center(child: Text('Belum ada data tersedia'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Kategori: ${item.category} | By: ${item.createdBy}'),
                          trailing: Chip(
                            label: Text(item.status, style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItemScreen(user: widget.user),
            ),
          );
          if (result == true) {
            setState(() {});
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Entry'),
      ),
    );
  }
}