import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CertificateService {
  Future<Uint8List> build({
    required String userName,
    required String language,
    required String level,
    required int score,
    required DateTime issuedAt,
  }) async {
    final baseFont = pw.Font.ttf(await rootBundle.load('assets/fonts/DejaVuSans.ttf'));
    final boldFont = pw.Font.ttf(await rootBundle.load('assets/fonts/DejaVuSans-Bold.ttf'));
    final document = pw.Document(theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont));
    final date = DateFormat('dd/MM/yyyy').format(issuedAt);
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColor.fromHex('#D4AF37'), width: 3),
            color: PdfColor.fromHex('#FFFFFF'),
          ),
          padding: const pw.EdgeInsets.all(30),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text('EA LANGUAGE HUB', style: pw.TextStyle(
                color: PdfColor.fromHex('#0A2342'), fontSize: 18,
                fontWeight: pw.FontWeight.bold, letterSpacing: 2,
              )),
              pw.SizedBox(height: 16),
              pw.Container(width: 72, height: 3, color: PdfColor.fromHex('#D4AF37')),
              pw.SizedBox(height: 24),
              pw.Text('CERTIFICADO DE CONCLUSÃO', style: pw.TextStyle(
                color: PdfColor.fromHex('#0A2342'), fontSize: 27,
                fontWeight: pw.FontWeight.bold,
              )),
              pw.SizedBox(height: 16),
              pw.Text('Certificamos que', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 7),
              pw.Text(userName, textAlign: pw.TextAlign.center, style: pw.TextStyle(
                color: PdfColor.fromHex('#0A2342'), fontSize: 29,
                fontWeight: pw.FontWeight.bold,
              )),
              pw.SizedBox(height: 12),
              pw.Text('concluiu o nível $level de $language com uma pontuação de $score%.',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 25),
              pw.Text('Emitido em $date', style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  _signature('EA LANGUAGE HUB', 'Plataforma de aprendizagem'),
                  _signature('Aprenda. Traduza. Comunique.', 'A sua jornada continua'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return document.save();
  }

  pw.Widget _signature(String title, String subtitle) => pw.Container(
        width: 210,
        padding: const pw.EdgeInsets.only(top: 8),
        decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: PdfColor.fromHex('#AAB4C0'))),
        ),
        child: pw.Column(children: [
          pw.Text(title, textAlign: pw.TextAlign.center, style: pw.TextStyle(
            fontSize: 10, fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#0A2342'),
          )),
          pw.SizedBox(height: 3),
          pw.Text(subtitle, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8)),
        ]),
      );
}
