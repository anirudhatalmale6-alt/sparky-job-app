import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gas_man_app/pages/market_place/all_tabs/login_page.dart';
import 'package:the_gas_man_app/pages/market_place/market_place_home_page.dart';
import 'package:the_gas_man_app/pages/new_calender/role_permissions.dart';
import 'package:the_gas_man_app/pages/new_tax_and_invoice/pages/auth/invoice_login_screen.dart';
import 'package:the_gas_man_app/utils_class/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/app_model.dart';
import '../main.dart';
import 'new_calender/calender_dashboard_page.dart';
import 'new_calender/upcoming_jobs_screen.dart';
import 'new_certificate/certificate_home_page.dart';
import 'new_tax_and_invoice/api_service/auth_token_store.dart';
import 'new_tax_and_invoice/invoice_and_tax_main_screen.dart';
import 'termsandcondition/terms_and_condition_page.dart';

class SparkyDashboardPage extends StatelessWidget {
  const SparkyDashboardPage({super.key});

  void _go(BuildContext context, Widget page) =>
      Navigator.push(context, CupertinoPageRoute(builder: (_) => page));

  void _goJobManagement(BuildContext context, AppModel app) {
    if (!app.isLoggedIn!) {
      _go(context, const InvoiceLoginScreen(fromScreen: "calender"));
    } else if (RolePermissions.canAccessJobs(userRole!)) {
      _go(context, const CalenderDashboardPage());
    } else {
      _showBlocked("You can't access Job Management System");
    }
  }

  void _goAccounting(BuildContext context, AppModel app) {
    if (!app.isLoggedIn!) {
      _go(context, InvoiceLoginScreen());
    } else if (RolePermissions.canAccessAccounting(userRole!)) {
      _go(context, const InvoiceAndTaxMainScreen());
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildBanner(context, app),
              const SizedBox(height: 12),
              _buildUpcomingBar(context, app),
              const SizedBox(height: 16),
              _buildGrid(context, app),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, AppModel app) {
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
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
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
        ),
        Positioned(
          top: 0,
          right: 16,
          child: SafeArea(
            bottom: false,
            child: GestureDetector(
              onTap: () {
                if (!app.isLoggedIn!) {
                  _go(context, const InvoiceLoginScreen(fromScreen: "calender"));
                } else {
                  _go(context, const UpcomingJobsScreen());
                }
              },
              child: const SizedBox(height: 50, width: 50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingBar(BuildContext context, AppModel app) {
    return GestureDetector(
      onTap: () {
        if (!app.isLoggedIn!) {
          _go(context, const InvoiceLoginScreen(fromScreen: "calender"));
        } else {
          _go(context, const UpcomingJobsScreen());
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
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

  Widget _buildGrid(BuildContext context, AppModel app) {
    final items = [
      _GridItem(
        title: 'Accounts &\nTax',
        icon: Icons.currency_pound,
        iconBgColor: Colors.white,
        iconColor: const Color(0xff1a8d5f),
        titleColor: const Color(0xff1a8d5f),
        bgColor: const Color(0xffe8f5ee),
        arrowColor: const Color(0xff1a8d5f),
        onTap: () => _goAccounting(context, app),
      ),
      _GridItem(
        title: 'Job\nManagement',
        icon: Icons.calendar_month,
        iconBgColor: Colors.white,
        iconColor: const Color(0xff2563eb),
        titleColor: const Color(0xff2563eb),
        bgColor: const Color(0xffe8eeff),
        arrowColor: const Color(0xff2563eb),
        onTap: () => _goJobManagement(context, app),
      ),
      _GridItem(
        title: 'Electrical\nCertificates',
        icon: Icons.verified_user_outlined,
        iconBgColor: Colors.white,
        iconColor: const Color(0xffef6c00),
        titleColor: const Color(0xffef6c00),
        bgColor: const Color(0xfffff0e5),
        arrowColor: const Color(0xffef6c00),
        onTap: () => _go(context, const CertificatesHomePage()),
      ),
      _GridItem(
        title: 'Marketplace',
        icon: Icons.shopping_cart_outlined,
        iconBgColor: Colors.white,
        iconColor: const Color(0xff0d7377),
        titleColor: const Color(0xff0d7377),
        bgColor: const Color(0xffe0f2f1),
        arrowColor: const Color(0xff0d7377),
        onTap: () => _go(
          context,
          !app.isMarketPlaceUserLoggedIn!
              ? LoginPage()
              : const MarketplaceHomePage(),
        ),
      ),
      _GridItem(
        title: 'Terms &\nConditions',
        icon: Icons.description_outlined,
        iconBgColor: Colors.white,
        iconColor: const Color(0xff6a1b9a),
        titleColor: const Color(0xff6a1b9a),
        bgColor: const Color(0xfff3e8ff),
        arrowColor: const Color(0xff6a1b9a),
        hasContactUs: true,
        onTap: () => _go(context, const TermsAndConditions()),
      ),
      _GridItem(
        title: 'Jobs\nCorner',
        icon: Icons.work_outline,
        iconBgColor: Colors.white,
        iconColor: const Color(0xffe91e63),
        titleColor: const Color(0xffe91e63),
        bgColor: const Color(0xfffce4ec),
        arrowColor: const Color(0xffe91e63),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Jobs Corner - Coming soon!")),
          );
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: item.onTap,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: item.iconBgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: item.titleColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  if (item.hasContactUs) ...[
                    const SizedBox(height: 6),
                    const Divider(height: 1, color: Color(0xffd1c4e9)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.headset_mic, size: 14, color: item.titleColor),
                        const SizedBox(width: 4),
                        Text(
                          'Contact Us',
                          style: TextStyle(
                            color: item.titleColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: item.arrowColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 18,
                      ),
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
}

class _GridItem {
  final String title;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Color titleColor;
  final Color bgColor;
  final Color arrowColor;
  final bool hasContactUs;
  final VoidCallback onTap;

  _GridItem({
    required this.title,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.titleColor,
    required this.bgColor,
    required this.arrowColor,
    this.hasContactUs = false,
    required this.onTap,
  });
}
