import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MortgageApp());
}

class MortgageApp extends StatelessWidget {
  const MortgageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mortgage Calculator',
      home: MortgageScreen(),
    );
  }
}

class MortgageScreen extends StatefulWidget {
  const MortgageScreen({super.key});

  @override
  State<MortgageScreen> createState() => _MortgageScreenState();
}

class _MortgageScreenState extends State<MortgageScreen> {
  Mortgage mortgage = Mortgage();
  bool termsAccepted = false;

  void modifyMortgage() async {
    Mortgage? updatedMortgage = await Navigator.push<Mortgage>(
      context,
      MaterialPageRoute(builder: (context) => ModifyScreen(mortgage: mortgage)),
    );

    if (updatedMortgage != null) {
      setState(() {
        mortgage = updatedMortgage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mortgage Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mortgage Amount: \$${mortgage.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            Text('Number of Years: ${mortgage.years}'),
            const SizedBox(height: 16),
            Text('Interest Rate: ${(mortgage.rate * 100).toStringAsFixed(2)}%'),
            const SizedBox(height: 16),
            Text(
              'Monthly Payment: \$${mortgage.monthlyPayment().toStringAsFixed(2)}',
            ),
            const SizedBox(height: 16),
            Text(
              'Total Payment: \$${mortgage.totalPayment().toStringAsFixed(2)}',
            ),
            CheckboxListTile(
              title: const Text('Terms and Conditions'),
              value: termsAccepted,
              onChanged: (bool? value) {
                setState(() {
                  termsAccepted = value ?? false;
                });

                if (value == true) {
                  showDialog<void>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Terms and Conditions'),
                        content: const Text(
                          'You have accepted the terms and conditions.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: modifyMortgage,
              child: const Text('MODIFY DATA'),
            ),
          ],
        ),
      ),
    );
  }
}

class Mortgage {
  double _amount = 100000;
  int _years = 30;
  double _rate = 0.035;

  // Values come from the lab example
  Mortgage({double amount = 100000, int years = 30, double rate = 0.035}) {
    setAmount(amount);
    setYears(years);
    setRate(rate);
  }

  double get amount => _amount;
  int get years => _years;
  double get rate => _rate;

  void setAmount(double newAmount) {
    if (newAmount >= 0) {
      _amount = newAmount;
    }
  }

  void setYears(int newYears) {
    if (newYears > 0) {
      _years = newYears;
    }
  }

  void setRate(double newRate) {
    if (newRate >= 0) {
      _rate = newRate;
    }
  }

  double monthlyPayment() {
    double monthlyRate = _rate / 12;
    double temp = pow(1 / (1 + monthlyRate), _years * 12).toDouble();

    return _amount * monthlyRate / (1 - temp);
  }

  double totalPayment() {
    return monthlyPayment() * _years * 12;
  }
}

class ModifyScreen extends StatefulWidget {
  const ModifyScreen({super.key, required this.mortgage});

  final Mortgage mortgage;

  @override
  State<ModifyScreen> createState() => _ModifyScreenState();
}

class _ModifyScreenState extends State<ModifyScreen> {
  final TextEditingController amountController = TextEditingController();
  final List<double> rates = [];
  int selectedYears = 30;
  int selectedRateIndex = 0;
  double selectedRate = 0;

  @override
  void initState() {
    super.initState();

    amountController.text = widget.mortgage.amount.toString();

    if ([10, 15, 30].contains(widget.mortgage.years)) {
      selectedYears = widget.mortgage.years;
    }

    for (int index = 0; index <= 52; index++) {
      rates.add(0.02 + (index * 0.0025));
    }

    selectedRateIndex = ((widget.mortgage.rate - 0.02) / 0.0025).round();
    selectedRate = rates[selectedRateIndex];
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modify Mortgage Data')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Mortgage Amount'),
            ),
            const SizedBox(height: 16),
            RadioGroup<int>(
              groupValue: selectedYears,
              onChanged: (int? value) {
                if (value != null) {
                  setState(() {
                    selectedYears = value;
                  });
                }
              },
              child: const Row(
                children: [
                  Text('Years'),
                  Spacer(),
                  Radio<int>(value: 10),
                  Text('10'),
                  Radio<int>(value: 15),
                  Text('15'),
                  Radio<int>(value: 30),
                  Text('30'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Interest Rate'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: rates.length,
                itemBuilder: (context, index) {
                  double rate = rates[index];

                  return ListTile(
                    title: Text('${(rate * 100).toStringAsFixed(2)}%'),
                    selected: index == selectedRateIndex,
                    onTap: () {
                      setState(() {
                        selectedRateIndex = index;
                        selectedRate = rate;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                double amount =
                    double.tryParse(amountController.text) ??
                    widget.mortgage.amount;

                if (amount < 0) {
                  amount = widget.mortgage.amount;
                }

                Navigator.pop(
                  context,
                  Mortgage(
                    amount: amount,
                    years: selectedYears,
                    rate: selectedRate,
                  ),
                );
              },
              child: const Text('DONE'),
            ),
          ],
        ),
      ),
    );
  }
}
