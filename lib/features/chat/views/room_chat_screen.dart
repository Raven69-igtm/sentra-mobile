import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/chat/repositories/chat_repository.dart';
import 'package:sentra/features/chat/views/chat_screen.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';
import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class VChatUser {
  final String name;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final int userId;

  VChatUser({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.isOnline,
    required this.userId,
  });
}

class RoomChat extends StatefulWidget {
  const RoomChat({super.key});

  @override
  _RoomChatState createState() => _RoomChatState();
}

class _RoomChatState extends State<RoomChat> {
  final ChatRepository _repository = ChatRepository();
  final TextEditingController _searchController = TextEditingController();

  List<VChatUser> users = [];
  bool isLoading = true;
  String? errorMessage;
  String _query = '';

  List<VChatUser> get _filteredUsers {
    if (_query.trim().isEmpty) return users;
    final q = _query.toLowerCase();
    return users.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.lastMessage.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).idAkun;
      final response = await _repository.dio.get(
        'https://${ApiClient.baseUrl}/api/conversations/$userId',
      );
      final data = response.data is List ? response.data : [];
      setState(() {
        users =
            data
                .map((user) {
                  return VChatUser(
                    name: user['name'] ?? 'Unknown',
                    lastMessage: user['last_message'] ?? '',
                    time: user['time'] ?? '',
                    isOnline: user['is_online'] == 1,
                    userId: user['user_id'] ?? 0,
                  );
                })
                .toList()
                .cast<VChatUser>();
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load conversations: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Pesan',
          style: TextStyle(
            fontFamily: "Mulish",
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: _fetchUsers,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.black87),
            onSelected: (v) {
              if (v == 'clear') {
                setState(() {
                  _query = '';
                  _searchController.clear();
                });
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Text('Bersihkan pencarian'),
                  ),
                ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _buildSearchField(theme),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUsers,
        color: Warna.backgroundIjo,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child:
              isLoading
                  ? _buildShimmerEffect()
                  : errorMessage != null
                  ? _buildErrorState(errorMessage!)
                  : _filteredUsers.isEmpty
                  ? _buildEmptyState()
                  : _buildListView(),
        ),
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari percakapan...',
          hintStyle: const TextStyle(fontFamily: "Mulish"),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon:
              _query.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      setState(() {
                        _query = '';
                        _searchController.clear();
                      });
                    },
                  )
                  : null,
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      key: const ValueKey('list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredUsers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserChatTile(user, index);
      },
    );
  }

  Widget _buildUserChatTile(VChatUser user, int index) {
    return Dismissible(
      key: Key('chat-${user.userId}'),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (direction) async {
        final result = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Hapus Percakapan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  'Apakah kamu yakin ingin menghapus percakapan dengan ${user.name}?',
                  style: const TextStyle(color: Colors.black87),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final senderId =
                          Provider.of<UserProvider>(
                            context,
                            listen: false,
                          ).idAkun;
                      if (senderId == null) {
                        Navigator.of(context).pop(false);
                        return;
                      }
                      try {
                        await _repository.deleteConversation(
                          senderId,
                          user.userId,
                        );
                        setState(() {
                          users.removeWhere((u) => u.userId == user.userId);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Percakapan dengan ${user.name} dihapus',
                            ),
                            backgroundColor: Colors.red.shade400,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.of(context).pop(true);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menghapus percakapan: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.of(context).pop(false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
        );
        return result;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ChatKonsultasiScreen(
                        receiverId: user.userId,
                        receiverName: user.name,
                      ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  _buildUserAvatar(user),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  fontFamily: "Mulish",
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildTimePill(user.time),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.lastMessage,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: "Mulish",
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade300, Colors.red.shade600],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          Icon(Icons.delete_forever_rounded, color: Colors.white, size: 28),
          SizedBox(width: 8),
          Text(
            'Hapus',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontFamily: "Mulish",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(VChatUser user) {
    final initial = (user.name.isNotEmpty ? user.name[0] : '?').toUpperCase();
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(2.2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.shade50,
              child: Text(
                initial,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 22,
                ),
              ),
            ),
          ),
        ),
        if (user.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade700,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimePill(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: "Mulish",
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      key: const ValueKey('shimmer'),
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 2),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Container(width: 48, height: 18, color: Colors.white),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      key: const ValueKey('empty'),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(
          Icons.chat_bubble_outline_rounded,
          color: Colors.grey[400],
          size: 64,
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Belum ada percakapan',
            style: TextStyle(
              color: Colors.grey,
              fontFamily: "Mulish",
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Mulai obrolan baru untuk melihat pesan di sini.',
            style: TextStyle(
              color: Colors.grey,
              fontFamily: "Mulish",
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: OutlinedButton.icon(
            onPressed: _fetchUsers,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Muat ulang'),
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return ListView(
      key: const ValueKey('error'),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.error_outline_rounded, color: Colors.red.shade300, size: 64),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Terjadi kesalahan',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: "Mulish",
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Cek koneksi internet Anda atau coba lagi nanti.\n"
            "Jika masalah berlanjut, silakan hubungi dukungan teknis.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: _fetchUsers,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            label: const Text(
              'Coba lagi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }
}
