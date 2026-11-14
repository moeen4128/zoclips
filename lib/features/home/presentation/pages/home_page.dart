import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_neutral_colors.dart';
import '../../../../core/widgets/responsive_page.dart';
import '../../../../injection_container.dart';
import '../cubit/videos_cubit.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/one_click_ai_magic_card.dart';
import '../widgets/project_tabs.dart';
import '../widgets/projects_grid.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VideosCubit>()..fetchVideos(),
      child: Scaffold(
        backgroundColor: context.neutrals.background,
        appBar: const HomeAppBar(),
        body: ResponsivePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.maxFormWidth,
                  ),
                  child: const OneClickAiMagicCard(),
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              const ProjectTabs(),
              const SizedBox(height: AppSizes.lg),
              const ProjectsGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
