import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      title: 'Power System Calculator',
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
      home: const PowerSystemCalculatorApp(),
    );
  }
}

class PowerSystemCalculatorApp extends StatefulWidget {
  const PowerSystemCalculatorApp({super.key});

  @override
  State<PowerSystemCalculatorApp> createState() => _PowerSystemCalculatorAppState();
}

class _PowerSystemCalculatorAppState extends State<PowerSystemCalculatorApp> with SingleTickerProviderStateMixin {
  int _selectedTab = 0;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Заміни 3 на кількість вкладок
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Power System Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TabBar(
              tabs: const [
                Tab(text: 'Cable'),
                Tab(text: 'SC Current'),
                Tab(text: 'Network'),
              ],
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
              labelColor: Theme.of(context).colorScheme.primary,
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedTab == 0
                  ? const CableCalculator()
                  : _selectedTab == 1
                  ? const ShortCircuitCalculator()
                  : const PowerNetworkCalculator(),
            ),
          ],
        ),
      ),
    );
  }
}

// Cable Calculator
class CableCalculator extends StatefulWidget {
  const CableCalculator({super.key});

  @override
  State<CableCalculator> createState() => _CableCalculatorState();
}

class _CableCalculatorState extends State<CableCalculator> {
  final TextEditingController _smController = TextEditingController(text: '1300');
  final TextEditingController _ikController = TextEditingController(text: '2500');
  final TextEditingController _tfController = TextEditingController(text: '2.5');
  CableResults? _results;

  @override
  void dispose() {
    _smController.dispose();
    _ikController.dispose();
    _tfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputField(
            controller: _smController,
            label: 'Sm (MVA)',
          ),
          const SizedBox(height: 8),
          InputField(
            controller: _ikController,
            label: 'Ik (A)',
          ),
          const SizedBox(height: 8),
          InputField(
            controller: _tfController,
            label: 'tf (s)',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _results = calculateCableParameters(
                  double.tryParse(_smController.text) ?? 0.0,
                  double.tryParse(_ikController.text) ?? 0.0,
                  double.tryParse(_tfController.text) ?? 0.0,
                );
              });
            },
            child: const Text('Calculate'),
          ),
          const SizedBox(height: 16),
          if (_results != null) ...[
            ResultText(text: 'Normal mode current: ${_results!.normalCurrent} A'),
            ResultText(text: 'Post-emergency current: ${_results!.postEmergencyCurrent} A'),
            ResultText(text: 'Economic cross-section: ${_results!.economicCrossSection} mm²'),
            ResultText(text: 'Minimum cross-section: ${_results!.minimumCrossSection} mm²'),
          ],
        ],
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const InputField({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
    );
  }
}

class ResultText extends StatelessWidget {
  final String text;

  const ResultText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

class CableResults {
  final String normalCurrent;
  final String postEmergencyCurrent;
  final String economicCrossSection;
  final String minimumCrossSection;

  CableResults({
    required this.normalCurrent,
    required this.postEmergencyCurrent,
    required this.economicCrossSection,
    required this.minimumCrossSection,
  });
}

CableResults calculateCableParameters(double sm, double ik, double tf) {
  final im = (sm / 2) / (sqrt(3.0) * 10);
  final imPa = 2 * im;
  final sEk = im / 1.4;
  final sVsS = (ik * sqrt(tf)) / 92;

  return CableResults(
    normalCurrent: im.toStringAsFixed(1),
    postEmergencyCurrent: imPa.toStringAsFixed(0),
    economicCrossSection: sEk.toStringAsFixed(1),
    minimumCrossSection: sVsS.toStringAsFixed(0),
  );
}

// Short Circuit Calculator
class ShortCircuitCalculator extends StatefulWidget {
  const ShortCircuitCalculator({super.key});

  @override
  State<ShortCircuitCalculator> createState() => _ShortCircuitCalculatorState();
}

class _ShortCircuitCalculatorState extends State<ShortCircuitCalculator> {
  final TextEditingController _skController = TextEditingController(text: '200');
  ShortCircuitResults? _results;

