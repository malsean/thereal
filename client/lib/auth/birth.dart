import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rebeal/Auth/signup.dart';
import '../animation/animation.dart';
import '../widget/custom/rippleButton.dart';

class BirthPage extends StatefulWidget {
  final String name;
  final VoidCallback? loginCallback;

  BirthPage({Key? key, required this.name, this.loginCallback}) : super(key: key);

  @override
  _BirthPageState createState() => _BirthPageState();
}

class _BirthPageState extends State<BirthPage> {
  int? selectedMonth;
  int? selectedDay;
  int? selectedYear;

  int calculateAge(int? month, int? day, int? year) {
    if (month == null || day == null || year == null) return 0;

    final birth = DateTime(year, month, day);
    final currentDate = DateTime.now();
    int age = currentDate.year - birth.year;
    if (birth.month > currentDate.month ||
        (birth.month == currentDate.month && birth.day > currentDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    List<int> dayList = List.generate(
      selectedMonth == 2
          ? (selectedYear != null && (selectedYear! % 4 == 0) &&
                  (selectedYear! % 100 != 0 || selectedYear! % 400 == 0)
              ? 29
              : 28)
          : (selectedMonth == 4 || selectedMonth == 6 || selectedMonth == 9 || selectedMonth == 11 ? 30 : 31),
      (i) => i + 1,
    );

    DropdownButton<int> _buildDropdown(String hint, int start, int end, int? currentValue, Function(int?) onChanged) {
      List<DropdownMenuItem<int>> items = List.generate((end - start + 1), (index) {
        return DropdownMenuItem<int>(
          value: start + index,
          child: Text((start + index).toString()),
        );
      });

      return DropdownButton<int>(
        value: currentValue,
        items: items,
        hint: Text(
          hint,
          style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w400),
        ),
        dropdownColor: Colors.black,
        style: TextStyle(color: Colors.white),
        onChanged: onChanged,
      );
    }

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Image.asset(
            "assets/rebeals.png",
            height: 130,
          ),
          backgroundColor: Colors.black,
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
body: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        "Hello ${widget.name}, what is your birthday?",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500
        ),
        textAlign: TextAlign.center,
      ),
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
                _buildDropdown('MM', 1, 12, selectedMonth, (val) {
                  setState(() {
                    selectedMonth = val;
                    selectedDay = null; // Reset selected day when month changes
                  });
                }),
                _buildDropdown('DD', 1, dayList.length, selectedDay, (val) {
                  setState(() {
                    selectedDay = val;
                  });
                }),
                _buildDropdown(
                    'YYYY',
                    DateTime.now().year - 130,
                    DateTime.now().year - 13,
                    selectedYear, (val) {
                  setState(() {
                    selectedYear = val;
                  });
                }),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              child: RippleButton(
                splashColor: Colors.transparent,
                child: Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                      child: Text(
                    "Continue",
                    style: TextStyle(
                        fontFamily: "icons.ttf",
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w800),
                  )),
                ),
                onPressed: () {
                  if (selectedMonth != null && selectedDay != null && selectedYear != null) {
                    final age = calculateAge(selectedMonth, selectedDay, selectedYear);
                    if (age >= 13 && age <= 130) {
                      HapticFeedback.heavyImpact();
                      Navigator.push(
                        context,
                        AwesomePageRoute(
                          transitionDuration: Duration(milliseconds: 600),
                          exitPage: widget,
                          enterPage: Signup(
                            name: widget.name,
                            birth: "$selectedMonth $selectedDay $selectedYear",
                          ),
                          transition: ZoomOutSlideTransition(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Age must be between 13 and 130'),
                        ),
                      );
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

