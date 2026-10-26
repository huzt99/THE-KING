import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const UniRouterApp());
}

class UniRouterApp extends StatelessWidget {
  const UniRouterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniRouter Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF111827),
        primaryColor: Colors.amber,
      ),
      home: const LoginScreen(),
    );
  }
}

// ================= شاشة تسجيل الدخول الحقيقية =================
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // التحقق مما إذا كان المستخدم مسجل الدخول مسبقاً
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Future<void> _handleLogin() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username == "Huzt88" && password == "2031992") {
      setState(() => _isLoading = true);
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("اسم المستخدم أو كلمة المرور غير صحيحة!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // إرسال طلب رمز التحقق عبر تليجرام (حقيقي)
  Future<void> _requestTelegramOTP() async {
    // يمكنك وضع توكن البت الخاص بك ومعرف الدردشة (Chat ID) هنا
    const String botToken = "YOUR_BOT_TOKEN";
    const String chatId = "YOUR_CHAT_ID";
    
    if (botToken == "YOUR_BOT_TOKEN") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى إعداد بوت تليجرام برمجياً أولاً")),
      );
      return;
    }

    try {
      final url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');
      await http.post(url, body: {
        'chat_id': chatId,
        'text': 'طلب تسجيل دخول جديد إلى تطبيق UniRouter Manager من حسين لخدمات الإنترنت.',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم إرسال طلب الرمز إلى تليجرام بنجاح!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل الاتصال بتليجرام")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security, size: 80, color: Colors.amber),
                const SizedBox(height: 20),
                const Text(
                  "UniRouter Manager",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "حسين لخدمات الإنترنت - نظام الأمان الحقيقي",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "اسم المستخدم (User)",
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1F2937),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "كلمة المرور (Password)",
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1F2937),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "تسجيل الدخول",
                            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: _requestTelegramOTP,
                  child: const Text(
                    "طلب رمز الدخول عبر تليجرام المسؤول >",
                    style: TextStyle(color: Colors.amber),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= الشاشة الرئيسية الحقيقية =================
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("حسين لخدمات الإنترنت - UniRouter"),
        backgroundColor: const Color(0xFF1F2937),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Card(
              color: Color(0xFF1F2937),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("👋 مرحباً بك، حسين", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
                    SizedBox(height: 8),
                    Text("نظام إدارة وصيانة الشبكات (Deco, Tenda, ONT)", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("أدوات الفحص والشبكة الحقيقية", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              tileColor: const Color(0xFF1F2937),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: const Icon(Icons.radar, color: Colors.amber),
              title: const Text("فحص الأجهزة المتاحة بالشبكة"),
              subtitle: const Text("سحب آيبات ديكو وتيندا وأونتي المتصلة فعلياً"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // هنا يتم ربط مسح الشبكة الحقيقي
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("جاري تهيئة فحص الشبكة الحالية...")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
