import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Solar Profit Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.amberAccent,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          labelStyle: TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const SolarCalculator(),
    );
  }
}


class CalculationResult {
  // Initial system
  final double energyShareWithoutImbalance;
  final double energyWithoutImbalance;
  final double profit;
  final double energyWithImbalance;
  final double penalty;
  // Improved system
  final double improvedEnergyShareWithoutImbalance;
  final double improvedEnergyWithoutImbalance;
  final double improvedProfit;
  final double improvedEnergyWithImbalance;
  final double improvedPenalty;
  final double totalProfit;

  CalculationResult({
    required this.energyShareWithoutImbalance,
    required this.energyWithoutImbalance,
    required this.profit,
    required this.energyWithImbalance,
    required this.penalty,
    required this.improvedEnergyShareWithoutImbalance,
    required this.improvedEnergyWithoutImbalance,
    required this.improvedProfit,
    required this.improvedEnergyWithImbalance,
    required this.improvedPenalty,
    required this.totalProfit,
  });
}

class SolarCalculator extends StatefulWidget {
  const SolarCalculator({super.key});

  @override
  State<SolarCalculator> createState() => _SolarCalculatorState();
}

class _SolarCalculatorState extends State<SolarCalculator> {
  final TextEditingController _pcController = TextEditingController(text: "5.0");
  final TextEditingController _sigmaController = TextEditingController(text: "0.25");
  final TextEditingController _priceController = TextEditingController(text: "7.0");

  CalculationResult? _result;

  @override
  void dispose() {
    _pcController.dispose();
    _sigmaController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solar Profit Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Калькулятор прибутку сонячної електростанції',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pcController,
              decoration: const InputDecoration(
                labelText: 'Середня потужність (МВт)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sigmaController,
              decoration: const InputDecoration(
                labelText: 'Стандартне відхилення',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Тариф (тис. грн/МВт⋅год)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final pc = double.parse(_pcController.text);
                    final sigma = double.parse(_sigmaController.text);
                    final pricePerMWh = double.parse(_priceController.text);

                    setState(() {
                      _result = calculateProfit(
                        pc: pc,
                        sigma: sigma,
                        pricePerMWh: pricePerMWh,
                      );
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Перевірте правильність введених даних')),
                    );
                  }
                },
                child: const Text('Розрахувати'),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              ResultCard(result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final CalculationResult result;

  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Початкова система:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Частка енергії без небалансів: ${result.energyShareWithoutImbalance.toStringAsFixed(1)}%'),
            Text('Енергія без небалансів: ${result.energyWithoutImbalance.toStringAsFixed(1)} МВт⋅год'),
            Text('Прибуток: ${result.profit.toStringAsFixed(1)} тис. грн'),
            Text('Енергія з небалансами: ${result.energyWithImbalance.toStringAsFixed(1)} МВт⋅год'),
            Text('Штраф: ${result.penalty.toStringAsFixed(1)} тис. грн'),

            const SizedBox(height: 16),

            const Text('Покращена система:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Частка енергії без небалансів: ${result.improvedEnergyShareWithoutImbalance.toStringAsFixed(1)}%'),
            Text('Енергія без небалансів: ${result.improvedEnergyWithoutImbalance.toStringAsFixed(1)} МВт⋅год'),
            Text('Прибуток: ${result.improvedProfit.toStringAsFixed(1)} тис. грн'),
            Text('Енергія з небалансами: ${result.improvedEnergyWithImbalance.toStringAsFixed(1)} МВт⋅год'),
            Text('Штраф: ${result.improvedPenalty.toStringAsFixed(1)} тис. грн'),

            const Divider(height: 32),

            Text(
              'Загальний прибуток: ${result.totalProfit.toStringAsFixed(1)} тис. грн',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

CalculationResult calculateProfit({
  required double pc,
  required double sigma,
  required double pricePerMWh,
}) {
  // Initial system (formulas 9.1-9.6)
  final energyShareWithoutImbalance = calculateEnergyShareWithoutImbalance(pc, sigma);
  final energyWithoutImbalance = pc * 24 * energyShareWithoutImbalance / 100;
  final profit = energyWithoutImbalance * pricePerMWh;
  final energyWithImbalance = pc * 24 * (1 - energyShareWithoutImbalance / 100);
  final penalty = energyWithImbalance * pricePerMWh;

  // Improved system (formulas 9.7-9.11)
  final improvedSigma = sigma * 0.5; // Reducing deviation by half for improved system
  final improvedEnergyShareWithoutImbalance = calculateImprovedEnergyShareWithoutImbalance(pc, improvedSigma);
  final improvedEnergyWithoutImbalance = pc * 24 * improvedEnergyShareWithoutImbalance / 100; // W3 (9.8)
  final improvedProfit = improvedEnergyWithoutImbalance * pricePerMWh;
  final improvedEnergyWithImbalance = pc * 24 * (1 - improvedEnergyShareWithoutImbalance / 100); // W4 (9.10)
  final improvedPenalty = improvedEnergyWithImbalance * pricePerMWh;

  final totalProfit = improvedProfit - improvedPenalty;

  return CalculationResult(
    energyShareWithoutImbalance: energyShareWithoutImbalance,
    energyWithoutImbalance: energyWithoutImbalance,
    profit: profit,
    energyWithImbalance: energyWithImbalance,
    penalty: penalty,
    improvedEnergyShareWithoutImbalance: improvedEnergyShareWithoutImbalance,
    improvedEnergyWithoutImbalance: improvedEnergyWithoutImbalance,
    improvedProfit: improvedProfit,
    improvedEnergyWithImbalance: improvedEnergyWithImbalance,
    improvedPenalty: improvedPenalty,
    totalProfit: totalProfit,
  );
}

double calculateEnergyShareWithoutImbalance(double pc, double sigma) {
  return numericalIntegration(4.75, 5.25, 1000, pc, sigma);
}

// Function to calculate energy share without imbalance for improved system (9.7)
double calculateImprovedEnergyShareWithoutImbalance(double pc, double sigma) {
  // Using the same integration bounds but with reduced sigma
  return numericalIntegration(4.75, 5.25, 1000, pc, sigma);
}

// Function for normal distribution calculation (9.1)
double normalDistribution(double p, double pc, double sigma) {
  return (1 / (sigma * sqrt(2 * pi))) * exp(-pow(p - pc, 2) / (2 * pow(sigma, 2)));
}

// Function for numerical integration using the trapezoidal method
double numericalIntegration(
    double a, // lower bound
    double b, // upper bound
    int n,    // number of intervals
    double pc,
    double sigma,
    ) {
  final h = (b - a) / n;
  var sum = (normalDistribution(a, pc, sigma) + normalDistribution(b, pc, sigma)) / 2.0;

  for (int i = 1; i < n; i++) {
    final x = a + i * h;
    sum += normalDistribution(x, pc, sigma);
  }

  return h * sum * 100; // multiply by 100 to get percentage
}