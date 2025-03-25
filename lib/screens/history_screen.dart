import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/encouragement_provider.dart';
import '../utils/theme.dart';
import 'encouragement_result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // 날짜 포맷 함수
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '오늘';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('yyyy년 MM월 dd일').format(date);
    }
  }
  
  // 앱바 제목
  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('응원 기록', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(
          '당신이 받은 모든 응원들', 
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final encouragementProvider = Provider.of<EncouragementProvider>(context);
    final allEncouragements = encouragementProvider.encouragements;
    final favoriteEncouragements = encouragementProvider.favorites;
    
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '즐겨찾기'),
          ],
          labelColor: AppTheme.primaryColor,
          indicatorColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.secondaryTextColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 전체 탭
          _buildEncouragementList(allEncouragements),
          
          // 즐겨찾기 탭
          favoriteEncouragements.isEmpty
            ? const Center(child: Text('즐겨찾기한 응원 메시지가 없습니다.'))
            : _buildEncouragementList(favoriteEncouragements),
        ],
      ),
    );
  }
  
  // 응원 메시지 목록 위젯
  Widget _buildEncouragementList(List<dynamic> encouragements) {
    if (encouragements.isEmpty) {
      return const Center(
        child: Text('아직 받은 응원 메시지가 없습니다.'),
      );
    }
    
    return ListView.builder(
      itemCount: encouragements.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final encouragement = encouragements[index];
        
        return Dismissible(
          key: Key(encouragement.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('삭제 확인'),
                content: const Text('이 응원 메시지를 삭제하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('삭제', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            Provider.of<EncouragementProvider>(context, listen: false)
                .deleteEncouragement(encouragement.id);
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('응원 메시지가 삭제되었습니다.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(encouragement.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          encouragement.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: encouragement.isFavorite ? AppTheme.primaryColor : null,
                          size: 20,
                        ),
                        onPressed: () {
                          Provider.of<EncouragementProvider>(context, listen: false)
                              .toggleFavorite(encouragement.id);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    encouragement.query,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  encouragement.message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
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
      },
    );
  }
} 