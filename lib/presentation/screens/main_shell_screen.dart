import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_colors.dart';
import '../cubits/theme/theme_cubit.dart';
import 'dashboard/dashboard_screen.dart';
import 'issues/issues_screen.dart';
import 'advisory/advisory_screen.dart';
import 'about/about_screen.dart';
import 'contact/contact_screen.dart';
import 'privacy/privacy_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;
  final TextEditingController _pathController = TextEditingController(text: Directory.current.path);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';
    final brandPrimary = AppColors.brandPrimary(isDark);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: isDark ? AppColors.darkSidebarBackground : AppColors.lightSidebarBackground,
            indicatorColor: brandPrimary.withValues(alpha: 0.15),
            extended: true,
            minExtendedWidth: 240.w,
            leading: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/icon_app.png',
                        width: 32.w,
                        height: 32.h,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.shield, color: brandPrimary, size: 32.sp),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'secure_lens'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 16.sp,
                          color: brandPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Theme & Language Bar Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Theme Toggle Button
                      IconButton(
                        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 20.sp, color: brandPrimary),
                        tooltip: isDark ? 'light_mode'.tr() : 'dark_mode'.tr(),
                        onPressed: () {
                          context.read<ThemeCubit>().toggleTheme();
                        },
                      ),
                      // Language Switcher Dropdown
                      DropdownButton<String>(
                        value: isArabic ? 'ar' : 'en',
                        underline: const SizedBox(),
                        style: TextStyle(color: brandPrimary, fontWeight: FontWeight.bold, fontSize: 13.sp),
                        items: const [
                          DropdownMenuItem(value: 'en', child: Text('EN')),
                          DropdownMenuItem(value: 'ar', child: Text('العربية')),
                        ],
                        onChanged: (lang) {
                          if (lang != null) {
                            context.setLocale(Locale(lang));
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: brandPrimary),
                label: Text('dashboard_tab'.tr()),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.bug_report_outlined),
                selectedIcon: Icon(Icons.bug_report, color: brandPrimary),
                label: Text('issues_tab'.tr()),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.lightbulb_outline),
                selectedIcon: Icon(Icons.lightbulb, color: brandPrimary),
                label: Text('advisory_tab'.tr()),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.info_outline),
                selectedIcon: Icon(Icons.info, color: brandPrimary),
                label: Text('about_tab'.tr()),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.contact_support_outlined),
                selectedIcon: Icon(Icons.contact_support, color: brandPrimary),
                label: Text('contact_tab'.tr()),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.privacy_tip_outlined),
                selectedIcon: Icon(Icons.privacy_tip, color: brandPrimary),
                label: Text('privacy_tab'.tr()),
              ),
            ],
          ),
          VerticalDivider(thickness: 1.w, width: 1.w, color: Theme.of(context).dividerColor),
          // Main Body Screen Stack
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                DashboardScreen(pathController: _pathController),
                const IssuesScreen(),
                const AdvisoryScreen(),
                const AboutScreen(),
                const ContactScreen(),
                const PrivacyScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
