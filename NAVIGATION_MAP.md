# Dashboard Navigation Mapping

## Complete Navigation Flow

### From Home Tab

#### Stat Circle Cards (3 tappable circles)

| Circle | Label | Data Source | Tap Action | Destination |
|--------|-------|-------------|-----------|-------------|
| 1️⃣ Left | No Of Deposits | `controller.summary['totalEntries']` | `controller.goToEntriesTab()` | Entries Tab (index 1) |
| 2️⃣ Center | Deposit Amount | `Helpers.formatAmount(controller.summary['totalBalance'])` | `controller.goToReportsTab()` | Reports Tab (index 3) |
| 3️⃣ Right | Account Opened | `controller.summary['activeAccounts']` | `controller.goToActiveAccountsTab()` | Accounts Tab (index 2, Active tab) |

#### Grid Navigation Cards (6 cards in 2×3 grid)

| Row | Col 1 | Col 2 |
|-----|-------|-------|
| 1 | **Pigmy Deposit** 💰 | **Balance Enquiry** 📊 |
| | → `controller.openDailyEntry()` | → `controller.goToReportsTab()` |
| | Opens: Daily Entry Page | Goes to: Reports Tab (index 3) |
| 2 | **Mini Statement** 📋 | **Report** 📈 |
| | → `controller.goToEntriesTab()` | → `controller.changeTab(3)` |
| | Goes to: Entries Tab (index 1) | Goes to: Reports Tab (index 3) |
| 3 | **Accounts** 👥 | **Settings** ⚙️ |
| | → `controller.goToAccountsTab()` | → `controller.changeTab(4)` |
| | Goes to: Accounts Tab (index 2) | Goes to: Settings Tab (index 4) |

---

## Tab Indices (From Controller)

```dart
Index 0: _HomeTab        // NEW DASHBOARD (home/dashboard page)
Index 1: _EntriesTab     // Entries list & timeline
Index 2: _AccountsTab    // Active & closed accounts
Index 3: _ReportsTab     // Summary reports
Index 4: _SettingsTab    // App settings
```

---

## Controller Methods Used

### Navigation Methods

```dart
// Primary navigation methods
controller.goToEntriesTab()        → changeTab(1) → Entries Tab
controller.goToReportsTab()        → changeTab(3) → Reports Tab
controller.goToAccountsTab()       → changeTab(2) → Accounts Tab (Active)
controller.goToActiveAccountsTab() → changeTab(2) with active index → Accounts (Active)

// Direct page navigation
controller.openDailyEntry()        → Get.toNamed(AppRoutes.dailyEntry)

// Generic method
controller.changeTab(index)        → currentTabIndex.value = index
```

### Data Methods

```dart
// Get data for display
controller.summary                 // Map with statistics
controller.summary['totalEntries'] → total number of entries
controller.summary['totalBalance'] → total amount (for balance display)
controller.summary['activeAccounts'] → count of active accounts

// Get app info
controller.appName.value           // "Entry Book" or from package info
controller.welcomeUserName.value   // "User" (can be customized)
```

---

## Navigation Request Flow

```
User taps stat circle/grid card
        ↓
InkWell ripple effect triggers
        ↓
onTap callback executes
        ↓
Controller method called
        ↓
Tab index changes
        ↓
IndexedStack switches to new page
        ↓
New tab displayed with animation
```

---

## Example: "Pigmy Deposit" Card Tap

1. User sees: 💰 **Pigmy Deposit** card on home grid
2. User taps: InkWell responds with ripple
3. Callback: `onTap: controller.openDailyEntry`
4. Method: Opens daily entry page (external route)
5. Result: Daily entry form displayed

---

## Example: "No Of Deposits" Circle Tap

1. User sees: Circle with "5" and "No Of Deposits"
2. User taps: InkWell circle responds with ripple
3. Callback: `onTap: controller.goToEntriesTab`
4. Method: `goToEntriesTab()` → `changeTab(1)`
5. Result: Entries tab (index 1) displayed with all entries

---

## Tab Switching Flow

```
Home (0) ←→ Entries (1)
   ↑           ↓
   ↓           ↓
Settings(4) ← Accounts (2)
   ↑           ↓
   └─ Reports (3)
```

