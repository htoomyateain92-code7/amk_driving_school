// class SessionModel {
//   final int id;
//   final DateTime startDt;
//   final DateTime endDt;
//   final String status;
//   // ဒီ session ရဲ့ id ကို booking payload ထဲ ထည့်ပို့ရမှာ ဖြစ်ပါတယ်

//   SessionModel({
//     required this.id,
//     required this.startDt,
//     required this.endDt,
//     required this.status,
//   });

//   factory SessionModel.fromJson(Map<String, dynamic> json) {
//     return SessionModel(
//       id: json['id'] as int,
//       // 🛑 အပြီးသတ်ပြင်ဆင်ချက်: Backend ကနေလာတဲ့ timezone မပါတဲ့ ISO string ကို UTC အဖြစ် တိုက်ရိုက် parse လုပ်ရန် 'Z' ထည့်ပေးခြင်း။
//       // ဥပမာ: "2024-05-20T10:00:00" ကို "2024-05-20T10:00:00Z" အဖြစ်ပြောင်းပြီး parse လုပ်ပါမယ်။
//       // ✅ ပြင်ဆင်ချက်: JSON key များကို မှန်ကန်အောင် ပြောင်းလဲခြင်း။
//       // Backend မှ 'start_dt' နှင့် 'end_dt' ဖြင့် data ပေးပို့သောကြောင့် key name များကို ပြင်ဆင်ရန်လိုအပ်သည်။
//       startDt: DateTime.parse(json['start_dt'] as String),
//       endDt: DateTime.parse(json['end_dt'] as String),
//       status: json['status'] ?? 'scheduled',
//     );
//   }
// }

class SessionModel {
  final int id;
  final DateTime startDt;
  final DateTime endDt;
  final String status;

  SessionModel({
    required this.id,
    required this.startDt,
    required this.endDt,
    required this.status,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    // Backend string မှာ 'T' ပါတဲ့ ISO Format ဖြစ်တယ်လို့ ယူဆပါတယ်။
    // ဥပမာ: "2025-10-23T07:30:00"
    String startString = json['start_dt'] as String;
    String endString = json['end_dt'] as String;

    // 💡 အဓိကပြင်ဆင်ချက်: Backend က Timezone Offset မပို့ရင် 'Z' ကို ကိုယ်တိုင်ထည့်ပါ။
    // ဒါမှ Dart က ၎င်းကို UTC အဖြစ် သိပြီး Duration တွက်ရာမှာ မှားယွင်းမှု နည်းပါးပါမယ်။
    if (!startString.endsWith('Z') && !startString.contains('+')) {
      startString += 'Z';
    }
    if (!endString.endsWith('Z') && !endString.contains('+')) {
      endString += 'Z';
    }

    return SessionModel(
      id: json['id'] as int,
      // တွက်ချက်မှု မှန်ကန်စေရန် parse ပြီးသား DateTime ကို toLocal() သို့ ပြောင်းလိုက်ပါ။
      startDt: DateTime.parse(startString).toLocal(),
      endDt: DateTime.parse(endString).toLocal(),
      status: json['status'] ?? 'scheduled',
    );
  }
}
