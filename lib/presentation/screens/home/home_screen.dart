import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // user info
  String fullName = "Student";
  String? photoUrl;

  // hero card
  String heroTitle = "";
  String heroSubtitle = "";
  IconData heroIcon = Icons.star;
  Timer? _heroTimer;

  // quick actions (label + icon emoji or simple string)
  List<Map<String, String>> quickActions = [];

  // tabs
  late TabController _tabController;

  // bottom nav
  int _selectedIndex = 0;

  // Firestore subscription for live updates (user doc)
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updateHeroByTime();
    // refresh hero card every minute (keeps it current)
    _heroTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) _updateHeroByTime();
    });

    _loadQuickActions();
    _listenUserDoc();
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _userSub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // Listen to user's Firestore doc for live updates
  void _listenUserDoc() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    _userSub = docRef.snapshots().listen(
      (snap) {
        if (!mounted) return;
        if (snap.exists) {
          final data = snap.data();
          setState(() {
            fullName = (data?['fullName'] as String?)?.trim() ?? "Student";
            photoUrl = (data?['photoUrl'] as String?)?.trim();
          });
        }
      },
      onError: (err) {
        // ignore: avoid_print
        print("Error listening user doc: $err");
      },
    );
  }

  // Default quick actions if Firestore doesn't provide them
  List<Map<String, String>> get _defaultQuickActions => [
    {"icon": "📷", "label": "Scan"},
    {"icon": "🚌", "label": "Track Bus"},
    {"icon": "💳", "label": "Wallet"},
    {"icon": "📅", "label": "Events"},
  ];

  // Load quick actions from Firestore collection `quick_actions` (optional)
  Future<void> _loadQuickActions() async {
    try {
      final col = FirebaseFirestore.instance.collection('quick_actions');
      final snapshot = await col.orderBy('order', descending: false).get();

      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs.map((d) {
          final data = d.data();
          return {
            "icon": (data['icon'] as String?) ?? "",
            "label": (data['label'] as String?) ?? "Action",
          };
        }).toList();
        if (mounted) setState(() => quickActions = list);
      } else {
        if (mounted) setState(() => quickActions = _defaultQuickActions);
      }
    } catch (e) {
      // If anything fails, fall back to defaults
      if (mounted) setState(() => quickActions = _defaultQuickActions);
      // ignore: avoid_print
      print("Failed to load quick actions: $e");
    }
  }

  void _updateHeroByTime() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      heroTitle = "Good Morning 🌅";
      heroSubtitle = "Check today's classes & deadlines.";
      heroIcon = Icons.wb_sunny;
    } else if (hour >= 12 && hour < 18) {
      heroTitle = "Good Afternoon 🌞";
      heroSubtitle = "Lunch break? See what's happening now.";
      heroIcon = Icons.lunch_dining;
    } else if (hour >= 18 && hour < 22) {
      heroTitle = "Good Evening 🌆";
      heroSubtitle = "Walking on campus? Find a buddy for a safer walk.";
      heroIcon = Icons.people;
    } else {
      heroTitle = "Good Night 🌙";
      heroSubtitle = "Late hours — stay safe & connected.";
      heroIcon = Icons.nightlight_round;
    }
    if (mounted) setState(() {});
  }

  // derive initials fallback
  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) return "S";
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return ((parts[0][0] + parts[1][0]).toUpperCase());
  }

  void _onQuickActionTap(Map<String, String> action) {
    // stub: replace with navigation or logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Tapped: ${action['label']}")));
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);
    // TODO: handle bottom nav routing
  }

  @override
  Widget build(BuildContext context) {
    // If quickActions haven't loaded yet, show defaults for immediate UI
    final actions = quickActions.isNotEmpty
        ? quickActions
        : _defaultQuickActions;

    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: SafeArea(
        child: Column(
          children: [
            // Top greeting row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // time-based short greeting
                          heroTitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // avatar: try photoUrl else initials
                  GestureDetector(
                    onTap: () {
                      // TODO: navigate to profile
                    },
                    child: photoUrl != null && photoUrl!.isNotEmpty
                        ? CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(photoUrl!),
                            backgroundColor: Colors.grey[200],
                          )
                        : CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.blue.shade700,
                            child: Text(
                              _getInitials(fullName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // spacing
            const SizedBox(height: 8),

            // Body scroll area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(heroIcon, color: Colors.white, size: 28),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    heroTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              heroSubtitle,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: () {
                                // TODO: hero CTA action
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Hero action tapped"),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("Find a Buddy"),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Quick Actions (horizontal)
                    SizedBox(
                      height: 96,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: actions.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final action = actions[i];
                          final iconText = action['icon'] ?? '';
                          final label = action['label'] ?? 'Action';
                          return GestureDetector(
                            onTap: () => _onQuickActionTap(action),
                            child: Container(
                              width: 88,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // show emoji/icon or placeholder
                                  Text(
                                    iconText,
                                    style: const TextStyle(fontSize: 26),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tabs + Feed (fixed height)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // TabBar
                          TabBar(
                            controller: _tabController,
                            labelColor: Colors.blue.shade700,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.blue.shade700,
                            tabs: const [
                              Tab(text: "Academics"),
                              Tab(text: "Community"),
                              Tab(text: "Placements"),
                            ],
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            height: 300,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _feedList([
                                  "📄 CS101: New assignment uploaded",
                                  "📢 AD203: Notes uploaded to files",
                                  "⏰ Deadline: Project Phase 1 submission",
                                ]),
                                _feedList([
                                  "🎉 Freshers party registration open",
                                  "📌 Debate club meeting at 5 PM",
                                  "🤝 Join the campus volunteering group",
                                ]),
                                _feedList([
                                  "💼 Infosys drive: Apply before 10th",
                                  "📌 Mock interview signups open",
                                  "📊 Placement stats updated",
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // SOS FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: real SOS behavior (call campus security / share location)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("SOS Triggered! 🚨")));
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.warning),
      ),

      // Bottom navigation (visual only for now)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Community"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Calendar",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _feedList(List<String> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.circle, size: 10, color: Colors.blue),
            title: Text(items[i]),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              // TODO: open detail
            },
          ),
        );
      },
    );
  }
}
