import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/session_service.dart';

class ViewAttendanceScreenNew extends StatefulWidget {
  const ViewAttendanceScreenNew({super.key});

  @override
  State<ViewAttendanceScreenNew> createState() =>
      _ViewAttendanceScreenNewState();
}

class _ViewAttendanceScreenNewState extends State<ViewAttendanceScreenNew> {
  String teacherId = '';
  String teacherName = '';

  @override
  void initState() {
    super.initState();
    _loadTeacherInfo();
  }

  Future<void> _loadTeacherInfo() async {
    final id = await SessionService.getUserId();
    final name = await SessionService.getUserName();
    setState(() {
      teacherId = id ?? '';
      teacherName = name ?? '';
    });
  }

  Future<void> _exportToPdf(
    String sessionId,
    String subject,
    String classTime,
    String date,
    List<Map<String, dynamic>> students,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Attendance Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Teacher: $teacherName'),
              pw.Text('Subject: $subject'),
              pw.Text('Date: $date'),
              pw.Text('Class Time: $classTime'),
              pw.Text('Total Present: ${students.length}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['#', 'Student ID', 'Student Name', 'Time'],
                data: List.generate(students.length, (index) {
                  final student = students[index];
                  return [
                    '${index + 1}',
                    student['studentId'] ?? 'N/A',
                    student['studentName'] ?? 'Unknown',
                    student['time'] ?? 'N/A',
                  ];
                }),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _exportToExcel(
    String sessionId,
    String subject,
    String classTime,
    String date,
    List<Map<String, dynamic>> students,
  ) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Attendance'];

      // Add header information
      sheet.appendRow([TextCellValue('Attendance Report')]);
      sheet.appendRow([TextCellValue('')]);
      sheet.appendRow([TextCellValue('Teacher:'), TextCellValue(teacherName)]);
      sheet.appendRow([TextCellValue('Subject:'), TextCellValue(subject)]);
      sheet.appendRow([TextCellValue('Date:'), TextCellValue(date)]);
      sheet.appendRow([TextCellValue('Class Time:'), TextCellValue(classTime)]);
      sheet.appendRow([
        TextCellValue('Total Present:'),
        TextCellValue(students.length.toString()),
      ]);
      sheet.appendRow([TextCellValue('')]);

      // Add table headers
      sheet.appendRow([
        TextCellValue('#'),
        TextCellValue('Student ID'),
        TextCellValue('Student Name'),
        TextCellValue('Time'),
      ]);

      // Add student data
      for (int i = 0; i < students.length; i++) {
        final student = students[i];
        sheet.appendRow([
          TextCellValue((i + 1).toString()),
          TextCellValue(student['studentId'] ?? 'N/A'),
          TextCellValue(student['studentName'] ?? 'Unknown'),
          TextCellValue(student['time'] ?? 'N/A'),
        ]);
      }

      // Save the file to Downloads folder
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fileName =
          'Attendance_${subject.replaceAll(' ', '_')}_${date.replaceAll('/', '-')}.xlsx';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel saved to Downloads: $fileName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting Excel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

          // Sort by timestamp descending (most recent first)
          attendanceDocs.sort((a, b) {
            final aTime =
                (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            final bTime =
                (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          // Group by sessionId (each QR code session)
          Map<String, List<QueryDocumentSnapshot>> groupedBySession = {};
          Map<String, Map<String, String>> sessionInfo = {};

          for (var doc in attendanceDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final sessionId = data['sessionId'] ?? 'unknown';

            if (!groupedBySession.containsKey(sessionId)) {
              groupedBySession[sessionId] = [];
              sessionInfo[sessionId] = {
                'subject': data['subject'] ?? 'N/A',
                'date': data['date'] ?? 'N/A',
                'classTime': data['classTime'] ?? 'N/A',
              };
            }
            groupedBySession[sessionId]!.add(doc);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedBySession.length,
            itemBuilder: (context, index) {
              final sessionId = groupedBySession.keys.elementAt(index);
              final records = groupedBySession[sessionId]!;
              final info = sessionInfo[sessionId]!;
              final subject = info['subject']!;
              final date = info['date']!;
              final classTime = info['classTime']!;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                child: Column(
                  children: [
                    ListTile(
                      tileColor: AppColors.primary.withOpacity(0.1),
                      leading: const Icon(
                        Icons.class_,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        subject,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text('$date • $classTime'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                            label: Text('${records.length} Present'),
                            backgroundColor: Colors.green.shade100,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              // Prepare student data for PDF
                              List<Map<String, dynamic>> students = records.map(
                                (doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final timestamp =
                                      data['timestamp'] as Timestamp?;
                                  return {
                                    'studentId': data['studentId'] ?? 'N/A',
                                    'studentName':
                                        data['studentName'] ?? 'Unknown',
                                    'time': timestamp != null
                                        ? DateFormat(
                                            'hh:mm a',
                                          ).format(timestamp.toDate())
                                        : 'N/A',
                                  };
                                },
                              ).toList();

                              await _exportToPdf(
                                sessionId,
                                subject,
                                classTime,
                                date,
                                students,
                              );
                            },
                            tooltip: 'Export to PDF',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.table_chart,
                              color: Colors.green,
                            ),
                            onPressed: () async {
                              // Prepare student data for Excel
                              List<Map<String, dynamic>> students = records.map(
                                (doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final timestamp =
                                      data['timestamp'] as Timestamp?;
                                  return {
                                    'studentId': data['studentId'] ?? 'N/A',
                                    'studentName':
                                        data['studentName'] ?? 'Unknown',
                                    'time': timestamp != null
                                        ? DateFormat(
                                            'hh:mm a',
                                          ).format(timestamp.toDate())
                                        : 'N/A',
                                  };
                                },
                              ).toList();

                              await _exportToExcel(
                                sessionId,
                                subject,
                                classTime,
                                date,
                                students,
                              );
                            },
                            tooltip: 'Export to Excel',
                          ),
                        ],
                      ),
                    ),
                    ExpansionTile(
                      title: const Text('View Students'),
                      children: records.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final studentId = data['studentId'] ?? 'N/A';
                        final studentName = data['studentName'] ?? 'Unknown';
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
                          subtitle: Text('ID: $studentId'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              Text(
                                timeStr,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
