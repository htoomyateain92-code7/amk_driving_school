import 'package:carapp/models/course_model.dart';
import 'package:carapp/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/constants.dart';
import '../../widgets/custom_glass_app_bar.dart';
import '../../widgets/glass_card.dart';
import '../../models/course_detail_model.dart'; // CourseDetail Model ကို သေချာ ထပ်ထည့်ပါ။
import 'package:flutter/foundation.dart';

// Mobile breakpoint constant for responsive design (optional, but good practice)
const double kMobileBreakpoint = 600.0;

class CourseDetailScreenForm extends StatefulWidget {
  final String title;
  final int courseId; // 0 for Create, > 0 for Update

  const CourseDetailScreenForm({
    super.key,
    required this.title,
    required this.courseId,
  });

  @override
  State<CourseDetailScreenForm> createState() => _CourseDetailScreenFormState(); // Class name ပြောင်းထားသည်
}

class _CourseDetailScreenFormState extends State<CourseDetailScreenForm> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _totalDurationHoursController;

  // State
  bool _isPublished = false;
  bool _isLoading = false;

  // Update အတွက် Original Course Data (API မှ ယူထားသည့် Data များကို သိမ်းဆည်းရန်)
  Course? _initialCourseData;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _totalDurationHoursController = TextEditingController();

    // 💡 [CHECKED]: ID > 0 ဖြစ်မှသာ Data Load လုပ်မည်။ (Create Mode အတွက် API မခေါ်ပါ)
    if (widget.courseId > 0) {
      _loadCourseData();
    } else {
      // Create Mode အတွက် default များကို သတ်မှတ်ပေးသည်
      _isPublished = true;
      _priceController.text = '0';
      _totalDurationHoursController.text = '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _totalDurationHoursController.dispose();
    super.dispose();
  }

  // Course Data ကို Server မှ ခေါ်ယူခြင်း (Update Mode အတွက်)
  Future<void> _loadCourseData() async {
    // 1. ✅ [CRITICAL GUARD]: ID 0 သို့မဟုတ် အနုတ်တန်ဖိုးဖြစ်နေရင် ချက်ချင်းထွက်ပါ
    if (widget.courseId <= 0) {
      if (kDebugMode) {
        print('INFO: Course ID is 0. Skip fetching data for Create Mode.');
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // API Service မှ CourseDetail ကို ရယူသည်။
      final CourseDetail detail = await _apiService.fetchCourseDetail(
        widget.courseId,
      );

      // CourseDetail မှ Course Model သို့ ပြန်ပြောင်းထည့်သည်။
      _initialCourseData = Course(
        id: detail.id,
        title: detail.title,
        description: detail.description,
        // 🛑 [FIXED]: priceValue (double) ကို String အဖြစ် ပြောင်းထည့်ရန်
        price: detail.priceValue.toString(),
        isPublished: detail.isPublic,
        totalDurationHours: detail.totalDurationHours,
        durationDays: detail.durationDays,
        // studentCount: detail.studentCount? ?? 0,
        color: 0xFF9C27B0, // Default value
      );

      // Controllers များတွင် Data ဖြည့်သွင်းခြင်း
      _titleController.text = _initialCourseData!.title ?? '';
      _descriptionController.text = _initialCourseData!.description ?? '';
      // 💡 price ကို String အဖြစ် ထည့်သွင်းပြီး null check လုပ်သည်
      _priceController.text = _initialCourseData!.price ?? '0';
      _totalDurationHoursController.text =
          _initialCourseData!.totalDurationHours ?? '0';

      _isPublished = _initialCourseData!.isPublished;
    } catch (e) {
      if (mounted) {
        if (kDebugMode) {
          print('FATAL ERROR during Course Data Load: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'သင်တန်းအချက်အလက် ခေါ်ယူရာတွင် အမှား: ${e.toString()}',
            ),
          ),
        );
        // Load မအောင်မြင်လျှင် Screen ကို ပိတ်ပစ်သည်
        Navigator.of(context).pop(false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Save (Create or Update) လုပ်ရန် Logic
  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 💡 price ကို Number အဖြစ် ပြောင်းနိုင်ခြင်း ရှိမရှိ အပြီးသတ်စစ်ပါ (Optional but safe)
    if (double.tryParse(_priceController.text) == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ဈေးနှုန်းကို မှန်ကန်သော ဂဏန်းတန်ဖိုး ထည့်သွင်းပါ။'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newCourse = Course(
        // Create Mode (0) ဖြစ်လျှင် Backend က ID ကို လျစ်လျူရှုမည်။
        id: widget.courseId,
        title: _titleController.text,
        description: _descriptionController.text,
        price: _priceController.text, // String format
        isPublished: _isPublished,

        totalDurationHours: _totalDurationHoursController.text,

        // Form မှာမပါဝင်သည့် Data များကို Update Mode အတွက် အဟောင်းအတိုင်း ပြန်ထည့်သည်
        studentCount: _initialCourseData?.studentCount ?? 0,
        color: _initialCourseData?.color ?? 0xFF9C27B0,
        durationDays: _initialCourseData?.durationDays,
      );

      if (widget.courseId == 0) {
        // Create Mode
        await _apiService.createCourse(newCourse);
      } else {
        // Update Mode
        await _apiService.updateCourse(widget.courseId, newCourse);
      }

      if (mounted) {
        // အောင်မြင်ပါက true ပြန်ပြီး Form ကို ပိတ်သည်
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'သင်တန်းသိမ်းဆည်းခြင်း မအောင်မြင်ပါ: ${e.toString()}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 [Final Guard]: ID 0 အတွက် Loading မပြပါ
    final bool showLoading = _isLoading && widget.courseId > 0;

    return Scaffold(
      appBar: CustomGlassAppBar(
        selectedLanguage: 'MM',
        onLanguageChanged: (value) {},
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        loginButton: const SizedBox.shrink(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kGradientStart, kGradientVia, kGradientEnd],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // 💡 Loading Logic ကို သုံး၍ UI ကို ပြသခြင်း
        child: showLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- 1. Title Field ---
                      _buildTextInput(
                        controller: _titleController,
                        label: 'သင်တန်း ခေါင်းစဉ်',
                        hint: 'ဥပမာ: အခြေခံမောင်းနှင်မှုသင်တန်း',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ခေါင်းစဉ် ထည့်သွင်းရန် လိုအပ်ပါသည်။';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: kDefaultPadding),

                      // --- 2. Description Field ---
                      _buildTextInput(
                        controller: _descriptionController,
                        label: 'သင်တန်း အသေးစိတ်',
                        hint: 'သင်တန်းအကြောင်း အကျဉ်းချုံး ဖော်ပြပါ။',
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'အသေးစိတ် ဖော်ပြရန် လိုအပ်ပါသည်။';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: kDefaultPadding),

                      // --- 3. Price Field ---
                      _buildTextInput(
                        controller: _priceController,
                        label: 'သင်တန်း ဈေးနှုန်း (MMK)',
                        hint: 'ဥပမာ: 150000 (အခမဲ့ဆိုပါက 0 ထည့်ပါ)',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(
                              r'^\d+[\.]?\d{0,2}',
                            ), // ဒဿမ 2 နေရာအထိ ခွင့်ပြုသည်
                          ),
                        ],
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'ဈေးနှုန်းကို ဂဏန်းဖြင့် မှန်ကန်စွာ ထည့်သွင်းပါ။';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: kDefaultPadding),

                      // --- 4. Duration Field ---
                      _buildTextInput(
                        controller: _totalDurationHoursController,
                        label: 'သင်တန်း ကြာချိန် (နာရီ)',
                        hint: 'ဥပမာ: 25',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ကြာချိန် ထည့်သွင်းရန် လိုအပ်ပါသည်။';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: kDefaultPadding * 1.5),

                      // --- 5. Is Published Switch ---
                      _buildPublishSwitch(),
                      const SizedBox(height: kDefaultPadding * 2),

                      // --- 6. Save Button ---
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveCourse,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save, color: Colors.black),
                        label: Text(
                          widget.courseId == 0
                              ? 'သင်တန်း ဖန်တီးရန်'
                              : 'ပြင်ဆင်မှု သိမ်းဆည်းရန်',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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

  // --- Reusable Text Input Field ---
  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return GlassCard(
      blurAmount: 5.0,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      borderRadius: 10.0,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        validator: validator,
      ),
    );
  }

  // --- Publish Switch Widget ---
  Widget _buildPublishSwitch() {
    return GlassCard(
      blurAmount: 5.0,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      borderRadius: 10.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'ထုတ်ဝေမည် (Public)',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          Switch(
            value: _isPublished,
            onChanged: (bool value) {
              setState(() {
                _isPublished = value;
              });
            },
            activeColor: Colors.lightGreenAccent,
            inactiveTrackColor: Colors.white38,
          ),
        ],
      ),
    );
  }
}
