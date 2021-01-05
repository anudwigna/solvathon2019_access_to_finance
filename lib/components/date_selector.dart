import 'package:flutter/material.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

class DateSelector extends StatefulWidget {
  final ValueChanged<NepaliDateTime> onDateChanged;

  ///OPTIONAL [default=2076]
  final int initialDateYear;
  final int initialMonth;
  final NepaliDateTime currentDate;

  const DateSelector({
    @required this.onDateChanged,
    this.currentDate,
    this.initialDateYear,
    this.initialMonth,
  });

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  NepaliDateTime _selectedDateTime;
  int popid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _selectedDateTime = widget.currentDate;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        NepaliDateTime date;
        date = await showAdaptiveDatePicker(
          initialDatePickerMode: DatePickerMode.day,
          context: context,
          initialDate: _selectedDateTime
                  .difference(NepaliDateTime(
                      widget.initialDateYear ?? NepaliDateTime.now().year,
                      widget.initialMonth ?? 1))
                  .isNegative
              ? NepaliDateTime(
                  widget.initialDateYear ?? NepaliDateTime.now().year,
                  _selectedDateTime.month)
              : _selectedDateTime,
          firstDate: NepaliDateTime(
              widget.initialDateYear ?? NepaliDateTime.now().year,
              widget.initialMonth ?? 1),
          lastDate: NepaliDateTime(NepaliDateTime.now().year + 10, 12),
        );
        if (date != null) {
          _selectedDateTime = date;
        }

        widget.onDateChanged(_selectedDateTime);
        setState(() {});
      },
      child: InputDecorator(
        decoration: InputDecoration(
            hasFloatingPlaceholder: true,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 5.0,
            ),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        child: Text(
          NepaliDateFormat("MMMM, y").format(_selectedDateTime),
          style: TextStyle(
              color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),
          // textAlign: TextAlign.center,
        ),
        // trailing: Icon(Icons.event),
      ),
    );
  }
}
