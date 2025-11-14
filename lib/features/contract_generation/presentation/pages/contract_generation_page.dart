import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/contract_generation_bloc.dart';
import '../bloc/contract_generation_event.dart';
import '../bloc/contract_generation_state.dart';
import '../widgets/step_indicator.dart';
import '../widgets/party_form_step.dart';
import '../widgets/object_details_step.dart';
import '../widgets/contract_details_step.dart';
import '../widgets/summary_step.dart';
import '../widgets/virtual_keyboard_wrapper.dart';

class ContractGenerationPage extends StatelessWidget {
  const ContractGenerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContractGenerationBloc()
        ..add(const ContractGenerationStarted()),
      child: const ContractGenerationView(),
    );
  }
}

class ContractGenerationView extends StatelessWidget {
  const ContractGenerationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.description),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ContractKiosk',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Sale-Purchase Contract Generation',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocConsumer<ContractGenerationBloc, ContractGenerationState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state.contract.isComplete) {
            _showSuccessDialog(context);
          }
        },
        builder: (context, state) {
          return VirtualKeyboardWrapper(
            child: Column(
              children: [
                // Step Indicator
                StepIndicator(currentStep: state.currentStep),

                // Step Content
                Expanded(
                  child: _buildStepContent(context, state),
                ),

                // Navigation Footer
                _buildNavigationFooter(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, ContractGenerationState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return switch (state.currentStep) {
      ContractStep.seller => PartyFormStep(
          title: 'Seller Information',
          subtitle: 'Please provide the seller\'s personal or company information',
          initialData: state.contract.seller,
          onChanged: (seller) {
            context.read<ContractGenerationBloc>().add(
                  SellerDataUpdated(seller),
                );
          },
        ),
      ContractStep.buyer => PartyFormStep(
          title: 'Buyer Information',
          subtitle: 'Please provide the buyer\'s personal or company information',
          initialData: state.contract.buyer,
          onChanged: (buyer) {
            context.read<ContractGenerationBloc>().add(
                  BuyerDataUpdated(buyer),
                );
          },
        ),
      ContractStep.objectDetails => ObjectDetailsStep(
          initialObjectDetails: state.contract.objectDetails,
          onChanged: (objectDetails) {
            context.read<ContractGenerationBloc>().add(
                  ObjectDetailsUpdated(objectDetails),
                );
          },
        ),
      ContractStep.contractDetails => ContractDetailsStep(
          initialContractDetails: state.contract.contractDetails,
          initialPrice: state.contract.price,
          onChanged: (contractDetails, price) {
            context.read<ContractGenerationBloc>().add(
                  ContractDetailsUpdated(
                    contractDetails: contractDetails,
                    price: price,
                  ),
                );
          },
        ),
      ContractStep.summary => SummaryStep(
          contract: state.contract,
        ),
    };
  }

  Widget _buildNavigationFooter(BuildContext context, ContractGenerationState state) {
    final isFirstStep = state.currentStep == ContractStep.seller;
    final isLastStep = state.currentStep == ContractStep.summary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back Button
            if (!isFirstStep)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          context.read<ContractGenerationBloc>().add(
                                const PreviousStepRequested(),
                              );
                        },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            if (!isFirstStep) const SizedBox(width: 16),

            // Next/Submit Button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: state.canProceed && !state.isLoading
                    ? () {
                        if (isLastStep) {
                          context.read<ContractGenerationBloc>().add(
                                const ContractSubmitted(),
                              );
                        } else {
                          context.read<ContractGenerationBloc>().add(
                                const NextStepRequested(),
                              );
                        }
                      }
                    : null,
                icon: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(isLastStep ? Icons.check : Icons.arrow_forward),
                label: Text(
                  isLastStep
                      ? 'Generate Contract'
                      : 'Continue to ${_getNextStepName(state.currentStep)}',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNextStepName(ContractStep currentStep) {
    switch (currentStep) {
      case ContractStep.seller:
        return 'Buyer Data';
      case ContractStep.buyer:
        return 'Object Details';
      case ContractStep.objectDetails:
        return 'Contract Details';
      case ContractStep.contractDetails:
        return 'Summary';
      case ContractStep.summary:
        return 'Complete';
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Colors.green[600],
          size: 64,
        ),
        title: const Text(
          'Contract Generated Successfully!',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Your contract has been generated. You can now print it or save it for your records.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement print functionality
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.print),
            label: const Text('Print Contract'),
          ),
        ],
      ),
    );
  }
}
