import 'package:flutter/material.dart';

class L10n {
  L10n._();

  static final ValueNotifier<Locale> notifier =
      ValueNotifier(const Locale('ar'));

  static bool get isAr => notifier.value.languageCode == 'ar';

  static void toggle() {
    notifier.value = isAr ? const Locale('en') : const Locale('ar');
  }

  static void setLocale(Locale l) => notifier.value = l;
}

/// Centralized strings. Use `S.<getter>` everywhere — they re-evaluate on each
/// build because `MaterialApp` rebuilds when [L10n.notifier] changes.
class S {
  S._();

  static bool get _ar => L10n.isAr;

  // ─────────────── Common ───────────────
  static String get appName => 'GasFlow';
  static String get tagline => _ar
      ? 'توزيع غاز ذكي ومبسّط.'
      : 'Smart gas distribution, simplified.';
  static String get back => _ar ? 'رجوع' : 'Back';
  static String get cancel => _ar ? 'إلغاء' : 'Cancel';
  static String get done => _ar ? 'تم' : 'Done';
  static String get save => _ar ? 'حفظ' : 'Save';
  static String get share => _ar ? 'مشاركة' : 'Share';
  static String get filter => _ar ? 'تصفية' : 'Filter';
  static String get all => _ar ? 'الكل' : 'All';
  static String get viewAll => _ar ? 'عرض الكل' : 'View all';
  static String get seeAll => _ar ? 'عرض الكل' : 'See all';
  static String get manage => _ar ? 'إدارة' : 'Manage';
  static String get currency => _ar ? 'ر.ي' : 'YER';
  static String get free => _ar ? 'مجاناً' : 'Free';

  // ─────────────── Roles ───────────────
  static String get roleAdmin => _ar ? 'مشرف' : 'Admin';
  static String get roleAgent => _ar ? 'موزع' : 'Agent';
  static String get roleCitizen => _ar ? 'عميل' : 'Citizen';

  // ─────────────── Statuses ───────────────
  static String get statusPending => _ar ? 'قيد الانتظار' : 'Pending';
  static String get statusAccepted => _ar ? 'مقبول' : 'Accepted';
  static String get statusRejected => _ar ? 'مرفوض' : 'Rejected';
  static String get statusCompleted => _ar ? 'مكتمل' : 'Completed';

  // ─────────────── Auth ───────────────
  static String get welcomeBack => _ar ? 'مرحباً بعودتك' : 'Welcome back';
  static String get signInSubtitle => _ar
      ? 'سجّل الدخول لإدارة طلبات الغاز بثقة.'
      : 'Sign in to manage your gas deliveries with confidence.';
  static String get email => _ar ? 'البريد الإلكتروني' : 'Email address';
  static String get emailHint => 'name@gasflow.com';
  static String get password => _ar ? 'كلمة المرور' : 'Password';
  static String get passwordHint => '••••••••';
  static String get emailRequired =>
      _ar ? 'البريد الإلكتروني مطلوب' : 'Email is required';
  static String get passwordMin =>
      _ar ? '٦ أحرف على الأقل' : 'Minimum 6 characters';
  static String get forgotPassword =>
      _ar ? 'نسيت كلمة المرور؟' : 'Forgot password?';
  static String get rememberMe => _ar ? 'تذكّرني' : 'Remember me';
  static String get signIn => _ar ? 'تسجيل الدخول' : 'Sign in';
  static String get orContinueWith =>
      _ar ? 'أو تابع باستخدام' : 'or continue with';
  static String get noAccount =>
      _ar ? 'ليس لديك حساب؟ ' : "Don't have an account? ";
  static String get signUp => _ar ? 'إنشاء حساب' : 'Sign up';
  static String get haveAccount =>
      _ar ? 'لديك حساب بالفعل؟ ' : 'Already have an account? ';

