import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  
  // Mengambil referensi box yang sudah dibuka di main.dart
  final _mahasiswaBox = Hive.box('mahasiswaBox');
  
  // Variable untuk melacak apakah sedang mode edit. Jika null = Tambah Data
  int? _editIndex;

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  // CREATE & UPDATE: Fungsi untuk menyimpan atau mengedit data
  void _simpanData() {
    if (_nimController.text.isEmpty || _namaController.text.isEmpty) return;

    final dataBaru = {
      'nim': _nimController.text,
      'nama': _namaController.text,
    };

    if (_editIndex == null) {
      // Tambah data baru
      _mahasiswaBox.add(dataBaru);
    } else {
      // Update data berdasarkan index
      _mahasiswaBox.putAt(_editIndex!, dataBaru);
      _editIndex = null; // Kembalikan ke mode tambah setelah update
    }

    // Kosongkan form setelah simpan/update
    _nimController.clear();
    _namaController.clear();
    setState(() {});
  }

  // READ (Persiapan Update): Menampilkan data ke form saat tombol edit diklik
  void _siapkanEditData(int index, Map data) {
    _nimController.text = data['nim'];
    _namaController.text = data['nama'];
    setState(() {
      _editIndex = index;
    });
  }

  // DELETE: Menampilkan dialog konfirmasi lalu menghapus data
  void _konfirmasiHapusData(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Konfirmasi'),
          content: const Text('Yakin ingin menghapus data?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _mahasiswaBox.deleteAt(index);
                Navigator.pop(context);
                
                // Jika data yang dihapus sedang diedit, reset form
                if (_editIndex == index) {
                  _nimController.clear();
                  _namaController.clear();
                  setState(() {
                    _editIndex = null;
                  });
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Beranda Admin'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'CRUD Hive Mahasiswa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // FORM INPUT
            TextField(
              controller: _nimController,
              decoration: InputDecoration(
                labelText: 'NIM',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            
            // TOMBOL SIMPAN / UPDATE
            ElevatedButton(
              onPressed: _simpanData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF3EDF7), // Warna ungu muda mengikuti desain
                foregroundColor: const Color(0xFF6750A4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_editIndex == null ? 'Simpan' : 'Update'),
            ),
            const SizedBox(height: 24),
            
            // LIST VIEW (Menampilkan Data)
            Expanded(
              // ValueListenableBuilder digunakan agar UI otomatis terupdate jika ada perubahan pada Hive
              child: ValueListenableBuilder(
                valueListenable: _mahasiswaBox.listenable(),
                builder: (context, Box box, _) {
                  if (box.isEmpty) {
                    return const Center(child: Text('Belum ada data mahasiswa.'));
                  }
                  
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final data = box.getAt(index) as Map;
                      
                      return Card(
                        color: const Color(0xFFF7F2FA), // Warna background card
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            data['nama'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(data['nim']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.black54),
                                onPressed: () => _siapkanEditData(index, data),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.black54),
                                onPressed: () => _konfirmasiHapusData(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}