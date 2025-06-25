import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EducationScreen extends ConsumerWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Education'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Village Foundations',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete these modules to unlock trading features',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _EducationModule(
                    title: 'Financial Literacy Basics',
                    description: 'Learn the fundamentals of personal finance',
                    progress: 0.0,
                    isLocked: false,
                  ),
                  _EducationModule(
                    title: 'Understanding Risk',
                    description: 'Learn about investment risk and reward',
                    progress: 0.0,
                    isLocked: true,
                  ),
                  _EducationModule(
                    title: 'Portfolio Basics',
                    description: 'Introduction to diversification',
                    progress: 0.0,
                    isLocked: true,
                  ),
                  _EducationModule(
                    title: 'Cryptocurrency 101',
                    description: 'Understanding digital assets',
                    progress: 0.0,
                    isLocked: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EducationModule extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final bool isLocked;

  const _EducationModule({
    required this.title,
    required this.description,
    required this.progress,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLocked ? Colors.grey.shade400 : const Color(0xFFD4AF37),
          child: Icon(
            isLocked ? Icons.lock : Icons.school,
            color: isLocked ? Colors.grey.shade600 : Colors.white,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isLocked ? Colors.grey.shade600 : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(
                color: isLocked ? Colors.grey.shade500 : null,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isLocked ? Colors.grey.shade400 : const Color(0xFF059669),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isLocked ? Colors.grey.shade400 : null,
        ),
        onTap: isLocked ? null : () {
          // TODO: Navigate to module content
        },
      ),
    );
  }
}