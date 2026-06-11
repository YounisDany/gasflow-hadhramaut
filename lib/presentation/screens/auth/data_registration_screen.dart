import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/prefs.dart';
import '../../../core/session/session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/store/app_store.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/lang_toggle.dart';
import '../../widgets/location_picker.dart';
import '../../widgets/primary_button.dart';

enum RegistrationRole { citizen, agent }

class DataRegistrationScreen extends StatefulWidget {
  const DataRegistrationScreen({super.key});

  @override
  State<DataRegistrationScreen> createState() => _DataRegistrationScreenState();
}

class _DataRegistrationScreenState extends State<DataRegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Shared
  final _name = TextEditingController();
  final _phone = TextEditingController();

  // Citizen-only
  final _email = TextEditingController();
  final _region = TextEditingController();
  final _district = TextEditingController();
  final _family = TextEditingController();

  // Agent-only
  final _address = TextEditingController();

  RegistrationRole _role = RegistrationRole.citizen;
  bool _loading = false;
  bool _agree = true;
  LatLng? _location; // captured GPS / picked-on-map location
  bool _locating = false;

  late final AnimationController _headerAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _headerFade =
      CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _region.dispose();
    _district.dispose();
    _family.dispose();
    _address.dispose();
    _headerAnim.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    final res = await LocationService.current();
    if (!mounted) return;
    setState(() => _locating = false);
    if (res.ok) {
      setState(() => _location = res.point);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.error ?? S.locationPermissionDenied),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickOnMap() async {
    final picked = await showLocationPicker(context, initial: _location);
    if (picked != null && mounted) {
      setState(() => _location = picked);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() || !_agree) return;
    if (_location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.locationRequired),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _loading = true);

    final isCitizen = _role == RegistrationRole.citizen;
    final name = _name.text.trim();
    final phone = _phone.text.trim();
    final place = isCitizen ? _region.text.trim() : _address.text.trim();
    final lat = _location!.latitude;
    final lng = _location!.longitude;

    try {
      // 1) Persist the user's profile + role on their account.
      await AuthService.saveProfile({
        'role': isCitizen ? 'citizen' : 'agent',
        'name': name,
        'phone': phone,
        if (isCitizen) 'email': _email.text.trim(),
        'region': place,
        if (isCitizen) 'district': _district.text.trim(),
        if (isCitizen) 'family': _family.text.trim(),
        'lat': lat,
        'lng': lng,
        'profileComplete': true,
      });
      // 2) Drop the actual request into the queue the approver watches.
      if (isCitizen) {
        await appStore.submitCitizenRequest(
            name: name, phone: phone, address: place, lat: lat, lng: lng);
      } else {
        await appStore.submitAgentRequest(
            name: name, area: place, phone: phone, lat: lat, lng: lng);
      }
      Session.saveProfile(
          name: name,
          phone: phone,
          email: _email.text.trim(),
          region: place,
          lat: lat,
          lng: lng);
      Session.profileComplete = true;
    } catch (_) {
      // Offline / rules: still let the user proceed; the profile flag is set.
      Session.saveProfile(lat: lat, lng: lng);
      Session.profileComplete = true;
    }

    // Reflect the completed profile in the remembered local session.
    Session.role = isCitizen ? 'citizen' : 'agent';
    if (Prefs.rememberMe) {
      await Prefs.saveSession(
        role: Session.role,
        name: Session.nameNotifier.value,
        email: Session.emailNotifier.value,
        phone: Session.phoneNotifier.value,
        region: Session.regionNotifier.value,
        profileComplete: Session.profileComplete,
        isJoined: Session.isJoined,
        lat: Session.latNotifier.value,
        lng: Session.lngNotifier.value,
      );
    }

    if (!mounted) return;
    setState(() => _loading = false);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SuccessSheet(role: _role),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCitizen = _role == RegistrationRole.citizen;
    final isAgent = _role == RegistrationRole.agent;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── Premium gradient header ───
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, left: 16),
                child: Center(child: LangToggle()),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF0D47A1), Color(0xFF0A3A7E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Animated icon
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            S.dataRegistrationTitle,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            S.signupSubtitle,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Body content ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Section: Role Selection ───
                    _SectionLabel(
                      icon: Icons.assignment_ind_rounded,
                      label: L10n.isAr ? 'اختر نوع حسابك' : 'Choose your role',
                    ),
                    const SizedBox(height: 14),
                    _PremiumRoleCard(
                      icon: Icons.person_rounded,
                      title: S.roleCitizen,
                      description: S.citizenRoleDesc,
                      color: const Color(0xFF3B82F6),
                      selected: isCitizen,
                      onTap: () => setState(() => _role = RegistrationRole.citizen),
                    ),
                    const SizedBox(height: 10),
                    _PremiumRoleCard(
                      icon: Icons.delivery_dining_rounded,
                      title: S.agentRoleTitle,
                      description: S.agentRoleDesc,
                      color: AppColors.primary,
                      selected: isAgent,
                      onTap: () => setState(() => _role = RegistrationRole.agent),
                    ),

                    const SizedBox(height: 28),

                    // ─── Section: Personal Info ───
                    _SectionLabel(
                      icon: Icons.badge_rounded,
                      label: L10n.isAr ? 'المعلومات الشخصية' : 'Personal information',
                    ),
                    const SizedBox(height: 14),

                    // Info fields wrapped in a card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _name,
                            label: isCitizen ? S.fullName4 : S.fullName,
                            hint: isCitizen ? S.fullName4Hint : S.fullNameHint,
                            icon: Icons.person_outline_rounded,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? S.nameRequired : null,
                          ),
                          const SizedBox(height: 14),
                          CustomTextField(
                            controller: _phone,
                            label: S.phone,
                            hint: S.phoneHint,
                            icon: Icons.phone_iphone_rounded,
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                (v == null || v.length < 8) ? S.phoneInvalid : null,
                          ),

                          // ─── Citizen-specific fields ───
                          if (isCitizen) ...[
                            const SizedBox(height: 14),
                            CustomTextField(
                              controller: _email,
                              label: S.email,
                              hint: S.emailHint,
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                                  (v == null || !v.contains('@')) ? S.emailInvalid : null,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _region,
                                    label: S.region,
                                    hint: S.regionHint,
                                    icon: Icons.public_rounded,
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? S.nameRequired
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _district,
                                    label: S.district,
                                    hint: S.districtHint,
                                    icon: Icons.location_city_rounded,
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? S.nameRequired
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            CustomTextField(
                              controller: _family,
                              label: S.familySize,
                              hint: S.familySizeHint,
                              icon: Icons.groups_rounded,
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? S.nameRequired : null,
                            ),
                          ],

                          // ─── Agent-specific fields ───
                          if (isAgent) ...[
                            const SizedBox(height: 14),
                            CustomTextField(
                              controller: _address,
                              label: S.addressFull,
                              hint: S.addressHint,
                              icon: Icons.location_on_outlined,
                              maxLines: 2,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? S.nameRequired : null,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ─── Section: Location ───
                    _SectionLabel(
                      icon: Icons.map_rounded,
                      label: L10n.isAr ? 'الموقع' : 'Location',
                    ),
                    const SizedBox(height: 14),
                    _LocationCard(
                      location: _location,
                      locating: _locating,
                      onUseCurrent: _useCurrentLocation,
                      onPickOnMap: _pickOnMap,
                    ),

                    const SizedBox(height: 24),

                    // ─── Terms & Submit ───
                    _TermsRow(
                      value: _agree,
                      onChanged: (v) => setState(() => _agree = v),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: S.requestToJoin,
                      icon: Icons.check_circle_rounded,
                      loading: _loading,
                      onPressed: _agree ? _submitRequest : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Premium Role Card — each role has its own unique accent color
// ═══════════════════════════════════════════════════════════════════

class _PremiumRoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PremiumRoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? null : AppColors.surface,
        gradient: selected
            ? LinearGradient(
                colors: [color.withValues(alpha: 0.08), color.withValues(alpha: 0.02)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? color : AppColors.border,
          width: selected ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? color.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: selected ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected ? color : color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    icon,
                    color: selected ? Colors.white : color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: selected ? color : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Radio indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? color : Colors.transparent,
                    border: Border.all(
                      color: selected ? color : AppColors.border,
                      width: 2,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Section label with icon
// ═══════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Location capture card
// ═══════════════════════════════════════════════════════════════════

class _LocationCard extends StatelessWidget {
  final LatLng? location;
  final bool locating;
  final VoidCallback onUseCurrent;
  final VoidCallback onPickOnMap;

  const _LocationCard({
    required this.location,
    required this.locating,
    required this.onUseCurrent,
    required this.onPickOnMap,
  });

  @override
  Widget build(BuildContext context) {
    final hasLoc = location != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: hasLoc ? AppColors.success : AppColors.border,
          width: hasLoc ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: hasLoc
                      ? AppColors.successSoft
                      : AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasLoc
                      ? Icons.check_circle_rounded
                      : Icons.location_off_rounded,
                  color: hasLoc ? AppColors.success : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasLoc ? S.locationSet : S.setLocationOnMap,
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasLoc
                          ? '${location!.latitude.toStringAsFixed(5)}, '
                              '${location!.longitude.toStringAsFixed(5)}'
                          : S.tapMapToSetLocation,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: locating ? null : onUseCurrent,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: locating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_rounded,
                          size: 18, color: AppColors.primary),
                  label: Text(
                    S.useCurrentLocation,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPickOnMap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.map_rounded,
                      size: 18, color: Colors.white),
                  label: Text(
                    hasLoc
                        ? (L10n.isAr ? 'تغيير' : 'Change')
                        : (L10n.isAr ? 'الخريطة' : 'Map'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Terms Row
// ═══════════════════════════════════════════════════════════════════

class _TermsRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _TermsRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: value ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
              boxShadow: value
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            child: value
                ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium,
                children: [
                  TextSpan(text: S.agreeTo),
                  TextSpan(
                    text: S.terms,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: S.and),
                  TextSpan(
                    text: S.privacy,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Success Bottom Sheet — animated confetti-like celebration
// ═══════════════════════════════════════════════════════════════════

class _SuccessSheet extends StatelessWidget {
  final RegistrationRole role;
  const _SuccessSheet({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 28),
          // Stacked circle badge
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.08),
                ),
              ),
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.15),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.success, AppColors.success.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            S.requestSubmitted,
            style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              role == RegistrationRole.citizen
                  ? S.agentWillReview
                  : S.requestSubmittedDesc,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: S.continueBtn,
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                role == RegistrationRole.agent
                    ? AppRoutes.agentHome
                    : AppRoutes.citizenHome,
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
