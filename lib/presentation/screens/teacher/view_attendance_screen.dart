import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/session_service.dart';

class ViewAttendanceScreen extends StatefulWidget {
  const ViewAttendanceScreen({super.key});

  @override
  State<ViewAttendanceScreen> createState() => _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends State<ViewAttendanceScreen> {
  String teacherId = '';

  @override
  void initState() {
    super.initState();
    _loadTeacherId();
  }

  Future<void> _loadTeacherId() async {
    final id = await SessionService.getUserId();
    setState(() {
      teacherId = id ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (teacherId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("View Attendance"),
        backgroundColor: AppColors.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where('teacherId', isEqualTo: teacherId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No attendance records yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final attendanceDocs = snapshot.data!.docs;

          // Group attendance by date
          Map<String, List<QueryDocumentSnapshot>> groupedByDate = {};

          for (var doc in attendanceDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['timestamp'] as Timestamp?;

            if (timestamp != null) {
              final date = DateFormat('yyyy-MM-dd').format(timestamp.toDate());
              if (!groupedByDate.containsKey(date)) {
                groupedByDate[date] = [];
              }
              groupedByDate[date]!.add(doc);
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedByDate.length,
            itemBuilder: (context, index) {
              final date = groupedByDate.keys.elementAt(index);
              final records = groupedByDate[date]!;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(
                    date,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text('${records.length} students present'),
                  children: records.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final studentId = data['studentId'] ?? 'N/A';
                    final studentName = data['studentName'] ?? 'Unknown';
                    final subject = data['subject'] ?? 'N/A';
                    final timestamp = data['timestamp'] as Timestamp?;
                    final timeStr = timestamp != null
                        ? DateFormat('hh:mm a').format(timestamp.toDate())
                        : 'N/A';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text(
                          studentName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(studentName),
                      subtitle: Text('ID: $studentId • $subject'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          Text(timeStr, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
