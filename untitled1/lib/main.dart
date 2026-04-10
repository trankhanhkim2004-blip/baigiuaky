import 'package:flutter/material.dart';

void main() {
  runApp(const PastelReminderApp());
}

class PastelReminderApp extends StatelessWidget {
  const PastelReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nhắc việc pastel',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF4A9C4),
          brightness: Brightness.light,
        ),
      ),
      home: const ReminderHomePage(),
    );
  }
}

enum ReminderMethod { bell, email, notification }

enum PriorityLevel { low, medium, high }

enum TaskFilter { all, pending, done }

class TaskItem {
  final String title;
  final String location;
  final String note;
  final DateTime dateTime;
  final bool enableReminder;
  final ReminderMethod? reminderMethod;
  final int? remindBeforeMinutes;
  final PriorityLevel priority;
  bool isDone;

  TaskItem({
    required this.title,
    required this.location,
    required this.note,
    required this.dateTime,
    required this.enableReminder,
    required this.reminderMethod,
    required this.remindBeforeMinutes,
    required this.priority,
    this.isDone = false,
  });
}

class ReminderHomePage extends StatefulWidget {
  const ReminderHomePage({super.key});

  @override
  State<ReminderHomePage> createState() => _ReminderHomePageState();
}

class _ReminderHomePageState extends State<ReminderHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<TaskItem> _tasks = [];
  TaskFilter _taskFilter = TaskFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddTaskPage() async {
    final result = await Navigator.push<TaskItem>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTaskPage(),
      ),
    );

    if (result != null) {
      setState(() {
        _tasks.insert(0, result);
      });
      _showMessage('Đã thêm công việc');
    }
  }

  void _toggleDone(int indexInFilteredList, bool? value) {
    final task = _filteredTasks[indexInFilteredList];
    setState(() {
      task.isDone = value ?? false;
    });
  }

  void _deleteTask(int indexInFilteredList) {
    final task = _filteredTasks[indexInFilteredList];
    setState(() {
      _tasks.remove(task);
    });
    _showMessage('Đã xóa công việc');
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFE88FB1),
      ),
    );
  }

  int get _doneCount => _tasks.where((e) => e.isDone).length;
  int get _pendingCount => _tasks.where((e) => !e.isDone).length;

  List<TaskItem> get _filteredTasks {
    final keyword = _searchController.text.trim().toLowerCase();

    return _tasks.where((task) {
      final matchKeyword =
          keyword.isEmpty ||
              task.title.toLowerCase().contains(keyword) ||
              task.location.toLowerCase().contains(keyword) ||
              task.note.toLowerCase().contains(keyword);

      final matchFilter = switch (_taskFilter) {
        TaskFilter.all => true,
        TaskFilter.pending => !task.isDone,
        TaskFilter.done => task.isDone,
      };

      return matchKeyword && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nhắc việc pastel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFD85D8C),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFEFF5),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTaskPage,
        backgroundColor: const Color(0xFFF08FB4),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Thêm việc',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm công việc...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFE16C98),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFFF4B8CC),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFFE88FB1),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip('Tất cả (${_tasks.length})', TaskFilter.all),
                    _buildFilterChip(
                      'Chưa xong ($_pendingCount)',
                      TaskFilter.pending,
                    ),
                    _buildFilterChip('Đã xong ($_doneCount)', TaskFilter.done),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: tasks.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _buildTaskCard(task, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEF4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF6C7D8)),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD9E7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: Color(0xFFD85D8C),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Danh sách công việc',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFFD85D8C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tổng: ${_tasks.length} • Chưa xong: $_pendingCount • Đã xong: $_doneCount',
                  style: const TextStyle(
                    color: Color(0xFF9A6878),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(TaskItem task, int index) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: task.isDone ? const Color(0xFFFFF1F6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF6CADA)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: task.isDone,
                activeColor: const Color(0xFFE88FB1),
                onChanged: (value) => _toggleDone(index, value),
              ),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF7A4A5C),
                    decoration:
                    task.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _deleteTask(index),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFE16C98),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _taskInfo(Icons.access_time_filled, _formatDateTime(task.dateTime)),
          const SizedBox(height: 6),
          _taskInfo(Icons.location_on_rounded, task.location),
          if (task.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            _taskInfo(Icons.sticky_note_2_outlined, task.note),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _smallTag(task.isDone ? 'Đã hoàn thành' : 'Đang chờ'),
                _smallTag(_priorityText(task.priority)),
                if (task.enableReminder)
                  _smallTag('Nhắc trước ${task.remindBeforeMinutes} phút'),
                if (task.enableReminder && task.reminderMethod != null)
                  _smallTag(_methodText(task.reminderMethod!)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEF4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF6C7D8)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: Color(0xFFFFD9E7),
              child: Icon(
                Icons.favorite_rounded,
                color: Color(0xFFD85D8C),
                size: 30,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Chưa có công việc nào',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFFD85D8C),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Bấm "Thêm việc" để tạo công việc mới nhé',
              style: TextStyle(
                color: Color(0xFF9B6677),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String text, TaskFilter value) {
    final isSelected = _taskFilter == value;

    return ChoiceChip(
      selected: isSelected,
      showCheckmark: false,
      label: Text(text),
      selectedColor: const Color(0xFFF19BB9),
      backgroundColor: const Color(0xFFFFEEF4),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF8D5A6B),
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: Color(0xFFF3BED2)),
      onSelected: (_) {
        setState(() {
          _taskFilter = value;
        });
      },
    );
  }

  Widget _taskInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE16C98)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF7D5A68),
            ),
          ),
        ),
      ],
    );
  }

  Widget _smallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFF5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF6CADB)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF9B6677),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final d = dateTime.day.toString().padLeft(2, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final y = dateTime.year.toString();
    final h = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return '$d/$m/$y - $h:$min';
  }

  String _methodText(ReminderMethod method) {
    switch (method) {
      case ReminderMethod.bell:
        return 'Chuông điện thoại';
      case ReminderMethod.email:
        return 'Email';
      case ReminderMethod.notification:
        return 'Thông báo';
    }
  }

  String _priorityText(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.low:
        return 'Ưu tiên thấp';
      case PriorityLevel.medium:
        return 'Ưu tiên trung bình';
      case PriorityLevel.high:
        return 'Ưu tiên cao';
    }
  }
}

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  bool _enableReminder = true;
  ReminderMethod _selectedMethod = ReminderMethod.notification;
  int _remindBeforeMinutes = 10;
  PriorityLevel _selectedPriority = PriorityLevel.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final note = _noteController.text.trim();

    if (title.isEmpty) {
      _showMessage('Vui lòng nhập tên công việc');
      return;
    }

    if (_selectedDateTime.isBefore(DateTime.now())) {
      _showMessage('Thời gian phải lớn hơn hiện tại');
      return;
    }

    final task = TaskItem(
      title: title,
      location: location.isEmpty ? 'Chưa có địa điểm' : location,
      note: note,
      dateTime: _selectedDateTime,
      enableReminder: _enableReminder,
      reminderMethod: _enableReminder ? _selectedMethod : null,
      remindBeforeMinutes: _enableReminder ? _remindBeforeMinutes : null,
      priority: _selectedPriority,
    );

    Navigator.pop(context, task);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFE88FB1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm công việc',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFD85D8C),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFEFF5),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEF4),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFF6C7D8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderBox(),
                const SizedBox(height: 18),
                _buildLabel('Tên công việc'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _titleController,
                  hint: 'Ví dụ: Họp nhóm, làm bài tập, đi học...',
                  icon: Icons.favorite_border,
                ),
                const SizedBox(height: 14),
                _buildLabel('Địa điểm'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _locationController,
                  hint: 'Ví dụ: Phòng A2, thư viện, quán cà phê...',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 14),
                _buildLabel('Ghi chú'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _noteController,
                  hint: 'Thêm ghi chú cho công việc...',
                  icon: Icons.edit_note_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                _buildLabel('Thời gian'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF4B8CC)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: Color(0xFFE16C98),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _formatDateTime(_selectedDateTime),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7E5868),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.edit_calendar_rounded,
                          color: Color(0xFFE16C98),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _buildLabel('Mức độ ưu tiên'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPriorityChip('Thấp', PriorityLevel.low),
                    _buildPriorityChip('Trung bình', PriorityLevel.medium),
                    _buildPriorityChip('Cao', PriorityLevel.high),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF6C7D8)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _enableReminder,
                        activeColor: const Color(0xFFE88FB1),
                        title: const Text(
                          'Bật nhắc việc',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD85D8C),
                          ),
                        ),
                        subtitle: const Text(
                          'Nhắc trước khi đến thời gian công việc',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _enableReminder = value;
                          });
                        },
                      ),
                      if (_enableReminder) ...[
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Hình thức nhắc',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8D5A6B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildMethodChip(
                              'Chuông điện thoại',
                              Icons.alarm,
                              ReminderMethod.bell,
                            ),
                            _buildMethodChip(
                              'Email',
                              Icons.email_outlined,
                              ReminderMethod.email,
                            ),
                            _buildMethodChip(
                              'Thông báo',
                              Icons.notifications_active_outlined,
                              ReminderMethod.notification,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<int>(
                          value: _remindBeforeMinutes,
                          decoration: InputDecoration(
                            labelText: 'Nhắc trước',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFFE16C98),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Color(0xFFF4B8CC),
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 5, child: Text('5 phút')),
                            DropdownMenuItem(value: 10, child: Text('10 phút')),
                            DropdownMenuItem(value: 15, child: Text('15 phút')),
                            DropdownMenuItem(value: 30, child: Text('30 phút')),
                            DropdownMenuItem(value: 60, child: Text('60 phút')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _remindBeforeMinutes = value ?? 10;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF08FB4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.save_rounded),
                    label: const Text(
                      'Lưu công việc',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF6C7D8)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD9E7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFFD85D8C),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tạo công việc mới',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFFD85D8C),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Trang riêng để thêm công việc, gọn hơn trên điện thoại',
                  style: TextStyle(
                    color: Color(0xFF9A6878),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF8D5A6B),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFE16C98)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFF4B8CC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFFE88FB1),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMethodChip(String text, IconData icon, ReminderMethod method) {
    final isSelected = _selectedMethod == method;

    return ChoiceChip(
      selected: isSelected,
      showCheckmark: false,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : const Color(0xFFD85D8C),
          ),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF8D5A6B),
        fontWeight: FontWeight.w600,
      ),
      selectedColor: const Color(0xFFF19BB9),
      backgroundColor: const Color(0xFFFFEEF4),
      side: const BorderSide(color: Color(0xFFF3BED2)),
      onSelected: (_) {
        setState(() {
          _selectedMethod = method;
        });
      },
    );
  }

  Widget _buildPriorityChip(String text, PriorityLevel value) {
    final isSelected = _selectedPriority == value;

    return ChoiceChip(
      selected: isSelected,
      showCheckmark: false,
      label: Text(text),
      selectedColor: const Color(0xFFF19BB9),
      backgroundColor: const Color(0xFFFFEEF4),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF8D5A6B),
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: Color(0xFFF3BED2)),
      onSelected: (_) {
        setState(() {
          _selectedPriority = value;
        });
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final d = dateTime.day.toString().padLeft(2, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final y = dateTime.year.toString();
    final h = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return '$d/$m/$y - $h:$min';
  }
}