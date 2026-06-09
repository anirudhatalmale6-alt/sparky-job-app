import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gas_man_app/pages/market_place/all_tabs/login_page.dart';
import 'package:the_gas_man_app/pages/market_place/market_place_home_page.dart';
import 'package:the_gas_man_app/pages/new_calender/role_permissions.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/auth/invoice_login_screen.dart';
import 'package:the_gas_man_app/pages/settings/engineer_settings_page.dart';
import 'package:the_gas_man_app/pages/tools/gas_rate_page.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/app_model.dart';
import '../main.dart';
import '../services/dashboard_service.dart';
import '../utils_class/money.dart';
import 'find_merchants_page.dart';
import 'new_calender/calender_dashboard_page.dart';
import 'new_calender/upcoming_jobs_screen.dart';
import 'new_certificate/certificate_home_page.dart';
import 'new_invoice_page/pages/account_home_page.dart';
import 'new_tax_and_invoice/api_service/auth_token_store.dart';
import 'new_tax_and_invoice/invoice_and_tax_main_screen.dart';
import 'radiator/radiator_calculator_page.dart';
import 'termsandcondition/terms_and_condition_page.dart';
import 'tools/latest_pipe_sizing_code.dart';
import 'tools/ventilation_page_new.dart';

class SparkyDashboardPage extends StatefulWidget {
  const SparkyDashboardPage({super.key});

  @override
  State<SparkyDashboardPage> createState() => _SparkyDashboardPageState();
}

