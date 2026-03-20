import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const CalendarWidget({super.key, required this.onDateSelected});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 244, 244, 244),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,

        selectedDayPredicate: (day) {
          return isSameDay(selectedDay, day);
        },

        onDaySelected: (selected, focused) {
          setState(() {
            selectedDay = selected;
            focusedDay = focused;
          });

          widget.onDateSelected(selected);
        },

        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),

        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(color: Colors.transparent),
          defaultTextStyle: TextStyle(fontSize: 13),
          weekendTextStyle: TextStyle(fontSize: 13),
        ),

        calendarBuilders: CalendarBuilders(
          /// SELECTED DATE (rounded rectangle)
          selectedBuilder: (context, date, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFC9A14A),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },

          /// TODAY DATE (normal style when not selected)
          todayBuilder: (context, date, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(6),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },

          /// NORMAL DAYS
          defaultBuilder: (context, date, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(6),
              alignment: Alignment.center,
              child: Text('${date.day}', style: const TextStyle(fontSize: 13)),
            );
          },
        ),
      ),
    );
  }
}
