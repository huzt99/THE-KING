import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dart_ping/dart_ping.dart';

void main() {
  runApp(const UniRouterApp());
}

class UniRouterApp extends StatelessWidget {
  const UniRouterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniRouter - Hussein Net',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        fontFamily: 'Cairo',
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeTab(),
    const ScannerTab(),
    const SavedRoutersTab(), // إدارة المشتركين والوصول عن بُعد
    const DiagnosticsTab(),  // أداة فحص الـ Ping والتشخيص
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield, color: Colors.orangeAccent, size: 24),
            SizedBox(width: 10),
            Text('UniRouter - حسين لخدمات الإنترنت'),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.orangeAccent),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('بوت التليجرام متصل وجاهز لإرسال التنبيهات لشبكة حسين نت')),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width > 800)
            NavigationRail(
              backgroundColor: const Color(0xFF1E293B),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('الرئيسية'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.wifi_find_outlined),
                  selectedIcon: Icon(Icons.wifi_find),
                  label: Text('فحص الشبكة'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('المشتركين'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.network_check_outlined),
                  selectedIcon: Icon(Icons.network_check),
                  label: Text('التشخيص'),
                ),
              ],
            ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 800
          ? BottomNavigationBar(
              backgroundColor: const Color(0xFF1E293B),
              selectedItemColor: Colors.orangeAccent,
              unselectedItemColor: Colors.grey,
              currentIndex: _selectedIndex,
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.wifi_find),
                  label: 'الفحص',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'المشتركين',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.network_check),
                  label: 'التشخيص',
                ),
              ],
            )
          : null,
    );
  }
}

// ==================== 1. شاشة الرئيسية ====================
class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          Row(
            children: [
              // عرض شعار التطبيق المصغر إذا توفر في الأصول
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orangeAccent, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/icon/app_icon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً بك، حسين 👋',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Hussein Net - نظام إدارة وصيانة الشبكات',
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              DashboardCard(
                title: 'إدارة المشتركين',
                value: '4 مشتركين مسجلين',
                icon: Icons.people,
                color: Colors.blue,
              ),
              DashboardCard(
                title: 'بوابة الشبكة الأساسية',
                value: '192.168.1.1',
                icon: Icons.lan,
                color: Colors.green,
              ),
              DashboardCard(
                title: 'تنبيهات التليجرام',
                value: 'متصل وجاهز',
                icon: Icons.smart_toy,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 15),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ==================== 2. شاشة فحص الشبكة ====================
class ScannerTab extends StatelessWidget {
  const ScannerTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('فحص الأجهزة على الشبكة المحلية (Network Scanner)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري فحص نطاق IP الحالي (192.168.1.x)...')),
              );
            },
            icon: const Icon(Icons.search),
            label: const Text('بدء فحص الشبكة المحلية'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildConnectedDeviceItem(context, 'الراوتر الرئيسي', '192.168.1.1', 'TP-Link / Cudy'),
                _buildConnectedDeviceItem(context, 'صحن النانو (Tower)', '192.168.1.20', 'PowerBeam M5'),
                _buildConnectedDeviceItem(context, 'جهاز الأونيو (FTTH)', '192.168.100.1', 'Huawei ONU'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedDeviceItem(BuildContext context, String title, String ip, String deviceType) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.devices, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('IP: $ip - ($deviceType)'),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_browser, color: Colors.greenAccent),
          onPressed: () => _openUrl(context, ip),
        ),
      ),
    );
  }
}

