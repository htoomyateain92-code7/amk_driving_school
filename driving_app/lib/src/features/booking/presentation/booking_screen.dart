import 'package:driving_app/src/features/booking/presentation/booking_controller.dart';

import 'package:driving_app/src/features/courses/presentation/course_detail_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:driving_app/src/features/courses/data/models/course_model.dart';
import 'package:driving_app/src/features/courses/data/models/session_model.dart';

import '../../auth/data/auth_repository.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({
    super.key,
    required this.courseId,
    required this.batchId,
  });
  final int courseId;
  final int batchId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  // Store selected session IDs
  final Set<int> _selectedSessionIds = {};

  @override
  void initState() {
    super.initState();
    // 🛑 ပြင်ဆင်ချက်- Screen ပွင့်တိုင်း isLoggedInProvider ကို invalidate လုပ်ပြီး
    // နောက်ဆုံး login status ကို ပြန်စစ်ခိုင်းပါမယ်။
    // ဒါမှ login screen ကနေ ပြန်လာတဲ့အခါ state အသစ်ကို ရရှိမှာပါ။
    Future.microtask(() => ref.invalidate(isLoggedInProvider));
  }

  @override
  Widget build(BuildContext context) {
    // Course Detail (requiredSessions နှင့် duration များပါဝင်သည်)
    final courseAsync =
        ref.watch(courseDetailControllerProvider(widget.courseId));

    // Batch အတွက် ရရှိနိုင်သော Sessions များ
    final sessionsAsync =
        ref.watch(availableSessionsControllerProvider(widget.batchId));

    final bookingState = ref.watch(bookingSubmitControllerProvider);

    ref.listen(bookingSubmitControllerProvider, (_, state) {
      if (state.hasError && state is! AsyncLoading) {
        String errorMsg = state.error is Exception
            ? state.error.toString().replaceFirst('Exception: ', '')
            : 'Unknown error occurred.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking Failed: $errorMsg')),
        );
      }
      if (state is AsyncData && state.value != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Booking successful! Waiting for approval.')),
        );

        context.go('/my-bookings');
      }
    });

    return courseAsync.when(
        data: (course) {
          final isLoggedInAsync = ref.watch(isLoggedInProvider);
          final bool isLoggedIn = isLoggedInAsync.when(
            data: (loggedIn) => loggedIn,
            loading: () => false,
            error: (e, st) => false,
          );

          // 🟢 ထပ်မံဖြည့်စွက်ထားသည်: Auth State Loading ဖြစ်နေခြင်းကို စစ်ဆေးခြင်း
          final bool isAuthLoading = isLoggedInAsync.isLoading;

          final requiredSessionsCount = course.requiredSessions;
          final selectedCount = _selectedSessionIds.length;

          // ✅ Session အရေအတွက် ပြည့်မီမှု စစ်ဆေးခြင်း
          final isCountMet = selectedCount == requiredSessionsCount;

          return Scaffold(
            appBar: AppBar(title: Text(course.title)),
            body: sessionsAsync.when(
              data: (sessions) {
                // Calculate total duration of selected sessions (informative only)
                final selectedDurationMinutes = sessions
                    .cast<
                        SessionModel>() // Null Check ပြဿနာဖြေရှင်းရန် Type ကို သေချာသတ်မှတ်ခြင်း
                    .where((s) => _selectedSessionIds.contains(s.id))
                    .fold<double>(0.0, (previousValue, session) {
                  final duration =
                      session.endDt.toUtc().difference(session.startDt.toUtc());
                  return previousValue + duration.inMinutes;
                });

                final selectedDurationHours = selectedDurationMinutes / 60;

                return Column(children: [
                  _buildSummaryCard(
                    context,
                    course: course,
                    selectedCount: selectedCount,
                    isCountMet: isCountMet,
                    selectedDurationHours: selectedDurationHours,
                  ),
                  if (sessions.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text("No available sessions in this batch."),
                      ),
                    )
                  else
                    Expanded(
                      // ✅ requiredSessionsCount ကို ပို့ပေးရန် ပြင်ဆင်ခြင်း
                      child: _buildSessionList(sessions.cast<SessionModel>(),
                          isCountMet, requiredSessionsCount),
                    ),
                ]);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) =>
                  Center(child: Text('Error loading sessions: $e')),
            ),
            bottomNavigationBar: _buildSubmitButton(
              bookingState: bookingState,
              isCountMet: isCountMet,
              isLoggedIn: isLoggedIn, // ✅ isLoggedIn status ကို ထည့်ပေးခြင်း
              // ✅ requiredSessionsCount ကို ပို့ပေးရန် ပြင်ဆင်ခြင်း
              requiredSessionsCount: requiredSessionsCount,
              selectedCount: selectedCount,
              isAuthLoading: isAuthLoading,
            ),
          );
        },
        loading: () => Scaffold(
            appBar: AppBar(title: const Text('Book Your Sessions')),
            body: const Center(child: CircularProgressIndicator())),
        error: (e, st) => Scaffold(
            appBar: AppBar(title: const Text('Book Your Sessions')),
            body: Center(child: Text('Error loading course: $e'))));
  }

  // Summary Card Widget
  Widget _buildSummaryCard(
    BuildContext context, {
    required Course course,
    required int selectedCount,
    required bool isCountMet,
    required double selectedDurationHours,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Batch Booking Summary',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const Divider(height: 20),

              // Sessions Count Check
              _buildSummaryRow(
                'Sessions Required:',
                '${course.requiredSessions} sessions',
                Colors.black87,
              ),

              // Selected Sessions Count
              _buildSummaryRow(
                'Sessions Selected:',
                '$selectedCount sessions',
                isCountMet ? Colors.green.shade700 : Colors.red.shade700,
              ),

              const SizedBox(height: 12),

              // Duration Check (for reference)
              _buildSummaryRow(
                'Total Course Duration:',
                '${course.totalDurationHours.toStringAsFixed(1)} hours',
                Colors.black54,
              ),
              _buildSummaryRow(
                'Total Selected Duration:',
                '${selectedDurationHours.toStringAsFixed(1)} hours',
                Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Session List Widget
  Widget _buildSessionList(
      List<SessionModel> sessions, bool isCountMet, int requiredSessionsCount) {
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final isSelected = _selectedSessionIds.contains(session.id);

        // Max count ပြည့်နေပြီး ဒီ session ကို မရွေးရသေးရင် Disable လုပ်ပါ
        // ✅ requiredSessionsCount ကို parameter မှ ရယူသုံးစွဲခြင်း
        final isMaxCountReached =
            _selectedSessionIds.length >= requiredSessionsCount;
        final isDisabled = isMaxCountReached && !isSelected;

        return CheckboxListTile(
          tileColor: isSelected
              ? Theme.of(context).colorScheme.tertiaryContainer
              : null,
          title: Text(
            DateFormat('EEE, MMM d').format(session.startDt),
            style: TextStyle(color: isDisabled ? Colors.grey : Colors.black),
          ),
          subtitle: Text(
            // 🛑 ပြင်ဆင်ချက်: DateTime object ကို local time သို့ ပြောင်းပြီးမှ format လုပ်ခြင်း။
            // ဒါမှ device ရဲ့ timezone မှာ အချိန်ကို မှန်မှန်ကန်ကန် ပြသနိုင်မှာပါ။
            '${DateFormat.jm().format(session.startDt.toLocal())} - ${DateFormat.jm().format(session.endDt.toLocal())}',
            style: TextStyle(color: isDisabled ? Colors.grey : Colors.black54),
          ),
          value: isSelected,
          onChanged: isDisabled
              ? null
              : (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedSessionIds.add(session.id);
                    } else {
                      _selectedSessionIds.remove(session.id);
                    }
                  });
                },
        );
      },
    );
  }

  // Submit Button Widget
  Widget _buildSubmitButton({
    required AsyncValue bookingState,
    required bool isCountMet,
    required bool isLoggedIn, // ✅ New parameter
    required int
        requiredSessionsCount, // ✅ requiredSessionsCount ကို parameter အဖြစ် ထည့်သွင်းခြင်း
    required int selectedCount, // 🛑 selectedCount ကို လက်ခံခြင်း
    required bool isAuthLoading, // 🟢 Auth Loading Status ကို လက်ခံခြင်း
  }) {
    // 1. စုစုပေါင်း Loading အခြေအနေ (Auth သို့မဟုတ် Booking)
    final isTotalLoading = bookingState.isLoading || isAuthLoading;

    // 2. Submit လုပ်နိုင်မှု စစ်ဆေးခြင်း (Loading မဖြစ်၊ Login ဝင်ပြီး၊ Count ပြည့်မှ)
    final canSubmit = isLoggedIn && isCountMet && !isTotalLoading;

    String buttonText;

    if (isAuthLoading) {
      // 🟢 Auth Loading နေရင်
      buttonText = 'Checking authentication...';
    } else if (!isLoggedIn) {
      // 1. Login မဝင်ရသေး
      buttonText = 'Login / Register to Book';
    } else if (isCountMet) {
      // 2. Login ဝင်ပြီး၊ Sessions အရေအတွက် ပြည့်ပြီ
      buttonText = 'Submit Booking';
    } else {
      // 3. Login ဝင်ပြီး၊ Sessions အရေအတွက် မပြည့်သေး/ပိုနေ
      final remainingToSelect = requiredSessionsCount - selectedCount;

      if (remainingToSelect > 0) {
        // လိုအပ်တာထက် နည်းနေရင်
        buttonText = 'Select $remainingToSelect more Sessions';
      } else {
        buttonText =
            'Error: Too many sessions selected (${selectedCount}/${requiredSessionsCount})';
      }
    }

    // 3. onPressed Logic
    VoidCallback? onPressed;

    if (isTotalLoading) {
      onPressed = null; // Loading နေရင် နှိပ်မရ
    } else if (!isLoggedIn) {
      // Login ဝင်ရန် နှိပ်ခြင်း
      onPressed = () {
        final currentPath = GoRouterState.of(context).matchedLocation;
        context.go('/login?from=${Uri.encodeComponent(currentPath)}');
      };
    } else if (canSubmit) {
      // Submit လုပ်ခြင်း
      onPressed = () {
        ref.read(bookingSubmitControllerProvider.notifier).submitBooking(
              courseId: widget.courseId,
              sessionIds: _selectedSessionIds.toList(),
            );
      };
    } else {
      onPressed = null; // Count မပြည့်ရင် သို့မဟုတ် ပိုနေရင် နှိပ်မရ
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: onPressed, // ✅ Updated onPressed
        style: ElevatedButton.styleFrom(
          // Loading နေရင် သို့မဟုတ် Submit လုပ်ခွင့်မရှိရင် Grey/Disabled အရောင်ပြ
          backgroundColor: isTotalLoading || (!canSubmit && isLoggedIn)
              ? Colors.grey
              : Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        // 🛑 Loading ဖြစ်နေရင် Spinner ပြ
        child: isTotalLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            // ✅ requiredSessionsCount ကို parameter မှ ရယူသုံးစွဲခြင်း
            : Text(
                buttonText, // ✅ buttonText ကို အသုံးပြုခြင်း
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }
}
