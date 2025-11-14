import 'package:flutter/material.dart';
import '../bloc/contract_generation_state.dart';

class StepIndicator extends StatelessWidget {
  final ContractStep currentStep;

  const StepIndicator({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final steps = ContractStep.values;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue[50]!,
            Colors.indigo[50]!,
          ],
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.checklist, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Contract Generation Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey[500], size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Estimated time: 10-15 minutes',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              for (int i = 0; i < steps.length; i++) ...[
                _StepCircle(
                  step: steps[i],
                  currentStep: currentStep,
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: steps[i].stepIndex < currentStep.stepIndex
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final ContractStep step;
  final ContractStep currentStep;

  const _StepCircle({
    required this.step,
    required this.currentStep,
  });

  bool get isCompleted => step.stepIndex < currentStep.stepIndex;
  bool get isCurrent => step == currentStep;
  bool get isPending => step.stepIndex > currentStep.stepIndex;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Widget content;

    if (isCompleted) {
      backgroundColor = Theme.of(context).primaryColor;
      textColor = Colors.white;
      content = const Icon(Icons.check, color: Colors.white, size: 20);
    } else if (isCurrent) {
      backgroundColor = Theme.of(context).primaryColor;
      textColor = Colors.white;
      content = Text(
        '${step.stepIndex + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      backgroundColor = Colors.grey[300]!;
      textColor = Colors.grey[600]!;
      content = Text(
        '${step.stepIndex + 1}',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(child: content),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            step.displayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
