import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/session/session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/app_card.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_chip.dart';

class ComplaintsScreen extends StatefulWidget {
  final bool embedded;
  const ComplaintsScreen({super.key, this.embedded = false});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: 2, vsync: this, initialIndex: 0);

  final _title = TextEditingController();
  final _desc = TextEditingController();

  @override
  void dispose() {
    _tab.dispose();
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(S.supportTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: TabBar(
              controller: _tab,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(11),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              tabs: [
                Tab(text: S.myBarcode),
                Tab(text: S.complaintsTab),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: TabBarView(
        controller: _tab,
        children: [
          const _BarcodeTab(),
          _ComplaintsTab(
            title: _title,
            desc: _desc,
            onSubmit: () {
              final t = _title.text.trim();
              final d = _desc.text.trim();
              if (t.isEmpty && d.isEmpty) return;
              appStore.addComplaint(
                title: t.isEmpty ? d : t,
                description: d,
              );
              _title.clear();
              _desc.clear();
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.textPrimary,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  content: Text(S.complaintSubmitted),
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

class _BarcodeTab extends StatefulWidget {
  const _BarcodeTab();
  @override
  State<_BarcodeTab> createState() => _BarcodeTabState();
}

class _BarcodeTabState extends State<_BarcodeTab> {
  final GlobalKey _qrKey = GlobalKey();
  static const String _code = 'GF-9C-2031';
  bool _busy = false;

  /// What the QR actually encodes: a pipe-delimited payload the agent scanner
  /// parses (`GF|<name>|<code>`), falling back to the bare code when no name is
  /// set yet. This is a real, camera-scannable QR.
  String get _payload {
    final name = Session.nameNotifier.value.trim();
    return name.isEmpty ? _code : 'GF|$name|$_code';
  }

  Future<Uint8List?> _capture() async {
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _share() async {
    final bytes = await _capture();
    final text = L10n.isAr
        ? 'رمز QR الخاص بي في GasFlow: $_code'
        : 'My GasFlow QR code: $_code';
    if (bytes != null) {
      await SharePlus.instance.share(ShareParams(
        text: text,
        files: [
          XFile.fromData(bytes, mimeType: 'image/png', name: 'gasflow_qr.png'),
        ],
      ));
    } else {
      await SharePlus.instance.share(ShareParams(text: text));
    }
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    final bytes = await _capture();
    String msg;
    if (bytes != null) {
      try {
        final uid = AuthService.currentUser?.uid ?? 'guest';
        await StorageService.uploadBytes('barcodes/$uid.png', bytes);
        msg = L10n.isAr
            ? 'تم حفظ الرمز في حسابك ☁️'
            : 'QR saved to your account ☁️';
      } catch (_) {
        msg = L10n.isAr ? 'تعذّر الحفظ، حاول مجدداً' : 'Could not save, try again';
      }
    } else {
      msg = L10n.isAr ? 'تعذّر الحفظ' : 'Could not save';
    }
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(S.yourUniqueBarcode, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 4),
              Text(S.showToAgent, style: AppTextStyles.bodySmall),
              const SizedBox(height: 22),
              RepaintBoundary(
                key: _qrKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: QrImageView(
                    data: _payload,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.primaryDark,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _code,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primaryDark,
                    letterSpacing: 2.4,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _share,
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: Text(S.share),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _save,
                      icon: _busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.download_rounded, size: 18),
                      label: Text(S.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionHeader(title: S.howItWorks),
        const SizedBox(height: 12),
        const _HowItWorks(),
      ],
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();
  @override
  Widget build(BuildContext context) {
    final items = [
      _HW(Icons.person_add_alt_rounded, S.getApproved, S.getApprovedDesc),
      _HW(Icons.qr_code_2_rounded, S.receiveBarcode, S.receiveBarcodeDesc),
      _HW(Icons.local_shipping_rounded, S.orderAnytime, S.orderAnytimeDesc),
    ];
    return Column(
      children: items
          .map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(i.icon,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i.title, style: AppTextStyles.titleMedium),
                          const SizedBox(height: 2),
                          Text(i.desc, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _HW {
  final IconData icon;
  final String title;
  final String desc;
  _HW(this.icon, this.title, this.desc);
}

class _ComplaintsTab extends StatelessWidget {
  final TextEditingController title;
  final TextEditingController desc;
  final VoidCallback onSubmit;

  const _ComplaintsTab({
    required this.title,
    required this.desc,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) {
        final list = appStore.complaints;
        return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.submitComplaint, style: AppTextStyles.titleLarge),
              const SizedBox(height: 4),
              Text(S.submitComplaintDesc, style: AppTextStyles.bodySmall),
              const SizedBox(height: 16),
              CustomTextField(
                controller: title,
                label: S.title,
                hint: S.titleHint,
                icon: Icons.title_rounded,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: desc,
                label: S.description,
                hint: S.descriptionHint,
                icon: Icons.description_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: S.sendComplaint,
                icon: Icons.send_rounded,
                onPressed: onSubmit,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionHeader(title: S.previousComplaints),
        const SizedBox(height: 12),
        if (list.isEmpty)
          EmptyState(
            icon: Icons.inbox_rounded,
            title: S.nothingYet,
            message: S.nothingYetDesc,
          )
        else
          ...list.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(c.title,
                              style: AppTextStyles.titleMedium),
                        ),
                        StatusChip(status: c.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(c.description, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.tag_rounded,
                            size: 14, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text('#${c.id}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textHint,
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
        );
      },
    );
  }
}

