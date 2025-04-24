import 'package:flutter/material.dart';

class Form1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Form 1")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(decoration: InputDecoration(labelText: 'NIK')),
              TextField(decoration: InputDecoration(labelText: 'Nama')),
              TextField(decoration: InputDecoration(labelText: 'Umur')),
              TextField(decoration: InputDecoration(labelText: 'Alamat')),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Hubungan dengan korban',
                ),
              ),
              TextField(decoration: InputDecoration(labelText: 'No. Telp')),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Form2()),
                  );
                },
                child: Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Form2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Form 2")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(decoration: InputDecoration(labelText: 'NIK')),
              TextField(decoration: InputDecoration(labelText: 'Nama')),
              TextField(
                decoration: InputDecoration(labelText: 'Tempat, Tgl Lahir'),
              ),
              TextField(decoration: InputDecoration(labelText: 'Umur')),
              TextField(
                decoration: InputDecoration(labelText: 'Jenis Kelamin'),
              ),
              TextField(decoration: InputDecoration(labelText: 'Pekerjaan')),
              TextField(decoration: InputDecoration(labelText: 'Agama')),
              TextField(decoration: InputDecoration(labelText: 'Pendidikan')),
              TextField(decoration: InputDecoration(labelText: 'No. Telp')),
              TextField(
                decoration: InputDecoration(labelText: 'Informasi Tambahan'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Form3()),
                  );
                },
                child: Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Form3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Form 3")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(decoration: InputDecoration(labelText: 'Jumlah Anak')),
              TextField(decoration: InputDecoration(labelText: 'Nama Pertama')),
              TextField(
                decoration: InputDecoration(labelText: 'Tanggal Lahir'),
              ),
              TextField(decoration: InputDecoration(labelText: 'Umur')),
              TextField(decoration: InputDecoration(labelText: 'Pendidikan')),
              TextField(decoration: InputDecoration(labelText: 'Agama')),
              TextField(decoration: InputDecoration(labelText: 'Status')),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Form4()),
                  );
                },
                child: Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Form4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Form 4")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Kronologi Kejadian'),
                maxLines: 5,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Form5()),
                  );
                },
                child: Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Form5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Form 5")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Tanggal dan Tempat Kejadian',
                ),
              ),
              TextField(decoration: InputDecoration(labelText: 'Jenis Kasus')),
              TextField(
                decoration: InputDecoration(labelText: 'Bukti Kekerasan'),
              ),
              ElevatedButton(onPressed: () {}, child: Text('Upload Bukti')),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Identitas yang dilampirkan',
                ),
              ),
              ElevatedButton(onPressed: () {}, child: Text('Upload Dokumen')),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Form Submitted')));
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
