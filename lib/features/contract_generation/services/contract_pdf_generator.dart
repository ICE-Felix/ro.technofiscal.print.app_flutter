import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../../core/services/pdf_service.dart';
import '../data/models/contract_model.dart';
import '../data/models/party_model.dart';
import '../data/models/address_model.dart';

/// Service for generating contract PDFs
class ContractPdfGenerator {
  /// Generate a complete vehicle sale contract PDF
  static Future<pw.Document> generateContractPdf(ContractModel contract) async {
    final pdf = pw.Document();

    // Add pages to PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(contract),
          pw.SizedBox(height: 20),
          _buildContractTitle(),
          pw.SizedBox(height: 30),
          _buildPartySection('VÂNZĂTOR (PERSOANĂ CARE ÎNSTRĂINEAZĂ)', contract.seller),
          pw.SizedBox(height: 20),
          _buildPartySection('CUMPĂRĂTOR (PERSOANĂ CARE DOBÂNDEȘTE)', contract.buyer),
          pw.SizedBox(height: 20),
          _buildObjectSection(contract),
          pw.SizedBox(height: 20),
          _buildContractTerms(contract),
          pw.SizedBox(height: 30),
          _buildSignatureSection(),
          pw.SizedBox(height: 20),
          _buildFooter(contract),
        ],
      ),
    );

    return pdf;
  }

  /// Header with contract metadata
  static pw.Widget _buildHeader(ContractModel contract) {
    final contractNumber = PdfService.generateContractNumber();
    final date = PdfService.getFormattedDate();

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'CONTRACT NR. $contractNumber',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Data: $date',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'ROMANIA',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Generat electronic',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ],
        ),
      ],
    );
  }

  /// Contract title
  static pw.Widget _buildContractTitle() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            'CONTRACT DE VÂNZARE-CUMPĂRARE',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            width: 300,
            height: 2,
            color: PdfColors.black,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'AUTOVEHICUL',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Party information section (Seller or Buyer)
  static pw.Widget _buildPartySection(String title, PartyModel party) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      padding: const pw.EdgeInsets.all(15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildInfoRow('Nume și Prenume / Denumire:', party.fullName),
          _buildInfoRow('CNP / CUI:', party.cnp),
          _buildInfoRow('Act identitate - Seria:', party.idSeries),
          _buildInfoRow('Act identitate - Număr:', party.idNumber),
          pw.SizedBox(height: 8),
          pw.Text(
            'DOMICILIU / SEDIU:',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 4),
          _buildInfoRow('Țara:', party.address.country),
          _buildInfoRow('Județul:', party.address.county),
          _buildInfoRow('Orașul:', party.address.city),
          _buildInfoRow('Cod poștal:', party.address.postalCode),
          _buildInfoRow('Strada:', party.address.street),
          _buildInfoRow('Număr:', party.address.streetNumber),
          pw.SizedBox(height: 8),
          _buildInfoRow('Telefon:', party.phone),
          if (party.email != null && party.email!.isNotEmpty)
            _buildInfoRow('Email:', party.email!),
        ],
      ),
    );
  }

  /// Object (vehicle) details section
  static pw.Widget _buildObjectSection(ContractModel contract) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      padding: const pw.EdgeInsets.all(15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'OBIECTUL CONTRACTULUI',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green900,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            contract.objectDetails,
            style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5),
          ),
        ],
      ),
    );
  }

  /// Contract terms and conditions
  static pw.Widget _buildContractTerms(ContractModel contract) {
    final numberFormat = NumberFormat.currency(locale: 'ro', symbol: 'RON');

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      padding: const pw.EdgeInsets.all(15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CLAUZE CONTRACTUALE',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange900,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildClause(
            '1. PREȚUL DE VÂNZARE',
            'Prețul convenit pentru vânzarea-cumpărarea autovehiculului '
            'este de ${numberFormat.format(contract.price)}.',
          ),
          pw.SizedBox(height: 8),
          _buildClause(
            '2. MODALITATEA DE PLATĂ',
            contract.paymentMethod,
          ),
          pw.SizedBox(height: 8),
          _buildClause(
            '3. PREDAREA BUNULUI',
            'Predarea autovehiculului către cumpărător se va face la data de '
            '${contract.deliveryDate}, în localitatea ${contract.location}.',
          ),
          if (contract.additionalTerms != null && contract.additionalTerms!.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _buildClause(
              '4. CLAUZE SUPLIMENTARE',
              contract.additionalTerms!,
            ),
          ],
          if (contract.warranty != null && contract.warranty!.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            _buildClause(
              '5. GARANȚIE',
              contract.warranty!,
            ),
          ],
          pw.SizedBox(height: 12),
          pw.Text(
            'Părțile declară că au citit și înțeles conținutul prezentului contract '
            'și sunt de acord cu toate clauzele menționate.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
          ),
        ],
      ),
    );
  }

  /// Individual clause
  static pw.Widget _buildClause(String title, String content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          content,
          style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.3),
        ),
      ],
    );
  }

  /// Signature section
  static pw.Widget _buildSignatureSection() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSignatureBox('VÂNZĂTOR'),
        _buildSignatureBox('CUMPĂRĂTOR'),
      ],
    );
  }

  /// Individual signature box
  static pw.Widget _buildSignatureBox(String label) {
    return pw.Container(
      width: 220,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey600, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 40),
          pw.Container(
            height: 1,
            color: PdfColors.grey400,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Semnătură și dată',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  /// Footer
  static pw.Widget _buildFooter(ContractModel contract) {
    return pw.Column(
      children: [
        pw.Container(
          width: double.infinity,
          height: 1,
          color: PdfColors.grey400,
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Contract generat electronic',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              'ContractKiosk - Document Generation System',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Acest document are valoare juridică conform legislației române în vigoare',
          style: pw.TextStyle(
            fontSize: 7,
            color: PdfColors.grey600,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// Helper to build info rows
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
