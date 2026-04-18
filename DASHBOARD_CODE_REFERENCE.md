# Dashboard Code Reference

## Complete Implementation Details

### DashboardView Structure

```dart
class DashboardView extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentTabIndex.value,
        children: [
          _HomeTab(controller: controller),      // Index 0 - NEW DESIGN
          _EntriesTab(controller: controller),   // Index 1
          _AccountsTab(controller: controller),  // Index 2
          _ReportsTab(controller: controller),   // Index 3
          _SettingsTab(controller: controller),  // Index 4
        ],
      )),
    );  // ← NO bottomNavigationBar anymore!
  }
}
```

### New HomeTab with Stat Circles & Grid

```dart
class _HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          // 1. HEADER WITH GRADIENT
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.appName.value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'WELCOME ${(controller.welcomeUserName.value).toUpperCase()}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. STAT CIRCLES (3 CARDS)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatCircleCard(
                  label: 'No Of Deposits',
                  value: '${controller.summary['totalEntries'] ?? 0}',
                  onTap: controller.goToEntriesTab,
                ),
                _StatCircleCard(
                  label: 'Deposit Amount',
                  value: Helpers.formatAmount(
                    (controller.summary['totalBalance'] ?? 0).toDouble()
                  ),
                  onTap: controller.goToReportsTab,
                ),
                _StatCircleCard(
                  label: 'Account Opened',
                  value: '${controller.summary['activeAccounts'] ?? 0}',
                  onTap: controller.goToActiveAccountsTab,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. GRID NAVIGATION (6 CARDS)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _GridNavigationCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Pigmy Deposit',
                  onTap: controller.openDailyEntry,
                ),
                _GridNavigationCard(
                  icon: Icons.account_balance_outlined,
                  label: 'Balance Enquiry',
                  onTap: () => controller.goToReportsTab(),
                ),
                _GridNavigationCard(
                  icon: Icons.receipt_long_outlined,
                  label: 'Mini Statement',
                  onTap: controller.goToEntriesTab,
                ),
                _GridNavigationCard(
                  icon: Icons.assessment_outlined,
                  label: 'Report',
                  onTap: () => controller.changeTab(3),
                ),
                _GridNavigationCard(
                  icon: Icons.people_outline,
                  label: 'Accounts',
                  onTap: controller.goToAccountsTab,
                ),
                _GridNavigationCard(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => controller.changeTab(4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
```

### Stat Circle Card Widget

```dart
class _StatCircleCard extends StatelessWidget {
  const _StatCircleCard({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(80),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Grid Navigation Card Widget

```dart
class _GridNavigationCard extends StatelessWidget {
  const _GridNavigationCard({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer
              .withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary
                .withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Controller Updates

```dart
class DashboardController extends GetxController {
  // ... existing code ...

  // NEW: Add welcome user name
  final welcomeUserName = 'User'.obs;

  // NEW: Add method to navigate to reports
  void goToReportsTab() => changeTab(3);

  // EXISTING methods work as-is:
  // - goToEntriesTab() → changeTab(1)
  // - goToAccountsTab() → changeTab(2)
  // - goToActiveAccountsTab() → changeTab(2) with tab index 0
  // - openDailyEntry() → navigates to daily entry
  // - etc...
}
```

## Key Design Decisions

1. **Removed Bottom Navigation**
   - More screen space for content
   - Cards are more discoverable
   - Modern banking app pattern

2. **Header Gradient**
   - Professional appearance
   - Visual separation from content
   - Responsive gradient angle

3. **Circular Stat Cards**
   - Eye-catching shape
   - Quick metrics at a glance
   - Consistent with banking UI

4. **2-Column Grid**
   - Optimal for phone screens
   - Easy to extend (add 7th card = 4 rows)
   - Balanced layout

5. **Theme Integration**
   - Uses primary color throughout
   - Supports light/dark modes
   - Respects theme settings

## Color Palette

From theme colors:
- **Primary**: Main action color, stat circles, grid icons
- **Primary Container**: Grid card backgrounds (50% opacity)
- **Primary (10% opacity)**: Stat circle background
- **Primary (30% opacity)**: Stat circle border
- **White**: Header text
- **Text colors**: Theme text styles

## Sizing & Spacing

```
Header:          100px height, 20px vertical padding
Spacing:         20-24px between sections
Stat Circles:    100x100 each, 16px horizontal margin
Grid Cards:      2 columns, 12px spacing
Grid Card H:     ~120px (auto height for text)
Border Radius:   80px (circles), 12px (cards)
Icons:           36px (grid), 24px (stat circles)
```

## Animation & Interaction

- **InkWell ripple**: Tap feedback on all interactive cards
- **Border radius**: Matches ripple area for smooth animation
- **No extra animations**: Keep it fast and responsive

---

This is the complete code reference for the new dashboard design!

