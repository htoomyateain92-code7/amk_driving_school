import 'package:flutter/material.dart';
import 'package:carapp/services/api_service.dart';
import '../constants/constants.dart'; // Styling အတွက်

class BlogDetailScreen extends StatefulWidget {
  final int blogId;
  final String title; // Blog ၏ ခေါင်းစဉ်

  const BlogDetailScreen({
    super.key,
    required this.blogId,
    required this.title, // title ကို required အဖြစ် လက်ခံထားသည်
  });

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>>? _blogDetailFuture;

  @override
  void initState() {
    super.initState();
    _blogDetailFuture = _apiService.fetchBlogDetail(widget.blogId);
  }

  // 💡 [NEW HELPER]: ISO String ကို ဖတ်ရလွယ်ကူသော Date အဖြစ် ပြောင်းလဲပေးသည်။
  String _formatDate(String? isoDateString) {
    if (isoDateString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(isoDateString);
      // Example: Sep 17, 2025
      return '${dateTime.month} ${dateTime.day}, ${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
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
        child: FutureBuilder<Map<String, dynamic>>(
          future: _blogDetailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent),
              );
            } else if (snapshot.hasError) {
              print('Blog Detail Fetch Error: ${snapshot.error}');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Text(
                    'အသေးစိတ် အချက်အလက်များ ခေါ်ယူရာတွင် Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              final blogData = snapshot.data!;

              // 💡 [FIX]: API Key များအတိုင်း ယူသည်။
              final String apiTitle =
                  blogData['title'] as String? ?? widget.title;
              final String apiContent =
                  blogData['body'] as String? ?? 'No content available.';
              final String apiDate = blogData['created_at'] as String;

              // Date ကို ဖတ်ရလွယ်ကူအောင် ပြောင်းလဲသည်။
              final String formattedDate = _formatDate(apiDate);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 💡 [FIXED]: API မှရသော title ကို ပြသသည်။
                    Card(
                      // 💡 Card Background ကို ပိုမို ကြည်လင်သော Transparent သို့မဟုတ် Gradient ဖြင့် ညှိရန်
                      color: Colors.white.withOpacity(
                        0.08,
                      ), // နည်းနည်းလေး ပိုမည်းပါစေ
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.white10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              apiTitle,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Published on: $formattedDate',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              apiContent,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text(
                  'Blog အသေးစိတ် မတွေ့ရပါ။',
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
