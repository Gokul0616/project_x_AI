import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class MediaService {
  static final ImagePicker _picker = ImagePicker();

  static Future<List<File>> pickImages({int maxImages = 4}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (images.length > maxImages) {
        return images.take(maxImages).map((xFile) => File(xFile.path)).toList();
      }
      
      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      throw MediaException('Failed to pick images: $e');
    }
  }

  static Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      return image != null ? File(image.path) : null;
    } catch (e) {
      throw MediaException('Failed to pick image: $e');
    }
  }

  static Future<File?> pickVideo({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 2, seconds: 20), // Twitter limit
      );
      
      return video != null ? File(video.path) : null;
    } catch (e) {
      throw MediaException('Failed to pick video: $e');
    }
  }

  static Future<File?> captureImage() async {
    return await pickImage(source: ImageSource.camera);
  }

  static Future<File?> captureVideo() async {
    return await pickVideo(source: ImageSource.camera);
  }

  static String getMediaType(String path) {
    final extension = path.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'image';
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return 'video';
      default:
        return 'unknown';
    }
  }

  static bool isImage(String path) {
    return getMediaType(path) == 'image';
  }

  static bool isVideo(String path) {
    return getMediaType(path) == 'video';
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static Future<String> uploadMedia(File file) async {
    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real app, you would upload to your server or cloud storage
    // and return the URL. For now, we'll return a placeholder URL
    final fileName = file.path.split('/').last;
    return 'https://placeholder.com/uploads/$fileName';
  }

  static Future<List<String>> uploadMultipleMedia(List<File> files) async {
    final List<String> urls = [];
    
    for (final file in files) {
      final url = await uploadMedia(file);
      urls.add(url);
    }
    
    return urls;
  }
}

class MediaException implements Exception {
  final String message;
  MediaException(this.message);
  
  @override
  String toString() => 'MediaException: $message';
}

class MediaItem {
  final String id;
  final String path;
  final String type;
  final String? url;
  final int? size;
  final bool isUploading;
  final double uploadProgress;

  const MediaItem({
    required this.id,
    required this.path,
    required this.type,
    this.url,
    this.size,
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });

  MediaItem copyWith({
    String? id,
    String? path,
    String? type,
    String? url,
    int? size,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return MediaItem(
      id: id ?? this.id,
      path: path ?? this.path,
      type: type ?? this.type,
      url: url ?? this.url,
      size: size ?? this.size,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}