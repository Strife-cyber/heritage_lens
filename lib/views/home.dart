import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heritage_lens/views/pages/dashboard_screen.dart';
import 'package:heritage_lens/views/pages/discover_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Setup the provider
final homeTabProvider = StateProvider<int>((ref) => 0);

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> with SingleTickerProviderStateMixin {
  SharedPreferences? _prefs;
  late TabController _tabController;

  // 2. Define your pages
  final List<Widget> _pages = [
    DashboardScreen(),
    DiscoverScreen(),
    Container(color: Colors.blueAccent.shade100, child: const Center(child: Text("Profile"))),
  ];

  @override
  void initState() {
    super.initState();
    _loadIndex();
    _tabController = TabController(length: _pages.length, vsync: this);
    
    // Sync TabController swipes with Riverpod state
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if(ref.read(homeTabProvider) != _tabController.index) {
          ref.read(homeTabProvider.notifier).state = _tabController.index;
          _saveIndex(_tabController.index);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(homeTabProvider);
    
    // Programmatically move the tab view if the provider changes (e.g. from nav bar tap)
    if (_tabController.index != currentIndex && !_tabController.indexIsChanging) {
       _tabController.animateTo(currentIndex);
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      extendBody: true, // Important: Makes the body go behind the floating bar
      
      // Use TabBarView to allow swiping between pages
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: _pages,
      ),
      
      // 3. The Custom Floating Bottom Bar
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 115, // Height of the area
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Container( 
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A), // Dark background from image
              borderRadius: BorderRadius.circular(50), // Capsule shape
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ]
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BottomNavItem(
                    icon: Icons.home_outlined,
                    isSelected: currentIndex == 0,
                    onTap: () => _updateIndex(0),
                  ),
                  _BottomNavItem(
                    icon: Icons.view_in_ar_outlined, // "Cube" icon
                    isSelected: currentIndex == 1,
                    onTap: () => _updateIndex(1),
                  ),
                  _BottomNavItem(
                    icon: Icons.person_outline,
                    isSelected: currentIndex == 2,
                    onTap: () => _updateIndex(2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateIndex(int index) {
    ref.read(homeTabProvider.notifier).state = index;
    _saveIndex(index);
  }

  void _loadIndex() async {
    _prefs = await SharedPreferences.getInstance();
    final savedIndex = _prefs?.getInt('home_tab_index') ?? 0;
    // Update state safely after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
       ref.read(homeTabProvider.notifier).state = savedIndex;
    });
  }

  Future<void> _saveIndex(int index) async {
    await _prefs?.setInt('home_tab_index', index);
  }
}

// 4. Custom Widget for the Individual Items
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          // If selected, show white circle, else transparent
          color: isSelected ? Colors.white : Colors.transparent, 
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          // If selected, icon is dark, else it is grey
          color: isSelected ? const Color(0xFF1A1A1A) : Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}