  // ─────────────── Signup ───────────────
  static String get createAccount => _ar ? 'إنشاء حساب' : 'Create account';
  static String get joinGasFlow =>
      _ar ? 'انضم إلى GasFlow' : 'Join GasFlow';
  static String get signupSubtitle => _ar
      ? 'اختر طريقة استخدامك للتطبيق — يمكنك التغيير لاحقاً.'
      : 'Pick how you want to use the app — you can always switch later.';
  static String get citizenRoleDesc => _ar
      ? 'اطلب اسطوانات الغاز من الموزعين القريبين.'
      : 'Order gas cylinders from nearby agents.';
  static String get agentRoleTitle =>
      _ar ? 'طلب الانضمام كموزع' : 'Request to be an Agent';
  static String get agentRoleDesc => _ar
      ? 'وزّع الغاز على العملاء في منطقتك.'
      : 'Distribute gas to citizens in your district.';
  static String get fullName => _ar ? 'الاسم الكامل' : 'Full name';
  static String get fullNameHint =>
      _ar ? 'مثال: أحمد العتيبي' : 'e.g. Ahmed Al-Otaibi';
  static String get nameRequired =>
      _ar ? 'الاسم مطلوب' : 'Name is required';
  static String get phone => _ar ? 'رقم الجوال' : 'Phone number';
  static String get phoneHint =>
      _ar ? '+967 7X XXX XXXX' : '+967 7X XXX XXXX';
  static String get phoneInvalid =>
      _ar ? 'أدخل رقماً صحيحاً' : 'Enter a valid phone';
  static String get emailInvalid =>
      _ar ? 'أدخل بريداً صحيحاً' : 'Enter a valid email';
  static String get passwordHintLong =>
      _ar ? '٦ أحرف على الأقل' : 'At least 6 characters';
  static String get confirmPassword => _ar ? 'تأكيد كلمة المرور' : 'Confirm password';
  static String get confirmPasswordHint => _ar ? 'أعد إدخال كلمة المرور' : 'Re-enter your password';
  static String get dataRegistrationTitle => _ar ? 'تسجيل بيانات العميل' : 'Citizen Data Registration';
  static String get agreeTo => _ar ? 'أوافق على ' : 'I agree to the ';
  static String get terms =>
      _ar ? 'شروط الاستخدام' : 'Terms of Service';
  static String get and => _ar ? ' و' : ' and ';
  static String get privacy => _ar ? 'سياسة الخصوصية' : 'Privacy Policy';
  static String get submitAgentRequest =>
      _ar ? 'إرسال طلب الموزع' : 'Submit agent request';
  static String get requestSubmitted =>
      _ar ? 'تم إرسال الطلب' : 'Request submitted';
  static String get accountCreated =>
      _ar ? 'تم إنشاء الحساب' : 'Account created';
  static String get requestSubmittedDesc => _ar
      ? 'سيقوم المشرف بمراجعة طلبك قريباً وستصلك إشعار عند الموافقة.'
      : 'An admin will review your agent request shortly. You will be notified once approved.';
  static String get agentWillReview => _ar
      ? 'سيقوم الوكيل بمراجعة طلبك قريباً وستصلك إشعار عند الموافقة.'
      : 'The agent will review your request shortly. You will be notified once approved.';
  static String get accountCreatedDesc => _ar
      ? 'يمكنك الآن طلب الغاز من أقرب موزع لك.'
      : 'You can now request gas from your nearest agent.';
  static String get backToLogin =>
      _ar ? 'العودة لتسجيل الدخول' : 'Back to login';
  static String get continueBtn => _ar ? 'متابعة' : 'Continue';
  static String get google => _ar ? 'جوجل' : 'Google';
  static String get apple => _ar ? 'آبل' : 'Apple';

  // ─────────────── Admin Dashboard ───────────────
  static String get welcomeAdmin =>
      _ar ? 'مرحباً بعودتك، أيها المشرف' : 'Welcome back, Admin';
  static String get opsDashboard =>
      _ar ? 'لوحة العمليات' : 'Operations dashboard';
  static String get todaysOverview =>
      _ar ? 'ملخص اليوم' : "Today's overview";
  static String get cylindersDelivered =>
      _ar ? 'اسطوانة تم توصيلها' : 'cylinders delivered';
  static String get aboveYesterday =>
      _ar ? '١٨٪ أعلى من الأمس' : '18% above yesterday';
  static String get totalUsers => _ar ? 'إجمالي المستخدمين' : 'Total users';
  static String get activeAgents => _ar ? 'الموزعون النشطون' : 'Active agents';
  static String get totalOrders => _ar ? 'إجمالي الطلبات' : 'Total orders';
  static String get pendingRequests =>
      _ar ? 'الطلبات المعلّقة' : 'Pending requests';
  static String get quickActions => _ar ? 'إجراءات سريعة' : 'Quick actions';
  static String get pendingAgentRequests =>
      _ar ? 'طلبات موزعين معلّقة' : 'Pending agent requests';
  static String get manageAgents => _ar ? 'إدارة\nالموزعين' : 'Manage\nagents';
  static String get usersShort => _ar ? 'المستخدمون' : 'Users';
  static String get reports => _ar ? 'التقارير' : 'Reports';
  static String get settings => _ar ? 'الإعدادات' : 'Settings';
  static String get dashboard => _ar ? 'لوحة' : 'Dashboard';
  static String get agentsTab => _ar ? 'الموزعون' : 'Agents';
  static String get logout => _ar ? 'خروج' : 'Logout';