  @override
  void dispose() {
    _skController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputField(
            controller: _skController,
            label: 'Short-Circuit Power (Sk) [MVA]',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final skValue = double.tryParse(_skController.text) ?? 0.0;
                _results = calculateShortCircuitParameters(skValue);
              });
            },
            child: const Text('Calculate'),
          ),
          const SizedBox(height: 16),
          if (_results != null) ...[
            ResultText(text: 'Xc: ${_results!.reactorImpedance}'),
            ResultText(text: 'Xt: ${_results!.transformerImpedance}'),
            ResultText(text: 'Total Resistance: ${_results!.totalImpedance}'),
            ResultText(text: 'Initial Three-Phase SC Current: ${_results!.initialShortCircuitCurrent}'),
          ],
        ],
      ),
    );
  }
}

class ShortCircuitResults {
  final String reactorImpedance;
  final String transformerImpedance;
  final String totalImpedance;
  final String initialShortCircuitCurrent;

  ShortCircuitResults({
    required this.reactorImpedance,
    required this.transformerImpedance,
    required this.totalImpedance,
    required this.initialShortCircuitCurrent,
  });
}

ShortCircuitResults calculateShortCircuitParameters(double sk) {
  // Reactor impedance calculation
  final xc = pow(10.5, 2) / sk;
  // Transformer impedance calculation
  final xt = (10.5 / 100) * (pow(10.5, 2) / 6.3);
  // Total impedance
  final totalImpedance = xc + xt;
  // Initial three-phase short-circuit current
  final initialSCCurrent = 10.5 / (sqrt(3.0) * totalImpedance);

  return ShortCircuitResults(
    reactorImpedance: xc.toStringAsFixed(2),
    transformerImpedance: xt.toStringAsFixed(2),
    totalImpedance: totalImpedance.toStringAsFixed(2),
    initialShortCircuitCurrent: initialSCCurrent.toStringAsFixed(1),
  );
}

// Power Network Calculator
class PowerNetworkCalculator extends StatefulWidget {
  const PowerNetworkCalculator({super.key});

  @override
  State<PowerNetworkCalculator> createState() => _PowerNetworkCalculatorState();
}

class _PowerNetworkCalculatorState extends State<PowerNetworkCalculator> {
  final TextEditingController _rsnController = TextEditingController(text: '10.65');
  final TextEditingController _xsnController = TextEditingController(text: '24.02');
  final TextEditingController _rsnMinController = TextEditingController(text: '34.88');
  final TextEditingController _xsnMinController = TextEditingController(text: '65.68');
  NetworkResults? _results;

  @override
  void dispose() {
    _rsnController.dispose();
    _xsnController.dispose();
    _rsnMinController.dispose();
    _xsnMinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputField(
            controller: _rsnController,
            label: 'Rsn (Ω)',
          ),
          const SizedBox(height: 8),
          InputField(
            controller: _xsnController,
            label: 'Xsn (Ω)',
          ),
          const SizedBox(height: 8),
          InputField(
            controller: _rsnMinController,
            label: 'Rsn min (Ω)',
          ),
          const SizedBox(height: 8),
          InputField(
            controller: _xsnMinController,
            label: 'Xsn min (Ω)',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _results = calculateNetwork(
                  rsn: double.tryParse(_rsnController.text) ?? 0.0,
                  xsn: double.tryParse(_xsnController.text) ?? 0.0,
                  rsnMin: double.tryParse(_rsnMinController.text) ?? 0.0,
                  xsnMin: double.tryParse(_xsnMinController.text) ?? 0.0,
                );
              });
            },
            child: const Text('Calculate'),
          ),
          const SizedBox(height: 16),
          if (_results != null)
            DisplayNetworkResults(results: _results!),
        ],
      ),
    );
  }
}

class DisplayNetworkResults extends StatelessWidget {
  final NetworkResults results;

  const DisplayNetworkResults({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '110kV bus SC currents (normal/minimum):',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('Three-phase: ${results.iSh3}/${results.iSh3Min} A'),
        Text('Two-phase: ${results.iSh2}/${results.iSh2Min} A'),

        const SizedBox(height: 16),
        const Text(
          '10kV bus SC currents (normal/minimum):',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('Three-phase: ${results.iShN3}/${results.iShN3Min} A'),
        Text('Two-phase: ${results.iShN2}/${results.iShN2Min} A'),

        const SizedBox(height: 16),
        const Text(
          'Point 10 SC currents (normal/minimum):',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('Three-phase: ${results.iLN3}/${results.iLN3Min} A'),
        Text('Two-phase: ${results.iLN2}/${results.iLN2Min} A'),
      ],
    );
  }
}

class Impedance {
  final double resistance;
  final double reactance;
  late final double impedance;

