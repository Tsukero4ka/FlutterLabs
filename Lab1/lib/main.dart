import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fuel Calculator',
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
      home: MainScreen(),
    );
  }
}


class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fuel Calculator'),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuButton(
              context,
              'Калькулятор складу палива',
              Icons.local_gas_station,
              FuelCalculatorScreen(),
            ),
            SizedBox(height: 20),
            _buildMenuButton(
              context,
              'Калькулятор складу мазуту',
              Icons.oil_barrel,
              MazutCalculatorScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, IconData icon, Widget screen) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

class FuelCalculatorScreen extends StatefulWidget {
  @override
  _FuelCalculatorScreenState createState() => _FuelCalculatorScreenState();
}

class _FuelCalculatorScreenState extends State<FuelCalculatorScreen> {
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _cpController = TextEditingController();
  final TextEditingController _spController = TextEditingController();
  final TextEditingController _npController = TextEditingController();
  final TextEditingController _opController = TextEditingController();
  final TextEditingController _wpController = TextEditingController();
  final TextEditingController _apController = TextEditingController();

  String _result = '';

  void _calculateComposition() {
    final calculator = FuelCompositionCalculator();
    setState(() {
      _result = calculator.calculateComposition(
        double.tryParse(_hpController.text) ?? 0.0,
        double.tryParse(_cpController.text) ?? 0.0,
        double.tryParse(_spController.text) ?? 0.0,
        double.tryParse(_npController.text) ?? 0.0,
        double.tryParse(_opController.text) ?? 0.0,
        double.tryParse(_wpController.text) ?? 0.0,
        double.tryParse(_apController.text) ?? 0.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Калькулятор складу палива')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInputField(_hpController, 'H, %'),
            _buildInputField(_cpController, 'CP, %'),
            _buildInputField(_spController, 'S, %'),
            _buildInputField(_npController, 'N, %'),
            _buildInputField(_opController, 'O, %'),
            _buildInputField(_wpController, 'W, %'),
            _buildInputField(_apController, 'A, %'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculateComposition,
              child: Text('Calculate'),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
            ),
            SizedBox(height: 16),
            Text(_result),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}

class FuelCompositionCalculator {
  String calculateComposition(
    double hp,
    double cp,
    double sp,
    double np,
    double op,
    double wp,
    double ap,
  ) {
    final krs = 100.0 / (100.0 - wp);
    final krg = 100.0 / (100.0 - wp - ap);

    final hc = hp * krs;
    final cc = cp * krs;
    final sc = sp * krs;
    final nc = np * krs;
    final oc = op * krs;
    final ac = ap * krs;

    final hg = hp * krg;
    final cg = cp * krg;
    final sg = sp * krg;
    final ng = np * krg;
    final og = op * krg;

    final qrn = 339 * cp + 1030 * hp - 108.8 * (op - sp) - 25 * wp;
    final qdn = qrn / (1 - 0.01 * wp);
    final qdafn = qrn / (1 - 0.01 * (wp + ap));

    return '''Коефіцієнт переходу від робочої до сухої маси: ${krs.toStringAsFixed(2)}
Коефіцієнт переходу від робочої до горючої маси: ${krg.toStringAsFixed(2)}

Склад сухої маси палива:
H_C = ${hc.toStringAsFixed(2)}%, C_C = ${cc.toStringAsFixed(2)}%, S_C = ${sc.toStringAsFixed(2)}%
N_C = ${nc.toStringAsFixed(3)}%, O_C = ${oc.toStringAsFixed(2)}%, A_C = ${ac.toStringAsFixed(2)}%

Склад горючої маси палива:
H_G = ${hg.toStringAsFixed(2)}%, C_G = ${cg.toStringAsFixed(2)}%, S_G = ${sg.toStringAsFixed(2)}%
N_G = ${ng.toStringAsFixed(3)}%, O_G = ${og.toStringAsFixed(2)}%

Нижча теплота згоряння:
Для робочої маси: ${(qrn / 1000).toStringAsFixed(4)} МДж/кг
Для сухої маси: ${(qdn / 1000).toStringAsFixed(4)} МДж/кг
Для горючої маси: ${(qdafn / 1000).toStringAsFixed(4)} МДж/кг''';
  }
}

class MazutCalculatorScreen extends StatefulWidget {
  @override
  _MazutCalculatorScreenState createState() => _MazutCalculatorScreenState();
}

class _MazutCalculatorScreenState extends State<MazutCalculatorScreen> {
  final TextEditingController _carbonGController = TextEditingController();
  final TextEditingController _hydrogenGController = TextEditingController();
  final TextEditingController _oxygenGController = TextEditingController();
  final TextEditingController _sulfurGController = TextEditingController();
  final TextEditingController _heatValueGController = TextEditingController();
  final TextEditingController _moisturePController = TextEditingController();
  final TextEditingController _ashDController = TextEditingController();
  final TextEditingController _vanadiumGController = TextEditingController();

  String _result = '';

  void _calculateMazutComposition() {
    final calculator = MazutCalculator();
    setState(() {
      _result = calculator.calculateMazutComposition(
        double.tryParse(_carbonGController.text) ?? 0.0,
        double.tryParse(_hydrogenGController.text) ?? 0.0,
        double.tryParse(_oxygenGController.text) ?? 0.0,
        double.tryParse(_sulfurGController.text) ?? 0.0,
        double.tryParse(_heatValueGController.text) ?? 0.0,
        double.tryParse(_moisturePController.text) ?? 0.0,
        double.tryParse(_ashDController.text) ?? 0.0,
        double.tryParse(_vanadiumGController.text) ?? 0.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Калькулятор складу мазуту')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInputField(_carbonGController, 'Вуглець (C), %'),
            _buildInputField(_hydrogenGController, 'Водень (H), %'),
            _buildInputField(_oxygenGController, 'Кисень (O), %'),
            _buildInputField(_sulfurGController, 'Сірка (S), %'),
            _buildInputField(
              _heatValueGController,
              'Нижча теплота згоряння МДж/кг',
            ),
            _buildInputField(_moisturePController, 'Вологість, %'),
            _buildInputField(_ashDController, 'Зольність, %'),
            _buildInputField(_vanadiumGController, 'Вміст ванадію (V), мг/кг'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculateMazutComposition,
              child: Text('Розрахувати'),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
            ),
            SizedBox(height: 16),
            Text(_result),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}

class MazutCalculator {
  String calculateMazutComposition(
    double carbonG,
    double hydrogenG,
    double oxygenG,
    double sulfurG,
    double heatValueG,
    double moistureP,
    double ashD,
    double vanadiumG,
  ) {
    final factor = (100 - moistureP - ashD) / 100;
    final carbonP = carbonG * factor;
    final hydrogenP = hydrogenG * factor;
    final oxygenP = oxygenG * factor;
    final sulfurP = sulfurG * factor;
    final ashP = ashD * (100 - moistureP) / 100;
    final vanadiumP = vanadiumG * (100 - moistureP) / 100;
    final heatValueP = heatValueG * (1 - 0.01 * (moistureP + ashP));

    return '''Склад робочої маси мазуту:
Вуглець (C): ${carbonP.toStringAsFixed(2)}%
Водень (H): ${hydrogenP.toStringAsFixed(2)}%
Кисень (O): ${oxygenP.toStringAsFixed(2)}%
Сірка (S): ${sulfurP.toStringAsFixed(2)}%
Зола (A): ${ashP.toStringAsFixed(2)}%
Ванадій (V): ${vanadiumP.toStringAsFixed(2)} мг/кг

Нижча теплота згоряння мазуту на робочу масу:
${heatValueP.toStringAsFixed(2)} МДж/кг''';
  }
}
