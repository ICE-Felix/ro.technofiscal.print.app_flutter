import 'package:equatable/equatable.dart';
import '../../data/models/contract_model.dart';

enum ContractStep {
  seller('Seller Data'),
  buyer('Buyer Data'),
  objectDetails('Object Details'),
  contractDetails('Contract Details'),
  summary('Summary');

  final String displayName;

  const ContractStep(this.displayName);

  int get stepIndex {
    switch (this) {
      case ContractStep.seller:
        return 0;
      case ContractStep.buyer:
        return 1;
      case ContractStep.objectDetails:
        return 2;
      case ContractStep.contractDetails:
        return 3;
      case ContractStep.summary:
        return 4;
    }
  }

  bool get isSeller => this == ContractStep.seller;
  bool get isBuyer => this == ContractStep.buyer;
  bool get isObjectDetails => this == ContractStep.objectDetails;
  bool get isContractDetails => this == ContractStep.contractDetails;
  bool get isSummary => this == ContractStep.summary;
}

class ContractGenerationState extends Equatable {
  final ContractStep currentStep;
  final ContractModel contract;
  final bool isLoading;
  final bool isValidating;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;
  final bool canProceed;

  const ContractGenerationState({
    this.currentStep = ContractStep.seller,
    required this.contract,
    this.isLoading = false,
    this.isValidating = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
    this.canProceed = false,
  });

  factory ContractGenerationState.initial() => ContractGenerationState(
        contract: ContractModel.empty(),
      );

  ContractGenerationState copyWith({
    ContractStep? currentStep,
    ContractModel? contract,
    bool? isLoading,
    bool? isValidating,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool? canProceed,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ContractGenerationState(
      currentStep: currentStep ?? this.currentStep,
      contract: contract ?? this.contract,
      isLoading: isLoading ?? this.isLoading,
      isValidating: isValidating ?? this.isValidating,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      canProceed: canProceed ?? this.canProceed,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        contract,
        isLoading,
        isValidating,
        isSaving,
        errorMessage,
        successMessage,
        canProceed,
      ];
}
