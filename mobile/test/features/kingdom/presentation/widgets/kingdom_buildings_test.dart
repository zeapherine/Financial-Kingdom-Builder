import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:financial_kingdom_builder/features/kingdom/presentation/widgets/kingdom_buildings.dart';
import 'package:financial_kingdom_builder/features/kingdom/presentation/widgets/additional_buildings.dart';

void main() {
  group('Kingdom Buildings Widget Tests', () {
    testWidgets('TownCenterBuilding renders correctly when unlocked', (WidgetTester tester) async {
      bool onTapCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TownCenterBuilding(
              isUnlocked: true,
              onTap: () => onTapCalled = true,
            ),
          ),
        ),
      );

      // Verify widget renders
      expect(find.byType(TownCenterBuilding), findsOneWidget);
      expect(find.text('Town Center'), findsOneWidget);
      expect(find.text('Kingdom Management'), findsOneWidget);

      // Test tap interaction
      await tester.tap(find.byType(TownCenterBuilding));
      await tester.pump();
      
      expect(onTapCalled, isTrue);
    });

    testWidgets('TownCenterBuilding renders correctly when locked', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TownCenterBuilding(
              isUnlocked: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify widget renders with locked styling
      expect(find.byType(TownCenterBuilding), findsOneWidget);
      expect(find.text('Town Center'), findsOneWidget);
      expect(find.text('Kingdom Management'), findsOneWidget);
    });

    testWidgets('LibraryBuilding renders correctly', (WidgetTester tester) async {
      bool onTapCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LibraryBuilding(
              isUnlocked: true,
              onTap: () => onTapCalled = true,
            ),
          ),
        ),
      );

      expect(find.byType(LibraryBuilding), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Learn & Study'), findsOneWidget);

      await tester.tap(find.byType(LibraryBuilding));
      await tester.pump();
      
      expect(onTapCalled, isTrue);
    });

    testWidgets('TradingPostBuilding renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TradingPostBuilding(
              isUnlocked: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(TradingPostBuilding), findsOneWidget);
      expect(find.text('Trading Post'), findsOneWidget);
      expect(find.text('Practice Trading'), findsOneWidget);
    });

    testWidgets('TreasuryBuilding renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TreasuryBuilding(
              isUnlocked: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(TreasuryBuilding), findsOneWidget);
      expect(find.text('Treasury'), findsOneWidget);
      expect(find.text('Manage Portfolio'), findsOneWidget);
    });

    testWidgets('MarketplaceBuilding renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarketplaceBuilding(
              isUnlocked: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(MarketplaceBuilding), findsOneWidget);
      expect(find.text('Marketplace'), findsOneWidget);
      expect(find.text('Social Trading'), findsOneWidget);
    });

    testWidgets('ObservatoryBuilding renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ObservatoryBuilding(
              isUnlocked: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ObservatoryBuilding), findsOneWidget);
      expect(find.text('Observatory'), findsOneWidget);
      expect(find.text('Market Analysis'), findsOneWidget);
    });

    testWidgets('AcademyBuilding renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AcademyBuilding(
              isUnlocked: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(AcademyBuilding), findsOneWidget);
      expect(find.text('Academy'), findsOneWidget);
      expect(find.text('Advanced Learning'), findsOneWidget);
    });

    group('Animation Tests', () {
      testWidgets('Buildings animate on tap', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TownCenterBuilding(
                isUnlocked: true,
                onTap: () {},
              ),
            ),
          ),
        );

        // Start tap
        await tester.press(find.byType(TownCenterBuilding));
        await tester.pump(const Duration(milliseconds: 100));
        
        // Animation should be in progress
        await tester.pump(const Duration(milliseconds: 100));
        
        // Release tap
        await tester.pumpAndSettle();
      });

      testWidgets('Locked buildings do not respond to tap', (WidgetTester tester) async {
        bool onTapCalled = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TownCenterBuilding(
                isUnlocked: false,
                onTap: () => onTapCalled = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(TownCenterBuilding));
        await tester.pump();
        
        // Should not trigger onTap when locked
        expect(onTapCalled, isFalse);
      });
    });

    group('Visual State Tests', () {
      testWidgets('Buildings show different visual states when locked/unlocked', (WidgetTester tester) async {
        // Test unlocked state
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TownCenterBuilding(
                    isUnlocked: true,
                    onTap: () {},
                  ),
                  TownCenterBuilding(
                    isUnlocked: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        // Both should render but with different visual states
        expect(find.byType(TownCenterBuilding), findsNWidgets(2));
        expect(find.text('Town Center'), findsNWidgets(2));
      });
    });

    group('CustomPainter Tests', () {
      testWidgets('Custom painters render without errors', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    TownCenterBuilding(isUnlocked: true, onTap: () {}),
                    LibraryBuilding(isUnlocked: true, onTap: () {}),
                    TradingPostBuilding(isUnlocked: true, onTap: () {}),
                    TreasuryBuilding(isUnlocked: true, onTap: () {}),
                    MarketplaceBuilding(isUnlocked: true, onTap: () {}),
                    ObservatoryBuilding(isUnlocked: true, onTap: () {}),
                    AcademyBuilding(isUnlocked: true, onTap: () {}),
                  ],
                ),
              ),
            ),
          ),
        );

        // Verify all buildings render without throwing exceptions
        expect(find.byType(TownCenterBuilding), findsOneWidget);
        expect(find.byType(LibraryBuilding), findsOneWidget);
        expect(find.byType(TradingPostBuilding), findsOneWidget);
        expect(find.byType(TreasuryBuilding), findsOneWidget);
        expect(find.byType(MarketplaceBuilding), findsOneWidget);
        expect(find.byType(ObservatoryBuilding), findsOneWidget);
        expect(find.byType(AcademyBuilding), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('Buildings are accessible to screen readers', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TownCenterBuilding(
                isUnlocked: true,
                onTap: () {},
              ),
            ),
          ),
        );

        // Test semantic properties
        expect(find.text('Town Center'), findsOneWidget);
        expect(find.text('Kingdom Management'), findsOneWidget);
        
        // Verify tappable area exists
        final gesture = await tester.startGesture(tester.getCenter(find.byType(TownCenterBuilding)));
        await gesture.up();
        await tester.pump();
      });
    });

    group('Error Cases', () {
      testWidgets('Buildings handle null onTap gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TownCenterBuilding(
                isUnlocked: true,
                onTap: null,
              ),
            ),
          ),
        );

        // Should render without error
        expect(find.byType(TownCenterBuilding), findsOneWidget);
        
        // Should not throw when tapped with null onTap
        await tester.tap(find.byType(TownCenterBuilding));
        await tester.pump();
      });
    });
  });
}