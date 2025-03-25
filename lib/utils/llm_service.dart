import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/secrets.dart';

class LLMService {
  static const String _apiKey = Secrets.grokApiKey;
  static const String _baseUrl = "https://api.groq.com/openai/v1/chat/completions";

  /// 사용자 메시지를 받아 LLM으로부터 응원 메시지를 생성합니다.
  static Future<String> generateEncouragement(String userMessage) async {
    try {
      print('API 요청 시작: $userMessage');
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'model': 'gemma2-9b-it',
          'messages': [
            {
              'role': 'system',
              'content': '당신은 사용자의 고민이나 어려움을 듣고 따뜻하고 진심 어린 응원의 메시지를 보내주는 도우미입니다. 최대 5-6문장으로 응답해주세요. 한국어로 응답해주세요.'
            },
            {
              'role': 'user',
              'content': userMessage,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 300,
        }),
      );
      
      if (response.statusCode == 200) {
        
        // UTF-8 디코딩 사용하여 JSON 파싱
        final jsonString = utf8.decode(response.bodyBytes);
        print('UTF-8 디코딩된 응답: ${jsonString.substring(0, min(200, jsonString.length))}...');
        
        final data = jsonDecode(jsonString);
        
        // 응답 구조 확인 및 로깅
        if (data['choices'] != null && 
            data['choices'].isNotEmpty && 
            data['choices'][0]['message'] != null &&
            data['choices'][0]['message']['content'] != null) {
          
          final encouragementMessage = data['choices'][0]['message']['content'] as String;
          print('추출된 메시지: $encouragementMessage');
          return encouragementMessage;
        } else {
          print('API 응답 구조 오류: $data');
          return '응원 메시지를 생성하지 못했습니다. 잠시 후 다시 시도해주세요.';
        }
      } else if (response.statusCode == 401) {
        print('API 인증 오류: ${utf8.decode(response.bodyBytes)}');
        return '인증에 문제가 있습니다. 관리자에게 문의해주세요.';
      } else {
        print('API 응답 오류: ${response.statusCode} ${utf8.decode(response.bodyBytes)}');
        return '응원 메시지 생성 서비스에 일시적인 문제가 있습니다. 잠시 후 다시 시도해주세요.';
      }
    } catch (e) {
      print('API 요청 예외 발생: $e');
      if (e is http.ClientException) {
        return '네트워크 연결에 문제가 있습니다. 인터넷 연결을 확인하고 다시 시도해 주세요.';
      } else {
        return '응원 메시지를 생성하는 중 오류가 발생했습니다. 다시 시도해 주세요.';
      }
    }
  }
  
  // min 함수 구현 (Dart math 패키지 대신 직접 구현)
  static int min(int a, int b) {
    return a < b ? a : b;
  }
  
  // 백업 응원 메시지 생성 (API 실패 시 사용)
  static String generateLocalEncouragement(String userMessage) {
    final messages = [
      "당신의 이야기에 깊이 공감해요. 때로는 그저 한 걸음씩 천천히 나아가는 것도 충분히 훌륭한 성취랍니다.",
      "지금 느끼는 감정이 힘들더라도, 그것은 당신이 진심을 다해 살고 있다는 증거에요. 당신의 여정을 응원합니다.",
      "걱정이 많을 때는 깊은 숨을 들이마시고 내쉬어보세요. 모든 것은 지나갑니다. 지금의 어려움도 곧 지나갈 거예요.",
      "당신이 쌓아온 모든 노력이 헛되지 않을 거예요. 비가 온 뒤에는 항상 무지개가 찾아오듯이, 좋은 날이 곧 올 거예요.",
      "자기 자신에게 좀 더 너그러워져도 괜찮아요. 완벽하지 않아도, 지금의 당신은 충분히 가치 있어요."
    ];
    
    // 간단한 인덱스 계산으로 메시지 선택
    final messageIndex = userMessage.length % messages.length;
    return messages[messageIndex];
  }
} 