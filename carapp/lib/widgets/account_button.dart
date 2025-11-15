import 'package:carapp/services/api_service.dart';
import 'package:carapp/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountButton extends StatelessWidget {
  const AccountButton({super.key});

  // ⚠️ NOTE: kGradientVia, kGradientEnd များကို constants/constants.dart မှ ခေါ်ယူရန် လိုအပ်ပါသည်။
  // ဤနေရာတွင် Hardcode ဖြင့် ယာယီထည့်သွင်းထားပါသည်။
  final Color kGradientVia = const Color(0xFF00bcd4);
  final Color kGradientEnd = const Color(0xFF00796b);

  @override
  Widget build(BuildContext context) {
    // Consumer ဖြင့် ApiService မှ အခြေအနေကို နားထောင်သည်
    return Consumer<ApiService>(
      builder: (context, apiService, child) {
        final bool isLoggedIn = apiService.isLoggedIn;
        final String displayName = apiService.userName ?? 'အကောင့်';

        // 💡 Login ဝင်ထားသည့် အခြေအနေ (နာမည်ပြသမည်)
        if (isLoggedIn) {
          return Tooltip(
            message: 'အကောင့်အချက်အလက် / ထွက်ရန်',
            child: TextButton(
              onPressed: () {
                // Profile/Logout Modal ကို ပြသရန်
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('အကောင့် အချက်အလက်'),
                    content: Text(
                      'လက်ရှိအကောင့်: $displayName\nRole: ${apiService.userRole}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          apiService.logout(); // Logout လုပ်ပါ
                        },
                        child: const Text(
                          'ထွက်ရန်',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('ပိတ်မည်'),
                      ),
                    ],
                  ),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // 💡 Login မဝင်ရသေးသည့် အခြေအနေ (Login Button ပြသမည်)
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [
                  kGradientVia.withOpacity(0.8),
                  kGradientEnd.withOpacity(0.8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: kGradientEnd.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(isModal: false),
                  ),
                );
              },
              icon: const Icon(Icons.login, color: Colors.white, size: 18),
              label: const Text(
                'ဝင်/အကောင့်ဖွင့်',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
