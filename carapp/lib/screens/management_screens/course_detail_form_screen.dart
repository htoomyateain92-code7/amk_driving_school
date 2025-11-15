import 'package:carapp/models/course_model.dart';
import 'package:carapp/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/constants.dart';
import '../../widgets/custom_glass_app_bar.dart';
import '../../widgets/glass_card.dart';

class CourseDetailScreenForm extends StatefulWidget {
  final String title;
  final int courseId; // 0 for Create, > 0 for Update

  const CourseDetailScreenForm({
    super.key,
    required this.title,
    required this.courseId,
  });

  @override
  State<CourseDetailScreenForm> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreenForm> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;

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
    _imageUrlController = TextEditingController();

    // 💡 [GUARD]: ID 0 ဖြစ်လျှင် Data ကို Load လုပ်ရန် မလိုပါ
    if (widget.courseId > 0) {
      _loadCourseData();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Course Data ကို Server မှ ခေါ်ယူခြင်း (Update Mode အတွက်)
  Future<void> _loadCourseData() async {
    // 💡 [GUARD]: ID 0 ဖြစ်လျှင် ချက်ချင်း return လုပ်ပါ
    if (widget.courseId == 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // API call သည် widget.courseId > 0 မှသာ အလုပ်လုပ်မည်
      final detail = await _apiService.fetchCourseDetail(widget.courseId);

      _initialCourseData = Course(
        // id သည် detail Model တွင် ရှိနေသည့် Type အတိုင်း ယူပြီး Nullable ကို စစ်သည်
        id: detail.id,
        title: detail.title,
        description: detail.description,
        price: detail.price,

        // 💡 [FIXED]: detail properties များကို Type Casting မပါဘဲ တိုက်ရိုက်ယူပြီး Nullable ကိုသာ စစ်ပါ။
        isPublished: _isPublished,

        color: 0xFF9C27B0,

        totalDurationHours: detail.totalDurationHours,
        // durationDays: detail.durationDays,
      );

      _titleController.text = _initialCourseData!.title ?? '';
      _descriptionController.text = _initialCourseData!.description ?? '';
      _priceController.text = _initialCourseData!.price?.toString() ?? '';

      _isPublished = _initialCourseData!.isPublished;
    } catch (e) {
      if (mounted) {
        // [INFO]: Error သည် ID 0 (သို့) ID အမှားအတွက် 404 ဖြစ်နိုင်သည်
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'သင်တန်းအချက်အလက် ခေါ်ယူရာတွင် Error: ${e.toString()}',
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

    setState(() {
      _isLoading = true;
    });

    try {
      final String priceString = (double.tryParse(_priceController.text) ?? 0.0)
          .toString();

      final newCourse = Course(
        // 💡 [CREATE/UPDATE LOGIC]: ID 0 ဖြစ်ပါက null (Create Mode)၊ မဟုတ်ပါက ID ကို သုံးသည်
        id: widget.courseId,
        title: _titleController.text,
        description: _descriptionController.text,
        price: priceString,
        isPublished: _isPublished,

        // Form မှာမပါဝင်သည့် Data များကို အဟောင်းအတိုင်း ပြန်ထည့်သည်
        studentCount: _initialCourseData?.studentCount ?? 0,
        color: _initialCourseData?.color ?? 0xFF9C27B0,
        totalDurationHours: _initialCourseData?.totalDurationHours,
        durationDays: _initialCourseData?.durationDays,
      );

      if (widget.courseId == 0) {
        // Create Mode - Create API ကို ခေါ်သည်
        await _apiService.createCourse(newCourse);
      } else {
        // Update Mode - Update API ကို ခေါ်သည်
        await _apiService.updateCourse(widget.courseId, newCourse);
      }

      if (mounted) {
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
        child: _isLoading && widget.courseId != 0
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
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              double.tryParse(value) == null) {
                            return 'ဈေးနှုန်းကို ဂဏန်းဖြင့် မှန်ကန်စွာ ထည့်သွင်းပါ။';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: kDefaultPadding),

                      // --- 4. Image URL Field ---
                      _buildTextInput(
                        controller: _imageUrlController,
                        label: 'Cover ပုံ URL (Optional)',
                        hint: 'ပုံ URL ကို ထည့်သွင်းပါ',
                        keyboardType: TextInputType.url,
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
