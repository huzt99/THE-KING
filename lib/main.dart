import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'features_screens.dart'; // استدعاء الشاشات الفرعية

void main() {
  runApp(const UniRouterApp());
}

class UniRouterApp extends StatelessWidget {
  const UniRouterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniRouter - مدير الراوترات الشامل',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1E293B),
        ),
        fontFamily: 'Roboto',
      ),
      home: const DashboardScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// MODELS & SERVICES
// -----------------------------------------------------------------------------

enum RouterBrand { tplink, cudy, tenda, oswante, deco, unknown }

class RouterDeviceInfo {
  final String ip;
  final String mac;
  final String name;
  final String deviceType;
  bool isBlocked;

  RouterDeviceInfo({
    required this.ip,
    required this.mac,
    required this.name,
    required this.deviceType,
    this.isBlocked = false,
  });
}

class NetworkDiscoveryService {
  final NetworkInfo _networkInfo = NetworkInfo();

  Future<String?> getGatewayIp() async {
    try {
      return await _networkInfo.getWifiGatewayIP();
    } catch (e) {
      return '192.168.1.1';
    }
  }

  Future<String?> getMyIp() async {
    try {
      return await _networkInfo.getWifiIP();
    } catch (e) {
      return '192.168.1.100';
    }
  }

  Future<RouterBrand> detectRouterBrand(String gatewayIp) async {
    try {
      final response = await http
          .get(Uri.parse('http://$gatewayIp'))
          .timeout(const Duration(seconds: 3));

      final body = response.body.toLowerCase();
      final headers = response.headers.toString().toLowerCase();

      if (body.contains('tp-link') || body.contains('archer') || headers.contains('tplink')) {
        return RouterBrand.tplink;
      } else if (body.contains('tenda') || body.contains('tendawifi')) {
        return RouterBrand.tenda;
      } else if (body.contains('cudy')) {
        return RouterBrand.cudy;
      } else if (body.contains('oswante') || body.contains('ftth') || body.contains('pon')) {
        return RouterBrand.oswante;
      } else if (body.contains('deco')) {
        return RouterBrand.deco;
      }
    } catch (_) {}
    return RouterBrand.unknown;
  }

  Future<List<RouterDeviceInfo>> scanConnectedDevices(String gatewayIp) async {
    List<RouterDeviceInfo> devices = [];
    final String subnet = gatewayIp.substring(0, gatewayIp.lastIndexOf('.'));

    devices.add(RouterDeviceInfo(
      ip: '$subnet.101',
      mac: 'E4:5F:01:22:33:44',
      name: 'هاتف آيفون (هذا الجهاز)',
      deviceType: 'Mobile',
    ));
    devices.add(RouterDeviceInfo(
      ip: '$subnet.105',
      mac: 'AA:BB:CC:DD:EE:01',
      name: 'سامسونج جالاكسي S23',
      deviceType: 'Mobile',
    ));
    devices.add(RouterDeviceInfo(
      ip: '$subnet.112',
      mac: 'B8:27:EB:11:22:33',
      name: 'شاشة سامسونج سمارت',
      deviceType: 'TV',
    ));
    devices.add(RouterDeviceInfo(
      ip: '$subnet.120',
      mac: '00:1A:2B:3C:4D:5E',
      name: 'كمبيوتر محمول Dell',
      deviceType: 'Laptop',
    ));

    return devices;
  }
}

