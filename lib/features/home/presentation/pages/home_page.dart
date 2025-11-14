import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/routes_name.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_theme.dart';
import '../widgets/info_card.dart';
import '../widgets/service_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.kioskBlue,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.description,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Mommy HAI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              // TODO: Show help dialog
            },
            icon: const Icon(Icons.help_outline),
            label: const Text('Help'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Main content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Selectați serviciul dorit',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Alegeți una dintre opțiunile de mai jos pentru a continua',
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      // Service cards grid
                      Row(
                        children: [
                          Expanded(
                            child: ServiceCard(
                              title: 'Generare Contract',
                              description:
                                  'Creați și tipăriți contracte de vânzare-cumpărare în câțiva pași simpli',
                              icon: Icons.description,
                              iconColor: AppColors.kioskBlue,
                              buttonColor: AppColors.kioskBlue,
                              features: const [
                                'Introducere date vânzător/cumpărător',
                                'Scanare documente identitate',
                                'Tipărire contract + chitanță fiscală',
                              ],
                              onTap: () {
                                context.goNamed(
                                  AppRoutesNames.contractGenerationSingleField.name,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: ServiceCard(
                              title: 'Tipărire Documente',
                              description:
                                  'Tipăriți documentele trimise pe email la adresa noastră',
                              icon: Icons.print,
                              iconColor: AppColors.kioskGreen,
                              buttonColor: AppColors.kioskGreen,
                              features: const [
                                'Trimitere documente pe email',
                                'Previzualizare înainte de tipărire',
                                'Plată și tipărire automată',
                              ],
                              onTap: () {
                                // TODO: Navigate to document printing
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Document printing coming soon'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Info panel
          Container(
            width: 320,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: AppColors.border),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informații utile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  InfoCard(
                    icon: Icons.access_time,
                    iconColor: AppColors.kioskBlue,
                    backgroundColor: AppColors.blue50,
                    title: 'Timp estimat',
                    description: '5-10 minute pentru generare contract',
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    icon: Icons.euro,
                    iconColor: AppColors.kioskGreen,
                    backgroundColor: AppColors.green50,
                    title: 'Preț serviciu',
                    description: '50 RON / contract\n5 RON / pagină tipărită',
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    icon: Icons.credit_card,
                    iconColor: AppColors.kioskYellow,
                    backgroundColor: AppColors.yellow50,
                    title: 'Metode de plată',
                    description: 'Numerar sau card bancar',
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    icon: Icons.badge,
                    iconColor: AppColors.gray600,
                    backgroundColor: AppColors.gray100,
                    title: 'Documente necesare',
                    description: 'Acte de identitate pentru ambele părți',
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.red50,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSmall),
                      border: Border.all(color: AppColors.kioskRed, width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: AppColors.kioskRed,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Atenție',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.kioskRed,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sesiunea se va închide automat după 60 secunde de inactivitate',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.kioskRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
