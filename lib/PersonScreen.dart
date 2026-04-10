import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grocery/PersonForm.dart';
import 'package:grocery/Person_Api.dart';
import 'package:grocery/theme_manager.dart';

class PersonScreen extends StatefulWidget {
  final int eventId;
  final String eventName;

  PersonScreen({required this.eventId, required this.eventName});

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  late Future<List<dynamic>> _personsFuture;

  @override
  void initState() {
    super.initState();
    _personsFuture = PersonApi().getPersonsByEvent(widget.eventId);
  }

  void _refreshPersons() {
    setState(() {
      _personsFuture = PersonApi().getPersonsByEvent(widget.eventId);
    });
  }

  void _showPersonActions(dynamic person) {
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isLight ? Colors.black26 : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _ActionTile(
              icon: Icons.edit_outlined,
              label: 'Edit Member info',
              color: const Color(0xFF7C3AED),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PersonForm(eventID: widget.eventId, eventName: widget.eventName, map: person)),
                );
                if (result == true) _refreshPersons();
              },
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.delete_outline,
              label: 'Remove Member',
              color: Colors.redAccent,
              onTap: () async {
                Navigator.pop(ctx);
                final deleted = await PersonApi().deleteUser(person['userID']);
                if (deleted) _refreshPersons();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = ThemeManager.instance.isLightMode;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<dynamic>>(
        future: _personsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          final persons = snapshot.data ?? [];

          if (persons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt, size: 64, color: isLight ? Colors.black12 : Colors.white10),
                  const SizedBox(height: 16),
                  Text('No members added yet', style: TextStyle(color: isLight ? Colors.black38 : Colors.white38)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: persons.length,
            itemBuilder: (context, index) {
              return _AnimatedMemberCard(
                person: persons[index],
                index: index,
                isLight: isLight,
                onTap: () => _showPersonActions(persons[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => PersonForm(eventID: widget.eventId, eventName: widget.eventName)));
            if (result == true) {
              _refreshPersons();
              _showToast('Member added successfully. 🎉');
            }
          },
          backgroundColor: const Color(0xFF1E293B),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Member', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class _AnimatedMemberCard extends StatefulWidget {
  final dynamic person;
  final int index;
  final bool isLight;
  final VoidCallback onTap;

  const _AnimatedMemberCard({required this.person, required this.index, required this.isLight, required this.onTap});

  @override
  State<_AnimatedMemberCard> createState() => _AnimatedMemberCardState();
}

class _AnimatedMemberCardState extends State<_AnimatedMemberCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    
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
    final person = widget.person;
    final userImage = person['userImage'];

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black.withOpacity(0.05), width: 1.5)),
                      child: ClipOval(
                        child: (userImage != null && userImage != '')
                            ? Image.file(File(userImage), fit: BoxFit.cover)
                            : Container(color: Colors.blue.withOpacity(0.1), child: const Icon(Icons.person, color: Colors.blue, size: 32)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(person['userName'] ?? 'Unknown', style: const TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                            child: const Text('MEMBER', style: TextStyle(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black12, size: 22),
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
