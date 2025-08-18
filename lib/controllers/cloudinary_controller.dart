import 'dart:convert';

import 'package:cloudinary/cloudinary.dart';
import 'package:friendly_card_teacher/config.dart';

class CloudinaryController {
  Cloudinary cloudinary = Cloudinary.signedConfig(
    apiKey: Config.apiKey,
    apiSecret: Config.apiSecret,
    cloudName: Config.cloudName,
  );
  Future<String> uploadImageFile(
    String filePath,
    String fileName,
    String folderName,
  ) async {
    if (filePath != '') {
      final response = await cloudinary.upload(
        file: filePath,
        folder: folderName,
        fileName: fileName,
        progressCallback: (count, total) {},
      );
      if (response.isSuccessful) {
        return response.secureUrl ?? '';
      } else {
        return 'https://res.cloudinary.com/drir6xyuq/image/upload/v1749203203/logo_icon.png';
      }
    }
    return 'https://res.cloudinary.com/drir6xyuq/image/upload/v1749203203/logo_icon.png';
  }

  Future<String> uploadImage(
    base64Image,
    String fileName,
    String folderName,
  ) async {
    try {
      if (base64Image != '') {
        final response = await cloudinary.upload(
          file: 'data:image/png;base64,$base64Image',
          fileBytes: base64Decode(base64Image),
          folder: folderName,
          fileName: fileName,
          progressCallback: (count, total) {},
        );
        if (response.isSuccessful) {
          return response.secureUrl ?? '';
        } else {
          return 'https://res.cloudinary.com/drir6xyuq/image/upload/v1749203203/logo_icon.png';
        }
      }
      return 'https://res.cloudinary.com/drir6xyuq/image/upload/v1749203203/logo_icon.png';
    } catch (e) {
      return 'https://res.cloudinary.com/drir6xyuq/image/upload/v1749203203/logo_icon.png';
    }
  }

  Future<void> deleteImage(String publicID) async {
    await cloudinary.destroy(publicID);
  }
}