// ==================== 3. شاشة المشتركين وإدارة الراوترات عن بُعد ====================
class SavedRoutersTab extends StatelessWidget {
  const SavedRoutersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> subscribers = [
      {
        'subscriber': 'محمد أحمد (منطقة العسكري)',
        'phone': '07800000000',
        'routerName': 'TP-Link Archer C20',
        'localIp': '192.168.0.1',
        'remoteIp': '100.64.10.5',
        'nanoIp': '192.168.1.20',
        'onuIp': '192.168.100.1',
      },
      {
        'subscriber': 'علي حسين (شارع الأطباء)',
        'phone': '07700000000',
        'routerName': 'Tenda N300 / F3',
        'localIp': '192.168.0.1',
        'remoteIp': '100.64.10.12',
        'nanoIp': '192.168.1.21',
        'onuIp': '192.168.100.1',
      },
      {
        'subscriber': 'كرار جبار (حي الحسين)',
        'phone': '07811111111',
        'routerName': 'Cudy WR1300',
        'localIp': '192.168.10.1',
        'remoteIp': '100.64.10.25',
        'nanoIp': '192.168.1.22',
        'onuIp': '192.168.100.1',
      },
      {
        'subscriber': 'احمد كاظم (منطقة النقيب)',
        'phone': '07822222222',
        'routerName': 'MikroTik CPE',
        'localIp': '192.168.88.1',
        'remoteIp': '100.64.10.99',
        'nanoIp': '192.168.1.254',
        'onuIp': '192.168.100.1',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إدارة المشتركين والوصول عن بُعد',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('خاصية إضافة مشترك جديد قيد التفعيل')),
                  );
                },
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('إضافة مشترك'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: subscribers.length,
              itemBuilder: (context, index) {
                final sub = subscribers[index];
                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.orangeAccent, size: 22),
                                const SizedBox(width: 8),
                                Text(sub['subscriber']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              ],
                            ),
                            Text('هاتف: ${sub['phone']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const Divider(height: 15, color: Colors.white10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('الراوتر: ${sub['routerName']}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                                const SizedBox(height: 3),
                                Text('Local: ${sub['localIp']} | Remote: ${sub['remoteIp']}', style: const TextStyle(fontSize: 11, color: Colors.greenAccent)),
                              ],
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.settings_remote, size: 16),
                              label: const Text('إدارة عن بُعد'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF334155),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                _showRemoteControlModal(
                                  context,
                                  subscriberName: sub['subscriber']!,
                                  localIp: sub['localIp']!,
                                  remoteIp: sub['remoteIp']!,
                                  nanoIp: sub['nanoIp']!,
                                  onuIp: sub['onuIp']!,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 4. شاشة الاتصال والتشخيص (Diagnostics & Ping) ====================
class DiagnosticsTab extends StatefulWidget {
  const DiagnosticsTab({Key? key}) : super(key: key);

  @override
  State<DiagnosticsTab> createState() => _DiagnosticsTabState();
}

class _DiagnosticsTabState extends State<DiagnosticsTab> {
  final TextEditingController _ipController = TextEditingController(text: '192.168.1.1');
  String _pingResult = 'اضغط على بدء التشخيص لفحص العنوان...';
  bool _isPingRunning = false;

  void _startPing() async {
    final targetIp = _ipController.text.trim();
    if (targetIp.isEmpty) return;

    setState(() {
      _isPingRunning = true;
      _pingResult = 'جاري إرسال حزم البيانات إلى $targetIp...\n';
    });

    try {
      final ping = Ping(targetIp, count: 4);
      ping.stream.listen((event) {
        setState(() {
          if (event.response != null) {
            _pingResult += 'استجابة: IP=${event.response?.ip} | الوقت=${event.response?.time?.inMilliseconds}ms\n';
          } else if (event.summary != null) {
            _pingResult += '\n--- ملخص الفحص ---\nالمرسل: ${event.summary?.transmitted}, المستقبل: ${event.summary?.received}, الفاقد: ${event.summary?.packetLoss}%\n';
          }
        });
      }, onDone: () {
        setState(() {
          _isPingRunning = false;
          _pingResult += '\n[تم الانتهاء من الفحص بنجاح]';
        });
      });
    } catch (e) {
      setState(() {
        _isPingRunning = false;
        _pingResult = 'حدث خطأ أثناء الاتصال: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          const Text(
            'أداة التشخيص والفحص (Ping & Connection)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 5),
          const Text(
            'فحص سرعة استجابة واستقرار الراوتر، النانو، أو الأونيو لأي مشترك.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _ipController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'عنوان IP (المحلي أو الخارجي للعميل)',
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.lan, color: Colors.blueAccent),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isPingRunning ? null : _startPing,
            icon: _isPingRunning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_isPingRunning ? 'جاري الفحص...' : 'بدء فحص الـ Ping للعميل'),
          ),
          const SizedBox(height: 20),
          const Text(
            'نتائج التشخيص المباشرة:',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: SingleChildScrollView(
              child: Text(
                _pingResult,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Modal نافذة التحكم والوصول عن بُعد للمشترك ====================
void _showRemoteControlModal(
  BuildContext context, {
  required String subscriberName,
  required String localIp,
  required String remoteIp,
  required String nanoIp,
  required String onuIp,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.support_agent, color: Colors.blueAccent, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscriberName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const Text(
                        'إدارة اتصالات وصيانة العميل',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: Colors.white10),
            const Text(
              'اختر نوع الاتصال (من مقر العمل أو بالمنزل):',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // 1. الدخول عبر الـ Remote / VPN (من مقر العمل)
            ListTile(
              tileColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.cloud_sync, color: Colors.white, size: 18),
              ),
              title: const Text('فتح راوتر العميل (عن بُعد / Remote IP)', style: TextStyle(fontSize: 13, color: Colors.white)),
              subtitle: Text('http://$remoteIp', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              trailing: const Icon(Icons.open_in_new, color: Colors.green, size: 18),
              onTap: () {
                Navigator.pop(context);
                _openUrl(context, remoteIp);
              },
            ),
            const SizedBox(height: 8),

            // 2. الدخول للـ Local (أثناء الصيانة الميدانية في البيت)
            ListTile(
              tileColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.router, color: Colors.white, size: 18),
              ),
              title: const Text('راوتر العميل (محلي / Local IP)', style: TextStyle(fontSize: 13, color: Colors.white)),
              subtitle: Text('http://$localIp', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              trailing: const Icon(Icons.open_in_new, color: Colors.blueAccent, size: 18),
              onTap: () {
                Navigator.pop(context);
                _openUrl(context, localIp);
              },
            ),
            const SizedBox(height: 8),

            // 3. النانو الخاص بالعميل
            ListTile(
              tileColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: const CircleAvatar(
                backgroundColor: Colors.orangeAccent,
                child: Icon(Icons.cell_tower, color: Colors.white, size: 18),
              ),
              title: const Text('صحن النانو الخاص بالعميل (Nano/AirOS)', style: TextStyle(fontSize: 13, color: Colors.white)),
              subtitle: Text('http://$nanoIp', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              trailing: const Icon(Icons.open_in_new, color: Colors.orangeAccent, size: 18),
              onTap: () {
                Navigator.pop(context);
                _openUrl(context, nanoIp);
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _openUrl(BuildContext context, String ipAddress) async {
  final Uri url = Uri.parse('http://$ipAddress');
  try {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر فتح الصفحة: $ipAddress')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('خطأ أثناء فتح الرابط: http://$ipAddress')),
    );
  }
}
