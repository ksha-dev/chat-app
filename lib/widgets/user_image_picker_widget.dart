import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePickerWidget extends StatefulWidget {
  const UserImagePickerWidget({super.key, required this.onImageSelected});

  final void Function(File) onImageSelected;

  @override
  State<UserImagePickerWidget> createState() => _UserImagePickerWidgetState();
}

class _UserImagePickerWidgetState extends State<UserImagePickerWidget> {
  File? _pickedImageFile;

  void _imagePicker() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    if (pickedImage == null) return;
    setState(() => _pickedImageFile = File(pickedImage.path));
    widget.onImageSelected(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          foregroundImage: _pickedImageFile == null ? null : FileImage(_pickedImageFile!),
          radius: 50,
          child: _pickedImageFile == null ? const Icon(Icons.image) : null,
        ),
        TextButton.icon(
          onPressed: _imagePicker,
          icon: const Icon(Icons.image),
          label: Text('${_pickedImageFile == null ? 'Add' : 'Edit'} image', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ),
      ],
    );
  }
}
