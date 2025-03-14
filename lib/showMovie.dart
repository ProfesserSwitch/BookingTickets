import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiadtiyod/%E0%B8%B4bookTicket.dart';

class ShowMoviesScreen extends StatefulWidget {
  const ShowMoviesScreen({super.key});

  @override
  State<ShowMoviesScreen> createState() => _ShowMoviesScreenState();
}

class _ShowMoviesScreenState extends State<ShowMoviesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> rows = ['A', 'B', 'C', 'D', 'E', 'F']; 
  final List<String> indexs = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']; 
  final List<String> theaters = ['C01', 'C02', 'C03', 'C04', 'C05', 'C06', 'C07', 'C08', 'C09', 'C10']; // รายชื่อโรงภาพยนตร์

  /// ลบ
  Future<void> deleteMovie(String docId) async {
    await _firestore.collection("BookingTickets").doc(docId).delete();
  }

  /// แก้ไข 
  void showEditDialog(String docId, String movieName, String currentTheater, String currentSeat) {

    String selectedRow = currentSeat.substring(0, 1); 
    String selectedSeatNumber = currentSeat.substring(1); 
    String selectedTheater = currentTheater; 

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              Text("🎬 $movieName", style: const TextStyle(fontWeight: FontWeight.bold)), 
              const Divider(),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedTheater,
                decoration: const InputDecoration(labelText: "เลือกโรงภาพยนตร์"),
                items: theaters.map((theater) {
                  return DropdownMenuItem<String>(
                    value: theater,
                    child: Text(theater),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedTheater = newValue!;
                  });
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedRow,
                      decoration: const InputDecoration(labelText: "แถวที่นั่ง"),
                      items: rows.map((row) {
                        return DropdownMenuItem<String>(
                          value: row,
                          child: Text(row),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedRow = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSeatNumber,
                      decoration: const InputDecoration(labelText: "ลำดับที่นั่ง"),
                      items: indexs.map((num) {
                        return DropdownMenuItem<String>(
                          value: num,
                          child: Text(num),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedSeatNumber = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("ยกเลิก"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newSeat = "$selectedRow$selectedSeatNumber"; 
                await _firestore.collection("BookingTickets").doc(docId).update({
                  "theater": selectedTheater,
                  "seat": newSeat, 
                });
                Navigator.pop(context); 
              },
              child: const Text("บันทึก"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "รายการภาพยนต์ที่จอง",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255), 
            fontWeight: FontWeight.bold, 
          ),
        ),
        centerTitle: true, 
        backgroundColor: const Color.fromARGB(255, 26, 26, 26), 
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("BookingTickets").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final movies = snapshot.data!.docs;
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              final data = movie.data() as Map<String, dynamic>;
              return Container(
                color: index.isEven ? Colors.grey[200] : const Color.fromARGB(255, 224, 224, 224), 
                child: ListTile(
                  title: Text("${data['movie']}"),
                  leading: Text("🎬", style: TextStyle(fontSize: 20)),
                  subtitle: Text("โรง: ${data['theater']} | ที่นั่ง: ${data['seat']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showEditDialog(
                          movie.id,
                          data['movie'],
                          data['theater'],
                          data['seat'],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteMovie(movie.id),
                      ),
                    ],
                  ),
                )
              );
            },
          );
        },
      ),
      // ปุ่มจองตั๋วหนัง
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMovieScreen()),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 10,
        child: Container(
          width: 70.0,  
          height: 70.0, 
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
