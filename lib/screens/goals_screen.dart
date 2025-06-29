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
  final String priority; // ຄວາມສຳຄັນ: high, medium, low
  final List<String> milestones; // ຈຸດຫມາຍກາງ
  final List<String> notes; // ບັນທຶກ

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
    this.priority = 'medium',
    this.milestones = const [],
    this.notes = const [],
  });

  double get progressPercentage =>
      math.min((currentValue / targetValue) * 100, 100);

  int get daysRemaining {
    final now = DateTime.now();
    if (targetDate.isBefore(now)) return 0;
    return targetDate.difference(now).inDays;
  }

  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;

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
      'priority': priority,
      'milestones': milestones,
      'notes': notes,
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
      priority: json['priority'] ?? 'medium',
      milestones: List<String>.from(json['milestones'] ?? []),
      notes: List<String>.from(json['notes'] ?? []),
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
    String? priority,
    List<String>? milestones,
    List<String>? notes,
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
      priority: priority ?? this.priority,
      milestones: milestones ?? this.milestones,
      notes: notes ?? this.notes,
    );
  }
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with TickerProviderStateMixin {
  List<Goal> _goals = [];
  bool _isLaoLanguage = true;
  String _filterCategory = 'all';
  String _sortBy = 'priority'; // priority, deadline, progress
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGoals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  void _addNote(Goal goal, String note) {
    final updatedNotes = List<String>.from(goal.notes)..add(note);
    final updatedGoal = goal.copyWith(notes: updatedNotes);

    setState(() {
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = updatedGoal;
      }
    });
    _saveGoals();
  }

  void _deleteGoal(Goal goal) {
    setState(() {
      _goals.removeWhere((g) => g.id == goal.id);
    });
    _saveGoals();
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

  List<Goal> get _filteredAndSortedGoals {
    var filtered = _goals.where((goal) {
      if (_filterCategory == 'all') return true;
      return goal.category == _filterCategory;
    }).toList();

    // Sort by selected criteria
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'priority':
          final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
          return priorityOrder[a.priority]!
              .compareTo(priorityOrder[b.priority]!);
        case 'deadline':
          return a.targetDate.compareTo(b.targetDate);
        case 'progress':
          return b.progressPercentage.compareTo(a.progressPercentage);
        default:
          return 0;
      }
    });

    return filtered;
  }

  List<Goal> get _activeGoals =>
      _filteredAndSortedGoals.where((goal) => !goal.isCompleted).toList();
  List<Goal> get _completedGoals =>
      _filteredAndSortedGoals.where((goal) => goal.isCompleted).toList();
  List<Goal> get _overdueGoals =>
      _goals.where((goal) => goal.isOverdue).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'priority',
                child: Text(_isLaoLanguage ? 'ຄວາມສຳຄັນ' : 'Priority'),
              ),
              PopupMenuItem(
                value: 'deadline',
                child: Text(_isLaoLanguage ? 'ກຳນົດເວລາ' : 'Deadline'),
              ),
              PopupMenuItem(
                value: 'progress',
                child: Text(_isLaoLanguage ? 'ຄວາມກ້າວໜ້າ' : 'Progress'),
              ),
            ],
          ),
          IconButton(
            onPressed: _addGoal,
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: _goals.isNotEmpty
            ? TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFE91E63),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFFE91E63),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.play_arrow),
                    text: _isLaoLanguage ? 'ດຳເນີນການ' : 'Active',
                  ),
                  Tab(
                    icon: const Icon(Icons.check_circle),
                    text: _isLaoLanguage ? 'ສຳເລັດ' : 'Completed',
                  ),
                  Tab(
                    icon: const Icon(Icons.analytics),
                    text: _isLaoLanguage ? 'ສະຖິຕິ' : 'Stats',
                  ),
                ],
              )
            : null,
      ),
      body: _goals.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Filter chips
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                            'all', _isLaoLanguage ? 'ທັງໝົດ' : 'All'),
                        _buildFilterChip(
                            'weight', _isLaoLanguage ? 'ນ້ຳໜັກ' : 'Weight'),
                        _buildFilterChip('exercise',
                            _isLaoLanguage ? 'ອອກກຳລັງ' : 'Exercise'),
                        _buildFilterChip(
                            'sleep', _isLaoLanguage ? 'ນອນ' : 'Sleep'),
                        _buildFilterChip(
                            'stress', _isLaoLanguage ? 'ຄວາມຄຽດ' : 'Stress'),
                        _buildFilterChip('nutrition',
                            _isLaoLanguage ? 'ໂພຊະນາການ' : 'Nutrition'),
                      ],
                    ),
                  ),
                ),

                // Alert for overdue goals
                if (_overdueGoals.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isLaoLanguage
                                ? '${_overdueGoals.length} ເປົ້າຫມາຍເກີນກຳນົດ'
                                : '${_overdueGoals.length} goals overdue',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGoalsList(_activeGoals),
                      _buildGoalsList(_completedGoals),
                      _buildStatsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String category, String label) {
    final isSelected = _filterCategory == category;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterCategory = category;
          });
        },
        selectedColor: const Color(0xFFE91E63).withOpacity(0.2),
        checkmarkColor: const Color(0xFFE91E63),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFFE91E63) : Colors.grey[600],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildGoalsList(List<Goal> goals) {
    if (goals.isEmpty) {
      return Center(
        child: Text(
          _isLaoLanguage
              ? 'ບໍ່ມີເປົ້າຫມາຍໃນໝວດນີ້'
              : 'No goals in this category',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) => _buildCompactGoalCard(goals[index]),
    );
  }

  Widget _buildCompactGoalCard(Goal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: goal.isOverdue
            ? Border.all(color: Colors.red[300]!, width: 1)
            : null,
      ),
      child: InkWell(
        onTap: () => _showGoalDetails(goal),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Icon with priority indicator
                  Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: goal.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(goal.icon, color: goal.color, size: 20),
                      ),
                      if (goal.priority == 'high')
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Goal info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLaoLanguage ? goal.titleLao : goal.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${goal.currentValue.toStringAsFixed(goal.unit == 'times' ? 0 : 1)}/${goal.targetValue.toStringAsFixed(goal.unit == 'times' ? 0 : 1)} ${goal.unit}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (goal.daysRemaining > 0)
                              Text(
                                '${goal.daysRemaining} ${_isLaoLanguage ? 'ມື້' : 'days'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: goal.daysRemaining <= 7
                                      ? Colors.orange
                                      : Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Progress circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          value: goal.progressPercentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                          strokeWidth: 3,
                        ),
                      ),
                      Text(
                        '${goal.progressPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (!goal.isCompleted) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showUpdateProgressDialog(goal),
                        icon: const Icon(Icons.add, size: 16),
                        label: Text(_isLaoLanguage ? 'ອັບເດດ' : 'Update'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: goal.color,
                          side: BorderSide(color: goal.color),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _showAddNoteDialog(goal),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                      ),
                      child: Icon(Icons.note_add, size: 16),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsTab() {
    final totalGoals = _goals.length;
    final completedGoals = _goals.where((g) => g.isCompleted).length;
    final overdueGoals = _overdueGoals.length;
    final avgProgress = _goals.isEmpty
        ? 0.0
        : _goals.fold<double>(0, (sum, goal) => sum + goal.progressPercentage) /
            _goals.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  totalGoals.toString(),
                  _isLaoLanguage ? 'ທັງໝົດ' : 'Total',
                  Colors.blue,
                  Icons.flag,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  completedGoals.toString(),
                  _isLaoLanguage ? 'ສຳເລັດ' : 'Completed',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  overdueGoals.toString(),
                  _isLaoLanguage ? 'ເກີນກຳນົດ' : 'Overdue',
                  Colors.red,
                  Icons.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '${avgProgress.toStringAsFixed(0)}%',
                  _isLaoLanguage ? 'ຄ່າສະເລ່ຍ' : 'Avg Progress',
                  Colors.orange,
                  Icons.trending_up,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Category breakdown
          Text(
            _isLaoLanguage ? 'ແຍກຕາມປະເພດ' : 'By Category',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildCategoryStats(),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryStats() {
    final categories = ['weight', 'exercise', 'sleep', 'stress', 'nutrition'];
    final categoryLabels = {
      'weight': _isLaoLanguage ? 'ນ້ຳໜັກ' : 'Weight',
      'exercise': _isLaoLanguage ? 'ອອກກຳລັງ' : 'Exercise',
      'sleep': _isLaoLanguage ? 'ນອນ' : 'Sleep',
      'stress': _isLaoLanguage ? 'ຄວາມຄຽດ' : 'Stress',
      'nutrition': _isLaoLanguage ? 'ໂພຊະນາການ' : 'Nutrition',
    };

    return categories.map((category) {
      final categoryGoals =
          _goals.where((g) => g.category == category).toList();
      final completedCount = categoryGoals.where((g) => g.isCompleted).length;
      final totalCount = categoryGoals.length;
      final percentage =
          totalCount > 0 ? (completedCount / totalCount) * 100 : 0.0;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Goal._getCategoryColor(category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Goal._getCategoryIcon(category),
                color: Goal._getCategoryColor(category),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryLabels[category]!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Goal._getCategoryColor(category),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$completedCount/$totalCount',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _showGoalDetails(Goal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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

              // Goal header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(goal.icon, color: goal.color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLaoLanguage ? goal.titleLao : goal.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _isLaoLanguage
                              ? goal.descriptionLao
                              : goal.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(goal);
                      } else if (value == 'edit') {
                        _editGoal(goal);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text(_isLaoLanguage ? 'ແກ້ໄຂ' : 'Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete,
                                size: 20, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              _isLaoLanguage ? 'ລຶບ' : 'Delete',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Progress section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: goal.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isLaoLanguage ? 'ຄວາມກ້າວໜ້າ' : 'Progress',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${goal.progressPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: goal.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: goal.progressPercentage / 100,
                      backgroundColor: Colors.white.withOpacity(0.5),
                      valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${goal.currentValue.toStringAsFixed(goal.unit == 'times' ? 0 : 1)} ${goal.unit}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          '${goal.targetValue.toStringAsFixed(goal.unit == 'times' ? 0 : 1)} ${goal.unit}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Goal info
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      _isLaoLanguage ? 'ວັນທີ່ເລີ່ມ' : 'Start Date',
                      '${goal.startDate.day}/${goal.startDate.month}/${goal.startDate.year}',
                      Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(
                      _isLaoLanguage ? 'ກຳນົດສິ້ນສຸດ' : 'Target Date',
                      '${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}',
                      Icons.flag,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      _isLaoLanguage ? 'ຄວາມສຳຄັນ' : 'Priority',
                      goal.priority == 'high'
                          ? (_isLaoLanguage ? 'ສູງ' : 'High')
                          : goal.priority == 'medium'
                              ? (_isLaoLanguage ? 'ກາງ' : 'Medium')
                              : (_isLaoLanguage ? 'ຕ່ຳ' : 'Low'),
                      Icons.priority_high,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(
                      _isLaoLanguage ? 'ເຫຼືອເວລາ' : 'Days Left',
                      goal.daysRemaining > 0
                          ? '${goal.daysRemaining} ${_isLaoLanguage ? 'ມື້' : 'days'}'
                          : (_isLaoLanguage ? 'ໝົດກຳນົດ' : 'Overdue'),
                      Icons.access_time,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Notes section
              Text(
                _isLaoLanguage
                    ? 'ບັນທຶກ (${goal.notes.length})'
                    : 'Notes (${goal.notes.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: goal.notes.isEmpty
                    ? Center(
                        child: Text(
                          _isLaoLanguage ? 'ຍັງບໍ່ມີບັນທຶກ' : 'No notes yet',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: goal.notes.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              goal.notes[index],
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        },
                      ),
              ),

              if (!goal.isCompleted) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showUpdateProgressDialog(goal);
                        },
                        icon: const Icon(Icons.add),
                        label: Text(_isLaoLanguage
                            ? 'ອັບເດດຄວາມກ້າວໜ້າ'
                            : 'Update Progress'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: goal.color,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isLaoLanguage ? 'ລຶບເປົ້າຫມາຍ' : 'Delete Goal'),
        content: Text(
          _isLaoLanguage
              ? 'ເຈົ້າຕ້ອງການລຶບເປົ້າຫມາຍນີ້ບໍ?'
              : 'Are you sure you want to delete this goal?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_isLaoLanguage ? 'ຍົກເລີກ' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              _deleteGoal(goal);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(_isLaoLanguage ? 'ລຶບ' : 'Delete'),
          ),
        ],
      ),
    );
  }

  void _editGoal(Goal goal) {
    // Implementation for editing goal
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isLaoLanguage
            ? 'ຟັງຊັນແກ້ໄຂຈະມາໃນອະນາຄົດ'
            : 'Edit feature coming soon'),
      ),
    );
  }

  void _showUpdateProgressDialog(Goal goal) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isLaoLanguage ? 'ອັບເດດຄວາມກ້າວໜ້າ' : 'Update Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText:
                    '${_isLaoLanguage ? 'ຄ່າໃໝ່' : 'New value'} (${goal.unit})',
                hintText: goal.currentValue.toString(),
              ),
            ),
            const SizedBox(height: 16),
            // Quick buttons for common increments
            Wrap(
              spacing: 8,
              children: [
                _buildQuickButton('+1',
                    () => controller.text = (goal.currentValue + 1).toString()),
                _buildQuickButton('+5',
                    () => controller.text = (goal.currentValue + 5).toString()),
                _buildQuickButton(
                    '+10',
                    () =>
                        controller.text = (goal.currentValue + 10).toString()),
                _buildQuickButton('${_isLaoLanguage ? 'ສຳເລັດ' : 'Complete'}',
                    () => controller.text = goal.targetValue.toString()),
              ],
            ),
          ],
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

  Widget _buildQuickButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  void _showAddNoteDialog(Goal goal) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isLaoLanguage ? 'ເພີ່ມບັນທຶກ' : 'Add Note'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: _isLaoLanguage ? 'ເຂີຍນບັນທຶກ...' : 'Write a note...',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_isLaoLanguage ? 'ຍົກເລີກ' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addNote(goal, controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(_isLaoLanguage ? 'ເພີ່ມ' : 'Add'),
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
  String _selectedPriority = 'medium';
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

                    // Priority selection
                    Text(
                      widget.isLaoLanguage ? 'ຄວາມສຳຄັນ:' : 'Priority:',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPriorityChip('high',
                            widget.isLaoLanguage ? 'ສູງ' : 'High', Colors.red),
                        const SizedBox(width: 8),
                        _buildPriorityChip(
                            'medium',
                            widget.isLaoLanguage ? 'ກາງ' : 'Medium',
                            Colors.orange),
                        const SizedBox(width: 8),
                        _buildPriorityChip('low',
                            widget.isLaoLanguage ? 'ຕ່ຳ' : 'Low', Colors.green),
                      ],
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
                      priority: _selectedPriority,
                      milestones: [],
                      notes: [],
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

  Widget _buildPriorityChip(String priority, String label, Color color) {
    final isSelected = _selectedPriority == priority;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPriority = priority;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? color : Colors.grey[600],
            ),
          ),
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
