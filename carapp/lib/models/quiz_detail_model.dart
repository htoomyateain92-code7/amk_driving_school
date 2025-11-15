// 📁 lib/models/quiz_detail_model.dart

// မေးခွန်းတစ်ခုစီအတွက် ရွေးချယ်စရာများ (MCQ အတွက်)
class QuizOption {
  final int id;
  final String text;

  QuizOption({required this.id, required this.text});

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id'] as int? ?? 0, // 💡 id ကို null ဖြစ်ရင် default 0 ပေးပါ
      // 🛑 [FIX]: text ကို null ဖြစ်ခဲ့ရင် Default Value ပေးပါ
      text: json['text'] as String? ?? 'ရွေးချယ်စရာမသိရ',
    );
  }
}

// မေးခွန်းတစ်ခုစီအတွက် စီမံရမည့် Items (ORDER အတွက်)
class OrderItem {
  final int id;
  final String text;

  OrderItem({required this.id, required this.text});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int? ?? 0, // 💡 id ကို null ဖြစ်ရင် default 0 ပေးပါ
      // 🛑 [FIX]: text ကို null ဖြစ်ခဲ့ရင် Default Value ပေးပါ
      text: json['text'] as String? ?? 'စီရန်အရာဝတ္ထုမသိရ',
    );
  }
}

// Quiz တစ်ခုအတွင်းက မေးခွန်းတစ်ခုချင်းစီ
class QuizQuestion {
  final int id;
  final String questionText; // API မှာ 'text' ဖြစ်နေသည်
  final String qtype; // 'MCQ', 'ORDER', 'FILL_IN_BLANK' စသဖြင့်
  final List<QuizOption>? options; // MCQ အတွက်သာ
  final List<OrderItem>? orderItems; // ORDER အတွက်သာ

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.qtype,
    this.options,
    this.orderItems,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    // Options (null check ပါပြီးသားဖြစ်၍ အဆင်ပြေသည်)
    final List<dynamic>? optionsList = json['options'];
    List<QuizOption>? options = optionsList != null
        ? optionsList
              .map((o) => QuizOption.fromJson(o as Map<String, dynamic>))
              .toList()
        : null;

    // Order Items (API မှာ 'order_items' key ရှိရမည်၊ null check ပါပြီးသားဖြစ်၍ အဆင်ပြေသည်)
    final List<dynamic>? orderItemsList = json['order_items'];
    List<OrderItem>? orderItems = orderItemsList != null
        ? orderItemsList
              .map((o) => OrderItem.fromJson(o as Map<String, dynamic>))
              .toList()
        : null;

    if (json['qtype'] == 'ORDER' &&
        (orderItems == null || orderItems.isEmpty)) {
      if (options != null && options.isNotEmpty) {
        // QuizOption ကို OrderItem အဖြစ် ပြောင်းလဲပေးသည် (id နဲ့ text တူလို့)
        orderItems = options
            .map((e) => OrderItem(id: e.id, text: e.text))
            .toList();
      }
    }

    // 💡 [FIX]: id ကို null check လုပ်ပါ။
    final int id = json['id'] as int? ?? 0;

    // 💡 [FIX]: questionText (API 'text') ကို null check လုပ်ပါ။
    final String questionText = json['text'] as String? ?? 'မေးခွန်းအမည်မသိရ';

    // 💡 [FIX]: qtype ကို null check လုပ်ပါ။
    final String qtype = json['qtype'] as String? ?? 'MCQ';

    return QuizQuestion(
      id: id,
      questionText: questionText,
      qtype: qtype,
      options: options,
      orderItems: orderItems,
    );
  }
}

// Quiz တစ်ခုလုံး၏ အသေးစိတ် Data
class QuizDetail {
  final int id;
  final String title;
  final int timeLimitSec;
  final List<QuizQuestion> questions;

  QuizDetail({
    required this.id,
    required this.title,
    required this.timeLimitSec,
    required this.questions,
  });

  factory QuizDetail.fromJson(Map<String, dynamic> json) {
    final List<dynamic> questionsList = json['questions'] ?? [];
    final List<QuizQuestion> questions = questionsList
        .map(
          (questionJson) =>
              QuizQuestion.fromJson(questionJson as Map<String, dynamic>),
        )
        .toList();

    return QuizDetail(
      id: json['id'] as int? ?? 0, // 💡 id ကို null check လုပ်ပါ။
      title:
          (json['title'] ?? json['quiz_title']) as String? ??
          'Quiz အမည်မသိရ', // 💡 API field ကို 'quiz_title' ဟု ယူဆသည်
      timeLimitSec:
          json['time_limit_sec'] as int? ??
          0, // 💡 API field ကို 'time_limit_sec' ဟု ယူဆသည်
      questions: questions,
    );
  }
}
