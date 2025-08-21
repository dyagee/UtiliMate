// lib/screens/categories_modal_sheet.dart
import 'package:flutter/material.dart';
import 'package:utilimate/utils/app_constants.dart';

class CategoriesModalSheet extends StatelessWidget {
  const CategoriesModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                // FIX: Changed ListView.builder to GridView.builder
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // At least 3 cards per row
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio:
                        1.0, // Adjust as needed to make cards square or rectangular
                  ),
                  itemCount: AppConstants.toolCategories.length,
                  itemBuilder: (context, index) {
                    final category = AppConstants.toolCategories[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context); // Pop the modal sheet first
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: category.screenBuilder),
                          );
                        },
                        child: Column(
                          // Arrange icon and text vertically for grid item
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category.icon,
                              size: 36,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Flexible(
                              // Use Flexible to prevent text overflow
                              child: Text(
                                category.name,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelLarge,
                                overflow:
                                    TextOverflow.ellipsis, // Handle long names
                                maxLines: 2, // Allow up to 2 lines for names
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
