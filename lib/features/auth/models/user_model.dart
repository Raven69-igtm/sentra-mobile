class UserModel {
  final int? id;
  final String? notelp;
  final String? nama;
  final String? email;
  final String? role;
  final String? alamat;
  final String? jeniskelamin;

  UserModel({
    required this.id,
    required this.notelp,
    required this.nama,
    required this.email,
    required this.role,
    required this.alamat,
    required this.jeniskelamin,
  });
  
  int? get idAkun => id;

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
  Map<String, dynamic> toJson() {
    return {
      'notelp': notelp,
      'nama': nama,
      'email': email,
      'role': role,
      'alamat': alamat,
      'jenis_kelamin': jeniskelamin,
    }..removeWhere((key, value) => value == null); 
  }


  UserModel logout() {
    return UserModel(
      id: null, 
      notelp: null, 
      nama: null,
      email: null,
      role: null, 
      alamat: null, 
      jeniskelamin: null, 
    );
  }
}
