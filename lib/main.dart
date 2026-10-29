import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyRate {
  final String code;
  final double value;
  final int nominal;

  CurrencyRate({
    required this.code,
    required this.value,
    required this.nominal,
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
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
  List<CurrencyRate> _rates = [];
  bool _isLoading = true;
  String? _error;

  // Названия валют для красивого отображения
  final Map<String, String> currencyNames = {
    'USD': 'Доллар США',
    'EUR': 'Евро',
    'GBP': 'Фунт стерлингов',
    'CNY': 'Китайский юань',
    'JPY': 'Японская йена',
    'AUD': 'Австралийский доллар',
    'AZN': 'Азербайджанский манат',
    'AMD': 'Армянский драм',
    'BYN': 'Белорусский рубль',
    'BRL': 'Бразильский реал',
    'HUF': 'Венгерский форинт',
    'HKD': 'Гонконгский доллар',
    'DZD': 'Алжирский динар',
    'BOB': 'Боливийский боливиано',
    'VND': 'Вьетнамский донг',
  };

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    try {
      // Запрос к API, который отдает данные в JSON (UTF-8)
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/RUB'),
      );

      if (response.statusCode != 200) {
        throw Exception('Статус: ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final Map<String, dynamic> ratesMap = data['rates'];

      List<CurrencyRate> loadedRates = [];

      // Берем только популярные валюты для красоты
      final targetCodes = ['USD', 'EUR', 'GBP', 'CNY', 'JPY', 'AUD', 'AZN', 'AMD', 'BYN', 'BRL', 'HUF', 'HKD'];

      for (var code in targetCodes) {
        if (ratesMap.containsKey(code)) {
          // API отдает сколько рублей за 1 единицу валюты, нам нужно наоборот (сколько валюты за 1 рубль)
          final double rate = 1 / (ratesMap[code] as num).toDouble();
          loadedRates.add(CurrencyRate(
            code: code,
            value: rate,
            nominal: 1,
          ));
        }
      }

      setState(() {
        _rates = loadedRates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Курсы валют')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Column(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  Text('Ошибка: $_error'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _fetchRates();
                    },
                    child: const Text('Попробовать снова'),
                  ),
                ],
              ),
            if (!_isLoading && _error == null)
              Expanded(
                child: ListView.builder(
                  itemCount: _rates.length,
                  itemBuilder: (context, index) {
                    final r = _rates[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(r.code)),
                        title: Text(currencyNames[r.code] ?? r.code),
                        subtitle: Text('1 ${r.code} = ${r.value.toStringAsFixed(2)} ₽'),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
