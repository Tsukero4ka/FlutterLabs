import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reliability Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ReliabilityCalculatorScreen(),
    );
  }
}

class ReliabilityCalculatorScreen extends StatefulWidget {
  const ReliabilityCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<ReliabilityCalculatorScreen> createState() => _ReliabilityCalculatorScreenState();
}

class _ReliabilityCalculatorScreenState extends State<ReliabilityCalculatorScreen> {
  final TextEditingController _connectionController = TextEditingController(text: "6");
  final TextEditingController _accidentPriceController = TextEditingController(text: "23.6");
  final TextEditingController _plannedPriceController = TextEditingController(text: "17.6");
  CalculationResult? _calculationResult;

  @override
  void dispose() {
    _connectionController.dispose();
    _accidentPriceController.dispose();
    _plannedPriceController.dispose();
    super.dispose();
  }

  void _calculateReliability() {
    final connection = double.tryParse(_connectionController.text) ?? 6.0;
    final accidentPrice = double.tryParse(_accidentPriceController.text) ?? 23.6;
    final plannedPrice = double.tryParse(_plannedPriceController.text) ?? 17.6;

    setState(() {
      _calculationResult = calculateReliability(
        connection.toDouble(),
        accidentPrice.toDouble(),
        plannedPrice.toDouble(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reliability Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InputField(
              controller: _connectionController,
              label: 'Підключення',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8.0),
            InputField(
              controller: _accidentPriceController,
              label: 'Ціна аварії',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8.0),
            InputField(
              controller: _plannedPriceController,
              label: 'Планова ціна',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _calculateReliability,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Розрахувати'),
            ),
            const SizedBox(height: 16.0),
            if (_calculationResult != null) ResultCard(result: _calculationResult!),
          ],
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;

  const InputField({
    Key? key,
    required this.controller,
    required this.label,
    required this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
    );
  }
}

class ResultCard extends StatelessWidget {
  final CalculationResult result;

  const ResultCard({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResultRow(label: "Частота відмов (W_oc)", value: result.wOc),
            ResultRow(label: "Середній час відновлення (t_v_oc)", value: result.tvOc, unit: "рік^-1"),
            ResultRow(label: "Коефіцієнт аварійного простою (k_a_oc)", value: result.kaOc, unit: "год"),
            ResultRow(label: "Коефіцієнт планового простою (k_p_oc)", value: result.kpOc),
            ResultRow(label: "Частота відмов (W_dk)", value: result.wDk, unit: "рік^-1"),
            ResultRow(label: "Частота відмов з урахуванням вимикача (W_dc)", value: result.wDc, unit: "рік^-1"),
            const Text("Математичні сподівання:"),
            ResultRow(label: "аварійних поломок (math_W_ned_a)", value: result.mathWNedA, unit: "кВт*год"),
            ResultRow(label: "планових поломок (math_W_ned_p)", value: result.mathWNedP, unit: "кВт*год"),
            ResultRow(label: "збитків (math_loses)", value: result.mathLoses, unit: "грн"),
          ],
        ),
      ),
    );
  }
}

class ResultRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;

  const ResultRow({
    Key? key,
    required this.label,
    required this.value,
    this.unit = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          Expanded(
            child: Text(
              "${value.toStringAsFixed(4)} $unit",
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class CalculationResult {
  final double wOc;
  final double tvOc;
  final double kaOc;
  final double kpOc;
  final double wDk;
  final double wDc;
  final double mathWNedA;
  final double mathWNedP;
  final double mathLoses;

  CalculationResult({
    required this.wOc,
    required this.tvOc,
    required this.kaOc,
    required this.kpOc,
    required this.wDk,
    required this.wDc,
    required this.mathWNedA,
    required this.mathWNedP,
    required this.mathLoses,
  });
}

CalculationResult calculateReliability(double n, double accidentPrice, double plannedPrice) {
  final wOc = 0.01 + 0.07 + 0.015 + 0.02 + 0.03 * n;
  final tvOc = (0.01 * 30 + 0.07 * 10 + 0.015 * 100 + 0.02 * 15 + (0.03 * n) * 2) / wOc;
  final kaOc = (wOc * tvOc) / 8760;
  final kpOc = 1.2 * (43 / 8760);
  final wDk = 2 * wOc * (kaOc + kpOc);
  final wDc = wDk + 0.02;

  final mathWNedA = 0.01 * 45 * math.pow(10, -3) * 5.12 * math.pow(10, 3) * 6451;
  final mathWNedP = 4 * math.pow(10, 3) * 5.12 * math.pow(10, 3) * 6451;
  final mathLoses = accidentPrice * mathWNedA + plannedPrice * mathWNedP;

  return CalculationResult(
    wOc: wOc,
    tvOc: tvOc,
    kaOc: kaOc,
    kpOc: kpOc,
    wDk: wDk,
    wDc: wDc,
    mathWNedA: mathWNedA,
    mathWNedP: mathWNedP,
    mathLoses: mathLoses,
  );
}