All tabs accessible from home dashboard via stat circles or grid cards.

---

## Data Binding

### Home Tab Display Data

```
Header:
  - App name: controller.appName.value
  - Welcome: controller.welcomeUserName.value

Stat Circles:
  - Deposits: controller.summary['totalEntries'] ?? 0
  - Amount: controller.summary['totalBalance'] ?? 0 (formatted)
  - Accounts: controller.summary['activeAccounts'] ?? 0

Grid Cards:
  - All cards call existing controller methods
  - No data display (action-based)
```

### Summary Data Structure

```dart
Map<String, num> get summary => repository.getSummary();

// Returns:
{
  'totalAccounts': int,
  'activeAccounts': int,
  'closedAccounts': int,
  'totalBalance': double,
  'totalEntries': int,
}
```

---

## State Management

### Observable Properties

```dart
currentTabIndex = 0.obs;           // Current tab (0-4)
welcomeUserName = 'User'.obs;      // Welcome username
appName = 'Entry Book'.obs;        // App name
appVersion = 'Loading...'.obs;     // App version
```

### Reactive Updates

All stat circles and labels automatically update when:
- Entries are added/deleted
- Accounts are created/closed
- Balance changes
- App data is refreshed

---

## Navigation Route Map

```
DASHBOARD HOME
├─ [Stat Circles] (3 cards)
│  ├─ Deposits → Entries Tab
│  │           Show: List of all entries with timeline
│  │
│  ├─ Amount → Reports Tab
│  │         Show: Summary statistics
│  │
│  └─ Accounts → Accounts Tab (Active)
│              Show: List of active accounts
│
└─ [Grid Cards] (6 cards)
   ├─ Pigmy Deposit → Daily Entry Page
   │               Show: Daily entry form
   │
   ├─ Balance Enquiry → Reports Tab
   │                 Show: Balance summary
   │
   ├─ Mini Statement → Entries Tab
   │               Show: List of entries
   │
   ├─ Report → Reports Tab
   │         Show: Full reports
   │
   ├─ Accounts → Accounts Tab
   │           Show: Account list
   │
   └─ Settings → Settings Tab
               Show: App settings
```

---

## Testing Navigation

To test all navigation:

1. **Stat Circles:**
   - [ ] Tap "No Of Deposits" → Entries tab shows
   - [ ] Tap "Deposit Amount" → Reports tab shows
   - [ ] Tap "Account Opened" → Accounts tab (active) shows

2. **Grid Cards:**
   - [ ] Tap "Pigmy Deposit" → Daily entry page opens
   - [ ] Tap "Balance Enquiry" → Reports tab shows
   - [ ] Tap "Mini Statement" → Entries tab shows
   - [ ] Tap "Report" → Reports tab shows
   - [ ] Tap "Accounts" → Accounts tab shows
   - [ ] Tap "Settings" → Settings tab shows

3. **Back Navigation:**
   - [ ] Back button from any tab → Returns to home
   - [ ] All tabs switch properly

4. **Data Display:**
   - [ ] Stat circles show correct counts
   - [ ] Amount formatted as ₹X,XXX.XX
   - [ ] App name displays correctly
   - [ ] Welcome message shows

---

## Quick Reference - Controller Methods

```dart
// Tab navigation
changeTab(int index)                 // Switch to tab by index
goToEntriesTab()                     // → Tab 1
goToAccountsTab()                    // → Tab 2
goToReportsTab()                     // → Tab 3
goToActiveAccountsTab()              // → Tab 2 (active view)

// Feature navigation
openDailyEntry()                     // Open daily entry form
openAccount()                        // Open new account form
openAccountDetails(accountNumber)    // Open account details

// Data access
get summary                          // Get statistics map
get recentAccounts                   // Get recent accounts list
get recentEntries                    // Get recent entries list
get entries                          // Get all entries (filtered)
get activeAccounts                   // Get active accounts
get closedAccounts                   // Get closed accounts
```

---

**Last Updated**: April 18, 2026
**Version**: 1.0 - Dashboard Navigation Map

