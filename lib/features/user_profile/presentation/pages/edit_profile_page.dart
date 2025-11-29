// lib/features/user_profile/presentation/pages/edit_profile_page.dart
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/get_it/get_it.dart';
import '../../../project_application/data/data_sources/project_application_remote_data_source.dart';
import '../../../project_application/data/models/uploaded_file_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../domain/repositories/user_profile_repository.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfileModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;

  late DateTime? _selectedBirthDate;
  late String _selectedGender; // 'MALE' | 'FEMALE'
  late String _avatarUrl;      // url hiện tại (có thể là placeholder ban đầu)

  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.fullName);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
    _addressCtrl = TextEditingController(text: widget.user.address);

    _selectedBirthDate = widget.user.birthDate;
    _selectedGender = (widget.user.gender.isNotEmpty
        ? widget.user.gender
        : 'MALE')
        .toUpperCase();
    _avatarUrl = widget.user.avatarUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initialDate = _selectedBirthDate ?? DateTime(now.year - 18, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Xong',
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  String _formatBirthDate(DateTime? date) {
    if (date == null) return 'Chưa chọn';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // Chọn ảnh + upload bằng API uploadCvFile, lấy fileUrl làm avatarUrl
  Future<void> _pickAndUploadAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result == null) return;

      final filePath = result.files.single.path;
      if (filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể đọc file ảnh đã chọn.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      setState(() {
        _isUploadingAvatar = true;
      });

      final file = File(filePath);

      // Dùng lại data source uploadCvFile để upload avatar
      final ds = getIt<ProjectApplicationRemoteDataSource>();
      final UploadedFileModel uploaded = await ds.uploadCvFile(file);

      setState(() {
        _avatarUrl = uploaded.fileUrl; // url ảnh mới
        _isUploadingAvatar = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật ảnh đại diện thành công!')),
      );
    } catch (e) {
      setState(() {
        _isUploadingAvatar = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể cập nhật ảnh: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _onSave() async {
    // Tạo bản user đã chỉnh sửa
    final updatedUser = widget.user.copyWith(
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      gender: _selectedGender,
      birthDate: _selectedBirthDate,
      avatarUrl: _avatarUrl,
    );

    setState(() {
      _isSaving = true;
    });

    final repo = getIt<UserProfileRepository>();

    final result = await repo.updateUserProfile(updatedUser);

    result.fold(
          (failure) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      },
          (user) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công!'),
          ),
        );
        // Trả user mới về ProfilePage
        Navigator.pop(context, user);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final avatarDisplayUrl =
    _avatarUrl.isNotEmpty && _avatarUrl.startsWith('http')
        ? _avatarUrl
        : 'https://via.placeholder.com/200x200.png?text=Avatar';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ===== AVATAR + NÚT ĐỔI ẢNH =====
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: colorScheme.primary.withOpacity(0.12),
                      backgroundImage: NetworkImage(avatarDisplayUrl),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: InkWell(
                        onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: _isUploadingAvatar
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                              : const Icon(
                            Icons.camera_alt_outlined,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== FORM THÔNG TIN =====
              TextField(
                controller: _nameCtrl,
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneCtrl,
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressCtrl,
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
              ),
              const SizedBox(height: 20),

              // ===== GIỚI TÍNH =====
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Giới tính',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Nam'),
                      selected: _selectedGender == 'MALE',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedGender = 'MALE';
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Nữ'),
                      selected: _selectedGender == 'FEMALE',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedGender = 'FEMALE';
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ===== NGÀY SINH =====
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ngày sinh',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickBirthDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _formatBirthDate(_selectedBirthDate),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      const Icon(Icons.calendar_month_outlined),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ===== NÚT LƯU =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _onSave,
                  icon: _isSaving
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Icon(Icons.check),
                  label: Text(
                    _isSaving ? 'Đang lưu...' : 'Lưu thay đổi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
