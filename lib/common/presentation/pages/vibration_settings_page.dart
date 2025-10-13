import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/vibration/vibration_cubit.dart';
import '../../../core/services/vibration/vibration_model.dart';
import '../../../core/services/vibration/vibration_prefs.dart';

class VibrationSettingsPage extends StatelessWidget {
  const VibrationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt rung')),
      body: BlocBuilder<VibrationCubit, VibrationState>(
        builder: (context, state) {
          final c = context.read<VibrationCubit>();
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Bật rung'),
                value: state.enabled,
                onChanged: (v) => c.setEnabled(v),
              ),
              const Divider(),
              _radio(context, state, VibrationType.none,   'Không rung'),
              _radio(context, state, VibrationType.light,  'Rung nhẹ'),
              _radio(context, state, VibrationType.medium, 'Rung vừa'),
              _radio(context, state, VibrationType.strong, 'Rung mạnh'),
              _radio(context, state, VibrationType.pattern,'Rung theo nhịp'),
            ],
          );
        },
      ),
    );
  }

  Widget _radio(BuildContext ctx, VibrationState s, VibrationType t, String label) {
    final c = ctx.read<VibrationCubit>();
    return RadioListTile<VibrationType>(
      title: Text(label),
      value: t,
      groupValue: s.type,
      onChanged: s.enabled ? (v) => c.setType(v!) : null,
    );
  }
}
