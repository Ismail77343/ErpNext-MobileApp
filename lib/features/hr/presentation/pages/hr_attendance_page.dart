import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/attendance_context.dart';
import '../providers/attendance_provider.dart';

class HrAttendancePage extends StatefulWidget {
  final bool embedded;

  const HrAttendancePage({super.key, this.embedded = false});

  @override
  State<HrAttendancePage> createState() => _HrAttendancePageState();
}

class _HrAttendancePageState extends State<HrAttendancePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AttendanceProvider>().load();
    });
  }

  Future<void> _handleAttendanceAction() async {
    final provider = context.read<AttendanceProvider>();
    final preview = await provider.prepareAttendanceAction();
    if (!mounted || preview == null) return;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AttendanceConfirmSheet(preview: preview),
    );
    if (confirmed != true || !mounted) return;

    final success = await provider.submitAttendanceAction(preview);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '${preview.logType == 'IN' ? 'Check in' : 'Check out'} recorded successfully.'
              : (provider.error ?? 'Unable to record attendance.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 36;
    final content = Consumer<AttendanceProvider>(
      builder: (context, attendance, _) {
        final data = attendance.contextData;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FBFF), Color(0xFFEAF7FA)],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () => context.read<AttendanceProvider>().load(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
              children: [
                _HrHeaderCard(attendance: attendance),
                const SizedBox(height: 14),
                if (attendance.isLoading && data == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  if (attendance.error != null) ...[
                    _StatusMessageCard(
                      message: attendance.error!,
                      isError: true,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _AttendanceActionCard(
                    attendance: attendance,
                    onPressed:
                        attendance.canSubmitAttendance &&
                            !attendance.isProcessing
                        ? _handleAttendanceAction
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _LocationSection(attendance: attendance),
                  const SizedBox(height: 14),
                  _LastCheckinCard(lastCheckin: data?.lastCheckin),
                ],
              ],
            ),
          ),
        );
      },
    );

    if (widget.embedded) return content;
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: content,
    );
  }
}

class _HrHeaderCard extends StatelessWidget {
  final AttendanceProvider attendance;

  const _HrHeaderCard({required this.attendance});

  @override
  Widget build(BuildContext context) {
    final data = attendance.contextData;
    final employee = data?.employee;
    final employeeName = employee?.employeeName.isNotEmpty == true
        ? employee!.employeeName
        : 'HR Attendance';
    final status = attendance.isCheckedIn ? 'Checked In' : 'Ready';
    final dateText = _formatDate(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B4E8A), Color(0xFF1D4ED8), Color(0xFF06B6D4)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B4E8A).withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const Spacer(),
              _GlassPill(text: status),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            employeeName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            employee?.company.isNotEmpty == true ? employee!.company : dateText,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                dateText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final String text;

