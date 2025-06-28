import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;

class Goal {
  final String id;
  final String title;
  final String titleLao;
  final String description;
  final String descriptionLao;
  final String category;
  final double targetValue;
  final double currentValue;
  final String unit;
  final DateTime startDate;
  final DateTime targetDate;
  final bool isCompleted;
  final IconData icon;
  final Color color;

  Goal({
    required this.id,
    required this.title,
    required this.titleLao,
    required this.description,
    required this.descriptionLao,
    required this.category,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.startDate,
    required this.targetDate,
    required this.isCompleted,
    required this.icon,
    required this.color,
  });

  double get progressPercentage =>
      math.min((currentValue / targetValue) * 100, 100);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleLao': titleLao,
      'description': description,
      'descriptionLao': descriptionLao,
      'category': category,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unit': unit,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      titleLao: json['titleLao'] ?? '',
      description: json['description'] ?? '',
      descriptionLao: json['descriptionLao'] ?? '',
      category: json['category'] ?? '',
      targetValue: json['targetValue']?.toDouble() ?? 0.0,
      currentValue: json['currentValue']?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      targetDate: DateTime.parse(json['targetDate']),
      isCompleted: json['isCompleted'] ?? false,
      icon: _getCategoryIcon(json['category'] ?? ''),
      color: _getCategoryColor(json['category'] ?? ''),
    );
  }

  static IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'weight':
        return Icons.scale;
      case 'exercise':
        return Icons.fitness_center;
      case 'sleep':
        return Icons.bedtime;
      case 'stress':
        return Icons.psychology;
      case 'nutrition':
        return Icons.restaurant;
      default:
        return Icons.flag;
    }
  }

  static Color _getCategoryColor(String category) {
    switch (category) {
      case 'weight':
        return Colors.blue;
      case 'exercise':
        return Colors.orange;
      case 'sleep':
        return Colors.purple;
      case 'stress':
        return Colors.green;
      case 'nutrition':
        return Colors.red;
      default:
        return const Color(0xFFE91E63);
    }
  }

  Goal copyWith({
    String? id,
    String? title,
    String? titleLao,
    String? description,
    String? descriptionLao,
    String? category,
    double? targetValue,
    double? currentValue,
    String? unit,
    DateTime? startDate,
    DateTime? targetDate,
    bool? isCompleted,
    IconData? icon,
    Color? color,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      titleLao: titleLao ?? this.titleLao,
      description: description ?? this.description,
      descriptionLao: descriptionLao ?? this.descriptionLao,
      category: category ?? this.category,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<Goal> _goals = [];
  bool _isLaoLanguage = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsData = prefs.getString('user_goals');
      if (goalsData != null) {
        final List<dynamic> decoded = jsonDecode(goalsData);
        setState(() {
          _goals = decoded.map((item) => Goal.fromJson(item)).toList();
        });
      }
    } catch (e) {
      print('Error loading goals: $e');
    }
  }

  Future<void> _saveGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_goals.map((goal) => goal.toJson()).toList());
      await prefs.setString('user_goals', encoded);
    } catch (e) {
      print('Error saving goals: $e');
    }
  }

  void _addGoal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddGoalModal(
        onAdd: (goal) {
          setState(() {
            _goals.add(goal);
          });
          _saveGoals();
        },
        isLaoLanguage: _isLaoLanguage,
      ),
    );
  }

  void _updateGoalProgress(Goal goal, double newValue) {
    final updatedGoal = goal.copyWith(
      currentValue: newValue,
      isCompleted: newValue >= goal.targetValue,
    );

    setState(() {
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = updatedGoal;
      }
    });

    _saveGoals();

    if (updatedGoal.isCompleted && !goal.isCompleted) {
      _showCongratuationsDialog(updatedGoal);
    }
  }

  void _showCongratuationsDialog(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉'),
        content: Text(
          _isLaoLanguage
              ? 'ຂໍສະແດງຄວາມຍິນດີ! ເຈົ້າບັນລຸເປົ້າຫມາຍ "${goal.titleLao}" ແລ້ວ!'
              : 'Congratulations! You achieved your goal "${goal.title}"!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_isLaoLanguage ? 'ຂອບໃຈ' : 'Thanks'),
          ),
        ],
      ),
    );
  }

  List<Goal> get _activeGoals =>
      _goals.where((goal) => !goal.isCompleted).toList();
  List<Goal> get _completedGoals =>
      _goals.where((goal) => goal.isCompleted).toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(_isLaoLanguage ? '🎯 ເປົ້າຫມາຍ' : '🎯 Goals'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isLaoLanguage = !_isLaoLanguage;
              });
            },
            icon: Text(
              _isLaoLanguage ? 'EN' : 'ລາວ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            onPressed: _addGoal,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _goals.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress overview
                  if (_goals.isNotEmpty) ...[
                    _buildProgressOverview(),
                    const SizedBox(height: 24),
                  ],

                  // Active goals
                  if (_activeGoals.isNotEmpty) ...[
                    Text(
                      _isLaoLanguage ? 'ເປົ້າຫມາຍປະຈຸບັນ' : 'Active Goals',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._activeGoals.map((goal) => _buildGoalCard(goal)),
                    const SizedBox(height: 24),
                  ],

                  // Completed goals
                  if (_completedGoals.isNotEmpty) ...[
                    Text(
                      _isLaoLanguage
                          ? 'ເປົ້າຫມາຍທີ່ສຳເລັດແລ້ວ'
                          : 'Completed Goals',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._completedGoals.map((goal) => _buildGoalCard(goal)),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _isLaoLanguage ? 'ຍັງບໍ່ມີເປົ້າຫມາຍ' : 'No goals yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isLaoLanguage
                ? 'ກົດ + ເພື່ອເພີ່ມເປົ້າຫມາຍໃໝ່'
                : 'Tap + to add your first goal',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview() {
    final totalGoals = _goals.length;
    final completedGoals = _completedGoals.length;
    final completionRate =
        totalGoals > 0 ? (completedGoals / totalGoals) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFF8BBD9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isLaoLanguage ? 'ສະຖິຕິເປົ້າຫມາຍ' : 'Goals Overview',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '$totalGoals',
                _isLaoLanguage ? 'ທັງໝົດ' : 'Total',
                Colors.white,
              ),
              _buildStatItem(
                '$completedGoals',
                _isLaoLanguage ? 'ສຳເລັດ' : 'Completed',
                Colors.white,
              ),
              _buildStatItem(
                '${completionRate.toStringAsFixed(0)}%',
                _isLaoLanguage ? 'ອັດຕາສຳເລັດ' : 'Success Rate',
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(Goal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: goal.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    goal.icon,
                    color: goal.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLaoLanguage ? goal.titleLao : goal.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isLaoLanguage ? goal.descriptionLao : goal.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (goal.isCompleted)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${goal.currentValue.toStringAsFixed(goal.unit == 'times' ? 0 : 1)} / ${goal.targetValue.toStringAsFixed(goal.unit == 'times' ? 0 : 1)} ${goal.unit}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${goal.progressPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: goal.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: goal.progressPercentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                  minHeight: 6,
                ),
              ],
            ),

            if (!goal.isCompleted) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showUpdateProgressDialog(goal),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(_isLaoLanguage ? 'ອັບເດດ' : 'Update'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: goal.color,
                        side: BorderSide(color: goal.color),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showUpdateProgressDialog(Goal goal) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isLaoLanguage ? 'ອັບເດດຄວາມກ້າວໜ້າ' : 'Update Progress'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText:
                '${_isLaoLanguage ? 'ຄ່າໃໝ່' : 'New value'} (${goal.unit})',
            hintText: goal.currentValue.toString(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_isLaoLanguage ? 'ຍົກເລີກ' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newValue = double.tryParse(controller.text);
              if (newValue != null) {
                _updateGoalProgress(goal, newValue);
                Navigator.pop(context);
              }
            },
            child: Text(_isLaoLanguage ? 'ບັນທຶກ' : 'Save'),
          ),
        ],
      ),
    );
  }
}

