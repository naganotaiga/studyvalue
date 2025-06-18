/// StudyValue - 警告表示ウィジェット
/// 段階的警告システムによるモチベーション管理

import 'package:flutter/cupertino.dart';
import '../models/user_profile.dart';
import '../models/study_session.dart';
import '../services/warning_system.dart';

class WarningDisplayWidget extends StatelessWidget {
  final UserProfile profile;
  final List<StudySession> sessions;
  
  const WarningDisplayWidget({
    super.key,
    required this.profile,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final warningData = WarningSystem.generateWarningData(profile, sessions);
    final motivationMessage = WarningSystem.generateMotivationMessage(profile, sessions);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getBackgroundColor(warningData.level),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(warningData.level),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                WarningSystem.getWarningIcon(warningData.level),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warningData.message,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(warningData.level),
                      ),
                    ),
                    if (warningData.submessage.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        warningData.submessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: _getTextColor(warningData.level),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          if (warningData.actionAdvice.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '💡 ${warningData.actionAdvice}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.label,
                ),
              ),
            ),
          ],
          
          if (motivationMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              motivationMessage,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: _getTextColor(warningData.level).withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor(WarningLevel level) {
    switch (level) {
      case WarningLevel.none:
        return CupertinoColors.systemGreen.withOpacity(0.1);
      case WarningLevel.level1:
        return CupertinoColors.systemBlue.withOpacity(0.1);
      case WarningLevel.level2:
        return CupertinoColors.systemOrange.withOpacity(0.1);
      case WarningLevel.level3:
        return CupertinoColors.systemRed.withOpacity(0.1);
    }
  }

  Color _getBorderColor(WarningLevel level) {
    switch (level) {
      case WarningLevel.none:
        return CupertinoColors.systemGreen.withOpacity(0.3);
      case WarningLevel.level1:
        return CupertinoColors.systemBlue.withOpacity(0.3);
      case WarningLevel.level2:
        return CupertinoColors.systemOrange.withOpacity(0.3);
      case WarningLevel.level3:
        return CupertinoColors.systemRed.withOpacity(0.3);
    }
  }

  Color _getTextColor(WarningLevel level) {
    switch (level) {
      case WarningLevel.none:
        return CupertinoColors.systemGreen;
      case WarningLevel.level1:
        return CupertinoColors.systemBlue;
      case WarningLevel.level2:
        return CupertinoColors.systemOrange;
      case WarningLevel.level3:
        return CupertinoColors.systemRed;
    }
  }
}