import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;

class ArquivoService {
  static Future<PlatformFile?> selecionarArquivo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'txt',
          'ppt',
          'pptx',
          'xlsx',
          'xls',
          'jpg',
          'jpeg',
          'png',
          'zip',
          'rar',
        ],
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      print('Erro ao selecionar arquivo: $e');
      return null;
    }
  }

  static Future<String?> uploadArquivo({
    required PlatformFile arquivo,
    required String materiaId,
    required String aulaId,
    Function(double)? onProgress,
  }) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${arquivo.name}';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('materias/$materiaId/$aulaId/$fileName');

      UploadTask uploadTask;

      if (kIsWeb) {
        // Upload para Web
        uploadTask = storageRef.putData(arquivo.bytes!);
      } else {
        // Upload para Mobile/Desktop
        uploadTask = storageRef.putFile(File(arquivo.path!));
      }

      // Monitorar progresso
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erro ao fazer upload: $e');
      return null;
    }
  }

  static Future<void> excluirArquivo(String url) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('Erro ao excluir arquivo: $e');
    }
  }

  static String obterIconePorExtensao(String nomeArquivo) {
    final extensao = nomeArquivo.split('.').last.toLowerCase();

    switch (extensao) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      case 'ppt':
      case 'pptx':
        return '📽️';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return '🖼️';
      case 'zip':
      case 'rar':
        return '🗜️';
      case 'txt':
        return '📃';
      default:
        return '📎';
    }
  }

  static String formatarTamanho(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