class _SparkyDashboardPageState extends State<SparkyDashboardPage> {
  final DashboardService _dashSvc = DashboardService();
  Map<String, dynamic>? _summary;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final token = await AuthTokenStore.read();
      if (token != null && token.isNotEmpty) {
        final data = await _dashSvc.getSummary();
        if (mounted) setState(() => _summary = data);
      }
    } catch (_) {}
    if (mounted) setState(() => _statsLoading = false);
  }

  String _statValue(String key) {
    if (_summary == null) return "-";
    final v = _summary![key];
    if (v == null) return "0";
    if (v is num) return v.toStringAsFixed(0);
    return v.toString();
  }

  int _invoiceStat(String key) {
    final inv = _summary?["invoices"];
    if (inv == null) return 0;
    return int.tryParse(inv[key]?.toString() ?? "0") ?? 0;
  }

  void _go(Widget page) =>
      Navigator.push(context, CupertinoPageRoute(builder: (_) => page));

  void _goJobManagement(AppModel app) {
    if (!app.isLoggedIn!) {
      _go(const InvoiceLoginScreen(fromScreen: "calender"));
    } else if (RolePermissions.canAccessJobs(userRole!)) {
      _go(const CalenderDashboardPage());
    } else {
      _showBlocked("You can't access Job Management System");
    }
  }

  void _goAccounting(AppModel app) {
    if (!app.isLoggedIn!) {
      _go(InvoiceLoginScreen());
    } else if (RolePermissions.canAccessAccounting(userRole!)) {
      _go(const InvoiceAndTaxMainScreen());
    } else {
      _showBlocked("You can't access Tax and Accounting system");
    }
  }

  void _showBlocked(String msg) {
    ScaffoldMessenger.of(mainKey!.currentContext!).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();

    return Scaffold(
      backgroundColor: const Color(0xfff0f2f8),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildBanner(app),
                Transform.translate(
                  offset: const Offset(0, -42),
                  child: Column(
                    children: [
                      _buildStatsCard(),
                      const SizedBox(height: 18),
                      _buildUpcomingBar(app),
                      const SizedBox(height: 22),
                      _buildQuickAccessHeader(),
                      const SizedBox(height: 16),
                      _buildQuickAccessGrid(app),
                      const SizedBox(height: 14),
                      _buildSponsorCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(AppModel app) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xff0f1b4c),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Image.asset(
                'assets/images/sparky_job_banner.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: const Color(0xff0f1b4c),
                  child: const Center(
                    child: Text(
                      'sparky job',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 16,
          child: SafeArea(
            bottom: false,
            child: GestureDetector(
              onTap: () {
                if (!app.isLoggedIn!) {
                  _go(const InvoiceLoginScreen(fromScreen: "calender"));
                } else {
                  _go(const UpcomingJobsScreen());
                }
              },
              child: const SizedBox(height: 50, width: 50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    final overdueCount = _invoiceStat("overdue_count").toString();
    final income = _summary?["thisMonth"]?["salesGross"];
    final incomeStr =
        income != null ? formatMoney(double.tryParse(income.toString()) ?? 0) : "-";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _statsLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          : Row(
              children: [
                _buildStatItem(
                  icon: Icons.calendar_today,
                  iconColor: const Color(0xff12c89a),
                  bgColor: const Color(0xffe8fff8),
                  value: _statValue("accountsReceivable") != "0"
                      ? _invoiceStat("total_invoices").toString()
                      : "0",
                  label: 'Upcoming\nJobs',
                ),
                _buildDivider(),
                _buildStatItem(
                  icon: Icons.description_outlined,
                  iconColor: const Color(0xffff6a00),
                  bgColor: const Color(0xfffff0e5),
                  value: overdueCount,
                  label: 'Invoices\nOverdue',
                ),
                _buildDivider(),
                _buildStatItem(
                  icon: Icons.currency_pound,
                  iconColor: const Color(0xff8a4eea),
                  bgColor: const Color(0xfff1eaff),
                  value: incomeStr,
                  label: 'This Month\nIncome',
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xff050a1f),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xff101628),
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 60,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: const Color(0xffe1e5ec),
    );
  }

  Widget _buildUpcomingBar(AppModel app) {
    return GestureDetector(
      onTap: () {
        if (!app.isLoggedIn!) {
          _go(const InvoiceLoginScreen(fromScreen: "calender"));
        } else {
          _go(const UpcomingJobsScreen());
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xff0f1b4c),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.calendar_today, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            const Text(
              'Upcoming\nappointments',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  color: Color(0xff0f1b4c),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Quick Access',
            style: TextStyle(
              color: Color(0xff050a1f),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid(AppModel app) {
    final items = [
      _QuickItem(
        title: 'Accounts\n& Tax',
        subtitle: 'Invoices, expenses\n& tax tools',
        icon: Icons.receipt_long,
        iconColor: const Color(0xff13bd72),
        bgColor: const Color(0xffeafff9),
        buttonColor: const Color(0xff12bd72),
        onTap: () => _goAccounting(app),
      ),
      _QuickItem(
        title: 'Electrical\nCertificates',
        subtitle: 'Electrical safety\ncertificates',
        icon: Icons.verified_user_outlined,
        iconColor: const Color(0xffff7300),
        bgColor: const Color(0xfffff1e8),
        buttonColor: const Color(0xffff7300),
        onTap: () => _go(const CertificatesHomePage()),
      ),
      _QuickItem(
        title: 'Jobs, Schedule\n& Team Chat',
        subtitle: 'Jobs, schedule\n& team chat',
        icon: Icons.calendar_month,
        iconColor: const Color(0xff006dff),
        bgColor: const Color(0xffedf6ff),
        buttonColor: const Color(0xff006dff),
        onTap: () => _goJobManagement(app),
      ),
      _QuickItem(
        title: 'Marketplace',
        subtitle: 'Buy & sell\nno fees',
        icon: Icons.shopping_cart_outlined,
        iconColor: const Color(0xff8438df),
        bgColor: const Color(0xfff6edff),
        buttonColor: const Color(0xff8438df),
        onTap: () => _go(
          !app.isMarketPlaceUserLoggedIn!
              ? LoginPage()
              : const MarketplaceHomePage(),
        ),
      ),
      _QuickItem(
        title: 'Jobs\nCorner',
        subtitle: 'Find or post\nelectrical work',
        icon: Icons.work_outline,
        iconColor: const Color(0xffe91e63),
        bgColor: const Color(0xfffce4ec),
        buttonColor: const Color(0xffe91e63),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Jobs Corner - Coming soon!")),
          );
        },
      ),
      _QuickItem(
        title: 'Gas Rate\nCalculator',
        subtitle: 'Gas rate\ncalculator',
        icon: Icons.speed_outlined,
        iconColor: const Color(0xff00c5c9),
        bgColor: const Color(0xffe8ffff),
        buttonColor: const Color(0xff00bfc2),
        onTap: () => _go(const GasRatePage()),
      ),
      _QuickItem(
        title: 'Pipe Sizing',
        subtitle: 'Pipe sizing\ncalculator',
        icon: Icons.architecture_outlined,
        iconColor: const Color(0xff16a8f7),
        bgColor: const Color(0xffeefaff),
        buttonColor: const Color(0xff1d9bf0),
        onTap: () => _go(const LatestGasPipeSizingPage()),
      ),
      _QuickItem(
        title: 'Ventilation',
        subtitle: 'Ventilation\ncalculator',
        icon: Icons.air_outlined,
        iconColor: const Color(0xff10bd72),
        bgColor: const Color(0xffedfff3),
        buttonColor: const Color(0xff10bd4f),
        onTap: () => _go(const VentilationCalculatorPage()),
      ),
      _QuickItem(
        title: 'Radiator\nCalculator',
        subtitle: 'Heat output\ncalculator',
        icon: Icons.calculate_outlined,
        iconColor: const Color(0xffff3d6e),
        bgColor: const Color(0xffffeef2),
        buttonColor: const Color(0xffff3d6e),
        onTap: () => _go(const RadiatorCalculatorPage()),
      ),
      _QuickItem(
        title: 'Find\nMerchants',
        subtitle: 'Local merchant\nfinder',
        icon: Icons.store_mall_directory_outlined,
        iconColor: const Color(0xff0097a7),
        bgColor: const Color(0xffe0f7fa),
        buttonColor: const Color(0xff0097a7),
        onTap: () => _go(const FindMerchantsPage()),
      ),
      _QuickItem(
        title: 'Company\nInfo',
        subtitle: 'Business\nsettings',
        icon: Icons.settings_outlined,
        iconColor: const Color(0xff607d8b),
        bgColor: const Color(0xffeceff1),
        buttonColor: const Color(0xff607d8b),
        onTap: () => _go(
          !app.isLoggedIn!
              ? const InvoiceLoginScreen(fromScreen: "company")
              : const CompanyInformationPage(shouldShowAppBar: true),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.55,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: item.onTap,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 14, 10, 12),
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 30),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Color(0xff050a1f),
                            fontSize: 15,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            color: Color(0xff182034),
                            fontSize: 12,
                            height: 1.25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: item.buttonColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSponsorCard() {
    return GestureDetector(
      onTap: () async {
        await launchUrl(Uri.parse("https://embrasspeerless.co.uk/"));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 18),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff0f1b4c), Color(0xff1a237e)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'Sponsored by Embrass Peerless',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color buttonColor;
  final VoidCallback onTap;

  _QuickItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.buttonColor,
    required this.onTap,
  });
}
