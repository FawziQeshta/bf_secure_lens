import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_colors.dart';
import '../../cubits/advisory/advisory_cubit.dart';
import '../../cubits/advisory/advisory_state.dart';
import 'widgets/guideline_card_widget.dart';

class AdvisoryScreen extends StatefulWidget {
  const AdvisoryScreen({super.key});

  @override
  State<AdvisoryScreen> createState() => _AdvisoryScreenState();
}

class _AdvisoryScreenState extends State<AdvisoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdvisoryCubit>().loadHardeningGuides();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandSecondary = AppColors.brandSecondary(isDark);

    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: brandSecondary, size: 28.sp),
              SizedBox(width: 12.w),
              Text(
                'advisory_title'.tr(),
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'advisory_subtitle'.tr(),
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: BlocBuilder<AdvisoryCubit, AdvisoryState>(
              builder: (context, state) {
                if (state is AdvisoryLoadedState) {
                  return ListView.builder(
                    itemCount: state.guides.length,
                    itemBuilder: (context, index) {
                      return GuidelineCardWidget(guide: state.guides[index]);
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
