import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/main.dart';

void main() {
  testWidgets('OnboardingPage loads with Get Started button',
          (WidgetTester tester) async {
        // Build the app with isLoggedIn = false to ensure onboarding is shown
        await tester.pumpWidget(const TaskManagerApp(isLoggedIn: false));

        // Check if Get Started button is present
        expect(find.text('Get Started'), findsOneWidget);
      });
}
