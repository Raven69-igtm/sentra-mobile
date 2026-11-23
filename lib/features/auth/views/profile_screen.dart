import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sentra/core/network/api_exception.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_spacing.dart';
import 'package:sentra/core/theme/app_typography.dart';
import 'package:sentra/core/utils/address_field.dart';
import 'package:sentra/core/widgets/sentra_button.dart';
import 'package:sentra/core/widgets/sentra_card.dart';
import 'package:sentra/core/widgets/sentra_curved_header.dart';
import 'package:sentra/core/widgets/sentra_gradient_icon.dart';
import 'package:sentra/core/widgets/sentra_snackbar.dart';
import 'package:sentra/core/widgets/sentra_text_field.dart';
import 'package:sentra/features/auth/controllers/profile_controller.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/auth/models/user_model.dart';
import 'package:sentra/features/auth/repositories/profile_repository.dart';
import 'package:sentra/features/auth/services/auth_session.dart';
import 'package:sentra/features/auth/views/login_screen.dart';
import 'package:sentra/features/chat/controllers/chat_controller.dart';
import 'package:sentra/features/report/controllers/report_controller.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ProfileScreen({super.key, this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  bool isSaving = false;
  UserModel? user;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController jeniskelaminController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user;
    _fillControllers(user);
    _refreshFromServer();
  }

  @override
  void dispose() {
    namaController.dispose();
    jeniskelaminController.dispose();
    emailController.dispose();
    noHpController.dispose();
    alamatController.dispose();
    super.dispose();
  }

  void _fillControllers(UserModel? data) {
    namaController.text = data?.nama ?? '';
    jeniskelaminController.text = data?.jeniskelamin ?? '';
    noHpController.text = data?.notelp ?? '';
    emailController.text = data?.email ?? '';
    alamatController.text = data?.alamat ?? '';
  }

  Future<void> _refreshFromServer() async {
    final notelp = user?.notelp ?? '';
    if (notelp.isEmpty) return;

    try {
      final fresh = await AuthSession.refreshProfile(notelp);
      if (!mounted) return;

      if (fresh == null) {
        await _logout(showMessage: 'Sesi tidak ditemukan. Silakan masuk kembali.');
        return;
      }

      Provider.of<UserProvider>(context, listen: false).setUser(fresh);
      await AuthSession.persist(fresh);
      if (!mounted) return;
      setState(() {
        user = fresh;
        _fillControllers(fresh);
      });
    } catch (_) {
      // Offline: tetap tampilkan data lokal.
    }
  }

  Future<void> _logout({String? showMessage}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatController = Provider.of<ChatController>(context, listen: false);
    userProvider.clearUser();
    chatController.reset();
    Get.delete<LaporanController>(force: true);
    await AuthSession.clear();
    if (!mounted) return;
    if (showMessage != null) {
      SentraSnackbar.show(
        showMessage,
        context: context,
        type: SentraSnackbarType.warning,
      );
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (user == null) {
      user = Provider.of<UserProvider>(context, listen: false).user;
      _fillControllers(user);
    }
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  bool _isValidPhoneNumber(String phone) =>
      RegExp(r'^[0-9]{10,15}$').hasMatch(phone);

  bool _validateAllFields() {
    if (namaController.text.trim().length < 2) {
      SentraSnackbar.show(
        'Nama lengkap minimal 2 karakter.',
        context: context,
        type: SentraSnackbarType.error,
      );
      return false;
    }
    if (jeniskelaminController.text.trim().isEmpty) {
      SentraSnackbar.show(
        'Jenis kelamin harus dipilih.',
        context: context,
        type: SentraSnackbarType.error,
      );
      return false;
    }
    if (!_isValidPhoneNumber(noHpController.text.trim())) {
      SentraSnackbar.show(
        'Nomor telepon harus 10–15 digit angka.',
        context: context,
        type: SentraSnackbarType.error,
      );
      return false;
    }
    if (!_isValidEmail(emailController.text.trim())) {
      SentraSnackbar.show(
        'Format email tidak valid.',
        context: context,
        type: SentraSnackbarType.error,
      );
      return false;
    }
    if (alamatController.text.trim().isEmpty) {
      SentraSnackbar.show(
        'Alamat tidak boleh kosong.',
        context: context,
        type: SentraSnackbarType.error,
      );
      return false;
    }
    return true;
  }

  Future<void> _handleSaveOrToggleEdit() async {
    if (!isEditing) {
      setState(() => isEditing = true);
      return;
    }

    if (!_validateAllFields()) return;
    final updatedUser = UserModel(
      id: user?.id,
      nama: namaController.text.trim(),
      jeniskelamin: jeniskelaminController.text.trim(),
      notelp: noHpController.text.trim(),
      email: emailController.text.trim(),
      alamat: alamatController.text.trim(),
      role: user?.role ?? 'user',
    );

    if (updatedUser.id == null) {
      SentraSnackbar.show(
        'Sesi tidak valid. Silakan masuk kembali.',
        context: context,
        type: SentraSnackbarType.error,
      );
      return;
    }

    setState(() => isSaving = true);
    final akunController = ProfileController(ProfileRepository());

    try {
      await akunController.updateAkun(updatedUser.id.toString(), updatedUser);
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);
      await AuthSession.persist(updatedUser);
      if (!mounted) return;
      setState(() {
        user = updatedUser;
        isSaving = false;
        isEditing = false;
      });
      SentraSnackbar.show(
        akunController.message ?? 'Profil berhasil diperbarui.',
        context: context,
        type: SentraSnackbarType.success,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => isSaving = false);
      SentraSnackbar.show(
        e.message,
        context: context,
        type: SentraSnackbarType.error,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => isSaving = false);
      SentraSnackbar.show(
        akunController.message ??
            'Profil gagal diperbarui. Periksa sambungan internet Anda.',
        context: context,
        type: SentraSnackbarType.error,
      );
    }
  }

  Future<void> _showLogoutDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColors.errorSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Keluar dari Akun?',
                  style: AppTypography.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Anda perlu masuk kembali untuk melihat riwayat laporan dan konsultasi.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SentraButton.danger(
                  label: 'Ya, Keluar',
                  onPressed: () => Navigator.pop(ctx, true),
                ),
                const SizedBox(height: AppSpacing.sm),
                SentraButton.outlined(
                  label: 'Batal',
                  onPressed: () => Navigator.pop(ctx, false),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      await _logout();
    }
  }

  String _initials(String? name) {
    final n = (name ?? '').trim();
    if (n.isEmpty) return 'U';
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 96),
          child: Column(
            children: [
              _buildHeader(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.maxContentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.md,
                      AppSpacing.pageHorizontal,
                      AppSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProfileFormCard(),
                        const SizedBox(height: AppSpacing.lg),
                        SentraButton.primary(
                          label:
                              isEditing ? 'Simpan Perubahan' : 'Ubah Profil',
                          icon:
                              isEditing
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.edit_outlined,
                          isLoading: isSaving,
                          gradient: AppColors.headerCurvedGradient,
                          onPressed: _handleSaveOrToggleEdit,
                        ),
                        if (isEditing) ...[
                          const SizedBox(height: AppSpacing.sm),
                          SentraButton.outlined(
                            label: 'Batal',
                            onPressed: () {
                              _fillControllers(user);
                              setState(() => isEditing = false);
                            },
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xxl),
                        SentraButton.danger(
                          label: 'Keluar dari Akun',
                          icon: Icons.logout_rounded,
                          onPressed: _showLogoutDialog,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Curved Header Gradient (#52AE77 -> #5270AD) melengkung ke bawah.
  Widget _buildHeader() {
    final topInset = MediaQuery.of(context).padding.top;
    return SentraCurvedHeader(
      curveHeight: 34,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        topInset + AppSpacing.md,
        AppSpacing.pageHorizontal,
        52,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.maxContentWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.onBack != null || Navigator.canPop(context))
                    IconButton(
                      tooltip: 'Kembali',
                      onPressed: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else {
                          Navigator.maybePop(context);
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                  Text(
                    'Profil',
                    style: AppTypography.title.copyWith(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withValues(alpha: 0.16),
                      child: Text(
                        _initials(user?.nama),
                        style: AppTypography.title.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.nama ?? 'Pengguna SENTRA',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.title.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.notelp ?? '-',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileFormCard() {
    return SentraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Informasi Pribadi', style: AppTypography.subtitle),
              const Spacer(),
              if (isEditing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    'Mode Ubah',
                    style: AppTypography.label.copyWith(
                      letterSpacing: 0.2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SentraTextField(
            label: 'Nama Lengkap',
            hintText: 'Nama belum diisi',
            controller: namaController,
            readOnly: !isEditing,
            prefixIcon: Icons.person_outline_rounded,
            useGradientIcon: true,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildGenderField(),
          const SizedBox(height: AppSpacing.md),
          SentraTextField(
            label: 'Nomor Telepon',
            hintText: 'Nomor belum diisi',
            controller: noHpController,
            readOnly: !isEditing,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            useGradientIcon: true,
          ),
          const SizedBox(height: AppSpacing.md),
          SentraTextField(
            label: 'Email',
            hintText: 'Email belum diisi',
            controller: emailController,
            readOnly: !isEditing,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            useGradientIcon: true,
          ),
          const SizedBox(height: AppSpacing.md),
          AddressAutocompleteStandard(
            label: 'Alamat Lengkap',
            hint: user?.alamat ?? 'Alamat belum diisi',
            controller: alamatController,
            isRequired: true,
            icon: Icons.location_on_outlined,
            isEditing: isEditing,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Kelamin',
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        if (isEditing)
          DropdownButtonFormField<String>(
            dropdownColor: AppColors.surface,
            decoration: const InputDecoration(
              prefixIcon: SentraGradientIcon(Icons.wc_rounded, size: 20),
              hintText: 'Pilih jenis kelamin',
            ),
            initialValue:
                jeniskelaminController.text.isNotEmpty
                    ? jeniskelaminController.text
                    : null,
            items:
                const ['Pria', 'Wanita'].map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: AppTypography.body),
                  );
                }).toList(),
            onChanged: (newValue) {
              setState(() => jeniskelaminController.text = newValue ?? '');
            },
          )
        else
          SentraTextField(
            hintText: 'Jenis kelamin belum diisi',
            controller: jeniskelaminController,
            readOnly: true,
            prefixIcon: Icons.wc_rounded,
            useGradientIcon: true,
          ),
      ],
    );
  }
}
