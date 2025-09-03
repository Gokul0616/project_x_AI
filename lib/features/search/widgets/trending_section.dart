import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';
import 'package:project_x/core/providers/theme_provider.dart';

class TrendingSection extends StatelessWidget {
  const TrendingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor(isDark), width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'What\'s happening',
                    style: TextStyles.titleMedium,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: AppColors.textSecondary(isDark),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTrendItem(
                'Trending in Technology',
                '#FlutterDev',
                '52.4K Tweets',
                isDark,
              ),
              _buildTrendItem(
                'Trending',
                '#OpenAI',
                '89.2K Tweets',
                isDark,
              ),
              _buildTrendItem(
                'Sports · Trending',
                '#SuperBowl',
                '156K Tweets',
                isDark,
              ),
              _buildTrendItem(
                'Technology · Trending',
                '#JavaScript',
                '34.7K Tweets',
                isDark,
              ),
              _buildTrendItem(
                'Entertainment · Trending',
                '#Netflix',
                '67.1K Tweets',
                isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendItem(String category, String topic, String count, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: TextStyles.caption.copyWith(
              color: AppColors.textSecondary(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            topic,
            style: TextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyles.caption.copyWith(
              color: AppColors.textSecondary(isDark),
            ),
          ),
        ],
      ),
    );
  }
}