  // ─────────────── Manage Agents ───────────────
  static String get manageAgentsTitle =>
      _ar ? 'إدارة الموزعين' : 'Manage agents';
  static String get searchAgentsHint =>
      _ar ? 'ابحث بالاسم أو الحي…' : 'Search by name or district…';
  static String get noAgentsFound =>
      _ar ? 'لا يوجد موزعون' : 'No agents found';
  static String get noAgentsFoundDesc => _ar
      ? 'حاول بحثاً مختلفاً أو امسح الفلتر.'
      : 'Try a different search or clear the filter.';
  static String get citizens => _ar ? 'العملاء' : 'Citizens';
  static String get rating => _ar ? 'التقييم' : 'Rating';
  static String get distance => _ar ? 'المسافة' : 'Distance';
  static String get reject => _ar ? 'رفض' : 'Reject';
  static String get approve => _ar ? 'موافقة' : 'Approve';
  static String approvedMsg(String name) =>
      _ar ? 'تمت الموافقة على $name' : '$name approved';
  static String rejectedMsg(String name) =>
      _ar ? 'تم رفض $name' : '$name rejected';
  static String get agentIdLabel => _ar ? 'معرف الموزع • ' : 'Agent ID • ';
  static String ratingCitizens(double rating, int citizens) => _ar
      ? '${rating.toStringAsFixed(1)} تقييم  •  $citizens عميل'
      : '${rating.toStringAsFixed(1)} rating  •  $citizens citizens';

  // ─────────────── Users Management ───────────────
  static String get settingsAndUsers =>
      _ar ? 'الإعدادات والمستخدمون' : 'Settings & Users';
  static String get system => _ar ? 'النظام' : 'System';
  static String get notificationsLabel =>
      _ar ? 'الإشعارات' : 'Notifications';
  static String get notificationsDesc => _ar
      ? 'تنبيهات البريد والإشعارات المباشرة'
      : 'Email and push alerts';
  static String get twoFactor =>
      _ar ? 'المصادقة الثنائية' : 'Two-factor authentication';
  static String get twoFactorDesc => _ar
      ? 'مطلوبة لحسابات المشرفين'
      : 'Required for admin accounts';
  static String get pricingRules =>
      _ar ? 'قواعد التسعير' : 'Pricing rules';
  static String get pricingRulesDesc => _ar
      ? 'حدد السعر الأساسي للاسطوانة'
      : 'Set base price per cylinder';
  static String get dataExport => _ar ? 'تصدير البيانات' : 'Data export';
  static String get dataExportDesc => _ar
      ? 'تصدير المستخدمين والطلبات'
      : 'Export users and orders';
  static String get account => _ar ? 'الحساب' : 'Account';
  static String get adminProfile =>
      _ar ? 'الملف الشخصي' : 'Admin profile';
  static String get adminProfileDesc =>
      _ar ? 'تعديل المعلومات الشخصية' : 'Edit personal information';
  static String get signOut => _ar ? 'تسجيل الخروج' : 'Sign out';
  static String get signOutDesc =>
      _ar ? 'العودة لشاشة الدخول' : 'Return to login';
  static String usersCount(int n) => _ar ? 'المستخدمون ($n)' : 'Users ($n)';

  // ─────────────── Agent Home ───────────────
  static String hello(String name) => _ar ? 'مرحباً، $name 👋' : 'Hello, $name 👋';
  static String helloShort(String name) => _ar ? 'مرحباً، $name' : 'Hello, $name';
  static String get youreOnline => _ar ? 'أنت متصل الآن' : "You're online";
  static String get acceptingOrders => _ar
      ? 'تستقبل الطلبات الجديدة وطلبات الانضمام'
      : 'Accepting new orders and citizen requests';
  static String get myCitizens => _ar ? 'عملائي' : 'My citizens';
  static String get pending => _ar ? 'معلّق' : 'Pending';
  static String get todaysOrders =>
      _ar ? 'طلبات اليوم' : "Today's orders";
  static String get completedLabel => _ar ? 'مكتمل' : 'Completed';
  static String get quickLinks => _ar ? 'روابط سريعة' : 'Quick links';
  static String get citizenRequestsShort =>
      _ar ? 'طلبات\nالعملاء' : 'Citizen\nrequests';
  static String get gasOrdersShort => _ar ? 'طلبات\nالغاز' : 'Gas\norders';
  static String get scanBarcodeShort =>
      _ar ? 'مسح\nرمز QR' : 'Scan\nQR code';
  static String get myStats => _ar ? 'إحصائياتي' : 'My\nstats';
  static String get latestNotifications =>
      _ar ? 'آخر الإشعارات' : 'Latest notifications';
  static String get markAllRead =>
      _ar ? 'تحديد الكل كمقروء' : 'Mark all read';
  static String get newGasOrder =>
      _ar ? 'طلب غاز جديد' : 'New gas order';
  static String get newGasOrderDesc => _ar
      ? 'قام أحمد العتيبي بطلب 2 × اسطوانة 12 كجم.'
      : 'Ahmed Al-Otaibi placed an order for 2 × 12kg cylinders.';
  static String get newCitizenRequest =>
      _ar ? 'طلب انضمام جديد' : 'New citizen request';
  static String get newCitizenRequestDesc => _ar
      ? 'سارة بنت محمد ترغب بالانضمام لمنطقتك.'
      : 'Sara Bin Mohammed wants to join your district.';
  static String get newComplaint =>
      _ar ? 'شكوى جديدة' : 'New complaint';
  static String get newComplaintDesc => _ar
      ? 'تم الإبلاغ عن تأخر التوصيل من ريم الدوسري (CMP-301).'
      : 'Late delivery reported by Reem Al-Dosari (CMP-301).';
  static String minutesAgo(int n) => _ar ? 'قبل $n د' : '${n}m ago';
  static String hoursAgo(int n) => _ar ? 'قبل $n س' : '${n}h ago';
  static String daysAgo(int n) => _ar ? 'قبل $n ي' : '${n}d ago';
  static String get awaitingAction =>
      _ar ? 'بانتظار إجرائك' : 'Awaiting your action';
  static String get tabHome => _ar ? 'الرئيسية' : 'Home';
  static String get tabRequests => _ar ? 'الطلبات' : 'Requests';
  static String get tabOrders => _ar ? 'الطلبات' : 'Orders';
  static String get tabScan => _ar ? 'مسح' : 'Scan';

