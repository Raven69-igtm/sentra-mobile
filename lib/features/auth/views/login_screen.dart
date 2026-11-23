import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_spacing.dart';
import 'package:sentra/core/theme/app_typography.dart';
import 'package:sentra/core/utils/address_field.dart';
import 'package:sentra/core/widgets/sentra_button.dart';
import 'package:sentra/core/widgets/sentra_curved_header.dart';
import 'package:sentra/core/widgets/sentra_gradient_icon.dart';
import 'package:sentra/core/widgets/sentra_snackbar.dart';
import 'package:sentra/core/widgets/sentra_text_field.dart';
import 'package:sentra/features/auth/controllers/login_controller.dart';
import 'package:sentra/features/auth/controllers/register_controller.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/auth/models/user_model.dart';
import 'package:sentra/features/auth/services/auth_session.dart';
import 'package:sentra/features/auth/views/ganti_nomor_screen.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';
import 'package:sentra/features/notification/repositories/notif_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final RegisterController repository = RegisterController();
  int selectedIndex = 0;
  bool isLoading = false;
  bool isRegistering = false;
  String? selectedValue;
  String? selectedGender;
  bool _genderSubmittedError = false;

  // Masuk controllers
  final TextEditingController nomorController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Daftar controllers
  final TextEditingController regisnomor = TextEditingController();
  final TextEditingController regispassword = TextEditingController();
  final TextEditingController regispasswordkonfirm = TextEditingController();
  final TextEditingController regisnama = TextEditingController();
  final TextEditingController regisanswer = TextEditingController();
  final TextEditingController regisalamat = TextEditingController();

  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nomorController.dispose();
    passwordController.dispose();
    regisnomor.dispose();
    regispassword.dispose();
    regispasswordkonfirm.dispose();
    regisnama.dispose();
    regisanswer.dispose();
    regisalamat.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!(_signInFormKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);

    final loginController = Provider.of<LoginController>(
      context,
      listen: false,
    );
    final bool success = await loginController.login(
      nomorController.text.trim(),
      passwordController.text,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (!success) {
      SentraSnackbar.show(
        loginController.errorMessage ??
            'Gagal masuk. Periksa nomor telepon dan kata sandi Anda.',
        context: context,
        type: SentraSnackbarType.error,
      );
      return;
    }

    final UserModel activeUser = loginController.user!;
    Provider.of<UserProvider>(context, listen: false).setUser(activeUser);

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await NotificationRepository().updateFCMToken(activeUser.id, fcmToken);
      }
    } catch (_) {}

    await AuthSession.persist(activeUser);
    if (!mounted) return;

    SentraSnackbar.show(
      'Berhasil masuk. Selamat datang, ${activeUser.nama}.',
      context: context,
      type: SentraSnackbarType.success,
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 0)),
      (route) => false,
    );
  }

  Future<void> _handleSignUp() async {
    final formValid = _signUpFormKey.currentState?.validate() ?? false;
    if (selectedGender == null) {
      setState(() => _genderSubmittedError = true);
    }
    if (!formValid || selectedGender == null) return;

    if (regispassword.text != regispasswordkonfirm.text) {
      SentraSnackbar.show(
        'Konfirmasi kata sandi tidak cocok.',
        context: context,
        type: SentraSnackbarType.error,
      );
      return;
    }

    final phone = regisnomor.text.trim();
    if (isRegistering) return;
    setState(() => isRegistering = true);

    final result = await repository.register(
      phone,
      regisnama.text.trim(),
      regispassword.text,
      selectedValue ?? '',
      regisanswer.text.trim(),
      selectedGender ?? 'Pria',
      regisalamat.text.trim(),
    );

    if (!mounted) return;
    setState(() => isRegistering = false);

    if (!result.success) {
      SentraSnackbar.show(
        result.message,
        context: context,
        type: SentraSnackbarType.error,
      );
      return;
    }

    SentraSnackbar.show(
      result.message,
      context: context,
      type: SentraSnackbarType.success,
    );
    nomorController.text = phone;
    setState(() => selectedIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        // Curved Header Gradient Splash Screen (#52AE77 -> #5270AD) melengkung ke bawah
                        SentraCurvedHeader(
                          curveHeight: 34,
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.authHorizontal,
                            topInset + 20,
                            AppSpacing.authHorizontal,
                            54,
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/logo/Image.png',
                                width: 82,
                                height: 62,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                selectedIndex == 0
                                    ? 'Masuk ke SENTRA'
                                    : 'Buat Akun Baru',
                                textAlign: TextAlign.center,
                                style: AppTypography.title.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                selectedIndex == 0
                                    ? 'Gunakan nomor telepon dan kata sandi Anda'
                                    : 'Lengkapi data diri untuk mulai melapor dan berkonsultasi',
                                textAlign: TextAlign.center,
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.92),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bagian bawah putih bersih
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: AppSpacing.maxContentWidth,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.authHorizontal,
                                AppSpacing.lg,
                                AppSpacing.authHorizontal,
                                AppSpacing.xl,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildSegmentedTabs(),
                                  const SizedBox(height: AppSpacing.xxl),
                                  selectedIndex == 0
                                      ? _buildSignInForm()
                                      : _buildSignUpForm(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Footer identitas di bagian paling bawah layar
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.authHorizontal,
                          AppSpacing.lg,
                          AppSpacing.authHorizontal,
                          AppSpacing.xl,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/image/beranda/logo_nganjuk.png',
                              height: 26,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Flexible(
                              child: Text(
                                'Layanan Dinsos & PPA Kabupaten Nganjuk',
                                textAlign: TextAlign.center,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSegmentedTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildSegmentItem(index: 0, label: 'Masuk'),
          _buildSegmentItem(index: 1, label: 'Daftar'),
        ],
      ),
    );
  }

  Widget _buildSegmentItem({required int index, required String label}) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
          hoverColor: AppColors.splashGradientStart.withValues(alpha: 0.10),
          splashColor: AppColors.splashGradientEnd.withValues(alpha: 0.16),
          onTap: () {
            if (!isSelected) {
              HapticFeedback.lightImpact();
              setState(() => selectedIndex = index);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
              border:
                  isSelected
                      ? Border.all(color: AppColors.border)
                      : Border.all(color: Colors.transparent),
            ),
            child:
                isSelected
                    ? SentraGradientText(label, style: AppTypography.bodyStrong)
                    : Text(
                      label,
                      style: AppTypography.bodyStrong.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SentraTextField(
            label: 'Nomor Telepon',
            hintText: 'Contoh: 081234567890',
            controller: nomorController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icons.phone_outlined,
            useGradientIcon: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nomor telepon tidak boleh kosong';
              }
              if (!RegExp(r'^0[0-9]{9,12}$').hasMatch(value.trim())) {
                return 'Nomor harus 10–13 digit dan diawali angka 0';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SentraTextField(
            label: 'Kata Sandi',
            hintText: 'Masukkan kata sandi Anda',
            obscureText: true,
            controller: passwordController,
            prefixIcon: Icons.lock_outline_rounded,
            useGradientIcon: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kata sandi tidak boleh kosong';
              }
              if (value.length < 8) {
                return 'Kata sandi minimal 8 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GantiNomorScreen()),
                );
              },
              child: Text(
                'Lupa / Ganti Nomor?',
                style: AppTypography.bodyStrong.copyWith(
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SentraButton.primary(
            label: 'Masuk',
            isLoading: isLoading,
            gradient: AppColors.headerCurvedGradient,
            onPressed: _handleSignIn,
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _signUpFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SentraTextField(
            label: 'Nama Lengkap',
            hintText: 'Masukkan nama lengkap Anda',
            controller: regisnama,
            keyboardType: TextInputType.name,
            prefixIcon: Icons.person_outline_rounded,
            useGradientIcon: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama lengkap tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SentraTextField(
            label: 'Kata Sandi',
            hintText: 'Minimal 8 karakter',
            controller: regispassword,
            obscureText: true,
            prefixIcon: Icons.lock_outline_rounded,
            useGradientIcon: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kata sandi tidak boleh kosong';
              }
              if (value.length < 8) {
                return 'Kata sandi minimal 8 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SentraTextField(
            label: 'Konfirmasi Kata Sandi',
            hintText: 'Ulangi kata sandi Anda',
            controller: regispasswordkonfirm,
            obscureText: true,
            prefixIcon: Icons.lock_outline_rounded,
            useGradientIcon: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi kata sandi tidak boleh kosong';
              }
              if (value != regispassword.text) {
                return 'Kata sandi tidak cocok';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SentraTextField(
            label: 'Nomor Telepon',
            hintText: 'Contoh: 081234567890',
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: regisnomor,
            prefixIcon: Icons.phone_outlined,
            useGradientIcon: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nomor telepon tidak boleh kosong';
              }
              if (!RegExp(r'^0[0-9]{9,12}$').hasMatch(value.trim())) {
                return 'Nomor harus 10–13 digit dan diawali angka 0';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // Pertanyaan Keamanan
          const Text(
            'Pertanyaan Keamanan',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          DropdownButtonFormField<String>(
            dropdownColor: AppColors.surface,
            decoration: const InputDecoration(
              hintText: 'Pilih pertanyaan keamanan',
            ),
            initialValue: selectedValue,
            items:
                const [
                  'Apa Warna Favorit anda ?',
                  'Apa Hewan Favorit anda ?',
                  'Dimana anda Lahir ?',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: AppTypography.body),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() => selectedValue = newValue);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pertanyaan keamanan harus dipilih';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SentraTextField(
            label: 'Jawaban Pertanyaan Keamanan',
            hintText: 'Masukkan jawaban Anda',
            keyboardType: TextInputType.text,
            controller: regisanswer,
            prefixIcon: Icons.shield_outlined,
            useGradientIcon: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Jawaban tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // Jenis Kelamin
          const Text(
            'Jenis Kelamin',
            style: TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _buildGenderChip('Pria', Icons.male_rounded),
              const SizedBox(width: AppSpacing.md),
              _buildGenderChip('Wanita', Icons.female_rounded),
            ],
          ),
          if (_genderSubmittedError && selectedGender == null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Jenis kelamin harus dipilih',
              style: AppTypography.caption.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),

          AddressAutocompleteCustom(
            label: 'Alamat Lengkap',
            hintText: 'Masukkan alamat lengkap Anda',
            controller: regisalamat,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Alamat tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          SentraButton.primary(
            label: isRegistering ? 'Memproses...' : 'Daftar',
            isLoading: isRegistering,
            gradient: AppColors.headerCurvedGradient,
            onPressed: _handleSignUp,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip(String value, IconData icon) {
    final isSelected = selectedGender == value;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        hoverColor: AppColors.splashGradientStart.withValues(alpha: 0.10),
        splashColor: AppColors.splashGradientEnd.withValues(alpha: 0.16),
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            selectedGender = value;
            _genderSubmittedError = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: AppSpacing.minTouchTarget,
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? LinearGradient(
                      colors: [
                        AppColors.splashGradientStart.withValues(alpha: 0.16),
                        AppColors.splashGradientEnd.withValues(alpha: 0.16),
                      ],
                    )
                    : null,
            color: isSelected ? null : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color:
                  isSelected
                      ? AppColors.splashGradientStart
                      : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SentraGradientIcon(icon, size: 18),
              const SizedBox(width: AppSpacing.xs),
              isSelected
                  ? SentraGradientText(value, style: AppTypography.bodyStrong)
                  : Text(
                    value,
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
