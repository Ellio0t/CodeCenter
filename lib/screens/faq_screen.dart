import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../widgets/header_actions.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            title: 'FAQs',
            actions: buildHeaderActions(context),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: faqs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildFaqCard(context, faqs[index], isDarkMode);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard(BuildContext context, Map<String, String> faq, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
        border: isDarkMode ? Border.all(color: Colors.white10) : null,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: isDarkMode ? Colors.white : Colors.black87,
          collapsedIconColor: isDarkMode ? Colors.white70 : Colors.black54,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Text(
            faq['question']!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDarkMode ? Colors.white : const Color(0xFF2D3436),
            ),
          ),
          children: [
            Text(
              faq['answer']!,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDarkMode ? Colors.grey[300] : const Color(0xFF636E72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
