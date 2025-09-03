import 'package:flutter/material.dart';
import 'package:project_x/core/constants/app_constants.dart';
import 'package:project_x/core/constants/asset_constants.dart';

class AuthSidePanel extends StatelessWidget {
  final String title;
  final String description;
  
  const AuthSidePanel({
    super.key,
    required this.title,
    required this.description,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(AppConstants.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Image.asset(
            AssetConstants.logoWhite,
            width: 48,
            height: 48,
          ),
          
          const Spacer(),
          
          // Content
          Text(
            title,
            style: theme.textTheme.displayLarge?.copyWith(fontSize: 32),
          ),
          
          const SizedBox(height: AppConstants.paddingM),
          
          Text(
            description,
            style: theme.textTheme.bodyLarge,
          ),
          
          const Spacer(),
          
          // Footer with terms
          Text(
            'By signing up, you agree to our Terms, Privacy Policy, and Cookie Use.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}