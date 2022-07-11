
import 'package:flutter/material.dart';

class CustomIconButtom extends StatelessWidget {
  const CustomIconButtom({Key? key, required this.icon, this.function}) : super(key: key);

  final IconData icon;
  final Function? function;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => function != null ? function!() : null,
          child: SizedBox(
            width: 50,
            height: 50,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}
