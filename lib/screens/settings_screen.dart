import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/encouragement_provider.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  final String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.ant_revolution.heart_station';
  final String appStoreUrl = 'https://apps.apple.com/미구현입니다';

  // 알림 설정 대화상자
  Future<void> _showNotificationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림 설정'),
        content: const Text('알림 기능은 아주 천천히 개발 중입니다.\n(유료기능)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 데이터 초기화 대화상자
  Future<void> _showClearDataDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 초기화'),
        content: const Text('모든 응원 메시지가 삭제됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('초기화', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      // 사용자가 초기화를 선택한 경우
      Provider.of<EncouragementProvider>(context, listen: false).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모든 데이터가 초기화되었습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showAboutDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.favorite, color: Colors.white),
        ),
        Container(
          width: 16,
        ),
        Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('마음 충전소', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('버전: 1.0.0', style: TextStyle(fontSize: 16)),
        ],
      ),]
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Text('당신의 이야기에 엉뚱하지만 진심 담은 응원을 보내는 앱입니다.'),
          SizedBox(height: 8),
          Text('© 2025 마음 충전소'),
          const SizedBox(height: 24),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final Uri url = Uri.parse('https://abalone-rhythm-dc2.notion.site/1c0b648474ed80b0b974f2027fc97947?pvs=4');
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            },
            child: const Text(
              '개인정보 처리방침',
              style: TextStyle(
                color: AppTheme.primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _showDevInfoDialog(context);
          },
          child: const Text('개발 정보'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    ),
  );
}

  // 앱 정보 대화상자
  Future<void> _showDevInfoDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('개발 정보', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          SizedBox(height: 16),
          Text('Product Design', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Google AI Studio'),
          SizedBox(height: 8),
          Text('Development', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Sonnet'),
          SizedBox(height: 8),
          Text('Language model', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Gemma'),
          SizedBox(height: 8),
          Text('API Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Grok'),
          SizedBox(height: 8),
          Text('Powered by', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Ant Revolution')
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    ));
  }

  // 앱 공유하기
  Future<void> _shareApp(BuildContext context) async {
    const String appName = '마음 충전소';
    const String appDesc = '당신의 이야기에 엉뚱하지만 진심 담은 응원을 보내는 앱';
    
    final String shareText = '''
$appName - $appDesc

Android: $playStoreUrl
iOS: $appStoreUrl

친구에게 응원의 메시지를 선물하세요! 💖
''';

    try {
      await Share.share(
        shareText,
        subject: '$appName 앱을 공유합니다',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('앱 공유 중 오류가 발생했습니다: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // 일반 설정 섹션
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
            child: Text(
              '일반 설정',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // 알림 설정
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text('알림 설정'),
            subtitle: const Text('응원 알림 및 기타 알림 설정'),
            onTap: () => _showNotificationDialog(context),
          ),
          
          const Divider(),
          
          // 데이터 관리 섹션
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
            child: Text(
              '데이터 관리',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // 데이터 초기화
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('데이터 초기화'),
            subtitle: const Text('모든 응원 메시지를 삭제합니다'),
            onTap: () => _showClearDataDialog(context),
          ),
          
          const Divider(),
          
          // 정보 섹션
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
            child: Text(
              '정보',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // 앱 정보
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('앱 정보'),
            subtitle: const Text('버전, 개발자 정보, 이용약관 등'),
            onTap: () => _showAboutDialog(context),
          ),
          
          // 평가하기
          ListTile(
            leading: const Icon(Icons.star_border),
            title: const Text('앱 평가하기'),
            subtitle: const Text('마음 충전소를 평가해 주세요'),
            onTap: () async {
              final Uri url = Uri.parse(playStoreUrl);
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            },
          ),
          
          // 공유하기
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('앱 공유하기'),
            subtitle: const Text('친구들에게 마음 충전소를 추천해 주세요'),
            onTap: () => _shareApp(context),
          ),
        ],
      ),
    );
  }
} 