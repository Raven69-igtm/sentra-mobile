class UserModel {
  final int id;
  final String notelp;
  final String nama;
  final String email;
  final String role;
  final String alamat;
  final String jeniskelamin;

  UserModel({
    required this.id,
    required this.notelp,
    required this.nama,
    required this.email,
    required this.role,
    required this.alamat,
    required this.jeniskelamin

  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id_akun'],
      notelp: json['notelp'],
      nama: json['nama'],
      email: json['email'] ?? '',
      role: json['role'],
      alamat: json['alamat'] ?? '',
      jeniskelamin: json['jenis_kelamin'] ?? '',
    );
  }
}
