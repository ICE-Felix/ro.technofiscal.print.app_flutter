import 'package:flutter/material.dart';
import '../../../../core/style/app_colors.dart';

class TermsAcceptanceCard extends StatelessWidget {
  final bool isAccepted;
  final Function(bool)? onChanged;

  const TermsAcceptanceCard({
    super.key,
    required this.isAccepted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAccepted ? AppColors.kioskGreen : AppColors.gray200,
          width: isAccepted ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => onChanged?.call(!isAccepted),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isAccepted ? AppColors.kioskGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isAccepted ? AppColors.kioskGreen : AppColors.gray300,
                  width: 2,
                ),
              ),
              child: isAccepted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'I accept the terms and conditions',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'I confirm that all information provided is accurate and I agree to the terms of service',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.gray600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
