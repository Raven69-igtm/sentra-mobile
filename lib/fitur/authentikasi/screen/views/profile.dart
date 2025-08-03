import 'package:google_sign_in/google_sign_in.dart';
import 'package:sentra/fitur/authentikasi/data/controllers/profilecontroller.dart';
import 'package:sentra/fitur/authentikasi/data/localdirectory/akunprefs.dart';
import 'package:sentra/fitur/authentikasi/data/models/usermodel.dart';
import 'package:sentra/fitur/authentikasi/data/provider/userprovider.dart';
import 'package:sentra/fitur/authentikasi/data/repositories/profilerepositories.dart';
import 'package:sentra/utils/color.dart';
import 'package:sentra/fitur/authentikasi/screen/views/loginscreen.dart';
import 'package:sentra/utils/customsnackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
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
    // Inisialisasi controller dengan data user
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [_buildHeader(), _buildProfileForm()]),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Warna.backgroundIjo, Warna.backgroundBiru],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 18),
          Row(
            children: [
              Row(
                children: [
                  Image.asset("assets/logo/Image.png", width: 35, height: 35),
                  SizedBox(width: 10),
                  Text(
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
              Spacer(),
              Row(
                children: [
                  Text(
                    "Logout",
                    style: TextStyle(
                      fontFamily: "Mulish",
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      bool? confirmLogout = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              "Konfirmasi Logout",
                              style: TextStyle(fontFamily: "Mulish"),
                            ),
                            content: Text(
                              "Apakah Anda yakin ingin keluar?",
                              style: TextStyle(fontFamily: "Mulish"),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: Text(
                                  "Batal",
                                  style: TextStyle(
                                    fontFamily: "Mulish",
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Text(
                                  "Logout",
                                  style: TextStyle(
                                    fontFamily: "Mulish",
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
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
                        print('Before logout - User: ${userProvider.user}');
                        userProvider.clearUser();
                        print('After logout - User: ${userProvider.user}');
                        await Future.delayed(Duration(milliseconds: 100));
                        if (mounted) {
                          GoogleSignIn().signOut();
                          AkunPrefs.hapusAkun();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 70),
          Text(
            'Hi, ${user?.nama ?? "Pengguna"}',
            style: TextStyle(
              fontFamily: "Mulish",
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Welcome to SENTRA.\nDisini anda dapat mengupdate data Profile anda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: "Mulish",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTextField(
            'Nama Lengkap',
            "${user?.nama ?? "Nama belum diisi"}",
            false,
            namaController,
          ),
          _buildGenderField(), 
          _buildTextField(
            'Nomor Telepon',
            "${user?.notelp ?? "Nomor belum diisi"}",
            false,
            noHpController,
          ),
          _buildTextField(
            'Email',
            "${user?.email ?? "Email belum diisi"}",
            false,
            emailController,
          ),
          _buildTextField(
            'Alamat',
            "${user?.alamat ?? "Alamat belum diisi"}",
            true,
            alamatController,
          ),
          SizedBox(height: 20),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    bool isMultiline,
    TextEditingController? controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          labelStyle: TextStyle(
            fontFamily: 'Mulish',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          hintText: hint,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        maxLines: isMultiline ? 3 : 1,
        controller: controller,
        readOnly: !isEditing,
      ),
    );
  }

  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child:
          isEditing
              ? DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Jenis Kelamin',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  labelStyle: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                value:
                    jeniskelaminController.text.isNotEmpty
                        ? jeniskelaminController.text
                        : null,
                hint: Text(
                  "${user?.jeniskelamin ?? "Jenis Kelamin belum diisi"}",
                  style: TextStyle(fontFamily: 'Mulish'),
                ),
                items:
                    ['Pria', 'Wanita'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(fontFamily: 'Mulish'),
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
                  labelText: 'Jenis Kelamin',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  labelStyle: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  hintText:
                      "${user?.jeniskelamin ?? "Jenis Kelamin belum diisi"}",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.black, width: 2),
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
              0.3,
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
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          if (isEditing) {
            // Validasi sederhana
            if (namaController.text.isEmpty) {
              CustomSnackbar.show('Nama tidak boleh kosong');
              return;
            }

            final updatedUser = UserModel(
              id: user?.id,
              nama:
                  namaController.text.isNotEmpty
                      ? namaController.text
                      : user?.nama ?? '',
              jeniskelamin:
                  jeniskelaminController.text.isNotEmpty
                      ? jeniskelaminController.text
                      : user?.jeniskelamin ?? '',
              notelp:
                  noHpController.text.isNotEmpty
                      ? noHpController.text
                      : user?.notelp ?? '',
              email:
                  emailController.text.isNotEmpty
                      ? emailController.text
                      : user?.email ?? '',
              alamat:
                  alamatController.text.isNotEmpty
                      ? alamatController.text
                      : user?.alamat ?? '',
              role: user?.role ?? 'user',
            );
            user = updatedUser;
            final akunController = ProfileController(ProfileRepository());

            try {
              await akunController.updateAkun(user!.id.toString(), updatedUser);
              CustomSnackbar.show('Berhasil mengupdate profil');
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Gagal update: $e')));
            }
          }
          setState(() {
            isEditing = !isEditing;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(0),
              topRight: Radius.circular(0),
              bottomRight: Radius.circular(20),
            ),
          ),
          minimumSize: Size(120, 50),
        ),
        child: Text(
          isEditing ? "Confirm" : "Edit Profile",
          style: TextStyle(
            fontFamily: "Mulish",
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
