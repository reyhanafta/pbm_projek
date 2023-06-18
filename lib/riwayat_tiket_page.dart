import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RiwayatTiketPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Tiket'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('riwayat_tiket').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final tiket = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Nama: ${tiket['nama']}'),
                subtitle: Text('Tujuan: ${tiket['tujuan']}'),
                trailing: Text('Jumlah Tiket: ${tiket['jumlahTiket']}'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
