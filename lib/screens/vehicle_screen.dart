import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vehicle.dart';
import '../providers/auth_provider.dart';
import '../services/vehicle_service.dart';
import '../theme/app_theme.dart';

class VehicleScreen extends StatelessWidget {
  const VehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Phương tiện của tôi'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (user != null)
            IconButton(
              onPressed: () => _showVehicleSheet(context, ownerId: user.id),
              icon: const Icon(Icons.add_circle_outline),
            ),
        ],
      ),
      body: user == null
          ? _EmptyLoginState(
              onLogin: () => Navigator.pushNamed(context, '/login'),
            )
          : StreamBuilder<List<Vehicle>>(
              stream: VehicleService.watchVehicles(user.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Không tải được phương tiện: ${snapshot.error}',
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final vehicles = snapshot.data ?? [];
                if (vehicles.isEmpty) {
                  return _EmptyVehiclesState(
                    onAdd: () => _showVehicleSheet(context, ownerId: user.id),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  itemCount: vehicles.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return _VehicleCard(
                      vehicle: vehicle,
                      onEdit: () => _showVehicleSheet(
                        context,
                        ownerId: user.id,
                        existing: vehicle,
                      ),
                      onDelete: () => _confirmDelete(context, vehicle),
                      onSetDefault: vehicle.isDefault
                          ? null
                          : () async {
                              await VehicleService.setDefaultVehicle(
                                user.id,
                                vehicle.id,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã đặt xe mặc định'),
                                  ),
                                );
                              }
                            },
                    );
                  },
                );
              },
            ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showVehicleSheet(context, ownerId: user.id),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Thêm xe'),
            ),
    );
  }

  void _confirmDelete(BuildContext context, Vehicle vehicle) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa phương tiện'),
        content: Text('Xóa ${vehicle.name} (${vehicle.licensePlate})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await VehicleService.deleteVehicle(vehicle.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa phương tiện')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showVehicleSheet(
    BuildContext context, {
    required String ownerId,
    Vehicle? existing,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VehicleFormSheet(ownerId: ownerId, existing: existing),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSetDefault;

  const _VehicleCard({
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusXxl,
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: vehicle.isDefault
              ? AppTheme.primary.withValues(alpha: 0.2)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer.withValues(alpha: 0.18),
                  borderRadius: AppTheme.radiusLg,
                ),
                child: Icon(
                  vehicle.type == 'car'
                      ? Icons.directions_car
                      : Icons.two_wheeler,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vehicle.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (vehicle.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: AppTheme.radiusFull,
                            ),
                            child: const Text(
                              'Mặc định',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.licensePlate,
                      style: const TextStyle(
                        color: AppTheme.outline,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${vehicle.typeLabel} • ${vehicle.color} • ${vehicle.seats} chỗ',
                      style: const TextStyle(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'default':
                      onSetDefault?.call();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                  if (!vehicle.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Text('Đặt mặc định'),
                    ),
                  const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VehicleFormSheet extends StatefulWidget {
  final String ownerId;
  final Vehicle? existing;

  const _VehicleFormSheet({required this.ownerId, this.existing});

  @override
  State<_VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends State<_VehicleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _plateCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _seatsCtrl;
  late final bool _isEditing;
  late String _type;
  late bool _isDefault;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final vehicle = widget.existing;
    _isEditing = vehicle != null;
    _nameCtrl = TextEditingController(text: vehicle?.name ?? '');
    _plateCtrl = TextEditingController(text: vehicle?.licensePlate ?? '');
    _colorCtrl = TextEditingController(text: vehicle?.color ?? 'Trắng');
    _type = vehicle?.type ?? 'car';
    _seatsCtrl = TextEditingController(
      text: (vehicle?.seats ?? _defaultSeatsForType(_type)).toString(),
    );
    _isDefault = vehicle?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _plateCtrl.dispose();
    _colorCtrl.dispose();
    _seatsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.existing == null
                      ? 'Thêm phương tiện'
                      : 'Sửa phương tiện',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _field(_nameCtrl, 'Tên xe', 'Toyota Vios'),
            const SizedBox(height: 12),
            _field(_plateCtrl, 'Biển số', '51G-123.45'),
            const SizedBox(height: 12),
            _field(_colorCtrl, 'Màu xe', 'Trắng'),
            const SizedBox(height: 12),
            _field(
              _seatsCtrl,
              'Số chỗ',
              _defaultSeatsForType(_type).toString(),
              keyboardType: TextInputType.number,
              helperText: _type == 'motorbike'
                  ? 'Xe máy thường là 2 chỗ'
                  : 'Ô tô thường là 5 hoặc 7 chỗ',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _typeChip('Ô tô', 'car'),
                const SizedBox(width: 8),
                _typeChip('Xe máy', 'motorbike'),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Đặt làm xe mặc định'),
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusLg,
                  ),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.existing == null ? 'Thêm xe' : 'Lưu thay đổi',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        filled: true,
        fillColor: AppTheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: AppTheme.radiusLg,
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Không được để trống';
        }

        if (controller == _seatsCtrl) {
          final seats = int.tryParse(value.trim());
          if (seats == null || seats <= 0) {
            return 'Số chỗ không hợp lệ';
          }
          if (_type == 'motorbike' && seats > 2) {
            return 'Xe máy chỉ nên để tối đa 2 chỗ';
          }
          if (_type == 'car' && seats < 4) {
            return 'Ô tô nên từ 4 chỗ trở lên';
          }
        }

        return null;
      },
    );
  }

  Widget _typeChip(String label, String value) {
    final selected = _type == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _type = value;
          final currentSeats = int.tryParse(_seatsCtrl.text.trim());

          if (!_isEditing || currentSeats == null) {
            _seatsCtrl.text = _defaultSeatsForType(value).toString();
            return;
          }

          if (value == 'motorbike' && currentSeats > 2) {
            _seatsCtrl.text = '2';
          } else if (value == 'car' && currentSeats < 4) {
            _seatsCtrl.text = _defaultSeatsForType(value).toString();
          }
        });
      },
      selectedColor: AppTheme.primary.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        color: selected ? AppTheme.primary : AppTheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: selected ? AppTheme.primary : AppTheme.outlineVariant,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final seats =
        int.tryParse(_seatsCtrl.text.trim()) ?? _defaultSeatsForType(_type);
    setState(() => _saving = true);

    try {
      if (widget.existing == null) {
        await VehicleService.createVehicle(
          ownerId: widget.ownerId,
          name: _nameCtrl.text.trim(),
          licensePlate: _plateCtrl.text.trim(),
          type: _type,
          color: _colorCtrl.text.trim(),
          seats: seats,
          isDefault: _isDefault,
        );
      } else {
        await VehicleService.updateVehicle(
          widget.existing!.copyWith(
            name: _nameCtrl.text.trim(),
            licensePlate: _plateCtrl.text.trim(),
            type: _type,
            color: _colorCtrl.text.trim(),
            seats: seats,
            isDefault: _isDefault,
          ),
        );
        if (_isDefault) {
          await VehicleService.setDefaultVehicle(
            widget.ownerId,
            widget.existing!.id,
          );
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể lưu xe: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  int _defaultSeatsForType(String type) {
    return type == 'motorbike' ? 2 : 5;
  }
}

class _EmptyVehiclesState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyVehiclesState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: AppTheme.outline,
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có phương tiện nào',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Thêm xe để dễ tạo chuyến và quản lý xe mặc định.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.outline),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Thêm xe'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLoginState extends StatelessWidget {
  final VoidCallback onLogin;

  const _EmptyLoginState({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: AppTheme.outline),
            const SizedBox(height: 16),
            const Text(
              'Vui lòng đăng nhập',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bạn cần đăng nhập để quản lý phương tiện.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.outline),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLg),
              ),
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
