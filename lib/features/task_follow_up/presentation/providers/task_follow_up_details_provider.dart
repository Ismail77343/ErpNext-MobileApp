import 'package:flutter/material.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/task_follow_up_details.dart';
import '../../domain/usecases/add_task_follow_up_update_usecase.dart';
import '../../domain/usecases/close_task_follow_up_usecase.dart';
import '../../domain/usecases/get_task_follow_up_details_usecase.dart';
import '../../domain/usecases/mark_task_follow_up_read_usecase.dart';
import '../../domain/usecases/upload_task_follow_up_attachment_usecase.dart';

class TaskFollowUpDetailsProvider extends ChangeNotifier {
  TaskFollowUpDetailsProvider(
    this._getDetailsUseCase,
    this._addUpdateUseCase,
    this._closeTaskUseCase,
    this._markReadUseCase,
    this._uploadAttachmentUseCase,
  );

  final GetTaskFollowUpDetailsUseCase _getDetailsUseCase;
  final AddTaskFollowUpUpdateUseCase _addUpdateUseCase;
  final CloseTaskFollowUpUseCase _closeTaskUseCase;
  final MarkTaskFollowUpReadUseCase _markReadUseCase;
  final UploadTaskFollowUpAttachmentUseCase _uploadAttachmentUseCase;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  TaskFollowUpDetails? _details;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  TaskFollowUpDetails? get details => _details;

  Future<void> load(String name, {bool markRead = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _details = await _getDetailsUseCase.call(name);
      if (markRead) {
        await _markReadUseCase.call(name);
      }
    } catch (e) {
      _error = e.toString();
      AppLogger.error('task follow up details failed: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addUpdate({
    required String note,
    required int progress,
    required String status,
    String? attachmentPath,
  }) async {
    final current = _details;
    if (current == null) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final attachment = attachmentPath == null || attachmentPath.isEmpty
          ? null
          : await _uploadAttachmentUseCase.call(
              filePath: attachmentPath,
              docname: current.name,
            );
      await _addUpdateUseCase.call(
        name: current.name,
        note: note,
        progress: progress,
        status: status,
        attachment: attachment,
      );
      await load(current.name);
      return true;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('add task follow up update failed: $_error');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> closeTask({required String status, required String note}) async {
    final current = _details;
    if (current == null) return false;
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      await _closeTaskUseCase.call(
        name: current.name,
        status: status,
        note: note,
      );
      await load(current.name);
      return true;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('close task follow up failed: $_error');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
