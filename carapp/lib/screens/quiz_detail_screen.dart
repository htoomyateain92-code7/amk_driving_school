import 'package:flutter/material.dart';
import 'package:carapp/services/api_service.dart';
import '../models/quiz_detail_model.dart'; // QuizDetail, QuizQuestion, QuizOption, OrderItem ပါဝင်သည်
import '../constants/constants.dart';

class QuizDetailScreen extends StatefulWidget {
  final int quizId;
  final String quizTitle;
  final String title; // 💡 title ထည့်သွင်း

  const QuizDetailScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.title, // 💡 title ကို required အဖြစ် ထည့်သွင်း
  });

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  final ApiService _apiService = ApiService();

  Future<QuizDetail>? _quizDetailFuture;
  int _currentQuestionIndex = 0;
  int? _selectedOptionId; // MCQ အတွက် ရွေးချယ်ထားသော Option ID
  List<OrderItem> _orderedItems = []; // ORDER Question အတွက် လက်ရှိစီထားမှု

  @override
  void initState() {
    super.initState();
    _quizDetailFuture = _apiService.fetchQuizQuestions(widget.quizId);
  }

  // --- Quiz Logic Helper ---
  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _selectedOptionId = null; // Reset MCQ selection
      _orderedItems = []; // Reset ORDER items for the new question
    });
  }

  // 💡 [FIXED]: Quiz ပြီးဆုံးရင် CourseSelectionScreen ကို ပြန်သွားပါမည်။
  void _finishQuiz(int totalQuestions) {
    print('Quiz Finished! Total Questions: $totalQuestions');

    // 1. Alert Dialog ပြသသည်
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        // Dialog Context ကို သုံးပါ
        title: const Text('Quiz ပြီးဆုံးပါပြီ'),
        content: Text('မေးခွန်း ${totalQuestions} ခု ဖြေဆိုပြီးပါပြီ။'),
        actions: [
          TextButton(
            onPressed: () {
              // 1. Dialog ကို ပိတ်လိုက်သည်။
              Navigator.of(dialogContext).pop();

              // 2. QuizDetailScreen ကို ပိတ်ပြီး CourseSelectionScreen သို့ ပြန်သွားသည်။
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // 💡 [NEW HELPER]: Next Button ကို နှိပ်နိုင်မနိုင် စစ်ဆေးသည်
  bool _canSubmit(QuizQuestion currentQuestion) {
    if (currentQuestion.qtype == 'MCQ') {
      // MCQ အတွက် Option ရွေးထားမှသာ ရမည်
      return _selectedOptionId != null;
    }
    if (currentQuestion.qtype == 'ORDER') {
      // ORDER အတွက် Items များ Data ရှိပြီး၊ List ကို စတင်သတ်မှတ်ပြီးမှသာ ရမည်။
      // Drag လုပ်စရာမလိုဘဲ အမြဲတမ်း နှိပ်လို့ရစေရန် ပြုလုပ်ထားပါသည်။
      return currentQuestion.orderItems != null &&
          currentQuestion.orderItems!.isNotEmpty;
    }
    // အခြား မပံ့ပိုးသေးသော အမျိုးအစားများ
    return false;
  }

  // --- Question Type ပေါ်မူတည်ပြီး Options များကို ပြသသည် ---
  Widget _buildQuestionContent(QuizQuestion currentQuestion) {
    if (currentQuestion.qtype == 'MCQ' &&
        currentQuestion.options != null &&
        currentQuestion.options!.isNotEmpty) {
      // 💡 [MCQ Logic]
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: currentQuestion.options!.map((option) {
          final isSelected = _selectedOptionId == option.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap: () {
                setState(() {
                  _selectedOptionId = option.id;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? Colors.cyanAccent : Colors.white30,
                  width: isSelected ? 2 : 1,
                ),
              ),
              tileColor: isSelected
                  ? Colors.cyanAccent.withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
              title: Text(
                option.text,
                style: TextStyle(
                  color: isSelected ? Colors.cyanAccent : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      );
    } else if (currentQuestion.qtype == 'ORDER') {
      final List<OrderItem>? sourceItems = currentQuestion.orderItems;

      // 🛑 [FIX]: Data မပါဝင်ရင် သီးသန့် Error ပြပါ
      if (sourceItems == null || sourceItems.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(kDefaultPadding),
            child: Text(
              'ORDER မေးခွန်းအတွက် စီရမည့် Item များ Data မပြည့်စုံပါ။ (API Data စစ်ဆေးပါ)',
              style: TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      // 💡 [FIX]: မေးခွန်းအသစ်အတွက် _orderedItems ကို စတင်သတ်မှတ်ပြီး shuffle လုပ်ပါ
      if (_orderedItems.isEmpty || _orderedItems.length != sourceItems.length) {
        _orderedItems = List.from(sourceItems);
        _orderedItems.shuffle(); // 💡 စီရန်အတွက် shuffle လုပ်ပါ
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10, left: 8),
            child: Text(
              'အဆင့်လိုက် စီပေးပါ။ (Drag and Drop)',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(
            height: 300, // Fixed height for ReorderableListView
            child: ReorderableListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _orderedItems.removeAt(oldIndex);
                  _orderedItems.insert(newIndex, item);
                  // 💡 ORDER type အတွက် Selection Logic (အဖြေစစ်ဖို့) ကို ဒီနေရာမှာ လုပ်ရပါမယ်။
                });
              },
              children: _orderedItems.map((item) {
                return Card(
                  key: ValueKey(item.id),
                  color: Colors.white.withOpacity(0.1),
                  child: ListTile(
                    title: Text(
                      item.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                    leading: const Icon(
                      Icons.drag_handle,
                      color: Colors.white70,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    // 💡 [UNSUPPORTED/NO DATA]
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(kDefaultPadding),
        child: Text(
          'ဤမေးခွန်းအမျိုးအစားကို ပံ့ပိုးမှုမရှိသေးပါ သို့မဟုတ် Data မပြည့်စုံပါ။',
          style: TextStyle(color: Colors.yellowAccent),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (Scaffold, AppBar, Container) ...

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.quizTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: kGradientStart,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kGradientStart, kGradientVia, kGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<QuizDetail>(
          future: _quizDetailFuture,
          builder: (context, snapshot) {
            // ... (Loading, Error States) ...
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent),
              );
            } else if (snapshot.hasError) {
              print('Quiz Detail Fetch Error: ${snapshot.error}');
              return Center(
                child: Text(
                  'မေးခွန်းများ ခေါ်ယူရာတွင် Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            } else if (snapshot.hasData) {
              final QuizDetail quizDetail = snapshot.data!;
              final List<QuizQuestion> questions = quizDetail.questions;

              if (questions.isEmpty) {
                return const Center(
                  child: Text(
                    'မေးခွန်းများ မရှိသေးပါ။',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              // ... (Quiz Finished Logic) ...
              if (_currentQuestionIndex >= questions.length) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Quiz ပြီးဆုံးပါပြီ။',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _finishQuiz(
                            questions.length,
                          ), // 💡 Quiz ပြီးဆုံးခြင်း Logic ကို ခေါ်သည်
                          child: const Text('Back to Course Selection'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 💡 လက်ရှိ မေးခွန်းကို ပြသရန်
              final currentQuestion = questions[_currentQuestionIndex];
              final isLastQuestion =
                  _currentQuestionIndex == questions.length - 1;

              return Column(
                children: [
                  // --- Question Progress ---
                  Padding(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: Text(
                      'Question ${_currentQuestionIndex + 1} of ${questions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),

                  // --- Main Question Card ---
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            color: Colors.white10,
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                // 💡 Model Property 'questionText' ဟု ယူဆ၍ အသုံးပြုထားသည်။
                                currentQuestion.questionText,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 💡 Options List ကို buildQuestionContent ဖြင့် အစားထိုး
                          _buildQuestionContent(currentQuestion),
                        ],
                      ),
                    ),
                  ),

                  // --- Navigation Button ---
                  Padding(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: ElevatedButton(
                      // 💡 [FIX]: _canSubmit Helper Function ကို သုံးပြီး စစ်ဆေးသည်
                      onPressed: _canSubmit(currentQuestion)
                          ? isLastQuestion
                                ? () => _finishQuiz(questions.length)
                                : _nextQuestion
                          : null, // Submit မလုပ်နိုင်ရင် Disabled
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: isLastQuestion
                            ? Colors.green
                            : Colors.cyanAccent,
                        disabledBackgroundColor:
                            Colors.grey.shade700, // Disabled color
                      ),
                      child: Text(
                        isLastQuestion ? 'Finish Quiz' : 'Next Question',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text(
                  'Quiz အသေးစိတ် မတွေ့ရပါ။',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
