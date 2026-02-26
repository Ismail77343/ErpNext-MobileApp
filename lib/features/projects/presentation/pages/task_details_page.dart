import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/datasources/project_remote_datasource.dart';
import '../../domain/entities/task_details.dart';

class TaskDetailsPage extends StatefulWidget {
  final String taskName;

  const TaskDetailsPage({super.key, required this.taskName});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  final ProjectRemoteDataSource _remoteDataSource = ProjectRemoteDataSource();
  bool _isLoading = false;
  TaskDetails? _details;
  String? _error;
  final Set<String> _downloadingAttachments = <String>{};

  @override
  void initState() {
    super.initState();
    AppLogger.nav('open task details page: ${widget.taskName}');
    _loadTaskDetails();
  }

  Future<void> _loadTaskDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _remoteDataSource.getTaskDetails(widget.taskName);
      if (!mounted) return;
      setState(() => _details = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openFollowUpPage() async {
    final details = _details;
    if (details == null) return;

    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddFollowUpPage(
          taskName: details.name,
          currentProgress: details.progress.toInt(),
        ),
      ),
    );

    if (added == true) {
      await _loadTaskDetails();
    }
  }

  Future<void> _openAttachment(String rawPath) async {
    final url = _resolveAttachmentUrl(rawPath);
    try {
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open attachment')),
        );
      }
    } on MissingPluginException {
      _showError('url_launcher plugin not registered. Rebuild app fully.');
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _downloadAttachment(String rawPath) async {
    if (_downloadingAttachments.contains(rawPath)) return;
    setState(() => _downloadingAttachments.add(rawPath));
    final url = _resolveAttachmentUrl(rawPath);

    try {
      final uri = Uri.parse(url);
      final response = await HttpClient().getUrl(uri).then((r) => r.close());
      if (response.statusCode != 200) {
        throw Exception('Download failed: ${response.statusCode}');
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      final dir = await getApplicationDocumentsDirectory();
      final fileName = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : 'attachment_${DateTime.now().millisecondsSinceEpoch}';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Downloaded: ${file.path}')));
    } on MissingPluginException {
      _showError('Required plugin not registered. Rebuild app fully.');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _downloadingAttachments.remove(rawPath));
      }
    }
  }

  String _resolveAttachmentUrl(String rawPath) {
    final path = rawPath.trim();
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '${ApiConstants.baseUrl}$path';
    return '${ApiConstants.baseUrl}/$path';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final details = _details;

    return Scaffold(
      appBar: AppBar(title: Text('Task ${widget.taskName}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: details == null ? null : _openFollowUpPage,
        label: const Text('Add Follow Up'),
        icon: const Icon(Icons.add_task_rounded),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : details == null
          ? const Center(child: Text('No task details found'))
          : RefreshIndicator(
              onRefresh: _loadTaskDetails,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _TaskHeader(details: details),
                  const SizedBox(height: 14),
                  const _SectionTitle('Child Follow'),
                  if (details.childFollow.isEmpty)
                    const _EmptyCard(label: 'No child follow records')
                  else
                    ...details.childFollow.map(
                      (item) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.followUp.isNotEmpty
                                          ? item.followUp
                                          : (item.title.isNotEmpty
                                                ? item.title
                                                : item.name),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${item.progress.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      color: _progressColor(item.progress),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Date: ${_displayDate(item.dateFollow.isNotEmpty ? item.dateFollow : item.dueDate)} ${item.timeFollow}',
                              ),
                              if (item.registrationDateTime.isNotEmpty)
                                Text(
                                  'Registered: ${_displayDateTime(item.registrationDateTime)}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              if (item.attachment.isNotEmpty)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Attachment: ${item.attachment}',
                                        style: const TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Open',
                                      onPressed: () =>
                                          _openAttachment(item.attachment),
                                      icon: const Icon(
                                        Icons.open_in_new_rounded,
                                        size: 18,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Download',
                                      onPressed:
                                          _downloadingAttachments.contains(
                                            item.attachment,
                                          )
                                          ? null
                                          : () => _downloadAttachment(
                                              item.attachment,
                                            ),
                                      icon:
                                          _downloadingAttachments.contains(
                                            item.attachment,
                                          )
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.download_rounded,
                                              size: 18,
                                            ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: item.progress.clamp(0, 100) / 100,
                                  minHeight: 7,
                                  color: _progressColor(item.progress),
                                  backgroundColor: const Color(0xFFE2E8F0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  const _SectionTitle('Activity Log'),
                  if (details.activityLog.isEmpty)
                    const _EmptyCard(label: 'No activity yet')
                  else
                    ...details.activityLog.map(
                      (log) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      log.commentBy,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _displayDateTime(log.creation),
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(_stripHtml(log.content)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class AddFollowUpPage extends StatefulWidget {
  final String taskName;
  final int currentProgress;

  const AddFollowUpPage({
    super.key,
    required this.taskName,
    required this.currentProgress,
  });

  @override
  State<AddFollowUpPage> createState() => _AddFollowUpPageState();
}

class _AddFollowUpPageState extends State<AddFollowUpPage> {
  final ProjectRemoteDataSource _remoteDataSource = ProjectRemoteDataSource();
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _noteController;
  late final TextEditingController _progressController;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _attachmentPath;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _progressController = TextEditingController(
      text: widget.currentProgress.toString(),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(withData: false);
      if (result == null || result.files.single.path == null) return;
      setState(() => _attachmentPath = result.files.single.path);
    } on MissingPluginException {
      _showPluginMissingMessage();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final file = await _imagePicker.pickImage(source: ImageSource.camera);
      if (file == null) return;
      setState(() => _attachmentPath = file.path);
    } on MissingPluginException {
      _showPluginMissingMessage();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _pickVideoFromCamera() async {
    try {
      final file = await _imagePicker.pickVideo(source: ImageSource.camera);
      if (file == null) return;
      setState(() => _attachmentPath = file.path);
    } on MissingPluginException {
      _showPluginMissingMessage();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      String? attachmentUrl;
      if (_attachmentPath != null && _attachmentPath!.isNotEmpty) {
        attachmentUrl = await _remoteDataSource.uploadAttachment(
          filePath: _attachmentPath!,
          doctype: 'Task',
          docname: widget.taskName,
        );
      }

      await _remoteDataSource.addFollowUp(
        taskName: widget.taskName,
        dateFollow: _dateOnly(_selectedDate),
        timeFollow: _timeOnly(_selectedTime),
        progress: int.parse(_progressController.text.trim()),
        followUp: _noteController.text.trim(),
        attachment: attachmentUrl,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showPluginMissingMessage() {
    _showError(
      'Plugin not registered yet. Please stop the app completely, run flutter pub get, then run flutter clean and flutter run.',
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Follow Up')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Follow Up Date *'),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: _InputBox(
                text: _dateOnly(_selectedDate),
                icon: Icons.date_range_rounded,
              ),
            ),
            const SizedBox(height: 12),
            const Text('Follow Up Time'),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (time != null) setState(() => _selectedTime = time);
              },
              child: _InputBox(
                text: _timeOnly(_selectedTime),
                icon: Icons.access_time_rounded,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _progressController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Progress % (0-100) *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final n = int.tryParse((value ?? '').trim());
                if (n == null || n < 0 || n > 100) {
                  return 'Enter valid progress from 0 to 100';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Follow Up Note *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Follow up note is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            const Text('Attachment'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('File'),
                ),
                OutlinedButton.icon(
                  onPressed: _pickImageFromCamera,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera Photo'),
                ),
                OutlinedButton.icon(
                  onPressed: _pickVideoFromCamera,
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text('Camera Video'),
                ),
              ],
            ),
            if (_attachmentPath != null) ...[
              const SizedBox(height: 8),
              Text(
                _attachmentPath!,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Follow Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _dateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String _timeOnly(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }
}

class _TaskHeader extends StatelessWidget {
  final TaskDetails details;

  const _TaskHeader({required this.details});

  @override
  Widget build(BuildContext context) {
    final percent = details.progress.clamp(0, 100).toDouble();
    final color = _progressColor(percent);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              details.subject.isNotEmpty ? details.subject : details.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Task: ${details.name}'),
            const SizedBox(height: 3),
            Text('Project: ${details.project}'),
            const SizedBox(height: 3),
            Text('Status: ${details.status}'),
            const SizedBox(height: 3),
            Text('Priority: ${details.priority}'),
            const SizedBox(height: 3),
            Text(
              'From ${_displayDate(details.expectedStartDate)} to ${_displayDate(details.expectedEndDate)}',
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progress',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percent / 100,
              color: color,
              minHeight: 10,
              backgroundColor: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(999),
            ),
            if (details.description.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(details.description),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String label;

  const _EmptyCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(14), child: Text(label)),
    );
  }
}

class _InputBox extends StatelessWidget {
  final String text;
  final IconData icon;

  const _InputBox({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF475467), size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

Color _progressColor(double percent) {
  if (percent < 35) return const Color(0xFFDC2626);
  if (percent < 70) return const Color(0xFFD97706);
  return const Color(0xFF16A34A);
}

String _displayDate(String value) {
  final d = DateTime.tryParse(value);
  if (d == null) return value.isEmpty ? '-' : value;
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

String _displayDateTime(String value) {
  final d = DateTime.tryParse(value);
  if (d == null) return value.isEmpty ? '-' : value;
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$y-$m-$day $hh:$mm';
}

String _stripHtml(String html) {
  return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
}
