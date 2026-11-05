import 'package:google_sign_in/google_sign_in.dart';
import 'package:sentra/features/auth/controllers/profile_controller.dart';
import 'package:sentra/features/auth/preferences/account_prefs.dart';
import 'package:sentra/features/auth/models/user_model.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/auth/repositories/profile_repository.dart';
import 'package:sentra/core/utils/address_field.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/features/auth/views/login_screen.dart';
import 'package:sentra/core/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  UserModel? user;
  TextEditingController namaController = TextEditingController();
  TextEditingController jeniskelaminController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController noHpController = TextEditingController();
  TextEditingController alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user;
    namaController.text = user?.nama ?? '';
    jeniskelaminController.text = user?.jeniskelamin ?? '';
    noHpController.text = user?.notelp ?? '';
    emailController.text = user?.email ?? '';
    alamatController.text = user?.alamat ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (user == null) {
      user = Provider.of<UserProvider>(context, listen: false).user;
      namaController.text = user?.nama ?? '';
      jeniskelaminController.text = user?.jeniskelamin ?? '';
      noHpController.text = user?.notelp ?? '';
      emailController.text = user?.email ?? '';
      alamatController.text = user?.alamat ?? '';
    }
  }

  bool _validateAllFields() {
    if (namaController.text.trim().isEmpty) {
      CustomSnackbar.show('Nama lengkap tidak boleh kosong', warna: Colors.red);
      return false;
    }
    if (jeniskelaminController.text.trim().isEmpty) {
      CustomSnackbar.show('Jenis kelamin harus dipilih', warna: Colors.red);
      return false;
    }
    if (noHpController.text.trim().isEmpty) {
      CustomSnackbar.show(
        'Nomor telepon tidak boleh kosong',
        warna: Colors.red,
      );
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      CustomSnackbar.show('Email tidak boleh kosong', warna: Colors.red);
      return false;
    }
    if (alamatController.text.trim().isEmpty) {
      CustomSnackbar.show('Alamat tidak boleh kosong', warna: Colors.red);
      return false;
    }
    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhoneNumber(String phone) {
    return RegExp(r'^[0-9]{10,15}$').hasMatch(phone);
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildProfileForm(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Warna.backgroundIjo, Warna.backgroundBiru],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Warna.backgroundIjoDark.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                Row(
                  children: [
                    Image.asset("assets/logo/Image.png", width: 36, height: 36),
                    const SizedBox(width: 10),
                    const Text(
                      'SENTRA',
                      style: TextStyle(
                        fontFamily: "Mulish",
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    bool? confirmLogout = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text(
                            "Konfirmasi Logout",
                            style: TextStyle(fontFamily: "Mulish"),
                          ),
                          content: const Text(
                            "Apakah Anda yakin ingin keluar?",
                            style: TextStyle(fontFamily: "Mulish"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text(
                                "Batal",
                                style: TextStyle(
                                  fontFamily: "Mulish",
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text(
                                "Logout",
                                style: TextStyle(
                                  fontFamily: "Mulish",
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirmLogout == true) {
                      final userProvider = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      );
                      userProvider.clearUser();
                      await Future.delayed(const Duration(milliseconds: 100));
                      if (mounted) {
                        GoogleSignIn().signOut();
                        AkunPrefs.hapusAkun();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false,
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Logout",
                    style: TextStyle(fontFamily: "Mulish", color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Text(
                    _initials(user?.nama),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "Mulish",
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${user?.nama ?? "Pengguna"}',
                        style: const TextStyle(
                          fontFamily: "Mulish",
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Welcome to SENTRA. Di sini Anda dapat mengupdate data profil.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: "Mulish",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isEditing ? Icons.edit_note : Icons.person,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isEditing ? 'Mode Edit' : 'Profil',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: "Mulish",
                          fontSize: 12,
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
    );
  }

  Widget _buildProfileForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.black54),
                    const SizedBox(width: 8),
                    const Text(
                      'Informasi Profil',
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (isEditing)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          border: Border.all(color: Colors.orange.shade200),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.mode_edit_outline,
                              size: 14,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Mengedit',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontFamily: 'Mulish',
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Nama Lengkap',
                  user?.nama ?? "Nama belum diisi",
                  false,
                  namaController,
                  isRequired: true,
                  icon: Icons.person_rounded,
                ),
                _buildGenderField(),
                _buildTextField(
                  'Nomor Telepon',
                  user?.notelp ?? "Nomor belum diisi",
                  false,
                  noHpController,
                  isRequired: true,
                  isPhoneNumber: true,
                  icon: Icons.phone_rounded,
                ),
                _buildTextField(
                  'Email',
                  user?.email ?? "Email belum diisi",
                  false,
                  emailController,
                  isRequired: true,
                  isEmail: true,
                  icon: Icons.email_rounded,
                ),
                AddressAutocompleteStandard(
                  label: 'Alamat Lengkap',
                  hint: user?.alamat ?? "Alamat belum diisi",
                  controller: alamatController,
                  isRequired: true,
                  icon: Icons.location_on_outlined,
                  isEditing: isEditing,
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    bool isMultiline,
    TextEditingController? controller, {
    bool isRequired = false,
    bool isEmail = false,
    bool isPhoneNumber = false,
    IconData? icon,
  }) {
    final bool showErrorStyle =
        isEditing &&
        ((isRequired && controller!.text.trim().isEmpty) ||
            (isEmail &&
                controller!.text.trim().isNotEmpty &&
                !_isValidEmail(controller.text.trim())) ||
            (isPhoneNumber &&
                controller!.text.trim().isNotEmpty &&
                !_isValidPhoneNumber(controller.text.trim())));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
          labelText: isRequired ? '$label *' : label,
          hintText: hint,
          filled: true,
          fillColor: isEditing ? Colors.white : Colors.grey.shade50,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: TextStyle(
            fontFamily: 'Mulish',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color:
                showErrorStyle
                    ? Colors.red.shade700
                    : Colors.black87, // <- perbaikan
          ),
          hintStyle: const TextStyle(
            color: Colors.black45,
            fontFamily: 'Mulish',
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color:
                  showErrorStyle ? Colors.red.shade300 : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: showErrorStyle ? Colors.red : Colors.black,
              width: 1.8,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.6),
          ),
        ),
        style: const TextStyle(fontFamily: 'Mulish'),
        maxLines: isMultiline ? 3 : 1,
        controller: controller,
        readOnly: !isEditing,
        keyboardType:
            isPhoneNumber
                ? TextInputType.phone
                : isEmail
                ? TextInputType.emailAddress
                : TextInputType.text,
        onChanged: isEditing ? (_) => setState(() {}) : null,
      ),
    );
  }

  Widget _buildGenderField() {
    final bool genderError =
        isEditing && jeniskelaminController.text.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child:
          isEditing
              ? DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.wc_rounded,
                    color: Colors.black54,
                  ),
                  labelText: 'Jenis Kelamin *',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(),
                  ),
                  labelStyle: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: genderError ? Colors.red.shade700 : Colors.black87,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: genderError ? Colors.red : Colors.black,
                      width: 1.8,
                    ),
                  ),
                ),
                value:
                    jeniskelaminController.text.isNotEmpty
                        ? jeniskelaminController.text
                        : null,
                hint: Text(
                  user?.jeniskelamin ?? "Jenis Kelamin belum diisi",
                  style: const TextStyle(fontFamily: 'Mulish'),
                ),
                items:
                    ['Pria', 'Wanita'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(
                              value == 'Pria' ? Icons.male : Icons.female,
                              color:
                                  value == 'Pria' ? Colors.blue : Colors.pink,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              value,
                              style: const TextStyle(fontFamily: 'Mulish'),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    jeniskelaminController.text = newValue ?? '';
                  });
                },
              )
              : TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.wc_rounded,
                    color: Colors.black54,
                  ),
                  labelText: 'Jenis Kelamin *',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  labelStyle: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  hintText: user?.jeniskelamin ?? "Jenis Kelamin belum diisi",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.black, width: 1.8),
                  ),
                ),
                controller: jeniskelaminController,
                readOnly: true,
              ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isEditing ? Warna.birunom : Warna.backgroundIjo,
            Color.lerp(
              isEditing ? Warna.birunom : Warna.backgroundIjo,
              Colors.black,
              0.25,
            )!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(0),
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          if (isEditing) {
            if (!_validateAllFields()) return;
            if (!_isValidEmail(emailController.text.trim())) {
              CustomSnackbar.show('Format email tidak valid');
              return;
            }
            if (!_isValidPhoneNumber(noHpController.text.trim())) {
              CustomSnackbar.show(
                'Nomor telepon harus berupa angka (10-15 digit)',
              );
              return;
            }
            if (namaController.text.trim().length < 2) {
              CustomSnackbar.show('Nama harus minimal 2 karakter');
              return;
            }

            final updatedUser = UserModel(
              id: user?.id,
              nama: namaController.text.trim(),
              jeniskelamin: jeniskelaminController.text.trim(),
              notelp: noHpController.text.trim(),
              email: emailController.text.trim(),
              alamat: alamatController.text.trim(),
              role: user?.role ?? 'user',
            );

            user = updatedUser;
            final akunController = ProfileController(ProfileRepository());

            try {
              await akunController.updateAkun(user!.id.toString(), updatedUser);
              Provider.of<UserProvider>(
                context,
                listen: false,
              ).setUser(updatedUser);
              CustomSnackbar.show('Berhasil mengupdate profil');
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Gagal update: $e')));
              return;
            }
          }
          setState(() {
            isEditing = !isEditing;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isEditing ? Icons.check_circle_rounded : Icons.edit_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              isEditing ? "Confirm" : "Edit Profile",
              style: const TextStyle(
                fontFamily: "Mulish",
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
