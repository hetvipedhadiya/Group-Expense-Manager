import 'package:flutter/material.dart';
import 'package:grocery/DeveloperScreenPage.dart';
import 'package:grocery/Event_Api.dart';
import 'package:grocery/ExpenseDetail.dart';
import 'package:grocery/FormScreen.dart';
import 'package:grocery/theme_manager.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class NewScreen extends StatefulWidget {
  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> with TickerProviderStateMixin {
  Future<List<dynamic>>? _futureEvents;
  bool _showAllEvents = false;

  @override
  void initState() {
    super.initState();
    _futureEvents = EventApi().fetchEventsByHostId();
  }

  void _refreshEvents() {
    setState(() {
      _futureEvents = EventApi().fetchEventsByHostId();
    });
  }

  void _showEventActions(BuildContext context, dynamic event) {
    final isLight = ThemeManager.instance.isLightMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF1A1040),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isLight ? Colors.black26 : Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(event['eventName'] ?? '', style: TextStyle(color: isLight ? const Color(0xFF0F172A) : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _BottomSheetAction(
              icon: Icons.edit_outlined,
              label: 'Edit Event',
              color: const Color(0xFF7C3AED),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreateEventScreen(map: event))).then((value) {
                  if (value == true) _refreshEvents();
                });
              },
            ),
            const SizedBox(height: 12),
            _BottomSheetAction(
              icon: Icons.delete_outline,
              label: 'Delete Event',
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, event);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic event) {
    final isLight = ThemeManager.instance.isLightMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isLight ? Colors.white : const Color(0xFF1A1040),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Event?', style: TextStyle(color: isLight ? const Color(0xFF0F172A) : Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${event['eventName']}"?', style: TextStyle(color: isLight ? Colors.black54 : const Color(0xFF9580C4))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: isLight ? Colors.black45 : const Color(0xFF8B7EC8)))),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            bool deleted = await EventApi().deleteEvent(event['eventID']);
            if (deleted) _refreshEvents();
          }, child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = ThemeManager.instance.isLightMode;
    return Scaffold(
      backgroundColor: isLight ? const Color(0xFFF1F5F9) : const Color(0xFF0D0D1F),
      body: FutureBuilder<List<dynamic>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          final events = snapshot.data ?? [];
          final totalAmount = events.fold(0.0, (sum, e) => sum + (e['amount'] ?? 0.0));
          final itemsToShowCount = _showAllEvents ? events.length : (events.length > 3 ? 3 : events.length);

          return CustomScrollView(
            slivers: [
              // PREMIUM HEADER WITH GRADIENT AND ABSTRACT DECOR (Matching image)
              SliverToBoxAdapter(
                child: Container(
                  height: 280,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(right: -50, top: -50, child: CircleAvatar(radius: 120, backgroundColor: Colors.white.withOpacity(0.03))),
                      Positioned(left: 30, top: 100, child: Opacity(opacity: 0.05, child: Icon(Icons.cloud_outlined, size: 100, color: Colors.white))),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _HeaderActionBtn(icon: Icons.share_outlined, onTap: () => Share.share('Join me on Expense Manager!')),
                                  const SizedBox(width: 8),
                                  _HeaderActionBtn(icon: isLight ? Icons.dark_mode_outlined : Icons.light_mode_outlined, onTap: () => ThemeManager.instance.toggleTheme().then((_) => setState(() {}))),
                                  const SizedBox(width: 8),
                                  _HeaderActionBtn(icon: Icons.info_outline, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DeveloperScreenPage()))),
                                ],
                              ),
                              const Spacer(),
                              const Text('Events', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // FLOATING SUMMARY CARD - Only show when NOT in "View All" mode
              if (!_showAllEvents)
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -60),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: isLight ? Colors.white : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isLight ? 0.08 : 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          _SummaryStat(label: 'Total Events', value: '${events.length}', color: const Color(0xFF6366F1), icon: Icons.event_note, isLight: isLight),
                          Container(width: 1, height: 40, color: isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.1)),
                          _SummaryStat(label: 'Total Amount', value: '₹${NumberFormat("#,##0", "en_IN").format(totalAmount)}', color: const Color(0xFF10B981), icon: Icons.payments_outlined, isLight: isLight),
                        ],
                      ),
                    ),
                  ),
                ),

              // LIST SECTION
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_showAllEvents ? 'All Events' : 'Recent Events', style: TextStyle(color: isLight ? const Color(0xFF1E293B) : Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => setState(() => _showAllEvents = !_showAllEvents),
                        child: Text(_showAllEvents ? 'Show Less' : 'View All', style: const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
              ),

              // STAGGERED LIST WITH SNAPPY ANIMATIONS
              SliverPadding(
                padding: EdgeInsets.fromLTRB(24, _showAllEvents ? 20 : 0, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      return _AnimatedEventCard(
                        event: events[i],
                        index: i,
                        isLight: isLight,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseDetail(eventName: events[i]['eventName'], eventId: events[i]['eventID']))).then((_) => _refreshEvents()),
                        onLongPress: () => _showEventActions(context, events[i]),
                      );
                    },
                    childCount: itemsToShowCount,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreateEventScreen())).then((val) { if (val == true) _refreshEvents(); }),
        backgroundColor: const Color(0xFF1E293B),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text('Add Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _AnimatedEventCard extends StatefulWidget {
  final dynamic event;
  final int index;
  final bool isLight;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _AnimatedEventCard({required this.event, required this.index, required this.isLight, required this.onTap, required this.onLongPress});

  @override
  State<_AnimatedEventCard> createState() => _AnimatedEventCardState();
}

class _AnimatedEventCardState extends State<_AnimatedEventCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    // SNAPPY DURATION as per user request
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    
    // Staggered trigger
    Future.delayed(Duration(milliseconds: widget.index * 40), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ev = widget.event;
    final dateStr = DateFormat('MMM dd, yyyy').format(DateTime.parse(ev['eventDate'] ?? DateTime.now().toString()));
    
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: widget.isLight ? Colors.white : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(widget.isLight ? 0.03 : 0.2), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: widget.isLight ? const Color(0xFFF1F5F9) : Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                      child: Icon(Icons.wallet_outlined, color: widget.isLight ? const Color(0xFF1E293B) : Colors.white70, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ev['eventName'] ?? '', style: TextStyle(color: widget.isLight ? const Color(0xFF1E293B) : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(dateStr, style: TextStyle(color: widget.isLight ? Colors.black26 : Colors.white38, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${NumberFormat("#,##0", "en_IN").format(ev['amount'] ?? 0)}', style: TextStyle(color: widget.isLight ? const Color(0xFF1E293B) : Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        const SizedBox(height: 4),
                        Icon(Icons.arrow_forward_ios, size: 12, color: widget.isLight ? Colors.black12 : Colors.white10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isLight;

  const _SummaryStat({required this.label, required this.value, required this.color, required this.icon, required this.isLight});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: isLight ? const Color(0xFF1E293B) : const Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isLight ? Colors.black38 : Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _HeaderActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

class _BottomSheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _BottomSheetAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.15))),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
