import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// =============================================================================
// 1. شاشة الرقابة الأبوية وتحديد السرعة (Parental Controls & QoS)
// =============================================================================

class ParentalControlScreen extends StatefulWidget {
  const ParentalControlScreen({super.key});

  @override
  State<ParentalControlScreen> createState() => _ParentalControlScreenState();
}

class _ParentalControlScreenState extends State<ParentalControlScreen> {
  // حالة الأجهزة وقيم السرعة المخصصة لكل جهاز
  final List<Map<String, dynamic>> _devicesQos = [
    {'name': 'هاتف آيفون (أحمد)', 'downloadLimit': 15.0, 'uploadLimit': 5.0, 'bedtimeActive': true},
    {'name': 'آيباد الأطفال', 'downloadLimit': 5.0, 'uploadLimit': 2.0, 'bedtimeActive': true},
    {'name': 'شاشة الصالة الذكية', 'downloadLimit': 25.0, 'uploadLimit': 10.0, 'bedtimeActive': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرقابة الأبوية وتحديد السرعة'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _devicesQos.length,
        itemBuilder: (context, index) {
          final device = _devicesQos[index];
          return Card(
            color: const Color(0xFF1E293B),
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.shieldHalved, color: Color(0xFF3B82F6), size: 18),
                          const SizedBox(width: 8),
                          Text(device['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Switch(
                        value: device['bedtimeActive'],
                        activeColor: Colors.blue,
                        onChanged: (val) {
                          setState(() {
                            device['bedtimeActive'] = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const Text('وضع النوم (قطع الإنترنت ليلاً): مفعل تلقائياً', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const Divider(height: 24, color: Colors.black26),
                  
                  // شريط سرعة التحميل (Download Limit)
                  Text('حد التحميل: ${device['downloadLimit'].toStringAsFixed(1)} Mbps', style: const TextStyle(fontSize: 13)),
                  Slider(
                    value: device['downloadLimit'],
                    min: 1.0,
                    max: 50.0,
                    divisions: 49,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      setState(() {
                        device['downloadLimit'] = val;
                      });
                    },
                  ),

                  // شريط سرعة الرفع (Upload Limit)
                  Text('حد الرفع: ${device['uploadLimit'].toStringAsFixed(1)} Mbps', style: const TextStyle(fontSize: 13)),
                  Slider(
                    value: device['uploadLimit'],
                    min: 1.0,
                    max: 20.0,
                    divisions: 19,
                    activeColor: const Color(0xFF3B82F6),
                    onChanged: (val) {
                      setState(() {
                        device['uploadLimit'] = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// 2. شاشة اختبار السرعة وأدوات صيانة النظام (SpeedTest & Tools)
// =============================================================================

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  bool _isTesting = false;
  double _downloadSpeed = 0.0;
  double _uploadSpeed = 0.0;
  int _pingTime = 0;
  String _testStatus = 'جاهز لبدء الفحص';

  void _startSpeedTest() {
    setState(() {
      _isTesting = true;
      _downloadSpeed = 0.0;
      _uploadSpeed = 0.0;
      _pingTime = 12;
      _testStatus = 'جاري فحص الـ Ping...';
    });

    // محاكاة حية لاختبار السرعة
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        if (_downloadSpeed < 85.5) {
          _downloadSpeed += 7.5;
          _testStatus = 'جاري اختبار التحميل (Download)...';
        } else if (_uploadSpeed < 32.0) {
          _uploadSpeed += 4.0;
          _testStatus = 'جاري اختبار الرفع (Upload)...';
        } else {
          _testStatus = 'اكتمل الفحص بنجاح!';
          _isTesting = false;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختبار السرعة وأدوات الصيانة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // بطاقة السرعة الكبرى
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const FaIcon(FontAwesomeIcons.gaugeHigh, color: Color(0xFF3B82F6), size: 48),
                    const SizedBox(height: 16),
                    Text(_testStatus, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSpeedGaugeItem('التحميل', '${_downloadSpeed.toStringAsFixed(1)} Mbps', Colors.green),
                        _buildSpeedGaugeItem('الرفع', '${_uploadSpeed.toStringAsFixed(1)} Mbps', Colors.blue),
                        _buildSpeedGaugeItem('البينغ (Ping)', '$_pingTime ms', Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _isTesting ? null : _startSpeedTest,
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: Text(_isTesting ? 'جاري الفحص...' : 'بدء فحص السرعة الان', style: const TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // أزرار صيانة الراوتر
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildToolButton('إعادة تشغيل الراوتر', FontAwesomeIcons.rotate, Colors.red, () {
                    _showActionDialog(context, 'تم إرسال أمر إعادة التشغيل (Reboot) للراوتر بنجاح.');
                  }),
                  _buildToolButton('تحديث النظام (Firmware)', FontAwesomeIcons.cloudArrowUp, Colors.purple, () {
                    _showActionDialog(context, 'الراوتر يعمل بأحدث إصدار متوفر حالياً.');
                  }),
                  _buildToolButton('نسخ الاحتياطي للإعدادات', FontAwesomeIcons.download, Colors.teal, () {
                    _showActionDialog(context, 'تم حفظ ملف إعدادات الراوتر بنجاح في جهازك.');
                  }),
                  _buildToolButton('فحص الثغرات والأمان', FontAwesomeIcons.lock, Colors.amber, () {
                    _showActionDialog(context, 'شبكتك محمية بتشفير WPA3 القوي. لا توجد ثغرات.');
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedGaugeItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildToolButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showActionDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('إشعار النظام'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