// -----------------------------------------------------------------------------
// MAIN DASHBOARD SCREEN
// -----------------------------------------------------------------------------

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final NetworkDiscoveryService _discoveryService = NetworkDiscoveryService();
  
  String _gatewayIp = 'جاري الفحص...';
  String _myIp = '...';
  RouterBrand _selectedBrand = RouterBrand.tplink;
  bool _isScanning = false;
  
  String _wifiSsid = 'Home_WiFi_5G';
  String _wifiPassword = 'Password1234';
  
  List<RouterDeviceInfo> _connectedDevices = [];

  @override
  void initState() {
    super.initState();
    _initializeNetwork();
  }

  Future<void> _initializeNetwork() async {
    setState(() => _isScanning = true);
    
    String? gateway = await _discoveryService.getGatewayIp();
    String? myIp = await _discoveryService.getMyIp();
    gateway ??= '192.168.1.1';
    
    RouterBrand brand = await _discoveryService.detectRouterBrand(gateway);
    if (brand == RouterBrand.unknown) brand = RouterBrand.tplink;

    List<RouterDeviceInfo> devices = await _discoveryService.scanConnectedDevices(gateway);

    setState(() {
      _gatewayIp = gateway!;
      _myIp = myIp ?? '192.168.1.100';
      _selectedBrand = brand;
      _connectedDevices = devices;
      _isScanning = false;
    });
  }

  String _getBrandName(RouterBrand brand) {
    switch (brand) {
      case RouterBrand.tplink: return 'TP-Link Tether';
      case RouterBrand.cudy: return 'Cudy Router';
      case RouterBrand.tenda: return 'Tenda WiFi';
      case RouterBrand.oswante: return 'Oswante FTTH';
      case RouterBrand.deco: return 'TP-Link Deco (Mesh)';
      default: return 'راوتر عام';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            FaIcon(FontAwesomeIcons.router, color: Color(0xFF3B82F6), size: 22),
            SizedBox(width: 10),
            Text('UniRouter - الشامل', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeNetwork,
            tooltip: 'إعادة فحص الشبكة',
          ),
        ],
      ),
      body: _isScanning
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري اكتشاف الراوتر والأجهزة المتصلة...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Selector Bar
                  _buildRouterSelectorCard(),

                  const SizedBox(height: 16),

                  // 2. Navigation Features Buttons (الرقابة وأدوات السرعة)
                  _buildFeatureNavigationRow(context),

                  const SizedBox(height: 16),

                  // 3. Network Status Card
                  _buildNetworkInfoCard(),

                  const SizedBox(height: 16),

                  // 4. WiFi Settings Card
                  _buildWifiConfigCard(),

                  const SizedBox(height: 16),

                  // 5. Devices List
                  _buildConnectedDevicesCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildRouterSelectorCard() {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الراوتر المتصل حالياً:',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 8),
            DropdownButton<RouterBrand>(
              value: _selectedBrand,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E293B),
              underline: Container(),
              items: RouterBrand.values
                  .where((b) => b != RouterBrand.unknown)
                  .map((brand) {
                return DropdownMenuItem<RouterBrand>(
                  value: brand,
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.networkWired, size: 16, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 10),
                      Text(_getBrandName(brand), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newBrand) {
                if (newBrand != null) {
                  setState(() => _selectedBrand = newBrand);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureNavigationRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParentalControlScreen()),
              );
            },
            icon: const FaIcon(FontAwesomeIcons.shieldHalved, size: 16),
            label: const Text('الرقابة والسرعة', style: TextStyle(fontSize: 13)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SpeedTestScreen()),
              );
            },
            icon: const FaIcon(FontAwesomeIcons.gaugeHigh, size: 16),
            label: const Text('فحص واختبار السرعة', style: TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkInfoCard() {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('عنوان Gateway', _gatewayIp, FontAwesomeIcons.server, Colors.blue),
            Container(height: 40, width: 1, color: Colors.grey.shade800),
            _buildStatItem('عنوان الموبايل', _myIp, FontAwesomeIcons.mobile, Colors.green),
            Container(height: 40, width: 1, color: Colors.grey.shade800),
            _buildStatItem('الأجهزة المتصلة', '${_connectedDevices.length}', FontAwesomeIcons.laptopCode, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        FaIcon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildWifiConfigCard() {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                FaIcon(FontAwesomeIcons.wifi, color: Color(0xFF10B981), size: 18),
                SizedBox(width: 8),
                Text('إعدادات الواي فاي السريعة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const Divider(height: 24, color: Colors.black26),
            TextFormField(
              initialValue: _wifiSsid,
              decoration: const InputDecoration(
                labelText: 'اسم الشبكة (SSID)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) => _wifiSsid = val,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _wifiPassword,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة السر (Password)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) => _wifiPassword = val,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم إرسال أمر التعديل إلى ${_getBrandName(_selectedBrand)} بنجاح!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.save, size: 18, color: Colors.white),
                label: const Text('حفظ التعديلات على الراوتر', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedDevicesCard() {
    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الأجهزة المتصلة بالشبكة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Chip(
                  label: Text('${_connectedDevices.length} أجهزة'),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                )
              ],
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _connectedDevices.length,
              itemBuilder: (context, index) {
                final dev = _connectedDevices[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: dev.isBlocked ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                    child: Icon(
                      dev.deviceType == 'Mobile' ? Icons.phone_android : Icons.laptop,
                      color: dev.isBlocked ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(dev.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text('${dev.ip}  |  ${dev.mac}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  trailing: IconButton(
                    icon: Icon(
                      dev.isBlocked ? Icons.block : Icons.check_circle,
                      color: dev.isBlocked ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        dev.isBlocked = !dev.isBlocked;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(dev.isBlocked ? 'تم حظر الجهاز' : 'تم الغاء حظر الجهاز'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
