import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Курсы валют',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF2F4F8),
        fontFamily: 'Roboto',
      ),
      home: const CurrencyScreen(),
    );
  }
}

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  int _currentState = 1;
  List<Map<String, dynamic>> _rates = [];
  String _errorMessage = '';

  final Map<String, Map<String, String>> _currencyInfo = {
    'USD': {'name': 'Доллар США', 'flag': '🇺🇸'},
    'EUR': {'name': 'Евро', 'flag': '🇪🇺'},
    'GBP': {'name': 'Фунт стерлингов', 'flag': '🇬🇧'},
    'CNY': {'name': 'Китайский юань', 'flag': '🇨🇳'},
    'JPY': {'name': 'Японская йена', 'flag': '🇯🇵'},
    'AUD': {'name': 'Австралийский доллар', 'flag': '🇦🇺'},
    'AZN': {'name': 'Азербайджанский манат', 'flag': '🇦🇿'},
    'AMD': {'name': 'Армянский драм', 'flag': '🇦🇲'},
    'BYN': {'name': 'Белорусский рубль', 'flag': '🇧🇾'},
    'BRL': {'name': 'Бразильский реал', 'flag': '🇧🇷'},
    'HUF': {'name': 'Венгерский форинт', 'flag': '🇭🇺'},
    'HKD': {'name': 'Гонконгский доллар', 'flag': '🇭🇰'},
    'KZT': {'name': 'Казахстанский тенге', 'flag': '🇰🇿'},
    'CHF': {'name': 'Швейцарский франк', 'flag': '🇨🇭'},
    'CAD': {'name': 'Канадский доллар', 'flag': '🇨🇦'},
    'SGD': {'name': 'Сингапурский доллар', 'flag': '🇸🇬'},
    'KRW': {'name': 'Южнокорейская вона', 'flag': '🇰🇷'},
    'INR': {'name': 'Индийская рупия', 'flag': '🇮🇳'},
    'TRY': {'name': 'Турецкая лира', 'flag': '🇹🇷'},
    'UAH': {'name': 'Украинская гривна', 'flag': '🇺🇦'},
  };

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() {
      _currentState = 1;
    });

    try {
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/RUB'),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final Map<String, dynamic> ratesMap = data['rates'];

      List<Map<String, dynamic>> loadedRates = [];

      for (var code in _currencyInfo.keys) {
        if (ratesMap.containsKey(code)) {
          final double rate = 1 / (ratesMap[code] as num).toDouble();
          loadedRates.add({
            'name': _currencyInfo[code]!['name'],
            'code': code,
            'flag': _currencyInfo[code]!['flag'],
            'value': rate,
          });
        }
      }

      loadedRates.sort((a, b) => a['name'].compareTo(b['name']));

      setState(() {
        _rates = loadedRates;
        _currentState = 0;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _currentState = 2;
      });
    }
  }

  // --- МОДАЛЬНОЕ ОКНО С ДЕТАЛЯМИ ---
  void _showCurrencyDetails(Map<String, dynamic> rate) {
    final double rubValue = rate['value']; // Сколько рублей за 1 единицу
    final double reverseValue = 1 / rubValue; // Сколько единиц за 1 рубль

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Полоска сверху для закрытия (визуальная)
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Флаг и Название
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      rate['flag'],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rate['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        Text(
                          rate['code'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Блок с курсами
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1 ${rate['code']}', style: const TextStyle(fontSize: 16)),
                        Text(
                          '${rubValue.toStringAsFixed(2)} ₽',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4C5BD4),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1 ₽', style: const TextStyle(fontSize: 16)),
                        Text(
                          '${reverseValue.toStringAsFixed(4)} ${rate['code']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4C5BD4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Кнопка закрыть
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C5BD4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Закрыть',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, bottom: 24, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF4C5BD4),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Курсы валют',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Актуальные данные на сегодня',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _fetchRates,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_currentState == 1) {
      return _buildLoadingState();
    } else if (_currentState == 2) {
      return _buildErrorState();
    } else {
      return _buildListState();
    }
  }

  Widget _buildListState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rates.length + 1,
      itemBuilder: (context, index) {
        if (index == _rates.length) {
          return const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 20),
            child: Center(
              child: Text(
                'Демонстрационные значения,\nне актуальные котировки.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }
        final rate = _rates[index];
        return _buildCard(rate);
      },
    );
  }

  // --- КАРТОЧКА (с обработкой нажатия) ---
  Widget _buildCard(Map<String, dynamic> rate) {
    return GestureDetector(
      onTap: () => _showCurrencyDetails(rate), // Вызов модального окна
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rate['flag'],
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rate['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '1 ${rate['code']}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${rate['value'].toStringAsFixed(2)} ₽',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF4C5BD4),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'за 1 ед.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF4C5BD4),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Загрузка данных...',
            style: TextStyle(
              color: Color(0xFF4C5BD4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off,
              color: Color(0xFFE57373),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Не удалось\nзагрузить данные',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchRates,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C5BD4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Попробовать снова',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}