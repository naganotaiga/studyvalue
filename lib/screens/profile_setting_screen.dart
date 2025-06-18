/// StudyValue - プロフィール設定画面
/// ユーザーの基本情報と勉強時間設定

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../models/user_profile.dart';
import '../services/salary_calculator.dart';

class ProfileSettingScreen extends ConsumerStatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  ConsumerState<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends ConsumerState<ProfileSettingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _universityController;
  late TextEditingController _ageController;
  late TextEditingController _weekdayHoursController;
  late TextEditingController _weekendHoursController;
  late TextEditingController _customSalaryController;
  
  DateTime _selectedExamDate = DateTime.now().add(const Duration(days: 365));
  String _selectedGender = '男性';
  bool _useCustomSalary = false;
  
  final List<String> _universities = [
    '東京大学',
    '京都大学',
    '大阪大学',
    '名古屋大学',
    '東北大学',
    '九州大学',
    '北海道大学',
    '早稲田大学',
    '慶應義塾大学',
    'その他私立大学',
    'その他国公立大学',
  ];
  
  final List<String> _genders = ['男性', '女性', 'その他'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadExistingProfile();
  }

  void _initializeControllers() {
    _universityController = TextEditingController(text: '東京大学');
    _ageController = TextEditingController(text: '18');
    _weekdayHoursController = TextEditingController(text: '8');
    _weekendHoursController = TextEditingController(text: '12');
    _customSalaryController = TextEditingController();
  }

  void _loadExistingProfile() {
    final profile = ref.read(userProfileProvider);
    if (profile != null) {
      _universityController.text = profile.targetUniversity;
      _ageController.text = profile.age.toString();
      _weekdayHoursController.text = profile.weekdayStudyHours.toString();
      _weekendHoursController.text = profile.weekendStudyHours.toString();
      _selectedExamDate = profile.examDate;
      _selectedGender = profile.gender;
      _useCustomSalary = profile.customSalaryData != null;
      if (_useCustomSalary) {
        _customSalaryController.text = profile.customSalaryData!.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _universityController.dispose();
    _ageController.dispose();
    _weekdayHoursController.dispose();
    _weekendHoursController.dispose();
    _customSalaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('プロフィール設定'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saveProfile,
          child: const Text('保存'),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildSection(
                  '基本情報',
                  [
                    _buildUniversityPicker(),
                    _buildGenderPicker(),
                    _buildAgeField(),
                    _buildExamDatePicker(),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  '勉強時間設定',
                  [
                    _buildStudyHoursField('平日勉強時間（時間/日）', _weekdayHoursController),
                    _buildStudyHoursField('休日勉強時間（時間/日）', _weekendHoursController),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  '年収設定',
                  [
                    _buildCustomSalaryToggle(),
                    if (_useCustomSalary) _buildCustomSalaryField(),
                    _buildSalaryPreview(),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildUniversityPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text('志望校'),
          ),
          Expanded(
            flex: 3,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                _showPicker(
                  context,
                  CupertinoPicker(
                    itemExtent: 32.0,
                    onSelectedItemChanged: (index) {
                      _universityController.text = _universities[index];
                    },
                    children: _universities.map((university) => Text(university)).toList(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _universityController.text,
                      style: const TextStyle(color: CupertinoColors.systemBlue),
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color: CupertinoColors.systemGrey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderPicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text('性別'),
          ),
          Expanded(
            flex: 3,
            child: CupertinoSlidingSegmentedControl<String>(
              groupValue: _selectedGender,
              children: const {
                '男性': Text('男性'),
                '女性': Text('女性'),
                'その他': Text('その他'),
              },
              onValueChanged: (value) {
                setState(() {
                  _selectedGender = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text('年齢'),
          ),
          Expanded(
            flex: 3,
            child: CupertinoTextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              suffix: const Text('歳'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamDatePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text('受験日'),
          ),
          Expanded(
            flex: 3,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => Container(
                    height: 250,
                    color: CupertinoColors.systemBackground,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: _selectedExamDate,
                      minimumDate: DateTime.now(),
                      onDateTimeChanged: (date) {
                        setState(() {
                          _selectedExamDate = date;
                        });
                      },
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    SalaryCalculator.formatDateJP(_selectedExamDate),
                    style: const TextStyle(color: CupertinoColors.systemBlue),
                  ),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color: CupertinoColors.systemGrey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyHoursField(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          Expanded(
            flex: 3,
            child: CupertinoTextField(
              controller: controller,
              keyboardType: TextInputType.number,
              suffix: const Text('時間'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSalaryToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const Expanded(
            child: Text('カスタム年収を使用'),
          ),
          CupertinoSwitch(
            value: _useCustomSalary,
            onChanged: (value) {
              setState(() {
                _useCustomSalary = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSalaryField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text('年収'),
          ),
          Expanded(
            flex: 3,
            child: CupertinoTextField(
              controller: _customSalaryController,
              keyboardType: TextInputType.number,
              prefix: const Text('¥'),
              suffix: const Text('円'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryPreview() {
    final university = _universityController.text;
    final customSalary = _useCustomSalary 
        ? double.tryParse(_customSalaryController.text)
        : null;
    final annualSalary = SalaryCalculator.getAnnualSalary(university, customSalary: customSalary);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '予想年収',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              SalaryCalculator.formatCurrency(annualSalary),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.systemGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, Widget picker) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground,
        child: picker,
      ),
    );
  }

  Future<void> _saveProfile() async {
    try {
      final age = int.tryParse(_ageController.text) ?? 18;
      final weekdayHours = int.tryParse(_weekdayHoursController.text) ?? 8;
      final weekendHours = int.tryParse(_weekendHoursController.text) ?? 12;
      final customSalary = _useCustomSalary 
          ? double.tryParse(_customSalaryController.text)
          : null;

      final profile = UserProfile(
        targetUniversity: _universityController.text,
        examDate: _selectedExamDate,
        gender: _selectedGender,
        age: age,
        weekdayStudyHours: weekdayHours,
        weekendStudyHours: weekendHours,
        customSalaryData: customSalary,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(userProfileProvider.notifier).saveProfile(profile);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('エラー'),
            content: Text('プロフィールの保存に失敗しました: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }
}