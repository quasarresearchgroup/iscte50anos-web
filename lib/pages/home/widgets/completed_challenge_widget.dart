import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';

class CompletedChallengeWidget extends StatefulWidget {
  CompletedChallengeWidget({Key? key}) : super(key: key);
  final Logger _logger = Logger();

  @override
  State<CompletedChallengeWidget> createState() =>
      _CompletedChallengeWidgetState();
}

class _CompletedChallengeWidgetState extends State<CompletedChallengeWidget>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  late AnimationController _animationController;

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget._logger.d("built CompletedChallengeWidget");
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Lottie.asset(
          "Resources/Lotties/thank-you-with-confetti.json",
        ),
        Text(
          AppLocalizations.of(context)!.qrScanNotificationAllVisited,
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}