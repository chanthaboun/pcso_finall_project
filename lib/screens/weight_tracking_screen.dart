import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;

class WeightRecord {
  final String id;
  final double weight;
  final DateTime date;
  final String? notes;

  WeightRecord({
    required this.id,
    required this.weight,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: json['id'] ?? '',
      weight: json['weight']?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date']),
      notes: json['notes'],
    );
  }
}

class WeightTrackingScreen extends StatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  List<WeightRecord> _weightRecords = [];
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWeightRecords();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadWeightRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final weightData = prefs.getString('weight_records');
      if (weightData != null) {
        final List<dynamic> decoded = jsonDecode(weightData);
        setState(() {
          _weightRecords =
              decoded.map((item) => WeightRecord.fromJson(item)).toList();
          _weightRecords.sort((a, b) => b.date.compareTo(a.date));
        });
      }
    } catch (e) {
      print('Error loading weight records: $e');
    }
  }

  Future<void> _saveWeightRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(_weightRecords.map((record) => record.toJson()).toList());
      await prefs.setString('weight_records', encoded);
    } catch (e) {
      print('Error saving weight records: $e');
    }
  }

  Future<void> _addWeightRecord() async {
    if (_weightController.text.isNotEmpty) {
      final weight = double.tryParse(_weightController.text);
      if (weight != null && weight > 0) {
        final record = WeightRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          weight: weight,
          date: DateTime.now(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        setState(() {
          _weightRecords.insert(0, record);
        });

        await _saveWeightRecords();
        _weightController.clear();
        _notesController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ບັນທຶກນ້ຳໜັກສຳເລັດ! 📊'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  double? get _currentWeight =>
      _weightRecords.isNotEmpty ? _weightRecords.first.weight : null;

  double? get _previousWeight =>
      _weightRecords.length > 1 ? _weightRecords[1].weight : null;

  double? get _weightChange {
    if (_currentWeight != null && _previousWeight != null) {
      return _currentWeight! - _previousWeight!;
    }
    return null;
  }

  List<WeightRecord> get _recentRecords {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    return _weightRecords
        .where((record) => record.date.isAfter(thirtyDaysAgo))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('📈 ນ້ຳໜັກ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add weight section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ບັນທຶກນ້ຳໜັກມື້ນີ້',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'ນ້ຳໜັກ (kg)',
                            hintText: 'ເຊັ່ນ: 65.5',
                            prefixIcon: const Icon(
                              Icons.scale,
                              color: Color(0xFFE91E63),
                            ),
                            suffixText: 'kg',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _addWeightRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('ບັນທຶກ'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'ໝາຍເຫດ (ເສີມ)',
                      hintText: 'ເຊັ່ນ: ຫຼັງອາຫານເຊົ້າ',
                      prefixIcon: const Icon(
                        Icons.note,
                        color: Color(0xFFE91E63),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Current stats
            if (_currentWeight != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE91E63).withOpacity(0.8),
                      const Color(0xFFE91E63),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'ນ້ຳໜັກປັດຈຸບັນ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_currentWeight!.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (_weightChange != null)
                          Column(
                            children: [
                              const Text(
                                'ການປ່ຽນແປງ',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    _weightChange! > 0
                                        ? Icons.trending_up
                                        : _weightChange! < 0
                                            ? Icons.trending_down
                                            : Icons.trending_flat,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_weightChange! > 0 ? '+' : ''}${_weightChange!.toStringAsFixed(1)} kg',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Chart section
            if (_recentRecords.length > 1) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ກາຟິກນ້ຳໜັກ (30 ວັນ)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E63),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: _WeightChart(
                          records: _recentRecords.reversed.toList()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Recent records
            const Text(
              'ປະຫວັດນ້ຳໜັກ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            if (_weightRecords.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.scale,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ຍັງບໍ່ມີການບັນທຶກນ້ຳໜັກ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: math.min(_weightRecords.length, 10),
                itemBuilder: (context, index) {
                  final record = _weightRecords[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.scale,
                            color: Color(0xFFE91E63),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${record.weight.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${record.date.day}/${record.date.month}/${record.date.year}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (record.notes != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  record.notes!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<WeightRecord> records;

  const _WeightChart({required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.length < 2) return const SizedBox.shrink();

    final minWeight = records.map((r) => r.weight).reduce(math.min) - 1;
    final maxWeight = records.map((r) => r.weight).reduce(math.max) + 1;
    final weightRange = maxWeight - minWeight;

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: _WeightChartPainter(
        records: records,
        minWeight: minWeight,
        maxWeight: maxWeight,
        weightRange: weightRange,
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<WeightRecord> records;
  final double minWeight;
  final double maxWeight;
  final double weightRange;

  _WeightChartPainter({
    required this.records,
    required this.minWeight,
    required this.maxWeight,
    required this.weightRange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE91E63)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = const Color(0xFFE91E63)
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < records.length; i++) {
      final x = (i / (records.length - 1)) * size.width;
      final y = size.height -
          ((records[i].weight - minWeight) / weightRange) * size.height;

      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw line
    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
      canvas.drawCircle(
          point,
          6,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
