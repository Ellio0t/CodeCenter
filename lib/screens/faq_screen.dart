import 'package:flutter/material.dart';
import '../config/app_config.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'question': 'What is the validity of a WinIt Code?',
      'answer': 'WinIt codes have a limited duration and expire after a certain period, usually a few hours from their publication. It\'s important to stay alert to notifications to take advantage of them before they expire.'
    },

    {
      'question': 'How can I know if a WinIt code is valid for my region?',
      'answer': 'Some codes may be specific to certain geographical regions. It\'s important to verify the conditions of each code to ensure it is applicable in your area. However, some codes may be valid for all regions.'
    },
    {
      'question': 'Can I share or transfer my WinIt codes to other people?',
      'answer': 'WinIt codes are usually for personal use and not transferable. Each user should apply the codes to their own account according to the specific terms of use.'
    },
    {
      'question': 'How can I stay updated on new WinIt codes?',
      'answer': 'It\'s important to subscribe to notifications from the service through the website and social media to receive alerts about new WinIt codes as soon as they become available.'
    },
    {
      'question': 'What happens if I incorrectly enter a WinIt code?',
      'answer': 'It\'s crucial to enter the code correctly as codes are case-sensitive. If a code doesn\'t work, verify that you\'ve entered it correctly and that there are no additional spaces at the beginning or end of the code.'
    },
    {
      'question': 'Can I accumulate WinIt codes to use later?',
      'answer': 'Generally, WinIt codes must be applied within the specified validity period. They usually do not accumulate or transfer to later periods.'
    },
    {
      'question': 'What should I do if I\'m not receiving notifications about new WinIt codes?',
      'answer': 'If you\'re not receiving notifications about new WinIt codes, check the notification settings on the website and make sure to follow the service\'s official social media accounts.'
    },
    {
      'question': 'Are there WinIt codes exclusive to subscribers or premium users?',
      'answer': 'Some WinIt codes may be exclusive to subscribers or premium users of the service. It\'s important to review the conditions of each code to determine if there are access restrictions.'
    },
    {
      'question': 'What is the privacy policy regarding the handling of data when subscribing to receive notifications about WinIt codes?',
      'answer': 'It\'s important to know how your personal data is handled and protected when subscribing to receive notifications about WinIt codes. Be sure to review the service\'s privacy policy for more information.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final appName = AppConfig.shared.appName;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Questions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Find answers to common questions about $appName.',
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Map FAQs to Section widgets
            ...faqs.map((faq) => _buildSection(
              context,
              faq['question']!,
              faq['answer']!,
            )),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.2)),
          boxShadow: [
             if (!isDark)
               BoxShadow(
                 color: Colors.black.withOpacity(0.05),
                 blurRadius: 10,
                 offset: const Offset(0, 4),
               ),
          ],
        ),
        child: Theme(
          data: TempThemeData.expansionTileTheme(context), 
          child: ExpansionTile(
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            iconColor: AppConfig.shared.primaryColor,
            collapsedIconColor: isDark ? Colors.white70 : Colors.black54,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape: const Border(), // Remove default dividers
            collapsedShape: const Border(),
            children: [
              Text(
                content,
                style: TextStyle(
                  height: 1.5,
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper to remove divider lines from ExpansionTile in newer Flutter versions without affecting global theme if not set
class TempThemeData {
  static ThemeData expansionTileTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      dividerColor: Colors.transparent,
      listTileTheme: ListTileThemeData(
         dense: true, 
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
