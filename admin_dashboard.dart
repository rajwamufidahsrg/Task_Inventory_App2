import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final UserAccount user;

  const AdminDashboardScreen({super.key, required this.user});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedStatusFilter = 'All';

  // --- Fitur Approval User (Khusus Super Admin) ---
  void _approveUser(UserAccount targetUser, bool approve) {
    setState(() {
      if (approve) {
        targetUser.isApproved = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Akun "${targetUser.username}" berhasil disetujui!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        registeredUsers.remove(targetUser);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pendaftaran "${targetUser.username}" ditolak dan dihapus.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });
  }

  // --- Fitur Hapus User (Super Admin & Admin Biasa) ---
  void _deleteUser(UserAccount targetUser) {
    // Proteksi: Tidak ada yang bisa menghapus Super Admin
    if (targetUser.role == 'Super Admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akses Ditolak! Akun Super Admin tidak dapat dihapus.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Admin biasa tidak bisa menghapus sesama Admin jika diinginkan, atau cukup hapus user
    setState(() {
      registeredUsers.remove(targetUser);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Akun "${targetUser.username}" berhasil dihapus dari sistem.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // --- Fitur Ubah Status Task / Inventaris ---
  void _changeStatus(ItemModel item) {
    String tempStatus = item.status;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ADMIN ACTION CONTROL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Color(0xFFC2410C),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Update Status Record',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    'Item: "${item.title}"',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  _buildStatusOption('Pending Approval', 'Pending', tempStatus, Colors.red, (val) => setStateModal(() => tempStatus = val!)),
                  _buildStatusOption('In-Progress (Proses)', 'Proses', tempStatus, Colors.amber, (val) => setStateModal(() => tempStatus = val!)),
                  _buildStatusOption('Completed (Selesai)', 'Selesai', tempStatus, Colors.green, (val) => setStateModal(() => tempStatus = val!)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC2410C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          item.status = tempStatus;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Simpan Perubahan Status', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusOption(String title, String value, String groupValue, Color color, ValueChanged<String?> onChanged) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              activeColor: color,
              onChanged: onChanged,
            ),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? color : Colors.black87)),
          ],
        ),
      ),
    );
  }

  // --- Widget Pengelolaan Registrasi Baru (Khusus Super Admin) ---
  Widget _buildPendingApprovalSection() {
    if (widget.user.role != 'Super Admin') return const SizedBox.shrink();

    final pendingUsers = registeredUsers.where((u) => !u.isApproved).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: Color(0xFFC2410C)),
              const SizedBox(width: 8),
              Text(
                'Persetujuan Pendaftaran User Baru (${pendingUsers.length})',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFC2410C)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          pendingUsers.isEmpty
              ? const Text('Tidak ada antrean pendaftaran baru.', style: TextStyle(fontSize: 12, color: Colors.grey))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingUsers.length,
                  itemBuilder: (context, index) {
                    final pendingUser = pendingUsers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(pendingUser.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Role: ${pendingUser.role} ${pendingUser.userAccess != null ? "(${pendingUser.userAccess})" : ""}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              tooltip: 'Setujui',
                              onPressed: () => _approveUser(pendingUser, true),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              tooltip: 'Tolak',
                              onPressed: () => _approveUser(pendingUser, false),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  // --- Widget Kelola Semua User Sistem ---
  Widget _buildUserManagementSection() {
    final allApprovedUsers = registeredUsers.where((u) => u.isApproved && u.username != widget.user.username).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manajemen Akun Terdaftar',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allApprovedUsers.length,
            itemBuilder: (context, index) {
              final u = allApprovedUsers[index];
              return ListTile(
                dense: true,
                title: Text(u.username, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Role: ${u.role}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _deleteUser(u),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = globalItemList.where((item) {
      if (_selectedStatusFilter == 'All') return true;
      return item.status == _selectedStatusFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text('${widget.user.role} Dashboard: ${widget.user.username}', style: const TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Persetujuan Pendaftaran (Khusus Super Admin)
            _buildPendingApprovalSection(),

            // Section Hapus & Kelola User
            _buildUserManagementSection(),

            // Title Record System
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Manajemen Record Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${filteredList.length} Items', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),

            // Item Record List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Kategori: ${item.category} | By: ${item.createdBy}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(label: Text(item.status, style: const TextStyle(fontSize: 10))),
                        IconButton(
                          icon: const Icon(Icons.edit_note, color: Color(0xFFC2410C)),
                          onPressed: () => _changeStatus(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}