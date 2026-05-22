import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_theme.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const _topUpOptions = [50000, 100000, 200000, 500000];
  int _selectedAmount = 100000;
  String? _syncedUserId;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final wallet = context.watch<WalletProvider>();

    if (user != null && user.id != _syncedUserId) {
      _syncedUserId = user.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<WalletProvider>().watchUser(user.id);
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Ví SmartCarpool')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF00A366)],
                ),
                borderRadius: AppTheme.radiusXxl,
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Số dư khả dụng',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMoney(wallet.balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Nạp ví qua MoMo Sandbox để demo, không trừ tiền thật.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppTheme.radiusXxl,
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nạp tiền demo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _topUpOptions.map((amount) {
                      final selected = amount == _selectedAmount;
                      return ChoiceChip(
                        selected: selected,
                        label: Text(_formatMoney(amount)),
                        onSelected: (_) =>
                            setState(() => _selectedAmount = amount),
                        selectedColor: AppTheme.primary,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppTheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: wallet.isLoading || user == null
                          ? null
                          : () => _openMomoSandbox(context, user.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA50064),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.radiusLg,
                        ),
                        elevation: 0,
                      ),
                      icon: wallet.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.qr_code_2_rounded),
                      label: const Text(
                        'Thanh toán MoMo Sandbox',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Lịch sử ví',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (wallet.transactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppTheme.radiusXxl,
                  boxShadow: AppTheme.cardShadow,
                ),
                child: const Text(
                  'Chưa có giao dịch nào',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.outline),
                ),
              )
            else
              ...wallet.transactions.map((tx) {
                final income = tx.amount >= 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppTheme.radiusXxl,
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            (income ? AppTheme.primary : AppTheme.error)
                                .withValues(alpha: 0.1),
                        child: Icon(
                          income ? Icons.south_west : Icons.north_east,
                          color: income ? AppTheme.primary : AppTheme.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tx.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${income ? '+' : ''}${_formatMoney(tx.amount)}',
                        style: TextStyle(
                          color: income ? AppTheme.primary : AppTheme.error,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _openMomoSandbox(BuildContext context, String userId) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _MomoSandboxScreen(amount: _selectedAmount),
      ),
    );

    if (!context.mounted || ok != true) return;
    final toppedUp = await context.read<WalletProvider>().topUp(
      userId,
      _selectedAmount,
    );
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          toppedUp
              ? 'MoMo Sandbox: đã nạp ${_formatMoney(_selectedAmount)}'
              : context.read<WalletProvider>().error ?? 'Nạp tiền thất bại',
        ),
        backgroundColor: toppedUp ? AppTheme.primary : AppTheme.error,
      ),
    );
  }

  String _formatMoney(int amount) {
    final sign = amount < 0 ? '-' : '';
    final raw = amount.abs().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$sign$raw đ';
  }
}

class _MomoSandboxScreen extends StatefulWidget {
  final int amount;

  const _MomoSandboxScreen({required this.amount});

  @override
  State<_MomoSandboxScreen> createState() => _MomoSandboxScreenState();
}

class _MomoSandboxScreenState extends State<_MomoSandboxScreen> {
  late final String _orderId;
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    _orderId = 'MOMO-SBX-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3F8),
      appBar: AppBar(
        title: const Text('MoMo Sandbox'),
        backgroundColor: const Color(0xFFA50064),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppTheme.radiusXxl,
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFA50064),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'MoMo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Quét QR sandbox',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Giao dịch demo, không phát sinh tiền thật.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.outline, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  _FakeQrCode(seed: _orderId),
                  const SizedBox(height: 18),
                  _infoRow('Số tiền', _formatMoney(widget.amount)),
                  const Divider(height: 24),
                  _infoRow('Đơn hàng', _orderId),
                  const Divider(height: 24),
                  _infoRow('Người nhận', 'Ví SmartCarpool'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _confirming
                    ? null
                    : () async {
                        setState(() => _confirming = true);
                        await Future<void>.delayed(
                          const Duration(milliseconds: 700),
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context, true);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA50064),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusLg,
                  ),
                  elevation: 0,
                ),
                icon: _confirming
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _confirming ? 'Đang xác nhận...' : 'Xác nhận thanh toán test',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _confirming ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFA50064),
                  side: const BorderSide(color: Color(0xFFA50064)),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusLg,
                  ),
                ),
                child: const Text(
                  'Hủy giao dịch',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.outline, fontSize: 13),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatMoney(int amount) {
    final raw = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$raw đ';
  }
}

class _FakeQrCode extends StatelessWidget {
  final String seed;

  const _FakeQrCode({required this.seed});

  @override
  Widget build(BuildContext context) {
    const size = 21;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusLg,
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: SizedBox(
        width: 210,
        height: 210,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: size * size,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: size,
          ),
          itemBuilder: (context, index) {
            final row = index ~/ size;
            final col = index % size;
            final dark = _isFinder(row, col) || _isPayload(row, col);
            return Container(color: dark ? Colors.black : Colors.white);
          },
        ),
      ),
    );
  }

  bool _isFinder(int row, int col) {
    final inTopLeft = row < 7 && col < 7;
    final inTopRight = row < 7 && col >= 14;
    final inBottomLeft = row >= 14 && col < 7;
    if (!inTopLeft && !inTopRight && !inBottomLeft) return false;
    final localRow = row % 14;
    final localCol = col % 14;
    final r = localRow >= 7 ? localRow - 14 : localRow;
    final c = localCol >= 7 ? localCol - 14 : localCol;
    final rr = r.abs();
    final cc = c.abs();
    return rr == 0 || rr == 6 || cc == 0 || cc == 6 || (rr >= 2 && cc >= 2);
  }

  bool _isPayload(int row, int col) {
    final hash = seed.codeUnits.fold<int>(
      0,
      (value, code) => (value * 31 + code) & 0x7fffffff,
    );
    final value = (row * 17 + col * 29 + hash) % 11;
    return value == 0 || value == 3 || value == 7;
  }
}
