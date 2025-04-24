import 'package:SENTRA/utils/color.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TextEditingController searchController = TextEditingController();
  String selectedFilter = "All";
  final List<Map<String, String>> reports = [
    {
      "id": "RKN892713891268",
      "tanggal": "08/05/2019",
      "kategori": "Kekerasan dalam Rumah Tangga",
      "korban": "Tumirah Astuti",
      "status": "On Process",
    },
    {
      "id": "RKN892713891268",
      "tanggal": "08/05/2019",
      "kategori": "Penelantaran",
      "korban": "Dion Prayono",
      "status": "Dikirim",
    },
    {
      "id": "RKN892713891268",
      "tanggal": "08/05/2019",
      "kategori": "Penelantaran",
      "korban": "Dion Prayono",
      "status": "Diterima",
    },
    {
      "id": "RKN892713891268",
      "tanggal": "08/05/2019",
      "kategori": "Penelantaran",
      "korban": "Dion Prayono",
      "status": "Selesai",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Warna.backgroundIjo,
                Warna.backgroundBiru,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/logo/Image.png',
              height: 30,
              width: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              "SENTRA",
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Spacer(), 
            const Text(
              "History Laporan",
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildTabButton("All"),
                buildTabButton("Dikirim"),
                buildTabButton("Diterima"),
                buildTabButton("Diproses"),
                buildTabButton("Selesai"),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by Name",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                return buildReportCard(reports[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  
  Widget buildTabButton(String text) {
    bool isSelected = text == selectedFilter;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text; 
        });
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: "Mulish",
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.green : Warna.font,
              ),
            ),
          ),
          if (isSelected)
            Container(
              height: 3,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildReportCard(Map<String, String> report) {
    Color statusColor = Colors.grey;
    if (report["status"] == "On Process") {
      statusColor = Colors.orange;
    } else if (report["status"] == "Dikirim") {
      statusColor = Colors.blue;
    } else if (report["status"] == "Diterima") {
      statusColor = Colors.purple;
    } else if (report["status"] == "Selesai") {
      statusColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ID Report : ${report['id']}",
              style: const TextStyle(
                fontFamily: "Mulish",
                fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text("Kategori : ${report['kategori']}",style: TextStyle(fontFamily: "Mulish"),),
            Text("Korban : ${report['korban']}",style: TextStyle(fontFamily: "Mulish"),),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Status : ${report['status']}",
                  style: TextStyle(
                    fontFamily: "Mulish",
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  report['tanggal']!,
                  style: const TextStyle(
                    fontFamily: "Mulish",
                    color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