  const _GlassPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AttendanceActionCard extends StatelessWidget {
  final AttendanceProvider attendance;
  final VoidCallback? onPressed;

  const _AttendanceActionCard({
    required this.attendance,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final logType = attendance.nextLogType;
    final label = logType == 'IN' ? 'Clock In' : 'Clock Out';
    final photoRequired =
        attendance.contextData?.settings.isPhotoRequiredFor(logType) ?? false;
    final subtitle = logType == 'IN'
        ? 'Verify your device, capture GPS${photoRequired ? ', take face photo' : ''}, then clock in.'
        : 'Verify your device, capture GPS${photoRequired ? ', take face photo' : ''}, then clock out.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE0F2FE),
                  child: Icon(
                    logType == 'IN'
                        ? Icons.login_rounded
                        : Icons.logout_rounded,
                    color: const Color(0xFF0369A1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!attendance.canSubmitAttendance) ...[
              const SizedBox(height: 14),
              _StatusMessageCard(
                message: _disabledReason(attendance),
                isError: true,
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPressed,
                icon: attendance.isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.fingerprint_rounded),
                label: Text(label),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
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

class _LocationSection extends StatelessWidget {
  final AttendanceProvider attendance;

  const _LocationSection({required this.attendance});

  @override
  Widget build(BuildContext context) {
    final locations = attendance.contextData?.allowedLocations ?? const [];
    final settings = attendance.contextData?.settings;

    if (locations.isEmpty) {
      return _StatusMessageCard(
        message: settings?.allowCheckinWithoutAssignment == true
            ? 'No assigned location. The server will select the nearest valid location when possible.'
            : 'No attendance location assigned.',
        isError: settings?.allowCheckinWithoutAssignment != true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Work Location',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 10),
        ...locations.map(
          (location) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _LocationCard(
              location: location,
              selected: attendance.selectedLocation?.name == location.name,
              onTap: () => attendance.selectLocation(location),
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  final AttendanceLocation location;
  final bool selected;
  final VoidCallback onTap;

  const _LocationCard({
    required this.location,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE0F2FE) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: selected
                  ? const Color(0xFF0284C7)
                  : const Color(0xFFE2E8F0),
              child: Icon(
                selected ? Icons.check_rounded : Icons.location_on_outlined,
                color: selected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.locationName.isNotEmpty
                        ? location.locationName
                        : location.name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${location.locationType.isEmpty ? 'Location' : location.locationType} | Radius ${location.radiusMeters.toStringAsFixed(0)} m',
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                  if (location.address.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      location.address,
                      style: const TextStyle(color: Color(0xFF64748B)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LastCheckinCard extends StatelessWidget {
  final LastCheckin? lastCheckin;

  const _LastCheckinCard({required this.lastCheckin});

  @override
  Widget build(BuildContext context) {
    final last = lastCheckin;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE0F2FE),
              child: Icon(Icons.history_rounded, color: Color(0xFF0369A1)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Last Attendance',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    last == null
                        ? 'No check-in recorded yet.'
                        : '${last.logType} | ${_formatDateTime(last.time)}',
                    style: const TextStyle(color: Color(0xFF475569)),
                  ),
                  if (last != null && last.geofenceStatus.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Geofence: ${last.geofenceStatus}',
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceConfirmSheet extends StatelessWidget {
  final AttendanceActionPreview preview;

  const _AttendanceConfirmSheet({required this.preview});

  @override
  Widget build(BuildContext context) {
    final location = preview.selectedLocation;
    final isOut = preview.isOutsideRange;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              preview.logType == 'IN'
                  ? 'Confirm Clock In'
                  : 'Confirm Clock Out',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            _ConfirmRow(label: 'Log Type', value: preview.logType),
            _ConfirmRow(
              label: 'Location',
              value: location?.locationName.isNotEmpty == true
                  ? location!.locationName
                  : (location?.name ?? 'Auto selected by server'),
            ),
            _ConfirmRow(
              label: 'GPS Accuracy',
              value: '${preview.position.accuracy.toStringAsFixed(1)} m',
            ),
            _ConfirmRow(
              label: 'Distance',
              value: preview.distanceMeters == null
                  ? 'Calculated by server'
                  : '${preview.distanceMeters!.toStringAsFixed(1)} m',
            ),
            if (preview.photoRequired) ...[
              const SizedBox(height: 8),
              _PhotoPreviewCard(photoPath: preview.photo?.path),
            ],
            if (isOut) ...[
              const SizedBox(height: 10),
              const _StatusMessageCard(
                message:
                    'You appear to be outside the selected range. The backend will make the final decision.',
                isError: true,
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPreviewCard extends StatelessWidget {
  final String? photoPath;

  const _PhotoPreviewCard({required this.photoPath});

  @override
  Widget build(BuildContext context) {
    final path = photoPath;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: path == null || path.isEmpty
                ? Container(
                    width: 74,
                    height: 74,
                    color: const Color(0xFFDDEAF0),
                    child: const Icon(Icons.face_rounded),
                  )
                : Image.file(
                    File(path),
                    width: 74,
                    height: 74,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Face Photo Captured',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  'Required by HR attendance settings and will be sent with this request.',
                  style: TextStyle(color: Color(0xFF64748B), height: 1.25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMessageCard extends StatelessWidget {
  final String message;
  final bool isError;

  const _StatusMessageCard({required this.message, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final bg = isError ? const Color(0xFFFFF1F2) : const Color(0xFFEFF6FF);
    final border = isError ? const Color(0xFFFDA4AF) : const Color(0xFFBFDBFE);
    final fg = isError ? const Color(0xFFBE123C) : const Color(0xFF1E3A8A);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.info_outline_rounded,
            color: fg,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: fg, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

String _disabledReason(AttendanceProvider attendance) {
  final data = attendance.contextData;
  if (data == null) return 'Attendance context is not loaded.';
  if (!data.enabled) return 'Attendance from mobile is disabled.';
  if (data.employee == null) {
    return 'No active employee is linked to your user.';
  }
  if (data.allowedLocations.isEmpty &&
      !data.settings.allowCheckinWithoutAssignment) {
    return 'No attendance location assigned.';
  }
  return 'Attendance action is not available.';
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatDateTime(DateTime? value) {
  if (value == null) return 'Not recorded';
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${_formatDate(local)} $hour:$minute';
}
