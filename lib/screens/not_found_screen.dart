import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/basics.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmptyState(
        icon: Icons.explore_off_outlined,
        title: 'Page not found',
        message: 'That link doesn’t lead anywhere in Kavo.',
        action: 'Go to the fashion store',
        onAction: () => context.go('/fashion'),
      ),
    );
  }
}
