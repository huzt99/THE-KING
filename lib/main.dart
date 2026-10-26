import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    const SavedRoutersTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniRouter - حسين لخدمات الإنترنت'),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('بوت التليجرام متصل وجاهز لإرسال التنبيهات')),
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
                  icon: Icon(Icons.router_outlined),
                  selectedIcon: Icon(Icons.router),
                  label: Text('الراوترات المحفوظة'),
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
              selectedItemColor: Colors.blueAccent,
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
                  label: 'فحص الشبكة',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.router),
                  label: 'المحفوظة',
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
          const Text(
            'مرحباً بك، حسين 👋',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'نظام إدارة وصيانة شبكات الإنترنت والراوترات.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              DashboardCard(
                title: 'الأجهزة المحفوظة',
                value: '4 راوترات',
                icon: Icons.router,
                color: Colors.blue,
              ),
              DashboardCard(
                title: 'بوابة الشبكة (Gateway)',
                value: '192.168.1.1',
                icon: Icons.lan,
                color: Colors.green,
              ),
              DashboardCard(
                title: 'تكامل التليجرام',
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
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 15),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            label: const Text('بدء فحص الشبكة'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildConnectedDeviceItem(context, 'الراوتر الرئيسي (Gateway)', '192.168.1.1', 'TP-Link / Cudy'),
                _buildConnectedDeviceItem(context, 'صحن / نانو (Ubiquiti Dish)', '192.168.1.20', 'PowerBeam M5 / AC'),
                _buildConnectedDeviceItem(context, 'جهاز أونيو (FTTH ONU)', '192.168.100.1', 'Huawei ONU'),
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

// ==================== 3. شاشة الراوترات المحفوظة والربط المباشر ====================
class SavedRoutersTab extends StatelessWidget {
  const SavedRoutersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> sampleRouters = [
      {
        'name': 'TP-Link Archer C20',
        'ip': '192.168.0.1',
        'nanoIp': '192.168.1.20',
        'onuIp': '192.168.100.1',
        'type': 'TP-Link Router'
      },
      {
        'name': 'Tenda N300 / F3',
        'ip': '192.168.0.1',
        'nanoIp': '192.168.1.21',
        'onuIp': '192.168.100.1',
        'type': 'Tenda Router'
      },
      {
        'name': 'Cudy WR1300',
        'ip': '192.168.10.1',
        'nanoIp': '192.168.1.22',
        'onuIp': '192.168.100.1',
        'type': 'Cudy Mesh/Router'
      },
      {
        'name': 'MikroTik Main Board',
        'ip': '192.168.88.1',
        'nanoIp': '192.168.1.254',
        'onuIp': '192.168.100.1',
        'type': 'MikroTik Core'
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
              const Text('الراوترات المحفوظة والأجهزة المقترنة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة راوتر'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: sampleRouters.length,
              itemBuilder: (context, index) {
                final r = sampleRouters[index];
                return Card(
                  color: const Color(0xFF1E293B),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.router, color: Colors.orangeAccent, size: 32),
                    title: Text(r['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('IP: ${r['ip']} | نوع: ${r['type']}'),
                    trailing: ElevatedButton.icon(
                      icon: const Icon(Icons.link, size: 16),
                      label: const Text('فتح الأجهزة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF334155),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        _showDeviceQuickAccessModal(
                          context,
                          routerName: r['name']!,
                          routerIp: r['ip']!,
                          nanoIp: r['nanoIp']!,
                          onuIp: r['onuIp']!,
                        );
                      },
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

// ==================== Modal النافذة التفاعلية للوصول السريع للأجهزة ====================
void _showDeviceQuickAccessModal(
  BuildContext context, {
  required String routerName,
  required String routerIp,
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
                const Icon(Icons.hub, color: Colors.blueAccent, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routerName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'عنوان الراوتر الرئيسي: $routerIp',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 25, color: Colors.white10),
            const Text(
              'اختر الجهاز المراد الدخول لصفحته مباشرة:',
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),

            // 1. الدخول للراوتر
            ListTile(
              tileColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.router, color: Colors.white, size: 20),
              ),
              title: const Text('صفحة إعدادات الراوتر', style: TextStyle(color: Colors.white)),
              subtitle: Text('http://$routerIp', style: const TextStyle(color: Colors.grey)),
              trailing: const Icon(Icons.open_in_new, color: Colors.blueAccent),
              onTap: () {
                Navigator.pop(context);
                _openUrl(context, routerIp);
              },
            ),
            const SizedBox(height: 10),

            // 2. الدخول للنانو (Ubiquiti)
            ListTile(
              tileColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const CircleAvatar(
                backgroundColor: Colors.orangeAccent,
                child: Icon(Icons.cell_tower, color: Colors.white, size: 20),
              ),
              title: const Text('صفحة النانو (Ubiquiti PowerBeam / AirOS)', style: TextStyle(color: Colors.white)),
              subtitle: Text('http://$nanoIp', style: const TextStyle(color: Colors.grey)),
              trailing: const Icon(Icons.open_in_new, color: Colors.orangeAccent),
              onTap: () {
                Navigator.pop(context);
                _openUrl(context, nanoIp);
              },
            ),
            const SizedBox(height: 10),

            // 3. الدخول للأونيو (FTTH ONU/ONT)
            ListTile(
              tileColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.settings_input_antenna, color: Colors.white, size: 20),
              ),
              title: const Text('صفحة الأونيو (FTTH ONU / Huawei ONT)', style: TextStyle(color: Colors.white)),
              subtitle: Text('http://$onuIp', style: const TextStyle(color: Colors.grey)),
              trailing: const Icon(Icons.open_in_new, color: Colors.green),
              onTap: () {
                Navigator.pop(context);
                _openUrl(context, onuIp);
              },
            ),
          ],
        ),
      );
    },
  );
}

// دالة فتح الرابط عبر متصفح الهاتف
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
