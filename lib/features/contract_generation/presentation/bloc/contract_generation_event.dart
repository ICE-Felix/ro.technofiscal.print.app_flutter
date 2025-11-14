import 'package:equatable/equatable.dart';
import '../../data/models/party_model.dart';

sealed class ContractGenerationEvent extends Equatable {
  const ContractGenerationEvent();

  @override
  List<Object?> get props => [];
}

class ContractGenerationStarted extends ContractGenerationEvent {
  const ContractGenerationStarted();
}

class NextStepRequested extends ContractGenerationEvent {
  const NextStepRequested();
}

class PreviousStepRequested extends ContractGenerationEvent {
  const PreviousStepRequested();
}

class SellerDataUpdated extends ContractGenerationEvent {
  final PartyModel seller;

  const SellerDataUpdated(this.seller);

  @override
  List<Object?> get props => [seller];
}

class BuyerDataUpdated extends ContractGenerationEvent {
  final PartyModel buyer;

  const BuyerDataUpdated(this.buyer);

  @override
  List<Object?> get props => [buyer];
}

class ObjectDetailsUpdated extends ContractGenerationEvent {
  final String objectDetails;

  const ObjectDetailsUpdated(this.objectDetails);

  @override
  List<Object?> get props => [objectDetails];
}

class ContractDetailsUpdated extends ContractGenerationEvent {
  final String contractDetails;
  final double price;

  const ContractDetailsUpdated({
    required this.contractDetails,
    required this.price,
  });

  @override
  List<Object?> get props => [contractDetails, price];
}

class ContractSubmitted extends ContractGenerationEvent {
  const ContractSubmitted();
}

class DraftSaved extends ContractGenerationEvent {
  const DraftSaved();
}

class DraftLoaded extends ContractGenerationEvent {
  const DraftLoaded();
}
