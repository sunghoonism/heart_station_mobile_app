import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/encouragement.dart';

class EncouragementProvider with ChangeNotifier {
  List<Encouragement> _encouragements = [];
  final Uuid _uuid = const Uuid();
  
  List<Encouragement> get encouragements => [..._encouragements];
  List<Encouragement> get favorites => _encouragements.where((e) => e.isFavorite).toList();
  
  static const String _storageKey = 'encouragements';
  
  EncouragementProvider() {
    _loadEncouragements();
  }
  
  Future<void> _loadEncouragements() async {
    final prefs = await SharedPreferences.getInstance();
    final encouragementsJson = prefs.getStringList(_storageKey) ?? [];
    
    _encouragements = encouragementsJson
        .map((json) => Encouragement.fromJson(jsonDecode(json)))
        .toList();
    
    // 날짜 기준으로 최신순 정렬
    _encouragements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    notifyListeners();
  }
  
  Future<void> _saveEncouragements() async {
    final prefs = await SharedPreferences.getInstance();
    
    final encodedData = _encouragements
        .map((encouragement) => jsonEncode(encouragement.toJson()))
        .toList();
    
    await prefs.setStringList(_storageKey, encodedData);
  }
  
  // 새로운 응원 메시지 생성
  Future<Encouragement> createEncouragement(String query, String message) async {
    final encouragement = Encouragement(
      id: _uuid.v4(),
      query: query,
      message: message,
      createdAt: DateTime.now(),
    );
    
    _encouragements.insert(0, encouragement); // 최신 메시지를 맨 앞에 추가
    await _saveEncouragements();
    notifyListeners();
    
    return encouragement;
  }
  
  // 응원 메시지 즐겨찾기 상태 토글
  Future<void> toggleFavorite(String id) async {
    final index = _encouragements.indexWhere((e) => e.id == id);
    if (index >= 0) {
      final updatedEncouragement = _encouragements[index].copyWith(
        isFavorite: !_encouragements[index].isFavorite,
      );
      
      _encouragements[index] = updatedEncouragement;
      await _saveEncouragements();
      notifyListeners();
    }
  }
  
  // 응원 메시지 삭제
  Future<void> deleteEncouragement(String id) async {
    _encouragements.removeWhere((e) => e.id == id);
    await _saveEncouragements();
    notifyListeners();
  }
  
  // 응원 메시지 가져오기
  Encouragement? getEncouragementById(String id) {
    try {
      return _encouragements.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // 모든 응원 메시지 삭제
  Future<void> clearAll() async {
    _encouragements.clear();
    await _saveEncouragements();
    notifyListeners();
  }
} 