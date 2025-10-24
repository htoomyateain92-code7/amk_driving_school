class Blog {
  final int id;
  final String title;
  final String summary;

  Blog({required this.id, required this.title, required this.summary});

  factory Blog.fromJson(Map<String, dynamic> json) {
    final body = json['body'] as String? ?? ''; // body が null でないことを確認

    // body ရဲ့ စာလုံးအရေအတွက်က ၁၀၀ ထက်များမှ စာလုံး ၁၀၀ ဖြတ်ပါ၊
    // နည်းရင် body တစ်ခုလုံးကိုပဲ summary အဖြစ်သုံးပါ
    final summaryText = body.length > 100
        ? '${body.substring(0, 100)}...' // စာဖြတ်ထားကြောင်းသိအောင် အစက်လေးတွေထည့်ပေးပါ
        : body;

    return Blog(
      id: json['id'],
      title: json['title'],
      summary: summaryText, // ပြင်ဆင်ပြီးသား summary ကိုသုံးပါ
    );
  }
}
