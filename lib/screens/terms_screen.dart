import 'package:flutter/material.dart';
import '../config/app_config.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appName = AppConfig.shared.appName;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions for $appName',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last updated: February 01, 2026',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Acceptance of Terms',
              'By accessing and using $appName, you accept and agree to be bound by the terms and provision of this agreement. In addition, when using this app\'s particular services, you shall be subject to any posted guidelines or rules applicable to such services.',
            ),
            _buildSection(
              context,
              '2. Provision of Services',
              'You agree and acknowledge that $appName is entitled to modify, improve or discontinue any of its services at its sole discretion and without notice to you even if it may result in you being prevented from accessing any information contained in it.',
            ),
            _buildSection(
              context,
              '3. Proprietary Rights',
              'You acknowledge and agree that $appName may contain proprietary and confidential information including trademarks, service marks and patents protected by intellectual property laws and international intellectual property treaties. $appName authorizes you to view and make a single copy of portions of its content for offline, personal, non-commercial use. Our content may not be sold, reproduced, or distributed without our written permission.',
            ),
            _buildSection(
              context,
              '4. Submitted Content',
              'When you submit content to $appName you simultaneously grant $appName an irrevocable, worldwide, royalty free license to publish, display, modify, distribute and syndicate your content worldwide.',
            ),
            _buildSection(
              context,
              '5. Termination of Agreement',
              'The Terms of this agreement will continue to apply in perpetuity until terminated by either party without notice at any time for any reason. Terms that are to continue in perpetuity shall be unaffected by the termination of this agreement.',
            ),
            _buildSection(
              context,
              '6. Disclaimer of Warranties',
              'You understand and agree that your use of $appName is entirely at your own risk and that our services are provided "As Is" and "As Available". $appName does not make any express or implied warranties, endorsements or representations whatsoever as to the operation of the $appName website, information, content, materials, or products.',
            ),
            _buildSection(
              context,
              '7. Jurisdiction',
              'You expressly understand and agree to submit to the personal and exclusive jurisdiction of the courts of the country, state, province or territory determined solely by $appName to resolve any legal matter arising from this agreement.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