  // ─────────────── Citizen Requests ───────────────
  static String get citizenRequestsTitle =>
      _ar ? 'طلبات العملاء' : 'Citizen requests';
  static String get noRequests => _ar ? 'لا توجد طلبات' : 'No requests';
  static String get noRequestsDesc => _ar
      ? 'ستظهر طلبات الانضمام الجديدة هنا.'
      : 'New citizen requests will appear here.';
  static String get accept => _ar ? 'قبول' : 'Accept';
  static String approvedSheetTitle(String name) =>
      _ar ? 'تمت الموافقة على $name' : '$name approved';
  static String get barcodeGeneratedDesc => _ar
      ? 'تم إنشاء رمز QR ومشاركته مع العميل.'
      : 'QR code generated and shared with the citizen.';

  // ─────────────── Gas Orders ───────────────
  static String get gasOrdersTitle => _ar ? 'طلبات الغاز' : 'Gas orders';
  static String get tabAll => _ar ? 'الكل' : 'All';
  static String get tabPending => _ar ? 'معلّق' : 'Pending';
  static String get tabAccepted => _ar ? 'مقبول' : 'Accepted';
  static String get tabDone => _ar ? 'مكتمل' : 'Done';
  static String get noOrdersHere =>
      _ar ? 'لا توجد طلبات هنا' : 'No orders here';
  static String get noOrdersHereDesc => _ar
      ? 'ستظهر طلبات الغاز الجديدة في هذا التبويب.'
      : 'New gas orders will show up in this tab.';
  static String get markDelivered =>
      _ar ? 'تم التوصيل' : 'Mark as delivered';
  static String cylinderCount(int qty, String size) =>
      _ar ? '$qty × اسطوانة $size' : '$qty × $size cylinder';
  static String totalCurrency(double v) =>
      _ar ? 'الإجمالي: ${v.toStringAsFixed(0)} ر.ي' :
            'Total: ${v.toStringAsFixed(0)} YER';

  // ─────────────── QR Scanner ───────────────
  static String get scanBarcode => _ar ? 'مسح رمز QR' : 'Scan QR code';
  static String get alignBarcode => _ar
      ? 'حاذِ رمز QR داخل الإطار'
      : 'Align the QR code inside the frame';
  static String get searchingBarcode =>
      _ar ? 'جاري البحث عن رمز QR…' : 'Searching for QR code…';
  static String get verified => _ar ? 'موثّق' : 'Verified';
  static String get confirmDelivery =>
      _ar ? 'تأكيد التوصيل' : 'Confirm delivery';

  // ─────────────── Citizen Home ───────────────
  static String get citySeiyun =>
      _ar ? 'سيئون، حضرموت' : 'Seiyun, Hadhramaut';
  static String get searchHint => _ar
      ? 'ابحث عن موزعين أو أحياء…'
      : 'Search agents, districts…';
  static String agentsWithinKm(int n, int km) => _ar
      ? 'يظهر $n موزعين خلال $km كم'
      : 'Showing $n agents within $km km';
  static String get needGasToday =>
      _ar ? 'تحتاج غاز اليوم؟' : 'Need gas today?';
  static String get orderInSeconds => _ar
      ? 'اطلب في ثوانٍ وتابع التوصيل لحظة بلحظة.'
      : 'Order in seconds and track delivery in real time.';
  static String get requestNow => _ar ? 'اطلب الآن' : 'Request now';
  static String get nearbyAgents =>
      _ar ? 'موزعون قريبون' : 'Nearby agents';
  static String kmAway(double km) =>
      _ar ? '${km.toStringAsFixed(1)} كم' : '${km.toStringAsFixed(1)} km away';
  static String get tabRequest => _ar ? 'طلب' : 'Request';
  static String get tabSupport => _ar ? 'الدعم' : 'Support';

