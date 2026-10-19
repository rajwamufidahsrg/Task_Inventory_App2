// lib/models/item_model.dart

class UserAccount {
  final String username;
  final String password;
  final String role; // 'Super Admin', 'Admin', 'Super User', atau 'User'
  bool isApproved;   // Status persetujuan Super Admin
  final String? userAccess; // Khusus User biasa: 'Task' atau 'Inventaris'

  UserAccount({
    required this.username,
    required this.password,
    required this.role,
    this.isApproved = false,
    this.userAccess,
  });
}

class ItemModel {
  final String id;
  final String title;
  final String category;
  String status;
  final String createdBy;

  ItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.createdBy,
  });
}

// Data Dummy Tersimpan
List<UserAccount> registeredUsers = [
  // Super Admin Bawaan
  UserAccount(
    username: 'superadmin',
    password: 'password123',
    role: 'Super Admin',
    isApproved: true,
  ),
  UserAccount(
    username: 'admin1',
    password: 'password123',
    role: 'Admin',
    isApproved: true,
  ),
  UserAccount(
    username: 'superuser1',
    password: 'password123',
    role: 'Super User',
    isApproved: true,
  ),
  UserAccount(
    username: 'user1',
    password: 'password123',
    role: 'User',
    isApproved: true,
    userAccess: 'Task',
  ),
];

List<ItemModel> globalItemList = [
  ItemModel(
    id: '1',
    title: 'Perbaikan PC Lab 1',
    category: 'Inventaris',
    status: 'Pending',
    createdBy: 'user1',
  ),
  ItemModel(
    id: '2',
    title: 'Update Module Flutter',
    category: 'Task',
    status: 'Proses',
    createdBy: 'user1',
  ),
];