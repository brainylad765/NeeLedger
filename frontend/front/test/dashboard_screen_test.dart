import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:front/screens/dashboard_screen.dart';
import 'package:front/screens/data_screen.dart';
import 'package:front/screens/projects_screen.dart';
import 'package:front/screens/home_screen_new.dart';
import 'package:front/screens/market_wallet_screen.dart';
import 'package:front/screens/profile_screen.dart';

void main() {
  testWidgets('DashboardScreen navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: DashboardScreen()));

    // Verify initial page is HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);

    // Tap on Data tab
    await tester.tap(find.text('Data'));
    await tester.pumpAndSettle();
    expect(find.byType(DataScreen), findsOneWidget);

    // Tap on Projects tab
    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectsScreen), findsOneWidget);

    // Tap on Market & Wallet tab
    await tester.tap(find.text('Market & Wallet'));
    await tester.pumpAndSettle();
    expect(find.byType(MarketWalletScreen), findsOneWidget);

    // Tap on Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
  });
}