  // ─────────────── Request Gas ───────────────
  static String get requestGasTitle => _ar ? 'طلب غاز' : 'Request gas';
  static String get chooseSize =>
      _ar ? 'اختر حجم الاسطوانة' : 'Choose cylinder size';
  static String get quantity => _ar ? 'الكمية' : 'Quantity';
  static String sizeCylinders(String size) =>
      _ar ? 'اسطوانات $size' : '$size cylinders';
  static String get deliveredToAddress => _ar
      ? 'يتم التوصيل لعنوانك'
      : 'Delivered to your address';
  static String get chooseAgent => _ar ? 'اختر الموزع' : 'Choose agent';
  static String get deliveryAddress =>
      _ar ? 'عنوان التوصيل' : 'Delivery address';
  static String get homeLabel => _ar ? 'المنزل' : 'Home';
  static String get change => _ar ? 'تغيير' : 'Change';
  static String get total => _ar ? 'الإجمالي' : 'Total';
  static String get confirmRequest =>
      _ar ? 'تأكيد الطلب' : 'Confirm request';

  // ─────────────── Request Status (no delivery — refill notifications) ───────────────
  static String get orderStatusTitle =>
      _ar ? 'حالة الطلب' : 'Request status';
  static String orderHash(String id) =>
      _ar ? 'الطلب رقم $id' : 'Request #$id';
  static String get gasOnTheWay =>
      _ar ? 'تعبئتك جاهزة قريباً' : 'Your refill is ready soon';
  static String get etaMinutes => _ar
      ? 'سيتم إشعارك قبل وبعد التعبئة'
      : "You'll be notified before and after refill";
  static String get tracking => _ar ? 'سجل الإشعارات' : 'Notification log';
  static String get stepRequestSubmitted =>
      _ar ? 'تم إرسال الطلب' : 'Request submitted';
  static String get stepAcceptedByAgent =>
      _ar ? 'قبول الوكيل' : 'Accepted by agent';
  static String get stepOutForDelivery =>
      _ar ? 'إشعار: قبل التعبئة' : 'Notice: Before refill';
  static String get stepDelivered =>
      _ar ? 'إشعار: تمت التعبئة' : 'Notice: Refilled';
  static String todayAt(String time) =>
      _ar ? 'اليوم، $time' : 'Today, $time';
  static String etaAt(String time) =>
      _ar ? 'متوقع $time' : 'Expected $time';
  static String ratingValue(double r) =>
      _ar ? '${r.toStringAsFixed(1)} تقييم' : '${r.toStringAsFixed(1)} rating';
  static String get cancelOrder => _ar ? 'إلغاء الطلب' : 'Cancel request';
  static String get contactAgent =>
      _ar ? 'تواصل مع الوكيل' : 'Contact agent';
  static String get orderDetails => _ar ? 'تفاصيل الطلب' : 'Request details';
  static String get cylinder => _ar ? 'الاسطوانة' : 'Cylinder';
  static String get addressLabel => _ar ? 'العنوان' : 'Address';
  static String get subtotal => _ar ? 'المجموع الفرعي' : 'Subtotal';
  static String get deliveryFee => _ar ? 'الرسوم' : 'Service fee';

  // ─────────────── Refill notifications ───────────────
  static String get notifyCustomer =>
      _ar ? 'إرسال إشعار للعميل' : 'Notify customer';
  static String get notifyBefore =>
      _ar ? 'قبل التعبئة' : 'Before refill';
  static String get notifyAfter =>
      _ar ? 'بعد التعبئة' : 'After refill';
  static String get sendNotifications =>
      _ar ? 'الإشعارات' : 'Send notifications';
  static String get notificationSent =>
      _ar ? 'تم إرسال الإشعار' : 'Notification sent';
  static String get beforeRefillMsg => _ar
      ? 'سنبدأ تعبئة اسطوانتك قريباً.'
      : "We'll start refilling your cylinder shortly.";
  static String get afterRefillMsg => _ar
      ? 'تمت تعبئة اسطوانتك بنجاح.'
      : 'Your cylinder has been refilled successfully.';
  static String get pickupNote => _ar
      ? 'سيتم إشعارك قبل البدء وبعد الانتهاء من التعبئة.'
      : "You'll receive a notification before and after the refill.";

