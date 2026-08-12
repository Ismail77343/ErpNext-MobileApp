import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'hr_attendance_page.dart';
import '../providers/attendance_provider.dart';

class HrPage extends StatelessWidget {
  final bool embedded;

  const HrPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final content = const _HrModuleContent();

    if (embedded) return content;
    return Scaffold(
      appBar: AppBar(title: const Text('Human Resources')),
      body: content,
    );
  }
}

class _HrModuleContent extends StatefulWidget {
  const _HrModuleContent();

  @override
  State<_HrModuleContent> createState() => _HrModuleContentState();
}

class _HrModuleContentState extends State<_HrModuleContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AttendanceProvider>().load();
    });
  }

  Future<void> _openAttendance(AttendanceProvider attendance) async {
    if (attendance.contextData == null && !attendance.isLoading) {
      await attendance.load();
      if (!mounted) return;
    }

    if (!attendance.canOpenAttendance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(attendance.deviceVerificationMessage())),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HrAttendancePage()),
    );
  }

  Future<void> _requestVerification(AttendanceProvider attendance) async {
    final phoneNumber = await _showPhoneNumberDialog();
    if (!mounted || phoneNumber == null) return;

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    final success = await context
        .read<AttendanceProvider>()
        .requestDeviceVerification(phoneNumber);
    if (!mounted) return;

    final currentAttendance = context.read<AttendanceProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Device verification request sent. Please wait for HR approval.'
              : (currentAttendance.error ??
                    'Unable to request device verification.'),
        ),
      ),
    );
  }

  Future<String?> _showPhoneNumberDialog() async {
    return showDialog<String>(
      context: context,
      builder: (_) => const _PhoneNumberDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 28;

    return Consumer<AttendanceProvider>(
      builder: (context, attendance, _) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF7FCFF), Color(0xFFEAF7FA)],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () => context.read<AttendanceProvider>().load(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
              children: [
                const _HrWelcomeCard(),
                const SizedBox(height: 18),
                if (attendance.isLoading && attendance.contextData == null)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: LinearProgressIndicator(),
                  ),
                if (attendance.error != null) ...[
                  _HrStatusCard(
                    message: attendance.error!,
                    icon: Icons.error_outline_rounded,
                    color: const Color(0xFFBE123C),
                    backgroundColor: const Color(0xFFFFF1F2),
                  ),
                  const SizedBox(height: 12),
                ],
                _DeviceVerificationCard(
                  attendance: attendance,
                  onRequest: attendance.isProcessing
                      ? null
                      : () => _requestVerification(attendance),
                  onRefresh: attendance.isLoading
                      ? null
                      : () => attendance.load(),
                ),
                const SizedBox(height: 18),
                const Text(
                  'HR Services',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                _ServiceCard(
                  title: 'Attendance',
                  subtitle: attendance.canOpenAttendance
                      ? 'Clock in and out with approved device and GPS.'
                      : 'Mobile device approval is required before attendance.',
                  icon: Icons.fingerprint_rounded,
                  gradient: const [Color(0xFF0E7490), Color(0xFF06B6D4)],
                  enabled: true,
                  onTap: () => _openAttendance(attendance),
                ),
                const SizedBox(height: 12),
                const _ServiceCard(
                  title: 'Leave Request',
                  subtitle: 'Request annual, sick, or emergency leave.',
                  icon: Icons.beach_access_rounded,
                  enabled: false,
                ),
                const SizedBox(height: 12),
                const _ServiceCard(
                  title: 'Attendance Log',
                  subtitle: 'Review your daily clock in and clock out history.',
                  icon: Icons.history_rounded,
                  enabled: false,
                ),
                const SizedBox(height: 12),
                const _ServiceCard(
                  title: 'Attendance Report',
                  subtitle: 'View monthly attendance summaries and exceptions.',
                  icon: Icons.analytics_outlined,
                  enabled: false,
                ),
                const SizedBox(height: 12),
                const _ServiceCard(
                  title: 'Export PDF',
                  subtitle: 'Download attendance reports as PDF files.',
                  icon: Icons.picture_as_pdf_outlined,
                  enabled: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PhoneNumberDialog extends StatefulWidget {
  const _PhoneNumberDialog();

  @override
  State<_PhoneNumberDialog> createState() => _PhoneNumberDialogState();
}

class _PhoneNumberDialogState extends State<_PhoneNumberDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verify Mobile Device'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Phone Number',
          hintText: '+9665XXXXXXXX',
        ),
        autofocus: true,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Send Request')),
      ],
    );
  }
}

class _DeviceVerificationCard extends StatelessWidget {
  final AttendanceProvider attendance;
  final VoidCallback? onRequest;
  final VoidCallback? onRefresh;

  const _DeviceVerificationCard({
    required this.attendance,
    required this.onRequest,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final verification = attendance.deviceVerification;
    if (verification == null || !verification.required) {
      return const _HrStatusCard(
        message: 'Mobile device verification is not required.',
        icon: Icons.verified_user_outlined,
        color: Color(0xFF0F766E),
        backgroundColor: Color(0xFFE0F2F1),
      );
    }

    final isApproved = verification.canCheckin || verification.verified;
    final canRequest =
        verification.canRequest ||
        verification.isNotRequested ||
        verification.isRejected ||
        verification.isRevoked;
    final color = isApproved
        ? const Color(0xFF0F766E)
        : verification.isPending
        ? const Color(0xFFD97706)
        : const Color(0xFFBE123C);
    final bg = isApproved
        ? const Color(0xFFE0F2F1)
        : verification.isPending
        ? const Color(0xFFFFF7ED)
        : const Color(0xFFFFF1F2);
    final icon = isApproved
        ? Icons.verified_rounded
        : verification.isPending
        ? Icons.hourglass_top_rounded
        : Icons.phonelink_lock_outlined;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isApproved
                      ? 'Device Approved'
                      : verification.isPending
                      ? 'Pending HR Approval'
                      : 'Device Verification Required',
                  style: TextStyle(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            attendance.deviceVerificationMessage(),
            style: TextStyle(
              color: color,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (verification.status.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Status: ${verification.status}',
              style: TextStyle(color: color.withValues(alpha: 0.82)),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              if (!isApproved && canRequest)
                FilledButton.icon(
                  onPressed: onRequest,
                  icon: attendance.isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_to_mobile_outlined),
                  label: const Text('Request Verification'),
                ),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh Status'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HrStatusCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _HrStatusCard({
    required this.message,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _HrWelcomeCard extends StatelessWidget {
  const _HrWelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF072F5F), Color(0xFF1D4ED8), Color(0xFF06B6D4)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E7490).withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'HR Mode',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Human Resources',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start with attendance today. More employee services are ready to plug in next.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final List<Color>? gradient;
  final VoidCallback? onTap;

  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeGradient =
        gradient ?? const [Color(0xFF0F766E), Color(0xFF14B8A6)];

    return Opacity(
      opacity: enabled ? 1 : 0.64,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: enabled
                  ? const Color(0xFFDDEAF0)
                  : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: enabled ? 0.08 : 0.04),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: enabled
                      ? LinearGradient(colors: activeGradient)
                      : null,
                  color: enabled ? null : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: enabled ? Colors.white : const Color(0xFF64748B),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (!enabled) const _SoonBadge(),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        height: 1.28,
                      ),
                    ),
                  ],
                ),
              ),
              if (enabled) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0xFF0E7490),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SoonBadge extends StatelessWidget {
  const _SoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Coming Soon',
        style: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
