import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const AuraMoodApp());

class AuraMoodApp extends StatelessWidget {
  const AuraMoodApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraMood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'SF Pro Display'),
      home: const SplashScreen(),
    );
  }
}

// ─── SPLASH SCREEN ───────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0));
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a0533), Color(0xFF3d1266), Color(0xFF6b21a8)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFf0abfc), Color(0xFF9333ea)],
                    ),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF9333ea).withOpacity(0.6),
                          blurRadius: 40, spreadRadius: 10),
                    ],
                  ),
                  child: const Icon(Icons.self_improvement, size: 52, color: Colors.white),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fade,
                child: const Column(children: [
                  Text('AuraMood', style: TextStyle(
                    fontSize: 36, fontWeight: FontWeight.w800,
                    color: Colors.white, letterSpacing: -1,
                  )),
                  SizedBox(height: 8),
                  Text('Feel your energy', style: TextStyle(
                    fontSize: 15, color: Color(0xFFd8b4fe), letterSpacing: 2,
                  )),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── DATA ────────────────────────────────────────────────────
const List<Map<String, dynamic>> moods = [
  {'label': 'Radiant',  'emoji': '✨', 'color': Color(0xFFfbbf24), 'desc': 'Glowing with energy'},
  {'label': 'Blissful', 'emoji': '🌸', 'color': Color(0xFFf472b6), 'desc': 'Light and joyful'},
  {'label': 'Focused',  'emoji': '🔵', 'color': Color(0xFF60a5fa), 'desc': 'Sharp and clear'},
  {'label': 'Serene',   'emoji': '🍃', 'color': Color(0xFF34d399), 'desc': 'Calm and peaceful'},
  {'label': 'Restless', 'emoji': '🌪️', 'color': Color(0xFFfb923c), 'desc': 'Scattered thoughts'},
  {'label': 'Cloudy',   'emoji': '🌧️', 'color': Color(0xFF94a3b8), 'desc': 'Heavy and low'},
];

// ─── HOME SCREEN ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _selectedMood = -1;
  final List<Map<String, dynamic>> _log = [];
  late AnimationController _bgCtrl;
  late Animation<double> _bgAnim;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _bgCtrl.dispose(); super.dispose(); }

  void _selectMood(int i) {
    setState(() => _selectedMood = i);
  }

  void _logMood() {
    if (_selectedMood == -1) return;
    setState(() {
      _log.insert(0, {
        ...moods[_selectedMood],
        'time': TimeOfDay.now().format(context),
      });
      _selectedMood = -1;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Mood logged ✨'),
      backgroundColor: const Color(0xFF7c3aed),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgAnim,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF1a0533), const Color(0xFF0f172a), _bgAnim.value)!,
                Color.lerp(const Color(0xFF3d1266), const Color(0xFF1e1b4b), _bgAnim.value)!,
              ],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(children: [
              _buildHeader(),
              Expanded(child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  const SizedBox(height: 8),
                  _buildQuestion(),
                  const SizedBox(height: 24),
                  _buildMoodGrid(),
                  const SizedBox(height: 24),
                  if (_selectedMood != -1) _buildSelectedCard(),
                  const SizedBox(height: 16),
                  _buildLogButton(),
                  const SizedBox(height: 32),
                  if (_log.isNotEmpty) _buildLog(),
                  const SizedBox(height: 32),
                ]),
              )),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('AuraMood', style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800,
            color: Colors.white, letterSpacing: -0.5,
          )),
          Text('${_log.length} entries today', style: const TextStyle(
            fontSize: 12, color: Color(0xFFd8b4fe),
          )),
        ]),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.insights_rounded, color: Colors.white, size: 22),
        ),
      ],
    ),
  );

  Widget _buildQuestion() => const Align(
    alignment: Alignment.centerLeft,
    child: Text('How is your\naura right now?', style: TextStyle(
      fontSize: 28, fontWeight: FontWeight.w800,
      color: Colors.white, height: 1.2, letterSpacing: -0.5,
    )),
  );

  Widget _buildMoodGrid() => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12,
      childAspectRatio: 0.9,
    ),
    itemCount: moods.length,
    itemBuilder: (_, i) {
      final selected = _selectedMood == i;
      return GestureDetector(
        onTap: () => _selectMood(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          decoration: BoxDecoration(
            color: selected
                ? (moods[i]['color'] as Color).withOpacity(0.25)
                : Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? moods[i]['color'] as Color : Colors.transparent,
              width: 2,
            ),
            boxShadow: selected ? [
              BoxShadow(
                color: (moods[i]['color'] as Color).withOpacity(0.4),
                blurRadius: 20, spreadRadius: 2,
              ),
            ] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(moods[i]['emoji'], style: const TextStyle(fontSize: 34)),
              const SizedBox(height: 8),
              Text(moods[i]['label'], style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFFd8b4fe),
              )),
            ],
          ),
        ),
      );
    },
  );

  Widget _buildSelectedCard() => AnimatedOpacity(
    opacity: _selectedMood != -1 ? 1 : 0,
    duration: const Duration(milliseconds: 300),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (moods[_selectedMood]['color'] as Color).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (moods[_selectedMood]['color'] as Color).withOpacity(0.4),
        ),
      ),
      child: Row(children: [
        Text(moods[_selectedMood]['emoji'], style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(moods[_selectedMood]['label'], style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
          )),
          Text(moods[_selectedMood]['desc'], style: const TextStyle(
            fontSize: 13, color: Color(0xFFd8b4fe),
          )),
        ]),
      ]),
    ),
  );

  Widget _buildLogButton() => GestureDetector(
    onTap: _logMood,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        gradient: _selectedMood != -1
            ? LinearGradient(colors: [
                moods[_selectedMood]['color'] as Color,
                (moods[_selectedMood]['color'] as Color).withOpacity(0.7),
              ])
            : const LinearGradient(colors: [Color(0xFF4b1d94), Color(0xFF6b21a8)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: _selectedMood != -1 ? [
          BoxShadow(
            color: (moods[_selectedMood]['color'] as Color).withOpacity(0.4),
            blurRadius: 20, offset: const Offset(0, 8),
          ),
        ] : [],
      ),
      child: const Center(child: Text('Log My Mood', style: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w700,
        color: Colors.white, letterSpacing: 0.3,
      ))),
    ),
  );

  Widget _buildLog() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Today\'s Journey', style: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700,
        color: Colors.white, letterSpacing: -0.3,
      )),
      const SizedBox(height: 14),
      ..._log.map((entry) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(children: [
            Text(entry['emoji'], style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry['label'], style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
              )),
              Text(entry['desc'], style: const TextStyle(
                fontSize: 12, color: Color(0xFFd8b4fe),
              )),
            ])),
            Text(entry['time'], style: const TextStyle(
              fontSize: 11, color: Color(0xFF9ca3af),
            )),
          ]),
        ),
      )),
    ],
  );
}