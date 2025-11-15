import 'package:equatable/equatable.dart';

class OrderCompletionModel extends Equatable {
  final String contractId;
  final String contractType;
  final int numberOfPages;
  final String language;
  final bool legalComplianceVerified;
  final int sellerCopies;
  final int buyerCopies;
  final int authorityCopies;
  final String documentFormat;
  final String paperSize;
  final String printQuality;
  final String colorMode;
  final bool printReady;
  final bool emailAvailable;
  final bool digitalArchiveSaved;
  final DateTime completionDate;
  final int processingTimeMinutes;

  const OrderCompletionModel({
    required this.contractId,
    this.contractType = 'Vehicle Sale Agreement',
    this.numberOfPages = 8,
    this.language = 'English',
    this.legalComplianceVerified = true,
    this.sellerCopies = 1,
    this.buyerCopies = 1,
    this.authorityCopies = 1,
    this.documentFormat = 'PDF',
    this.paperSize = 'A4',
    this.printQuality = 'High',
    this.colorMode = 'Black & White',
    this.printReady = true,
    this.emailAvailable = false,
    this.digitalArchiveSaved = true,
    required this.completionDate,
    this.processingTimeMinutes = 12,
  });

  int get totalCopies => sellerCopies + buyerCopies + authorityCopies;

  OrderCompletionModel copyWith({
    String? contractId,
    String? contractType,
    int? numberOfPages,
    String? language,
    bool? legalComplianceVerified,
    int? sellerCopies,
    int? buyerCopies,
    int? authorityCopies,
    String? documentFormat,
    String? paperSize,
    String? printQuality,
    String? colorMode,
    bool? printReady,
    bool? emailAvailable,
    bool? digitalArchiveSaved,
    DateTime? completionDate,
    int? processingTimeMinutes,
  }) {
    return OrderCompletionModel(
      contractId: contractId ?? this.contractId,
      contractType: contractType ?? this.contractType,
      numberOfPages: numberOfPages ?? this.numberOfPages,
      language: language ?? this.language,
      legalComplianceVerified: legalComplianceVerified ?? this.legalComplianceVerified,
      sellerCopies: sellerCopies ?? this.sellerCopies,
      buyerCopies: buyerCopies ?? this.buyerCopies,
      authorityCopies: authorityCopies ?? this.authorityCopies,
      documentFormat: documentFormat ?? this.documentFormat,
      paperSize: paperSize ?? this.paperSize,
      printQuality: printQuality ?? this.printQuality,
      colorMode: colorMode ?? this.colorMode,
      printReady: printReady ?? this.printReady,
      emailAvailable: emailAvailable ?? this.emailAvailable,
      digitalArchiveSaved: digitalArchiveSaved ?? this.digitalArchiveSaved,
      completionDate: completionDate ?? this.completionDate,
      processingTimeMinutes: processingTimeMinutes ?? this.processingTimeMinutes,
    );
  }

  @override
  List<Object?> get props => [
        contractId,
        contractType,
        numberOfPages,
        language,
        legalComplianceVerified,
        sellerCopies,
        buyerCopies,
        authorityCopies,
        documentFormat,
        paperSize,
        printQuality,
        colorMode,
        printReady,
        emailAvailable,
        digitalArchiveSaved,
        completionDate,
        processingTimeMinutes,
      ];
}