  Impedance(this.resistance, this.reactance) {
    impedance = sqrt(pow(resistance, 2) + pow(reactance, 2));
  }

  Impedance transformed() {
    final kpr = pow(11.0, 2) / pow(115.0, 2);
    return Impedance(resistance * kpr, reactance * kpr);
  }
}

class Currents {
  final String threePhaseNormal;
  final String twoPhaseNormal;
  final String threePhaseMin;
  final String twoPhaseMin;

  Currents({
    required this.threePhaseNormal,
    required this.twoPhaseNormal,
    required this.threePhaseMin,
    required this.twoPhaseMin,
  });
}

class NetworkResults {
  final String iSh3;
  final String iSh2;
  final String iSh3Min;
  final String iSh2Min;
  final String iShN3;
  final String iShN2;
  final String iShN3Min;
  final String iShN2Min;
  final String iLN3;
  final String iLN2;
  final String iLN3Min;
  final String iLN2Min;

  NetworkResults({
    required this.iSh3,
    required this.iSh2,
    required this.iSh3Min,
    required this.iSh2Min,
    required this.iShN3,
    required this.iShN2,
    required this.iShN3Min,
    required this.iShN2Min,
    required this.iLN3,
    required this.iLN2,
    required this.iLN3Min,
    required this.iLN2Min,
  });
}

double calculateTransformerReactance() {
  return (11.1 * pow(115.0, 2)) / (100 * 6.3);
}

Impedance calculateImpedances(double resistance, double reactance, double transformerReactance) {
  return Impedance(resistance, reactance + transformerReactance);
}

Currents calculateCurrents(double voltage, Impedance normal, Impedance minimum) {
  final threePhaseNormal = formatCurrent(voltage / (sqrt(3.0) * normal.impedance));
  final twoPhaseNormal = formatCurrent(double.parse(threePhaseNormal) * (sqrt(3.0) / 2));
  final threePhaseMin = formatCurrent(voltage / (sqrt(3.0) * minimum.impedance));
  final twoPhaseMin = formatCurrent(double.parse(threePhaseMin) * (sqrt(3.0) / 2));

  return Currents(
    threePhaseNormal: threePhaseNormal,
    twoPhaseNormal: twoPhaseNormal,
    threePhaseMin: threePhaseMin,
    twoPhaseMin: twoPhaseMin,
  );
}

Currents calculatePoint10Currents(Impedance normal, Impedance minimum) {
  const lineResistance = 12.52; // Total resistance of the line
  const lineReactance = 6.88; // Total reactance of the line

  final normalTotal = Impedance(normal.resistance + lineResistance, normal.reactance + lineReactance);
  final minimumTotal = Impedance(minimum.resistance + lineResistance, minimum.reactance + lineReactance);

  return calculateCurrents(11.0, normalTotal, minimumTotal);
}

String formatCurrent(double current) {
  return current.toStringAsFixed(1);
}

NetworkResults calculateNetwork({
  required double rsn,
  required double xsn,
  required double rsnMin,
  required double xsnMin,
}) {
  final xt = calculateTransformerReactance();
  final normal = calculateImpedances(rsn, xsn, xt);
  final minimum = calculateImpedances(rsnMin, xsnMin, xt);

  final currents110kV = calculateCurrents(115.0, normal, minimum);
  final currents10kV = calculateCurrents(11.0, normal.transformed(), minimum.transformed());
  final currentsPoint10 = calculatePoint10Currents(normal, minimum);

  return NetworkResults(
    iSh3: currents110kV.threePhaseNormal,
    iSh2: currents110kV.twoPhaseNormal,
    iSh3Min: currents110kV.threePhaseMin,
    iSh2Min: currents110kV.twoPhaseMin,
    iShN3: currents10kV.threePhaseNormal,
    iShN2: currents10kV.twoPhaseNormal,
    iShN3Min: currents10kV.threePhaseMin,
    iShN2Min: currents10kV.twoPhaseMin,
    iLN3: currentsPoint10.threePhaseNormal,
    iLN2: currentsPoint10.twoPhaseNormal,
    iLN3Min: currentsPoint10.threePhaseMin,
    iLN2Min: currentsPoint10.twoPhaseMin,
  );
}