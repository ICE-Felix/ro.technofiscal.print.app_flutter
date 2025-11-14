import 'package:flutter_bloc/flutter_bloc.dart';
import 'contract_generation_event.dart';
import 'contract_generation_state.dart';
import '../../data/models/contract_model.dart';

class ContractGenerationBloc
    extends Bloc<ContractGenerationEvent, ContractGenerationState> {
  ContractGenerationBloc() : super(ContractGenerationState.initial()) {
    on<ContractGenerationStarted>(_onStarted);
    on<NextStepRequested>(_onNextStep);
    on<PreviousStepRequested>(_onPreviousStep);
    on<SellerDataUpdated>(_onSellerDataUpdated);
    on<BuyerDataUpdated>(_onBuyerDataUpdated);
    on<ObjectDetailsUpdated>(_onObjectDetailsUpdated);
    on<ContractDetailsUpdated>(_onContractDetailsUpdated);
    on<ContractSubmitted>(_onContractSubmitted);
    on<DraftSaved>(_onDraftSaved);
    on<DraftLoaded>(_onDraftLoaded);
  }

  Future<void> _onStarted(
    ContractGenerationStarted event,
    Emitter<ContractGenerationState> emit,
  ) async {
    emit(state.copyWith(
      currentStep: ContractStep.seller,
      contract: ContractModel.empty(),
    ));
  }

  Future<void> _onNextStep(
    NextStepRequested event,
    Emitter<ContractGenerationState> emit,
  ) async {
    // Validate current step before proceeding
    final canProceed = _validateCurrentStep();

    if (!canProceed) {
      emit(state.copyWith(
        errorMessage: _getValidationErrorMessage(),
      ));
      return;
    }

    // Move to next step
    final nextStep = _getNextStep();
    if (nextStep != null) {
      emit(state.copyWith(
        currentStep: nextStep,
        canProceed: _canProceedToNextStep(nextStep),
        clearError: true,
      ));
    }
  }

  Future<void> _onPreviousStep(
    PreviousStepRequested event,
    Emitter<ContractGenerationState> emit,
  ) async {
    final previousStep = _getPreviousStep();
    if (previousStep != null) {
      emit(state.copyWith(
        currentStep: previousStep,
        canProceed: _canProceedToNextStep(previousStep),
        clearError: true,
      ));
    }
  }

  Future<void> _onSellerDataUpdated(
    SellerDataUpdated event,
    Emitter<ContractGenerationState> emit,
  ) async {
    final updatedContract = state.contract.copyWith(seller: event.seller);
    emit(state.copyWith(
      contract: updatedContract,
      canProceed: updatedContract.canProceedFromSeller,
      clearError: true,
    ));
  }

  Future<void> _onBuyerDataUpdated(
    BuyerDataUpdated event,
    Emitter<ContractGenerationState> emit,
  ) async {
    final updatedContract = state.contract.copyWith(buyer: event.buyer);
    emit(state.copyWith(
      contract: updatedContract,
      canProceed: updatedContract.canProceedFromBuyer,
      clearError: true,
    ));
  }

  Future<void> _onObjectDetailsUpdated(
    ObjectDetailsUpdated event,
    Emitter<ContractGenerationState> emit,
  ) async {
    final updatedContract = state.contract.copyWith(
      objectDetails: event.objectDetails,
    );
    emit(state.copyWith(
      contract: updatedContract,
      canProceed: updatedContract.canProceedFromObjectDetails,
      clearError: true,
    ));
  }

  Future<void> _onContractDetailsUpdated(
    ContractDetailsUpdated event,
    Emitter<ContractGenerationState> emit,
  ) async {
    final updatedContract = state.contract.copyWith(
      contractDetails: event.contractDetails,
      price: event.price,
    );
    emit(state.copyWith(
      contract: updatedContract,
      canProceed: updatedContract.canSubmit,
      clearError: true,
    ));
  }

  Future<void> _onContractSubmitted(
    ContractSubmitted event,
    Emitter<ContractGenerationState> emit,
  ) async {
    if (!state.contract.canSubmit) {
      emit(state.copyWith(
        errorMessage: 'Please complete all required fields',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // TODO: Implement actual submission logic (API call, PDF generation, etc.)
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Contract generated successfully!',
        contract: state.contract.copyWith(isComplete: true),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to generate contract: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDraftSaved(
    DraftSaved event,
    Emitter<ContractGenerationState> emit,
  ) async {
    emit(state.copyWith(isSaving: true));

    try {
      // TODO: Implement draft saving to local storage
      await Future.delayed(const Duration(milliseconds: 500));

      emit(state.copyWith(
        isSaving: false,
        successMessage: 'Draft saved successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save draft: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDraftLoaded(
    DraftLoaded event,
    Emitter<ContractGenerationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // TODO: Implement draft loading from local storage
      await Future.delayed(const Duration(milliseconds: 500));

      emit(state.copyWith(
        isLoading: false,
        successMessage: 'Draft loaded successfully',
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load draft: ${e.toString()}',
      ));
    }
  }

  bool _validateCurrentStep() {
    switch (state.currentStep) {
      case ContractStep.seller:
        return state.contract.canProceedFromSeller;
      case ContractStep.buyer:
        return state.contract.canProceedFromBuyer;
      case ContractStep.objectDetails:
        return state.contract.canProceedFromObjectDetails;
      case ContractStep.contractDetails:
        return state.contract.canSubmit;
      case ContractStep.summary:
        return true;
    }
  }

  bool _canProceedToNextStep(ContractStep step) {
    switch (step) {
      case ContractStep.seller:
        return state.contract.canProceedFromSeller;
      case ContractStep.buyer:
        return state.contract.canProceedFromBuyer;
      case ContractStep.objectDetails:
        return state.contract.canProceedFromObjectDetails;
      case ContractStep.contractDetails:
        return state.contract.canSubmit;
      case ContractStep.summary:
        return state.contract.canSubmit;
    }
  }

  String _getValidationErrorMessage() {
    switch (state.currentStep) {
      case ContractStep.seller:
        return 'Please complete all seller information fields';
      case ContractStep.buyer:
        return 'Please complete all buyer information fields';
      case ContractStep.objectDetails:
        return 'Please provide object details';
      case ContractStep.contractDetails:
        return 'Please provide contract details and price';
      case ContractStep.summary:
        return 'Please review and confirm';
    }
  }

  ContractStep? _getNextStep() {
    switch (state.currentStep) {
      case ContractStep.seller:
        return ContractStep.buyer;
      case ContractStep.buyer:
        return ContractStep.objectDetails;
      case ContractStep.objectDetails:
        return ContractStep.contractDetails;
      case ContractStep.contractDetails:
        return ContractStep.summary;
      case ContractStep.summary:
        return null; // Last step
    }
  }

  ContractStep? _getPreviousStep() {
    switch (state.currentStep) {
      case ContractStep.seller:
        return null; // First step
      case ContractStep.buyer:
        return ContractStep.seller;
      case ContractStep.objectDetails:
        return ContractStep.buyer;
      case ContractStep.contractDetails:
        return ContractStep.objectDetails;
      case ContractStep.summary:
        return ContractStep.contractDetails;
    }
  }
}
