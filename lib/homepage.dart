import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'profil_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0;
  late final List<Widget> _pages;

  List<Ticket> _ticketHistory = [];

  @override
  void initState() {
    super.initState();
    final userId = _auth.currentUser?.uid;
    _pages = [
      HomePageContent(
        ticketBookingCallback: _ticketBookingCallback,
        ticketHistory: _ticketHistory,
        userId: userId,
      ),
      RiwayatTiketPage(ticketHistory: _ticketHistory),
      ProfilPage(userId: userId),
    ];
  }

  void _selectPage(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 2) {
      Navigator.pushNamed(context, '/profil');
    }
  }

  void _logout() {
    _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _ticketBookingCallback(
      String name, String destination, int ticketCount) {
    setState(() {
      _ticketHistory.add(
        Ticket(name: name, destination: destination, ticketCount: ticketCount),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: Text('Home'),
            )
          : null,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _selectPage,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Ticket History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class Ticket {
  final String name;
  final String destination;
  final int ticketCount;

  Ticket({
    required this.name,
    required this.destination,
    required this.ticketCount,
  });
}

class HomePageContent extends StatelessWidget {
  final Function(String, String, int) ticketBookingCallback;
  final List<Ticket> ticketHistory;
  final String? userId;

  List<String> dummyImages = [
    'https://i0.wp.com/jadiberkah.com/wp-content/uploads/2023/01/bus-haryanto.jpg?resize=680%2C340&ssl=1',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRxieFMKMR5F11MThtjAm2m4j6_lcP1fl_RRQ&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKWsSJokKoe0-SKNN4sO20N7fFaAEk0yjeLA&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZ75dlfOWYKhuAtRFwsw23WpaGCAw_X4dujw&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQwdaKAhRO-S-eKkrR20woLzim6XdnrDUObMA&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZKgA_b9wuzFla3RJYResv_qEc6Pz9c-Sn8A&usqp=CAU',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTfSqVA8b4qLCky2G0kncg1JJIjg2zoIRw66Q&usqp=CAU',
  ];

  List<String> productNames = [
    'Haryanto',
    'Haryanto',
    'Haryanto',
    'Pandawa 87',
    'Kurnia',
    'Melody',
    'Setra',
  ];

  List<String> ticketPrices = [
    'Rp 50.000',
    'Rp 100.000',
    'Rp 200.000',
    'Rp 300.000',
    'Rp 400.000',
    'Rp 500.000',
    'Rp 600.000',
  ];

  HomePageContent({
    required this.ticketBookingCallback,
    required this.ticketHistory,
    required this.userId,
  });

  void _bookTicket(
      BuildContext context, String name, String destination) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController _ticketCountController = TextEditingController();
        return AlertDialog(
          title: Text('Book Ticket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: $name'),
              Text('Destination: $destination'),
              TextField(
                controller: _ticketCountController,
                decoration: InputDecoration(
                  labelText: 'Ticket Count',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Book'),
              onPressed: () {
                int ticketCount =
                    int.tryParse(_ticketCountController.text) ?? 0;
                if (ticketCount > 0) {
                  ticketBookingCallback(name, destination, ticketCount);
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Ticket Booking'),
                        content: Text('Ticket successfully booked.'),
                        actions: [
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Ticket count must be greater than 0.'),
                        actions: [
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      itemCount: dummyImages.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _bookTicket(context, productNames[index], ticketPrices[index]);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  dummyImages[index],
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 8),
                Text(
                  productNames[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(ticketPrices[index]),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RiwayatTiketPage extends StatelessWidget {
  final List<Ticket> ticketHistory;

  RiwayatTiketPage({required this.ticketHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Tiket'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: ticketHistory.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(ticketHistory[index].name),
              subtitle: Text(ticketHistory[index].destination),
              trailing: Text('${ticketHistory[index].ticketCount} ticket(s)'),
            ),
          );
        },
      ),
    );
  }
}
