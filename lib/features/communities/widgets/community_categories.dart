import 'package:flutter/material.dart';
import 'package:project_x/core/theme/color_palette.dart';
import 'package:project_x/core/theme/text_styles.dart';

class CommunityCategories extends StatelessWidget {
  const CommunityCategories({super.key});

  static const List<Map<String, dynamic>> categories = [
    {'name': 'Technology', 'icon': Icons.computer, 'color': AppColors.blue},
    {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.green},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.purple},
    {'name': 'News', 'icon': Icons.article, 'color': Colors.orange},
    {'name': 'Gaming', 'icon': Icons.games, 'color': Colors.red},
    {'name': 'Business', 'icon': Icons.business, 'color': Colors.indigo},
    {'name': 'Science', 'icon': Icons.science, 'color': Colors.teal},
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.amber},
    {'name': 'Health', 'icon': Icons.health_and_safety, 'color': Colors.pink},
    {'name': 'Art', 'icon': Icons.palette, 'color': Colors.deepPurple},
    {'name': 'Music', 'icon': Icons.music_note, 'color': Colors.cyan},
    {'name': 'Travel', 'icon': Icons.flight, 'color': Colors.lightBlue},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140, // Reduced height to make the overall grid smaller
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0, // Adjusted to make items more compact
          crossAxisSpacing: 6, // Reduced spacing
          mainAxisSpacing: 6, // Reduced spacing
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryItem(
            context,
            category['name'],
            category['icon'],
            category['color'],
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String name,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        // TODO: Filter communities by category
        print('Selected category: $name');
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8), // Reduced padding
        decoration: BoxDecoration(
          color: AppColors.surfaceColor1,
          borderRadius: BorderRadius.circular(10), // Slightly smaller radius
          border: Border.all(color: AppColors.borderColor1, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(
                6,
              ), // Reduced padding for icon container
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 12), // Reduced icon size
            ),
            const SizedBox(height: 6), // Reduced spacing
            Text(
              name,
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
                fontSize: 8, // Reduced font size
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
