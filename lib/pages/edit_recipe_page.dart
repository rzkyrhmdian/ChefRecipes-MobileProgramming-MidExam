import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/imgbb_service.dart';
import '../widgets/safe_network_image.dart';

class EditRecipePage extends StatefulWidget {
  final Recipe recipe;

  const EditRecipePage({
    super.key,
    required this.recipe,
  });

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  final _dbService = DbService();
  final _authService = AuthService();
  final _imgbbService = ImgbbService();

  final List<String> _categories = const [
    'Main Course',
    'Dessert',
    'Drinks',
    'Snack',
  ];

  late String _selectedCategory;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _imageUrl;

  Future<ImageSource?> _pickSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.recipe.title;
    _ingredientsController.text = widget.recipe.ingredients;
    _stepsController.text = widget.recipe.steps;
    _selectedCategory = widget.recipe.category;
    _imageUrl = widget.recipe.imageUrl;
  }

  Future<void> _captureAndUploadImage() async {
    final source = await _pickSourceDialog();
    if (source == null) return;

    if (_authService.currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first.')),
      );
      return;
    }

    setState(() => _isUploadingImage = true);
    try {
      final uploadedUrl = await _imgbbService.pickAndUploadImage(
        source: source,
      );
      if (uploadedUrl != null && mounted) {
        setState(() => _imageUrl = uploadedUrl);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload to ImgBB: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _updateRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final updatedRecipe = Recipe(
        id: widget.recipe.id,
        title: _titleController.text.trim(),
        category: _selectedCategory,
        ingredients: _ingredientsController.text.trim(),
        steps: _stepsController.text.trim(),
        imageUrl: _imageUrl,
        userId: widget.recipe.userId,
        createdAt: widget.recipe.createdAt,
      );

      await _dbService.updateRecipe(updatedRecipe);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update recipe: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ingredientsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Ingredients',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingredients cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stepsController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Steps',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Steps cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isUploadingImage ? null : _captureAndUploadImage,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  _isUploadingImage
                      ? 'Uploading image...'
                      : 'Upload New Photo (Camera/Gallery)',
                ),
              ),
              if (_imageUrl != null) ...[
                const SizedBox(height: 12),
                SafeNetworkImage(
                  imageUrl: _imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _updateRecipe,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