  // ─────────────── Verification / Joining ───────────────
  static String get verificationStatus =>
      _ar ? 'حالة الحساب' : 'Account status';
  static String get pendingAdminApproval => _ar
      ? 'طلبك كوكيل قيد مراجعة الإدارة'
      : 'Your agent application is under admin review';
  static String get pendingAgentApproval =>
      _ar ? 'بانتظار موافقة الوكيل' : 'Pending agent approval';
  static String approvedByAgent(String name) =>
      _ar ? 'مسجَّل لدى $name' : 'Registered with $name';
  static String get chooseAnAgentToJoin =>
      _ar ? 'اختر وكيلاً للانضمام إليه' : 'Choose an agent to join';
  static String get requestToJoin =>
      _ar ? 'إرسال طلب الانضمام' : 'Request to join';
  static String get cantRequestYet => _ar
      ? 'لا يمكنك طلب الغاز قبل قبولك من قبل وكيل.'
      : "You can't request gas until you're accepted by an agent.";
  static String get howVerificationWorks =>
      _ar ? 'كيف يتم التحقق' : 'How verification works';
  static String get verificationStep1Title =>
      _ar ? 'تسجيل الحساب' : 'Sign up';
  static String get verificationStep1Desc => _ar
      ? 'يختار المستخدم دوره: مواطن أو طلب انضمام كوكيل.'
      : 'You pick your role: citizen or agent request.';
  static String get verificationStep2Title =>
      _ar ? 'مراجعة الطلب' : 'Review';
  static String get verificationStep2Desc => _ar
      ? 'الوكلاء تتم مراجعتهم من الإدارة، والمواطنون من الوكيل المختار.'
      : 'Agents are reviewed by admin; citizens by their chosen agent.';
  static String get verificationStep3Title =>
      _ar ? 'تفعيل الحساب' : 'Activation';
  static String get verificationStep3Desc => _ar
      ? 'بعد القبول، يحصل المواطن على رمز QR ويبدأ بطلب الغاز.'
      : 'On approval, the citizen gets a QR code and can request gas.';

  // ─────────────── Signup fields (per role) ───────────────
  static String get fullName4 => _ar ? 'الاسم الرباعي' : 'Full 4-part name';
  static String get fullName4Hint =>
      _ar ? 'مثال: أحمد محمد سعد العتيبي' : 'e.g. Ahmed Mohammed Saad Al-Otaibi';
  static String get region => _ar ? 'المنطقة' : 'Region';
  static String get regionHint => _ar ? 'مثال: سيئون' : 'e.g. Seiyun';
  static String get district => _ar ? 'الحي' : 'District';
  static String get districtHint => _ar ? 'مثال: القرن' : 'e.g. Al Qarn';
  static String get familySize => _ar ? 'عدد أفراد الأسرة' : 'Family members';
  static String get familySizeHint => _ar ? 'مثال: 5' : 'e.g. 5';
  static String get addressFull => _ar ? 'العنوان' : 'Address';
  static String get addressHint => _ar
      ? 'الحي، الشارع، رقم المبنى'
      : 'District, street, building no.';

  // ─────────────── Admin: Complaints review ───────────────
  static String get viewComplaints => _ar ? 'عرض البلاغات' : 'View complaints';
  static String get complaintsReview =>
      _ar ? 'البلاغات' : 'Complaints';
  static String get complaintDetails =>
      _ar ? 'تفاصيل البلاغ' : 'Complaint details';
  static String get markResolved =>
      _ar ? 'تم الحل' : 'Mark resolved';
  static String get reportedBy =>
      _ar ? 'مقدِّم البلاغ' : 'Reported by';
  static String get reportedOn => _ar ? 'بتاريخ' : 'Reported on';

  // ─────────────── Complaints / Support ───────────────
  static String get supportTitle => _ar ? 'الدعم' : 'Support';
  static String get myBarcode => _ar ? 'رمز QR' : 'My QR code';
  static String get complaintsTab => _ar ? 'الشكاوى' : 'Complaints';
  static String get yourUniqueBarcode =>
      _ar ? 'رمز QR الخاص بك' : 'Your unique QR code';
  static String get showToAgent => _ar
      ? 'اعرضه للموزع عند التوصيل'
      : 'Show this to your agent at delivery';
  static String get howItWorks => _ar ? 'كيف يعمل' : 'How it works';
  static String get getApproved => _ar ? 'احصل على الموافقة' : 'Get approved';
  static String get getApprovedDesc => _ar
      ? 'يقوم أقرب موزع بمراجعة طلب الانضمام.'
      : 'Your nearest agent reviews your join request.';
  static String get receiveBarcode =>
      _ar ? 'استلم رمز QR' : 'Receive QR code';
  static String get receiveBarcodeDesc => _ar
      ? 'يتم إنشاء رمز QR فريد لحسابك.'
      : 'A unique QR code is generated for your account.';
  static String get orderAnytime => _ar ? 'اطلب في أي وقت' : 'Order anytime';
  static String get orderAnytimeDesc => _ar
      ? 'اعرض رمز QR عند التوصيل لتحقق سريع.'
      : 'Show the QR code at delivery for fast verification.';
  static String get submitComplaint =>
      _ar ? 'قدّم شكوى' : 'Submit a complaint';
  static String get submitComplaintDesc => _ar
      ? 'أخبرنا بما حدث — وسيتابع فريقنا قريباً.'
      : 'Tell us what went wrong — our team will follow up shortly.';
  static String get title => _ar ? 'العنوان' : 'Title';
  static String get titleHint => _ar ? 'ملخص قصير' : 'Short summary';
  static String get description => _ar ? 'الوصف' : 'Description';
  static String get descriptionHint => _ar
      ? 'أخبرنا بالمزيد عن المشكلة…'
      : 'Tell us more about the issue…';
  static String get sendComplaint =>
      _ar ? 'إرسال الشكوى' : 'Submit complaint';
  static String get previousComplaints =>
      _ar ? 'الشكاوى السابقة' : 'Previous complaints';
  static String get nothingYet => _ar ? 'لا شيء بعد' : 'Nothing yet';
  static String get nothingYetDesc => _ar
      ? 'ستظهر شكاواك السابقة هنا.'
      : 'Your past complaints will appear here.';
  static String get complaintSubmitted =>
      _ar ? 'تم إرسال الشكوى' : 'Complaint submitted';

