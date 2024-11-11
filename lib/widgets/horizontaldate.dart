import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Horizontaldate extends StatelessWidget {
  const Horizontaldate({
    super.key,
    required this.fromDate,
    required this.selectedDate,
    required this.toDate,
    required this.onDateSelected,
  });
  final DateTime fromDate, toDate, selectedDate;
  final Function(DateTime) onDateSelected;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(toDate.difference(fromDate).inDays + 1, (index) {
        DateTime currentDate = fromDate.subtract(Duration(days: index));
        bool isSelected = currentDate.year == selectedDate.year &&
            currentDate.month == selectedDate.month &&
            currentDate.day == selectedDate.day;
        return Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(left: index == 0 ? 16 : 8, right: 8),
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              onTap: isSelected ? null : () => onDateSelected(currentDate),
              child: Ink(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color.fromARGB(255, 163, 201, 219)
                      : Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  border: Border.all(
                    color: const Color.fromARGB(255, 163, 201, 219),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(currentDate.day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: isSelected ? Colors.white : Colors.black,
                        )),
                    Text(DateFormat.E().format(currentDate),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
