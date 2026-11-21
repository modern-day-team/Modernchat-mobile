import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:modernchat_mobile/main.dart';

void main() {
  testWidgets('应用启动显示登录页', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ModernChatApp()));

    expect(find.text('登录 ModernChat'), findsOneWidget);
  });
}
