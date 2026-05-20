import 'dart:typed_data';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/history_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploadingAvatar = false;
  Uint8List? _localAvatarBytes;

  Future<void> _pickAndUploadAvatar(AppUser user) async {
    if (_uploadingAvatar) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final Uint8List? bytes = file.bytes;
    if (bytes == null) return;

    setState(() {
      _localAvatarBytes = bytes;
      _uploadingAvatar = true;
    });
    try {
      final ext = file.extension ?? 'jpg';
      final url = await AuthService.uploadAvatarBytes(
        userId: user.id,
        bytes: bytes,
        fileName: 'avatar.$ext',
      );
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final ok = await auth.updateProfile(user.copyWith(avatarUrl: url));
      if (!ok) {
        throw Exception(auth.error ?? 'Khong the cap nhat avatar');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da cap nhat anh dai dien')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Khong upload duoc avatar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = MockData.tripHistory;
    final user = context.watch<AuthProvider>().currentUser;
    final displayName = user?.fullName ?? 'Nguyen Minh Tuan';
    final initials = user?.initials ?? 'MT';
    final rating = user?.rating.toStringAsFixed(1) ?? '4.8';
    final totalTrips = user?.totalTrips.toString() ?? '152';
    final avatarUrl = user?.avatarUrl;
    final avatarImage = _localAvatarBytes != null
        ? MemoryImage(_localAvatarBytes!)
        : _avatarImage(avatarUrl);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Text(
                      'Ca nhan',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceContainerLow,
                        borderRadius: AppTheme.radiusFull,
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: AppTheme.onSurface,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF00A366)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppTheme.radiusXxl,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: user == null ? null : () => _pickAndUploadAvatar(user),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            backgroundImage: avatarImage,
                            child: avatarImage == null
                                ? Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22,
                                    ),
                                  )
                                : null,
                          ),
                          if (_uploadingAvatar)
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 12,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: AppTheme.radiusFull,
                                ),
                                child: const Text(
                                  'Thanh vien bac',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                rating,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    _statCard(context, totalTrips, 'Chuyen di'),
                    const SizedBox(width: 8),
                    _statCard(context, rating, 'Danh gia'),
                    const SizedBox(width: 8),
                    _statCard(context, '2.4M', 'Tiet kiem'),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Ban dong hanh rut',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 16,
                      ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _companionCard(
                      context,
                      'Tran Thi Bich',
                      'Thuong xuyen di cung',
                    ),
                    const SizedBox(width: 12),
                    _companionCard(context, 'Le Hoang Nam', 'Da di 5 chuyen'),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lich su chuyen di',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 16,
                          ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/my-trips'),
                      child: const Text(
                        'Xem tat ca',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => HistoryCard(trip: history[i]),
                childCount: history.length,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppTheme.radiusXxl,
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      _menuItem(
                        context,
                        Icons.confirmation_number_outlined,
                        'Chuyen di cua toi',
                        onTap: () => Navigator.pushNamed(context, '/my-trips'),
                      ),
                      _menuDivider(),
                      _menuItem(
                        context,
                        Icons.directions_car_outlined,
                        'Phuong tien cua toi',
                        onTap: () => Navigator.pushNamed(context, '/vehicles'),
                      ),
                      _menuDivider(),
                      _menuItem(context, Icons.payment, 'Phuong thuc thanh toan'),
                      _menuDivider(),
                      _menuItem(
                        context,
                        Icons.notifications_outlined,
                        'Thong bao',
                        onTap: () => Navigator.pushNamed(context, '/notifications'),
                      ),
                      _menuDivider(),
                      _menuItem(context, Icons.help_outline, 'Trung tam ho tro'),
                      _menuDivider(),
                      _menuItem(
                        context,
                        Icons.logout,
                        'Dang xuat',
                        isDestructive: true,
                        onTap: () {
                          context.read<AuthProvider>().logout();
                          Navigator.pushReplacementNamed(context, '/');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusXxl,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _avatarImage(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) return null;
    if (avatarUrl.startsWith('data:image/')) {
      final commaIndex = avatarUrl.indexOf(',');
      if (commaIndex == -1) return null;
      final encoded = avatarUrl.substring(commaIndex + 1);
      return MemoryImage(base64Decode(encoded));
    }
    return NetworkImage(avatarUrl);
  }

  Widget _companionCard(BuildContext context, String name, String subtitle) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusXxl,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryContainer.withValues(alpha: 0.3),
            child: Text(
              name[0],
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: AppTheme.outline),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.error : AppTheme.onSurface,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDestructive ? AppTheme.error : AppTheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.outline.withValues(alpha: 0.5),
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _menuDivider() {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppTheme.onSurface.withValues(alpha: 0.05),
    );
  }
}
