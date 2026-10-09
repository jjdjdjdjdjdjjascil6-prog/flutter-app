import 'dart:async';
import 'dart:math';
import 'package:flutter/material';

void main() {
  runApp(const RealSoccerGameApp());
}

class RealSoccerGameApp extends StatelessWidget {
  const RealSoccerGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0F1D),
        primaryColor: const Color(0xFF00FF87),
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final TextEditingController _playerNameController = TextEditingController(text: "ميسي");
  final TextEditingController _rivalNameController = TextEditingController(text: "رونالدو");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050B14), Color(0xFF101F32), Color(0xFF0A0F1D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF00FF87), Color(0xFF60EFFF)]),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF00FF87).withOpacity(0.4), blurRadius: 30, spreadRadius: 2)
                    ],
                  ),
                  child: const Icon(Icons.sports_soccer, size: 80, color: Color(0xFF050B14)),
                ),
                const SizedBox(height: 25),
                const Text(
                  "PRO STADIUM 26",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.black, letterSpacing: 3, color: Colors.white),
                ),
                const Text("محاكاة واقعية لأجواء الملاعب العالمية", style: TextStyle(fontSize: 14, color: Colors.cyanAccent)),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.edit, color: Color(0xFF00FF87), size: 18),
                          SizedBox(width: 8),
                          Text("تخصيص أسماء نجوم المباراة", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildPlayerInputField("اسم لاعبك (الهجوم السريع):", _playerNameController, Colors.cyanAccent),
                      const SizedBox(height: 15),
                      _buildPlayerInputField("اسم لاعب الخصم (المدافع):", _rivalNameController, Colors.amberAccent),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildMenuButton(context, "🎮 انطلاق المباراة الكبرى", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GameplayScreen(
                        playerName: _playerNameController.text,
                        rivalName: _rivalNameController.text,
                      ),
                    ),
                  );
                }, const Color(0xFF00FF87), Colors.black),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInputField(String label, TextEditingController controller, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black25,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: color, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, VoidCallback onPressed, Color bg, Color textCol) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: bg.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textCol)),
      ),
    );
  }
}

class GameplayScreen extends StatefulWidget {
  final String playerName;
  final String rivalName;

  const GameplayScreen({super.key, required this.playerName, required this.rivalName});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  double playerX = 0.0;
  double playerY = 0.65;
  double rivalX = 0.0;
  double rivalY = -0.65;
  double ballX = 0.0;
  double ballY = 0.0;
  double ballXSpeed = 0.018;
  double ballYSpeed = 0.018;
  int myScore = 0;
  int enemyScore = 0;
  int matchMinute = 0;
  String crowdChant = "📣 الجماهير تملأ المدرجات وتشعل الحماس!";
  bool isGoalAnimation = false;
  Timer? stadiumLoopTimer;

  @override
  void initState() {
    super.initState();
    _startMatchEngine();
  }

  void _startMatchEngine() {
    stadiumLoopTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (isGoalAnimation) return;

      setState(() {
        ballX += ballXSpeed;
        ballY += ballYSpeed;

        if (ballX >= 0.88 || ballX <= -0.88) {
          ballXSpeed = -ballXSpeed;
          crowdChant = "👏 تصفيق من الجماهير على كرة حماسية قريبة من الخط!";
        }

        if (ballX > rivalX && rivalX < 0.75) {
          rivalX += 0.012;
        } else if (ballX < rivalX && rivalX > -0.75) {
          rivalX -= 0.012;
        }

        if ((ballY - playerY).abs() < 0.06 && (ballX - playerX).abs() < 0.22) {
          ballYSpeed = -ballYSpeed.abs();
          ballXSpeed += (ballX - playerX) * 0.06;
          crowdChant = "🔥 ركلة قوية من النجم ${widget.playerName}!";
        }

        if ((ballY - rivalY).abs() < 0.06 && (ballX - rivalX).abs() < 0.22) {
          ballYSpeed = ballYSpeed.abs();
          ballXSpeed += (ballX - rivalX) * 0.06;
          crowdChant = "🛡️ تصدي رائع ومباغت من المدافع ${widget.rivalName}!";
        }

        if (ballY <= -0.92) {
          if (ballX.abs() < 0.32) {
            _triggerGoalCelebration(isMine: true);
          } else {
            ballYSpeed = -ballYSpeed;
          }
        }

        if (ballY >= 0.92) {
          if (ballX.abs() < 0.32) {
            _triggerGoalCelebration(isMine: false);
          } else {
            ballYSpeed = -ballYSpeed;
          }
        }

        if (Random().nextInt(100) < 4) {
          matchMinute++;
          if (matchMinute >= 90) {
            timer.cancel();
            _showFinalResultDialog();
          }
        }
      });
    });
  }

  void _triggerGoalCelebration({required bool isMine}) {
    isGoalAnimation = true;
    if (isMine) {
      myScore++;
      crowdChant = " GOAL!!! ⚽ جماهير الاستاد تهتز فرحاً بهدف ${widget.playerName}!";
    } else {
      enemyScore++;
      crowdChant = "😱 صدمة في المدرجات! هدف مباغت لصالح فريق ${widget.rivalName}!";
    }

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        isGoalAnimation = false;
        ballX = 0;
        ballY = 0;
        ballXSpeed = 0.018 * (Random().nextBool() ? 1 : -1);
        ballYSpeed = isMine ? -0.018 : 0.018;
      });
    });
  }

  void _showFinalResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF101F32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🏁 صافرة النهاية الشوط الثاني", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF00FF87), fontWeight: FontWeight.bold)),
        content: Text(
          "انتهت ملحمة الاستاد الكبرى!\n\nنتيجة المباراة النهائية:\nفريق [${widget.playerName}]: $myScore\nفريق [${widget.rivalName}]: $enemyScore",
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 16),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF87)),
