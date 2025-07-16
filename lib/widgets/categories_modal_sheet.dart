// lib/widgets/categories_modal_sheet.dart
import 'package:flutter/material.dart';
import 'package:utilimate/utils/app_constants.dart';

class CategoriesModalSheet extends StatelessWidget {
  const CategoriesModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Use a fixed height or a fraction of screen height for the modal sheet.
      // This is crucial for the Column inside to have bounded height.
      height:
          MediaQuery.of(context).size.height *
          0.75, // Increased from 0.7 to 0.75
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Removed mainAxisSize: MainAxisSize.min
        // The container's fixed height will constrain the column.
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withAlpha((0.3 * 255).round()),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Text(
            'Tool Categories',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            // Expanded ensures GridView takes remaining space in the Column
            child: GridView.builder(
              // shrinkWrap: true, // Removed shrinkWrap as Expanded handles scrolling and sizing
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio:
                    0.85, // Adjusted aspect ratio for better fit (increased vertical space)
              ),
              itemCount: AppConstants.toolCategories.length,
              itemBuilder: (context, index) {
                final category = AppConstants.toolCategories[index];
                return Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.0),
                    onTap: () {
                      Navigator.pop(context); // Close the modal sheet
                      // Navigate to the selected category screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => category.screen,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            category.icon,
                            size: 36,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines:
                                2, // Allow up to 2 lines for category names
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
