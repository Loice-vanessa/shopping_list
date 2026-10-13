import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopping_list/main.dart';

void main() {
  testWidgets('adding a duplicate raises its quantity', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField), ' mILK');
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Milk is already on the list: now ×2'), findsOneWidget);
  });

  testWidgets('undo puts the item back in the same place', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(Icons.delete).at(1)); // Bread
    await tester.pumpAndSettle(); // let the SnackBar finish sliding in
    expect(find.text('Bread'), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    final names = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => (tile.title as Text).data)
        .toList();
    expect(names, ['Milk', 'Bread', 'Rice']);
  });
}