class _AddGoalModal extends StatefulWidget {
  final Function(Goal) onAdd;
  final bool isLaoLanguage;

  const _AddGoalModal({required this.onAdd, required this.isLaoLanguage});

  @override
  State<_AddGoalModal> createState() => _AddGoalModalState();
}

class _AddGoalModalState extends State<_AddGoalModal> {
  final _titleController = TextEditingController();
  final _titleLaoController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionLaoController = TextEditingController();
  final _targetController = TextEditingController();

  String _selectedCategory = 'weight';
  String _selectedUnit = 'kg';
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));

  final Map<String, List<String>> _categoryUnits = {
    'weight': ['kg', 'lbs'],
    'exercise': ['times', 'minutes', 'hours'],
    'sleep': ['hours', 'nights'],
    'stress': ['days', 'times'],
    'nutrition': ['days', 'times'],
  };

  final Map<String, Map<String, String>> _categoryLabels = {
    'weight': {'en': 'Weight Loss', 'lao': 'ການຫຼຸດນ້ຳໜັກ'},
    'exercise': {'en': 'Exercise', 'lao': 'ອອກກຳລັງກາຍ'},
    'sleep': {'en': 'Sleep', 'lao': 'ການນອນ'},
    'stress': {'en': 'Stress Management', 'lao': 'ຄຸ້ມຄອງຄວາມຄຽດ'},
    'nutrition': {'en': 'Nutrition', 'lao': 'ໂພຊະນາການ'},
  };

  @override
  void initState() {
    super.initState();
    _updateUnits();
  }

  void _updateUnits() {
    _selectedUnit = _categoryUnits[_selectedCategory]?.first ?? 'times';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.isLaoLanguage ? 'ເພີ່ມເປົ້າຫມາຍໃໝ່' : 'Add New Goal',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category selection
                    Text(
                      widget.isLaoLanguage ? 'ປະເພດ:' : 'Category:',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      items: _categoryLabels.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(
                            widget.isLaoLanguage
                                ? entry.value['lao']!
                                : entry.value['en']!,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                          _updateUnits();
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextField(
                      controller: widget.isLaoLanguage
                          ? _titleLaoController
                          : _titleController,
                      decoration: InputDecoration(
                        labelText: widget.isLaoLanguage
                            ? 'ຊື່ເປົ້າຫມາຍ'
                            : 'Goal Title',
                        hintText: widget.isLaoLanguage
                            ? 'ເຊັ່ນ: ຫຼຸດນ້ຳໜັກ 5 ກິໂລ'
                            : 'e.g., Lose 5 kg',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextField(
                      controller: widget.isLaoLanguage
                          ? _descriptionLaoController
                          : _descriptionController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText:
                            widget.isLaoLanguage ? 'ລາຍລະອຽດ' : 'Description',
                        hintText: widget.isLaoLanguage
                            ? 'ອະທິບາຍເປົ້າຫມາຍຂອງເຈົ້າ...'
                            : 'Describe your goal...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Target value and unit
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _targetController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText:
                                  widget.isLaoLanguage ? 'ເປົ້າຫມາຍ' : 'Target',
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
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: InputDecoration(
                              labelText:
                                  widget.isLaoLanguage ? 'ຫົວໜ່ວຍ' : 'Unit',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            items:
                                _categoryUnits[_selectedCategory]!.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedUnit = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Target date
                    Text(
                      widget.isLaoLanguage ? 'ກຳນົດເວລາ:' : 'Target Date:',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _targetDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _targetDate = date;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Color(0xFFE91E63)),
                            const SizedBox(width: 12),
                            Text(
                              '${_targetDate.day}/${_targetDate.month}/${_targetDate.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_validateForm()) {
                    final goal = Goal(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _titleController.text.isNotEmpty
                          ? _titleController.text
                          : _titleLaoController.text,
                      titleLao: _titleLaoController.text.isNotEmpty
                          ? _titleLaoController.text
                          : _titleController.text,
                      description: _descriptionController.text.isNotEmpty
                          ? _descriptionController.text
                          : _descriptionLaoController.text,
                      descriptionLao: _descriptionLaoController.text.isNotEmpty
                          ? _descriptionLaoController.text
                          : _descriptionController.text,
                      category: _selectedCategory,
                      targetValue: double.parse(_targetController.text),
                      currentValue: 0,
                      unit: _selectedUnit,
                      startDate: DateTime.now(),
                      targetDate: _targetDate,
                      isCompleted: false,
                      icon: Goal._getCategoryIcon(_selectedCategory),
                      color: Goal._getCategoryColor(_selectedCategory),
                    );

                    widget.onAdd(goal);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.isLaoLanguage ? 'ເພີ່ມເປົ້າຫມາຍ' : 'Add Goal',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateForm() {
    final hasTitle =
        _titleController.text.isNotEmpty || _titleLaoController.text.isNotEmpty;
    final hasTarget = _targetController.text.isNotEmpty &&
        double.tryParse(_targetController.text) != null;

    if (!hasTitle || !hasTarget) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isLaoLanguage
                ? 'ກະລຸນາປ້ອນຂໍ້ມູນໃຫ້ຄົບຖ້ວນ'
                : 'Please fill in all required fields',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }
}
