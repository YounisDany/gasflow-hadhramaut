# GasFlow — Flutter + Firebase

Modern Flutter (Material 3) app for **Gas Distribution Management** connecting
**Admin**, **Agent**, and **Citizen** roles. Fully wired to **Firebase**
(Auth · Cloud Firestore · Cloud Messaging · Storage), bilingual (Arabic/English
with RTL), light **and dark** themes.

- **Offline-first:** Firestore local persistence + queued writes — changes are
  saved offline and sync automatically on reconnect (with an offline banner).
- **Demo mode:** if Firebase isn't configured yet, the app falls back to bundled
  demo data so every screen and flow is usable on-device immediately.

## Run

```bash
flutter pub get
flutter run            # runs in demo mode until Firebase is configured
```

To go live with your own Firebase backend, follow **[SETUP_FIREBASE.md](SETUP_FIREBASE.md)**
(≈10 min: `flutterfire configure`, enable Email/Password + Firestore, deploy rules).

**Test accounts** (after Firebase setup, or in demo mode):
- Admin: `admin@gmail.com` / `12345678`
- Agent: any email containing `agent` · Citizen: any other email

## Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/app_constants.dart
│   ├── routes/app_routes.dart
│   └── theme/{app_colors,app_text_styles,app_theme}.dart
├── data/
│   ├── dummy/dummy_data.dart
│   └── models/{user_role,app_status,agent_model,citizen_model,order_model,complaint_model}.dart
└── presentation/
    ├── widgets/   (reusable: PrimaryButton, AppCard, StatCard, StatusChip,
    │              SectionHeader, Avatar, EmptyState, RoleCard, OrderTile,
    │              CustomTextField, AppLogo)
    └── screens/
        ├── splash/splash_screen.dart
        ├── auth/{login,signup}_screen.dart
        ├── admin/{admin_dashboard,manage_agents,users_management}_screen.dart
        ├── agent/{agent_home,citizen_requests,gas_orders,barcode_scanner}_screen.dart
        └── citizen/{citizen_home,request_gas,order_status,complaints}_screen.dart
```

## Flow

- **Splash → Login** (role tabs Admin / Agent / Citizen) → role dashboard.
- **Signup** offers Citizen or "Request Agent". Agent requests await admin approval.
- **Admin** approves/rejects agents, manages users, monitors stats.
- **Agent** approves citizen join requests (which generates a Barcode ID),
  accepts/rejects gas orders, and scans cylinder barcodes on delivery.
- **Citizen** browses nearest agents on a map preview, requests gas, tracks
  the order through a timeline, views their barcode and submits complaints.

## Design

- **Primary color:** `#1E88E5`
- **Typography:** Inter via `google_fonts`
- **Shape:** rounded corners (14–22), soft borders, generous spacing
- **Components:** Material 3 with custom theme, premium card design,
  status chips, gradient banners, animated transitions.
