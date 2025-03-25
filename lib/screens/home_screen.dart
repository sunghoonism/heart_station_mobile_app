import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/encouragement_provider.dart';
import '../utils/theme.dart';
import '../utils/llm_service.dart';
import 'encouragement_result_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // 응원 메시지 생성 기능
  Future<void> _generateEncouragement() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      // 입력이 비어있으면 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('마음을 나누고 싶은 이야기를 입력해주세요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String encouragementMessage = '';
    bool useLocalMessage = false;

    try {
      // LLM API를 통해 응원 메시지 생성
      encouragementMessage = await LLMService.generateEncouragement(text);
      
      // API 응답이 '응원 메시지 생성' 등의 오류 문구를 포함하는 경우 
      // 또는 한글이 깨진 경우 (특정 패턴으로 깨진 텍스트 감지)
      if (encouragementMessage.contains('응원 메시지를 생성') || 
          encouragementMessage.contains('인증에 문제') ||
          encouragementMessage.contains('서비스에 일시적인 문제') ||
          encouragementMessage.contains('네트워크 연결에 문제') ||
          _isKoreanTextCorrupted(encouragementMessage)) {
        
        useLocalMessage = true;
        // 백업 메시지 사용
        encouragementMessage = LLMService.generateLocalEncouragement(text);
      }
      
      final encouragementProvider = Provider.of<EncouragementProvider>(context, listen: false);
      
      // 새 응원 메시지 저장
      final encouragement = await encouragementProvider.createEncouragement(
        text,
        encouragementMessage,
      );

      // 결과 화면으로 이동
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EncouragementResultScreen(
              encouragementId: encouragement.id,
            ),
          ),
        );
        
        // API 결과가 아닌 로컬 메시지를 사용한 경우 알림
        if (useLocalMessage && mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('온라인 응원 서비스 연결에 문제가 있어 로컬 메시지를 표시합니다.'),
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          });
        }
      }
    } catch (e) {
      print('응원 메시지 생성 오류: $e');
      
      // 오류 발생 시 로컬 백업 메시지 사용
      try {
        encouragementMessage = LLMService.generateLocalEncouragement(text);
        
        final encouragementProvider = Provider.of<EncouragementProvider>(context, listen: false);
        final encouragement = await encouragementProvider.createEncouragement(
          text,
          encouragementMessage,
        );

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EncouragementResultScreen(
                encouragementId: encouragement.id,
              ),
            ),
          );
          
          // 서비스 오류 알림
          Future.delayed(const Duration(milliseconds: 500), () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('응원 메시지 생성 서비스에 문제가 발생했습니다. 로컬 메시지를 사용합니다.'),
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          });
        }
      } catch (innerError) {
        // 로컬 메시지 처리에도 실패한 경우
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('응원 메시지를 생성하는 중 오류가 발생했습니다: $innerError'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // 한글이 깨졌는지 확인하는 함수
  bool _isKoreanTextCorrupted(String text) {
    // 일반적인 한글의 유니코드 범위 (가-힣)
    final koreanRegex = RegExp(r'[가-힣]');
    
    // 깨진 한글에서 자주 나타나는 특수 문자 패턴
    final corruptedPattern = RegExp(r'í|ë|ì|ê|â|ã|ä|å|æ|ç|ð|ñ|ò|ó|ô|õ|ö|ø|ù|ú|û|ü|ý|þ|ÿ');
    
    // 정상적인 한글이 포함되어 있는지 확인
    bool hasKorean = koreanRegex.hasMatch(text);
    
    // 깨진 한글 패턴이 있는지 확인
    bool hasCorruptedPattern = corruptedPattern.hasMatch(text);
    
    // 한글이 포함되어 있지 않거나, 깨진 한글 패턴이 있으면 깨진 것으로 판단
    return !hasKorean || hasCorruptedPattern;
  }

  @override
  Widget build(BuildContext context) {
    // 최근 응원 메시지 가져오기
    final recentEncouragements = Provider.of<EncouragementProvider>(context)
        .encouragements
        .take(3)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 앱 제목
                Text(
                  '마음 충전소',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                ),
                const SizedBox(height: 8),
                
                // 앱 소개 문구
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                          children: [
                            const TextSpan(text: '당신의 이야기에,\n엉뚱하지만 마음은 따뜻한 솜솜이'),
                            WidgetSpan(
                              child: Image(
                                  image: AssetImage('assets/images/somsom2-removebg.png'),
                                  height: 20,
                                ),
                              ),
                            const TextSpan(text: '의 응원을 받아보세요.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // 메인 입력 영역
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
                      Text(
                        '오늘의 이야기',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      // 입력 필드
                      TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: '오늘 어떤 이야기가 당신의 마음을 힘들게 하였나요?',
                          hintMaxLines: 2,
                        ),
                        maxLines: 4,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),
                      
                      // 응원 받기 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _generateEncouragement,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text('응원 받기'),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 최근 응원 기록 섹션
                if (recentEncouragements.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '최근 응원 메시지',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(),
                            ),
                          );
                        },
                        child: const Text('더보기'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 최근 응원 메시지 목록
                  ...recentEncouragements.map((encouragement) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: ListTile(
                          title: Text(
                            encouragement.query.length > 30
                                ? '${encouragement.query.substring(0, 30)}...'
                                : encouragement.query,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            '${encouragement.createdAt.year}.${encouragement.createdAt.month}.${encouragement.createdAt.day}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EncouragementResultScreen(
                                  encouragementId: encouragement.id,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ),
      ),
      
      // 설정 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.settings),
      ),
    );
  }
} 