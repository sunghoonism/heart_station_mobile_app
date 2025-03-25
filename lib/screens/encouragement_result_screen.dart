import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/encouragement.dart';
import '../providers/encouragement_provider.dart';
import '../utils/theme.dart';

class EncouragementResultScreen extends StatelessWidget {
  final String encouragementId;

  const EncouragementResultScreen({
    Key? key,
    required this.encouragementId,
  }) : super(key: key);

  // 응원 메시지 공유 기능
  Future<void> _shareEncouragement(BuildContext context, Encouragement encouragement) async {
    final String shareText = '''
[마음 충전소] 응원 메시지

"${encouragement.message}"

- 마음 충전소 앱에서 보낸 응원 -
''';

    try {
      await Share.share(
        shareText,
        subject: '마음 충전소의 응원 메시지를 공유합니다',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('메시지 공유 중 오류가 발생했습니다: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final encouragementProvider = Provider.of<EncouragementProvider>(context);
    final encouragement = encouragementProvider.getEncouragementById(encouragementId);

    if (encouragement == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('응원 메시지'),
        ),
        body: const Center(
          child: Text('해당 응원 메시지를 찾을 수 없습니다.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('응원 메시지'),
        actions: [
          IconButton(
            icon: Icon(
              encouragement.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: encouragement.isFavorite ? AppTheme.primaryColor : null,
            ),
            onPressed: () {
              encouragementProvider.toggleFavorite(encouragement.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareEncouragement(context, encouragement);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사용자 입력 내용
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '나의 이야기',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          encouragement.query,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 응원 메시지 표시
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '마음 충전소의 응원',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.content_copy, size: 20),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: encouragement.message));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('응원 메시지가 클립보드에 복사되었습니다.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // 응원 메시지
                      Text(
                        encouragement.message,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.6,
                            ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 날짜 표시
                      Text(
                        '${encouragement.createdAt.year}년 ${encouragement.createdAt.month}월 ${encouragement.createdAt.day}일',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // 감정 선택 영역
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildEmotionButton(context, '😊', '고마워요'),
                    _buildEmotionButton(context, '😢', '위로가 됐어요'),
                    _buildEmotionButton(context, '😌', '안심이 됐어요'),
                    _buildEmotionButton(context, '🤔', '생각해볼게요'),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // 하단 버튼들
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('돌아가기'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('새로운 이야기 하기'),
                      ),
                    ),
                  ],
                ),
                
                // 공유 버튼 추가
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('이 응원 메시지 공유하기'),
                    onPressed: () {
                      _shareEncouragement(context, encouragement);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 감정 표현 버튼 위젯
  Widget _buildEmotionButton(BuildContext context, String emoji, String label) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('\'$label\' 감정이 기록되었습니다.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            elevation: 2,
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
} 