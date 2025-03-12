import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

// API istemci sınıfı
class DeviceApiClient {
  static const String _baseUrl = 'http://192.168.4.1';

  Future<String> fetchUartData() async {
    return _get('/uartData');
  }

  Future<void> toggleColdLight() async {
    await _get('/toggleColdLight');
  }

  Future<void> toggleRed() async {
    await _get('/toggleRed');
  }

  Future<void> toggleBlue() async {
    await _get('/toggleBlue');
  }

  Future<void> toggleGreen() async {
    await _get('/toggleGreen');
  }

  Future<String> _get(String path) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl$path'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('API error: $e');
      throw Exception('API isteği başarısız: $e');
    }
  }
}

// Veri sınıfı
class SensorData {
  final String temperature;
  final String humidity;
  final DateTime lastUpdated;

  SensorData({
    required this.temperature,
    required this.humidity,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory SensorData.fromString(String data) {
    final tempMatch = RegExp(r'Temperature:\s*([\d.]+)\s*\*C').firstMatch(data);
    final humMatch = RegExp(r'Humidity:\s*([\d.]+)\s*%RH').firstMatch(data);

    return SensorData(
      temperature: tempMatch?.group(1) ?? "N/A",
      humidity: humMatch?.group(1) ?? "N/A",
    );
  }

  factory SensorData.empty() {
    return SensorData(
      temperature: "N/A",
      humidity: "N/A",
      lastUpdated: DateTime.now(),
    );
  }

  String get formattedLastUpdated {
    return '${lastUpdated.hour.toString().padLeft(2, '0')}:${lastUpdated.minute.toString().padLeft(2, '0')}:${lastUpdated.second.toString().padLeft(2, '0')}';
  }
}

// Buton tipi
enum DeviceFeature {
  ai(
    activeText: 'AI Active',
    inactiveText: 'AI',
    icon: FontAwesomeIcons.brain,
    activeColor: Colors.pinkAccent,
  ),
  heatUp(
    activeText: 'Temperature Increasing...',
    inactiveText: 'Increase Temperature',
    icon: FontAwesomeIcons.lightbulb,
    activeColor: Colors.redAccent,
  ),
  coolDown(
    activeText: 'Lowering Temperature...',
    inactiveText: 'Lower Temperature',
    icon: FontAwesomeIcons.snowflake,
    activeColor: Colors.blue,
  ),
  clean(
    activeText: 'Cleaning the Room...',
    inactiveText: 'Clean the Room',
    icon: FontAwesomeIcons.wind,
    activeColor: Colors.greenAccent,
  );

  final String activeText;
  final String inactiveText;
  final IconData icon;
  final Color activeColor;

  const DeviceFeature({
    required this.activeText,
    required this.inactiveText,
    required this.icon,
    required this.activeColor,
  });
}

class WeatherCard extends StatefulWidget {
  final String city;
  final String temperature;
  final String weather;
  final String sunrise;
  final String sunset;
  final String maxTemp;
  final String minTemp;
  final String humidity;
  final String windSpeed;
  final bool isDayTime;

  const WeatherCard({
    Key? key,
    required this.city,
    required this.temperature,
    required this.weather,
    required this.sunrise,
    required this.sunset,
    required this.maxTemp,
    required this.minTemp,
    required this.humidity,
    required this.windSpeed,
    required this.isDayTime,
  }) : super(key: key);

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  final DeviceApiClient _apiClient = DeviceApiClient();
  SensorData _sensorData = SensorData.empty();

  // Her bir özellik için durum izleme
  final Map<DeviceFeature, bool> _featureStatus = {
    DeviceFeature.ai: false,
    DeviceFeature.heatUp: false,
    DeviceFeature.coolDown: false,
    DeviceFeature.clean: false,
  };

  // Yükleniyor durumu
  bool _isLoading = false;
  // Hata durumu
  String? _errorMessage;
  // İlk yükleme
  bool _initialDataLoaded = false;

  Future<void> _fetchSensorData() async {
    if (_isLoading) return; // Zaten yükleniyorsa çık

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final data = await _apiClient.fetchUartData();

      if (!mounted) return;

      setState(() {
        _sensorData = SensorData.fromString(data);
        _isLoading = false;
        _initialDataLoaded = true;
      });

      // Başarılı güncelleme bildirimi
      if (!_initialDataLoaded) return; // İlk yüklemede bildirim gösterme

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veriler başarıyla güncellendi'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Veri alınamadı. Lütfen bağlantınızı kontrol edin.';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veri güncelleme hatası: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _toggleFeature(DeviceFeature feature) async {
    try {
      setState(
          () => _featureStatus[feature] = !(_featureStatus[feature] ?? false));

      switch (feature) {
        case DeviceFeature.ai:
          await _apiClient.toggleColdLight();
          break;
        case DeviceFeature.heatUp:
          await _apiClient.toggleRed();
          break;
        case DeviceFeature.coolDown:
          await _apiClient.toggleBlue();
          break;
        case DeviceFeature.clean:
          await _apiClient.toggleGreen();
          break;
      }

      // Başarılı değişiklik bildirimi
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${feature.name} özelliği ${_featureStatus[feature]! ? 'aktif edildi' : 'devre dışı bırakıldı'}'),
          backgroundColor:
              _featureStatus[feature]! ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Hata durumunda buton durumunu geri al
      if (!mounted) return;

      setState(() {
        _featureStatus[feature] = !(_featureStatus[feature] ?? false);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İşlem başarısız: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Sadece uygulama başlatıldığında ilk verileri yükle
    _fetchSensorData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(
                  widget.isDayTime
                      ? 'assets/images/5.jpg'
                      : 'assets/images/6.jpg',
                ))),
        child: SafeArea(
          child: _buildContent(size),
        ),
      ),
    );
  }

  Widget _buildContent(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.05,
        horizontal: size.width * 0.05,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child:
              _errorMessage != null ? _buildErrorState() : _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Bir hata oluştu',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchSensorData,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden Dene'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSensorData(),
              const SizedBox(height: 32),
              _buildFeatureSection(),
            ],
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          widget.isDayTime ? Icons.wb_sunny : Icons.nightlight_round,
          color: widget.isDayTime ? Colors.orange : Colors.indigo,
          size: 32,
        ),
        const SizedBox(width: 12),
        Text(
          widget.city,
          style: const TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSensorData() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Cihaz Sensör Verileri",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _fetchSensorData,
                icon: const Icon(Icons.refresh),
                label: const Text('Yenile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          _buildSensorRow(
            icon: Icons.thermostat,
            label: "Sıcaklık:",
            value: "${_sensorData.temperature} °C",
          ),
          const SizedBox(height: 12),
          _buildSensorRow(
            icon: Icons.water_drop,
            label: "Nem:",
            value: "${_sensorData.humidity} %RH",
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Son güncelleme: ${_sensorData.formattedLastUpdated}',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Cihaz Kontrolleri",
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: DeviceFeature.values.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final feature = DeviceFeature.values[index];
            return _buildFeatureButton(feature);
          },
        ),
      ],
    );
  }

  Widget _buildFeatureButton(DeviceFeature feature) {
    final isActive = _featureStatus[feature] ?? false;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive
            ? feature.activeColor.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        border: Border.all(
          color: isActive ? feature.activeColor : Colors.grey.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _toggleFeature(feature),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  feature.icon,
                  size: 24,
                  color: isActive ? feature.activeColor : Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isActive ? feature.activeText : feature.inactiveText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isActive ? feature.activeColor : Colors.black87,
                    ),
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: (_) => _toggleFeature(feature),
                  activeColor: feature.activeColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
