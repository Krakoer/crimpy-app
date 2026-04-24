import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:crimpy/views/screens/trainings/training_creation_screen/custom_training_creation_screen.dart';
import 'package:crimpy/views/screens/trainings/repeater_creation_screen/repeater_creation_screen.dart';

class CreateTrainingFab extends StatelessWidget {
  const CreateTrainingFab({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      activeIcon: Icons.close,
      spaceBetweenChildren: 10,
      children: [
        SpeedDialChild(
          child: Icon(FontAwesomeIcons.ruler),
          label: "Custom training",
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => TrainingCreationScreen())),
        ),
        SpeedDialChild(
          child: Icon(FontAwesomeIcons.repeat),
          label: "Repeater training",
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => RepeaterCreationScreen())),
        ),
      ],
      child: Icon(Icons.add),
    );
  }
}
