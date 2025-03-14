import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMovieScreen extends StatefulWidget {
  const AddMovieScreen({super.key});

  @override
  State<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _movieController = TextEditingController();
  String? _selectedSeat;
  String? _selectedTheater;

  final List<String> rows = ['A', 'B', 'C', '', 'D', 'E', 'F']; 
  final List<String> seats = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']; 
  final List<String> theaters = ['C01', 'C02', 'C03', 'C04', 'C05', 'C06', 'C07', 'C08', 'C09', 'C10']; // รายชื่อโรงภาพยนตร์

  // ฟังก์ชันเพิ่มหนัง (อัปเดตให้แจ้งเตือนเมื่อข้อมูลไม่ครบ)
  Future<void> addMovie() async {
    if (_movieController.text.isEmpty || _selectedTheater == null || _selectedSeat == null) {
      // 🔔 แสดง Alert แจ้งเตือน
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("กรอกข้อมูลไม่ครบ!", style: TextStyle(color: Colors.red)),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      _movieController.text.isEmpty ? Icons.warning : Icons.check_circle,
                      color: _movieController.text.isEmpty ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    const Text("เลือกภาพยนตร์"),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _selectedTheater == null ? Icons.warning : Icons.check_circle,
                      color: _selectedTheater == null ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    const Text("เลือกโรงภาพยนตร์"),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _selectedSeat == null ? Icons.warning : Icons.check_circle,
                      color: _selectedSeat == null ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    const Text("เลือกที่นั่ง"),
                  ],
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () =>
                  Navigator.pop(context),
                child: const Text("ตกลง"),
              ),
            ],
          );
        },
      );
      return; 
    }
    // บันทึกข้อมูลลง Firestore 
    await _firestore.collection("BookingTickets").add({
      "movie": _movieController.text,
      "theater": _selectedTheater,
      "seat": _selectedSeat,
    });
    // เคลียร์ข้อมูล
    _movieController.clear();
    setState(() {
      _selectedTheater = null;
      _selectedSeat = null;
    });
    // กลับไปหน้าแรก
    Navigator.pop(context);
  }

  // ฟังก์ชันแสดงโรงภาพยนตร์แบบเลื่อนซ้ายขวา
  Widget buildTheaterSelector() {
    return SizedBox(
      height: 40, // ความสูงของรายการโรงภาพยนตร์
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // ✅ ทำให้เลื่อนซ้ายขวา
        itemCount: theaters.length,
        itemBuilder: (context, index) {
          String theater = theaters[index];
          bool isSelected = _selectedTheater == theater;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTheater = theater;
              });
            },
            child: Container(
              width: 70, // ✅ ขนาดกล่องโรงภาพยนตร์
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  theater,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ฟังก์ชันแสดงที่นั่งในรูปแบบกริด
  Widget buildSeatGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 40,
          color: Colors.blue,
          child: const Center(
            child: Text('Screen', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 10,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: rows.length * seats.length,
          itemBuilder: (context, index) {
            String row = rows[index ~/ seats.length];
            if (row.isEmpty) return const SizedBox.shrink();
            String seat = seats[index % seats.length];
            String seatId = row + seat;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSeat = seatId;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedSeat == seatId ? Colors.green : Colors.grey,
                  shape: BoxShape.rectangle,
                ),
                child: Center(
                  child: Text(seatId, style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("จองตั๋วรับชมหนัง")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _movieController, decoration: const InputDecoration(labelText: "ชื่อภาพยนตร์")),
            SizedBox(height: 16),
            Text("เลือกโรงภาพยนตร์"),
            SizedBox(height: 16),
            buildTheaterSelector(), 
            SizedBox(height: 16),
            Text("เลือกที่นั่ง"),
            SizedBox(height: 10),
            buildSeatGrid(), 
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity, 
              child: ElevatedButton(
                onPressed: addMovie,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), 
                  ),
                  elevation: 2, 
                ),
                child: const Text(
                  "จองตั๋ว",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
