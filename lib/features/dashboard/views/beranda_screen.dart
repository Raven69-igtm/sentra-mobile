import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentra/core/theme/app_colors.dart';
import 'package:sentra/core/theme/app_spacing.dart';
import 'package:sentra/core/theme/app_typography.dart';
import 'package:sentra/core/widgets/sentra_curved_header.dart';
import 'package:sentra/core/widgets/sentra_empty_state.dart';
import 'package:sentra/core/widgets/sentra_gradient_icon.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/dashboard/views/pppa_screen.dart';
import 'package:sentra/features/dashboard/views/widgets/layanan_card_background.dart';
import 'package:sentra/features/notification/controllers/notif_badge_provider.dart';
import 'package:sentra/features/notification/views/notification_screen.dart';
import 'package:sentra/features/pjsrk/views/pjsrk_screen.dart';

/// Model data untuk Menu Layanan di Beranda.
class LayananItem {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final ServicePalette palette;
  final IconData icon;
  final bool comingSoon;
  final LayananCardArt art;

  const LayananItem({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.palette,
    required this.icon,
    required this.art,
    this.comingSoon = false,
  });
}

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Urutan layanan: PPPA, PJSRK, PSK.
  static const List<LayananItem> _allLayanan = [
    LayananItem(
      id: 'pppa',
      title: 'PPPA',
      description:
          'Layanan Dinas Sosial Perlindungan Perempuan & Pemberdayaan Anak',
      tags: ['Pengaduan Kekerasan', 'Pemberdayaan Anak'],
      palette: ServicePalette.pppa,
      icon: Icons.shield_outlined,
      art: LayananCardArt.pppa,
    ),
    LayananItem(
      id: 'pjsrk',
      title: 'PJSRK',
      description: 'Rehabilitasi sosial, bencana & permasalahan sosial',
      tags: ['Rehabilitasi Sosial', 'Bencana', 'Permasalahan Sosial'],
      palette: ServicePalette.pjsrk,
      icon: Icons.favorite_border_rounded,
      art: LayananCardArt.pjsrk,
    ),
    LayananItem(
      id: 'psk',
      title: 'PSK',
      description: 'Makam pahlawan & jadwal kegiatan mendatang',
      tags: ['Makam Pahlawan', 'Jadwal Kegiatan'],
      palette: ServicePalette.psk,
      icon: Icons.outlined_flag_rounded,
      comingSoon: true,
      art: LayananCardArt.psk,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final int? userId = Provider.of<UserProvider>(context, listen: false).idAkun;
    if (userId != null && userId > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Provider.of<NotificationBadgeProvider?>(
          context,
          listen: false,
        )?.startForUser(userId);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat pagi,';
    if (hour >= 11 && hour < 15) return 'Selamat siang,';
    if (hour >= 15 && hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  void _onLayananTap(BuildContext context, LayananItem item) {
    if (item.comingSoon) return;
    HapticFeedback.lightImpact();
    switch (item.id) {
      case 'pjsrk':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PjsrkScreen()),
        );
        break;
      case 'pppa':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PppaScreen()),
        );
        break;
    }
  }

  String? _imageAssetFor(LayananItem item) {
    switch (item.id) {
      case 'pjsrk':
        return 'assets/image/beranda/pjsrk.png';
      case 'psk':
        return 'assets/image/beranda/psk.png';
      case 'pppa':
        return 'assets/image/beranda/pppa.png';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final String userName = userProvider.user?.nama ?? 'Pengguna';
    final topInset = MediaQuery.of(context).padding.top;

    final filteredLayanan =
        _allLayanan.where((item) {
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return item.title.toLowerCase().contains(q) ||
              item.description.toLowerCase().contains(q) ||
              item.tags.any((tag) => tag.toLowerCase().contains(q));
        }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 96),
          child: Column(
            children: [
              // Curved Header Gradient (#52AE77 -> #5270AD) melengkung ke bawah
              SentraCurvedHeader(
                curveHeight: 34,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  topInset + 12,
                  AppSpacing.pageHorizontal,
                  52,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSpacing.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(context),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          _getGreeting(),
                          style: AppTypography.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.title.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildVerifiedBadge(),
                      ],
                    ),
                  ),
                ),
              ),

              // Bagian bawah putih bersih: Search + Menu Layanan (PPPA, PJSRK, PSK)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.maxContentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.md,
                      AppSpacing.pageHorizontal,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: AppSpacing.xl),
                        const Text(
                          'Menu Layanan',
                          style: AppTypography.subtitle,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Pilih layanan yang Anda butuhkan',
                          style: AppTypography.caption,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (filteredLayanan.isEmpty)
                          SentraEmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'Layanan "$_searchQuery" tidak ditemukan',
                            description:
                                'Coba kata kunci lain seperti PPPA, PJSRK, Bencana, atau Rehabilitasi.',
                            actionLabel: 'Hapus Pencarian',
                            onAction: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        else
                          ...filteredLayanan.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: _buildServiceCard(context, item),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/logo/Image.png',
          width: 40,
          height: 32,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SENTRA',
                style: AppTypography.subtitle.copyWith(
                  letterSpacing: 0.9,
                  color: Colors.white,
                ),
              ),
              Text(
                'Dinas Sosial dan PPA',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        Builder(
          builder: (context) {
            final NotificationBadgeProvider? badge =
                Provider.of<NotificationBadgeProvider?>(context);
            final bool hasUnread = badge?.hasUnread ?? false;
            final int unreadCount = badge?.unreadCount ?? 0;
            final String badgeText = badge?.badgeText ?? '';

            return Semantics(
              button: true,
              label:
                  hasUnread
                      ? 'Buka notifikasi, $unreadCount belum dibaca'
                      : 'Buka notifikasi',
              child: Material(
                color: Colors.white.withValues(alpha: 0.18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  tooltip: 'Notifikasi',
                  constraints: const BoxConstraints(
                    minWidth: AppSpacing.minTouchTarget,
                    minHeight: AppSpacing.minTouchTarget,
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationPage(),
                      ),
                    );
                    if (context.mounted) {
                      Provider.of<NotificationBadgeProvider?>(
                        context,
                        listen: false,
                      )?.refresh();
                    }
                  },
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 23,
                      ),
                      if (hasUnread)
                        Positioned(
                          top: -6,
                          right: -8,
                          child: Container(
                            key: const Key('beranda_notif_badge'),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFB4B6A), Color(0xFFE11D48)],
                              ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x52E11D48),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              badgeText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                                fontFamily: 'Mulish',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            'Akun terverifikasi',
            style: AppTypography.label.copyWith(
              letterSpacing: 0.2,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: AppTypography.body,
      onChanged: (val) => setState(() => _searchQuery = val.trim()),
      decoration: InputDecoration(
        hintText: 'Cari layanan PPPA, PJSRK, bencana...',
        filled: true,
        fillColor: AppColors.surfaceVariant,
        prefixIcon: const SentraGradientIcon(Icons.search_rounded, size: 22),
        suffixIcon:
            _searchQuery.isNotEmpty
                ? IconButton(
                  tooltip: 'Hapus pencarian',
                  icon: const SentraGradientIcon(
                    Icons.cancel_rounded,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
                : null,
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, LayananItem item) {
    final bool isComingSoon = item.comingSoon;
    final Color cardColor = item.palette.primary;
    final String? imageAsset = _imageAssetFor(item);

    final Widget cardBody = Semantics(
      button: !isComingSoon,
      enabled: !isComingSoon,
      label:
          isComingSoon
              ? 'Layanan ${item.title}, segera hadir, belum tersedia'
              : 'Layanan ${item.title}: ${item.description}',
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isComingSoon ? null : () => _onLayananTap(context, item),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: isComingSoon ? 110 : 150),
            child: Stack(
              children: [
                if (imageAsset != null)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: 0.48,
                        heightFactor: 1,
                        child: Image.asset(
                          imageAsset,
                          fit: BoxFit.contain,
                          alignment: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                if (imageAsset != null)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            cardColor,
                            cardColor.withValues(alpha: 0.88),
                            cardColor.withValues(alpha: 0.45),
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(
                    isComingSoon ? AppSpacing.lg : AppSpacing.xl - 2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                            ),
                            child: Icon(
                              item.icon,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: AppTypography.subtitle.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          if (isComingSoon)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                              child: Text(
                                'Segera Hadir',
                                style: AppTypography.label.copyWith(
                                  letterSpacing: 0.2,
                                  color: cardColor,
                                ),
                              ),
                            )
                          else
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                        ],
                      ),
                      if (!isComingSoon) ...[
                        const SizedBox(height: AppSpacing.md + 2),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children:
                              item.tags
                                  .map(
                                    (tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusPill,
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: AppTypography.label.copyWith(
                                          letterSpacing: 0.1,
                                          color: cardColor,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (isComingSoon) {
      return Opacity(opacity: 0.55, child: cardBody);
    }
    return cardBody;
  }
}
