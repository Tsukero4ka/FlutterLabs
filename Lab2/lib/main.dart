import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Emission Calculator',
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
      home: const CalculatorApp(),
    );
  }
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  final coalAmountController = TextEditingController();
  final fuelOilAmountController = TextEditingController();
  final gasAmountController = TextEditingController();

  double resultCoal = 0.0;
  double resultFuelOil = 0.0;
  double resultGas = 0.0;

  @override
  void dispose() {
    coalAmountController.dispose();
    fuelOilAmountController.dispose();
    gasAmountController.dispose();
    super.dispose();
  }

  void calculateEmissions() {
    setState(() {
      resultCoal = calculateCoalEmission(
        double.tryParse(coalAmountController.text) ?? 0.0,
        0.8,
        20.47,
      );

      resultFuelOil = calculateFuelOilEmission(
        double.tryParse(fuelOilAmountController.text) ?? 0.0,
        1.0,
        39.48,
      );

      resultGas = calculateGasEmission(
        double.tryParse(gasAmountController.text) ?? 0.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emission Calculator'),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emission Calculator',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              _buildTextField(coalAmountController, 'Amount of coal (tons)', Icons.whatshot),
              const SizedBox(height: 8),
              _buildTextField(fuelOilAmountController, 'Amount of fuel oil (tons)', Icons.local_gas_station),
              const SizedBox(height: 8),
              _buildTextField(gasAmountController, 'Amount of natural gas (cubic meters)', Icons.cloud_queue),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: calculateEmissions,
                  child: const Text('Calculate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Coal emission: ${resultCoal.toStringAsFixed(6)} tons', style: TextStyle(color: Colors.white70)),
              Text('Fuel oil emission: ${resultFuelOil.toStringAsFixed(6)} tons', style: TextStyle(color: Colors.white70)),
              Text('Gas emission: ${resultGas.toStringAsFixed(6)} tons', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    );
  }
}

// Helper functions
double calculateCoalEmission(double amount, double emissionFactor, double heatingValue) {
  return 1e-6 * amount * heatingValue * emissionFactor;
}

double calculateFuelOilEmission(double amount, double emissionFactor, double heatingValue) {
  return 1e-6 * amount * heatingValue * emissionFactor;
}

double calculateGasEmission(double amount) {
  return 0.0; // No emissions for natural gas
}