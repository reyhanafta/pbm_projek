// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class PesanTiketPage extends StatefulWidget {
//   final Function(String, String, int) onTiketPesan;

//   PesanTiketPage({required this.onTiketPesan});

//   @override
//   _PesanTiketPageState createState() => _PesanTiketPageState();
// }

// class _PesanTiketPageState extends State<PesanTiketPage> {
//   TextEditingController _namaController = TextEditingController();
//   TextEditingController _tujuanController = TextEditingController();
//   TextEditingController _jumlahTiketController = TextEditingController();

//   Future<void> _pesanTiket() async {
//     String nama = _namaController.text;
//     String tujuan = _tujuanController.text;
//     int jumlahTiket = int.tryParse(_jumlahTiketController.text) ?? 0;

//     if (nama.isNotEmpty && tujuan.isNotEmpty && jumlahTiket > 0) {
//       try {
//         await FirebaseFirestore.instance.collection('riwayat_tiket').add({
//           'nama': nama,
//           'tujuan': tujuan,
//           'jumlahTiket': jumlahTiket,
//         });

//         // Panggil callback untuk mengirim data tiket ke halaman utama
//         widget.onTiketPesan(nama, tujuan, jumlahTiket);

//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text('Pemesanan Tiket'),
//               content: Text('Tiket berhasil dipesan.'),
//               actions: [
//                 TextButton(
//                   child: Text('OK'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             );
//           },
//         );

//         _namaController.clear();
//         _tujuanController.clear();
//         _jumlahTiketController.clear();
//       } catch (e) {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: Text('Error'),
//               content: Text('Gagal memesan tiket.'),
//               actions: [
//                 TextButton(
//                   child: Text('OK'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     } else {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Error'),
//             content: Text('Harap lengkapi semua field dengan benar.'),
//             actions: [
//               TextButton(
//                 child: Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Pesan Tiket'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _namaController,
//               decoration: InputDecoration(
//                 labelText: 'Nama',
//               ),
//             ),
//             SizedBox(height: 8),
//             TextField(
//               controller: _tujuanController,
//               decoration: InputDecoration(
//                 labelText: 'Tujuan',
//               ),
//             ),
//             SizedBox(height: 8),
//             TextField(
//               controller: _jumlahTiketController,
//               decoration: InputDecoration(
//                 labelText: 'Jumlah Tiket',
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _pesanTiket,
//               child: Text('Pesan Tiket'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