  // Language
  static String get langSwitch => _ar ? 'English' : 'العربية';

  // ─────────────── Guest mode / AuthGate ───────────────
  static String welcomeGuest() =>
      _ar ? 'مرحباً، ضيف 👋' : 'Welcome, guest 👋';
  static String get guestModeTitle =>
      _ar ? 'أنت تتصفّح كزائر' : "You're browsing as a guest";
  static String get guestModeDesc => _ar
      ? 'سجّل دخولك لتقديم طلبات الغاز وتلقي إشعارات التعبئة وإرسال الشكاوى.'
      : 'Sign in to request gas, receive refill notifications, and submit complaints.';
  static String get signInRequired =>
      _ar ? 'تسجيل الدخول مطلوب' : 'Sign in required';
  static String get signInToContinue => _ar
      ? 'يجب تسجيل الدخول لإكمال هذه الخطوة.'
      : 'You need to sign in to continue.';
  static String get signInToRequest => _ar
      ? 'سجّل دخولك لتقديم طلب الغاز ومتابعة حالته.'
      : 'Sign in to submit a gas request and track its status.';
  static String get signInToTrack => _ar
      ? 'سجّل دخولك لمتابعة طلباتك السابقة والحالية.'
      : 'Sign in to track your past and current requests.';
  static String get signInToSupport => _ar
      ? 'سجّل دخولك لإرسال شكوى أو الوصول إلى رمز QR.'
      : 'Sign in to submit a complaint or access your QR code.';
  static String get signInToContact => _ar
      ? 'سجّل دخولك للتواصل مع الوكيل.'
      : 'Sign in to contact the agent.';
  static String get notNow => _ar ? 'ليس الآن' : 'Not now';
  static String get continueAsGuest =>
      _ar ? 'متابعة كزائر' : 'Continue as guest';

  // ─────────────── Settings ───────────────
  static String get profile => _ar ? 'الملف الشخصي' : 'Profile';
  static String get appearance => _ar ? 'المظهر' : 'Appearance';
  static String get darkMode => _ar ? 'الوضع الليلي' : 'Dark mode';
  static String get aboutApp => _ar ? 'عن التطبيق' : 'About App';
  static String get version => _ar ? 'الإصدار' : 'Version';
  static String get editProfile => _ar ? 'تعديل الملف الشخصي' : 'Edit profile';
  static String get notifications => _ar ? 'الإشعارات' : 'Notifications';
  static String get notificationsDesc2 => _ar
      ? 'تلقي إشعارات الطلبات والتعبئة'
      : 'Receive order and refill notifications';
  static String get rateApp => _ar ? 'قيّم التطبيق' : 'Rate app';
  static String get rateAppDesc => _ar
      ? 'ساعدنا بتقييمك في المتجر'
      : 'Help us with your store rating';
  static String get shareApp => _ar ? 'شارك التطبيق' : 'Share app';
  static String get shareAppDesc => _ar
      ? 'أرسل التطبيق لأصدقائك وعائلتك'
      : 'Send the app to friends and family';
  static String get contactUs => _ar ? 'تواصل معنا' : 'Contact us';
  static String get contactUsDesc => _ar
      ? 'راسلنا عبر البريد الإلكتروني'
      : 'Reach us via email';
  static String get aboutAppDescription => _ar
      ? 'GasFlow هو تطبيق ذكي لتوزيع الغاز في اليمن. يربط بين العملاء والموزعين بطريقة سلسة وآمنة، مع إمكانية تتبع الطلبات وإدارة التوصيل بكفاءة عالية.'
      : 'GasFlow is a smart gas distribution app in Yemen. It connects customers and distributors seamlessly and securely, with order tracking and efficient delivery management.';
  static String get madeWithLove => _ar
      ? 'صُنع بـ ❤️ في حضرموت، اليمن'
      : 'Made with ❤️ in Hadhramaut, Yemen';
  static String get allRightsReserved => _ar
      ? 'جميع الحقوق محفوظة © 2026'
      : '© 2026 All rights reserved';
  static String get general => _ar ? 'عام' : 'General';
  static String get support => _ar ? 'الدعم والمساعدة' : 'Support';
  static String get savedSuccessfully => _ar ? 'تم الحفظ بنجاح' : 'Saved successfully';
  static String get fullNameLabel => _ar ? 'الاسم الكامل' : 'Full name';
  static String get phoneLabel => _ar ? 'رقم الجوال' : 'Phone number';
  static String get regionLabel => _ar ? 'المنطقة' : 'Region';
  static String get close => _ar ? 'إغلاق' : 'Close';

