import 'package:hive/hive.dart';
import 'package:quick_actions/quick_actions.dart';
import 'medicin_tile.dart'; // Erstat med den faktiske sti til din MedicinTile model

class QuickActionsManager {
  Future<void> updateQuickActions() async {
    final box = await Hive.openBox<MedicinTile>('medicinBox');
    final List<MedicinTile> allMedicin = box.values.toList();

    // Sortér listen baseret på doseAmount, så de mest brugte doser kommer først
    allMedicin.sort((a, b) => b.doseAmount.compareTo(a.doseAmount));

    // Opret en liste af ShortcutItems for de tre mest brugte medicin (hvis der er mindst tre)
    List<ShortcutItem> items = List<ShortcutItem>.generate(
      allMedicin.length < 3 ? allMedicin.length : 3, // Sørg for ikke at overskride listen længde
          (index) {
        final medicin = allMedicin[index];
        return ShortcutItem(
          type: 'dose_${medicin.name}',
          localizedTitle: medicin.name,
          // icon: 'icon_dose', // Sikr dig, at dette ikon er defineret i dine platformsspecifikke projekter
        );
      },
    );

    // Opdatér quick actions
    const QuickActions quickActions = QuickActions();
    quickActions.setShortcutItems(items);
  }
}
