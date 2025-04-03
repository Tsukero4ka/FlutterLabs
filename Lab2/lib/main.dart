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

  // Calculate emission factors
  final double coalParticulate = calculateEmissionFactor(20.47, 0.8, 25.20, 1.5, 0.985);
  final double fuelOilParticulate = calculateEmissionFactor(39.48, 1.0, 0.15, 0.0, 0.985);

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
        coalParticulate,
        20.47,
      );

      resultFuelOil = calculateFuelOilEmission(
        double.tryParse(fuelOilAmountController.text) ?? 0.0,
        fuelOilParticulate,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emission Calculator',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 16),

              TextField(
                controller: coalAmountController,
                decoration: const InputDecoration(
                  labelText: 'Amount of coal (tons)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 8),

              TextField(
                controller: fuelOilAmountController,
                decoration: const InputDecoration(
                  labelText: 'Amount of fuel oil (tons)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 8),

              TextField(
                controller: gasAmountController,
                decoration: const InputDecoration(
                  labelText: 'Amount of natural gas (cubic meters)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: calculateEmissions,
                  child: const Text('Calculate'),
                ),
              ),

              const SizedBox(height: 16),

              // Results
              Text('Coal emission: ${resultCoal.toStringAsFixed(6)} tons'),
              Text('Fuel oil emission: ${resultFuelOil.toStringAsFixed(6)} tons'),
              Text('Gas emission: ${resultGas.toStringAsFixed(6)} tons'),
            ],
          ),
        ),
      ),
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

double calculateEmissionFactor(
    double Q,
    double a,
    double A,
    double gamma,  // Heat loss due to incomplete combustion of volatile matter
    double etaZU,  // Dust collection system efficiency
    ) {
  return (1e+6 / Q) * a * (A / (100 - gamma)) * (1 - etaZU);
}