  // ─────────────── Notifications center ───────────────
  static String get notificationsTitle => _ar ? 'الإشعارات' : 'Notifications';
  static String get noNotifications =>
      _ar ? 'لا توجد إشعارات' : 'No notifications';
  static String get noNotificationsDesc => _ar
      ? 'ستظهر التنبيهات الجديدة هنا.'
      : 'New alerts will show up here.';
  static String get justNow => _ar ? 'الآن' : 'Just now';
  static String unreadCount(int n) => _ar ? '$n غير مقروء' : '$n unread';
  static String get allCaughtUp =>
      _ar ? 'لا جديد — أنت على اطّلاع ✅' : "You're all caught up ✅";

  // ─────────────── Complete profile / resume registration ───────────────
  static String get completeProfileTitle =>
      _ar ? 'أكمل تسجيل بياناتك' : 'Complete your profile';
  static String get completeProfileDesc => _ar
      ? 'لم تُكمل بياناتك بعد. أكملها لإرسال طلبك إلى الوكيل.'
      : "You haven't finished your details. Complete them to send your request to an agent.";
  static String get completeProfileCta =>
      _ar ? 'إكمال البيانات' : 'Complete now';
  static String get profilePendingTitle =>
      _ar ? 'طلبك قيد المراجعة' : 'Request under review';
  static String get profilePendingDesc => _ar
      ? 'تم إرسال بياناتك. سيصلك إشعار عند قبول الوكيل لك ثم يمكنك طلب الغاز.'
      : 'Your details were sent. You\'ll be notified once an agent approves you, then you can order gas.';

  // ─────────────── Nearest agent ───────────────
  // ─────────────── Connectivity ───────────────
  static String get offlineNotice => _ar
      ? 'غير متصل — تُحفظ تغييراتك وتُرسل عند عودة الاتصال'
      : 'Offline — your changes are saved and will sync when you reconnect';
  static String get syncOffline => _ar ? 'غير متصل' : 'Offline';
  static String get syncSyncing => _ar ? 'جاري المزامنة…' : 'Syncing…';
  static String get syncSynced => _ar ? 'متزامن' : 'Synced';
  static String syncPending(int n) =>
      _ar ? '$n بانتظار المزامنة' : '$n pending sync';
  static String get syncingNotice => _ar
      ? 'عاد الاتصال — جاري مزامنة تغييراتك…'
      : 'Back online — syncing your changes…';

  static String get nearestAgent => _ar ? 'أقرب وكيل لك' : 'Your nearest agent';
  static String get viewOnMap => _ar ? 'عرض على الخريطة' : 'View on map';

  // ─────────────── Admin profile ───────────────
  static String get adminProfileTitle =>
      _ar ? 'بيانات المشرف' : 'Admin profile';
  static String get adminName => _ar ? 'مدير النظام' : 'System Administrator';
  static String get role => _ar ? 'الصلاحية' : 'Role';
  static String get superAdmin => _ar ? 'مشرف عام' : 'Super admin';

  // ─────────────── Location ───────────────
  static String get yourLocation => _ar ? 'موقعك' : 'Your location';
  static String get setLocation =>
      _ar ? 'تحديد الموقع' : 'Set location';
  static String get setLocationOnMap =>
      _ar ? 'حدد موقعك على الخريطة' : 'Set your location on the map';
  static String get useCurrentLocation =>
      _ar ? 'استخدام موقعي الحالي' : 'Use my current location';
  static String get tapMapToSetLocation => _ar
      ? 'اضغط على الخريطة لتحديد موقعك، أو استخدم موقعك الحالي'
      : 'Tap the map to set your location, or use your current location';
  static String get locationSet => _ar ? 'تم تحديد الموقع' : 'Location set';
  static String get confirmLocation =>
      _ar ? 'تأكيد الموقع' : 'Confirm location';
  static String get locationRequired =>
      _ar ? 'يرجى تحديد الموقع' : 'Please set your location';
  static String get locationPermissionDenied => _ar
      ? 'تم رفض إذن الموقع. حدد موقعك على الخريطة يدوياً.'
      : 'Location permission denied. Set your location on the map manually.';
  static String get locationServicesDisabled => _ar
      ? 'خدمة الموقع متوقفة. فعّلها أو حدد موقعك على الخريطة.'
      : 'Location services are off. Enable them or set location on the map.';
  static String get gettingLocation =>
      _ar ? 'جارٍ تحديد موقعك...' : 'Getting your location...';
  static String get myLocation => _ar ? 'موقعي' : 'My location';
}
