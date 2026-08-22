import '../../domain/entities/opportunity.dart';

class OpportunityModel extends Opportunity {
  const OpportunityModel({
    required super.name,
    required super.opportunityName,
    required super.partyName,
    required super.firstName,
    required super.companyName,
    required super.content,
    required super.email,
    required super.mobileNo,
    required super.status,
    super.workflowState,
    required super.source,
    required super.lastModified,
    required super.lastUpdateDate,
    required super.nextFollowUpDate,
    required super.lastFollowUpReport,
    required super.hasFollowUp,
    required super.isOverdue,
    required super.isDueToday,
    required super.isDueThisWeek,
    required super.isDueThisMonth,
    required super.neverContacted,
  });

  factory OpportunityModel.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? json['id']?.toString() ?? '';
    final contact = json['contact'];
    final summary = json['follow_up_summary'];
    final contactMap = contact is Map<String, dynamic>
        ? contact
        : const <String, dynamic>{};
    final summaryMap = summary is Map<String, dynamic>
        ? summary
        : const <String, dynamic>{};

    return OpportunityModel(
      name: name,
      opportunityName: name,
      partyName: json['party_name']?.toString() ?? '',
      firstName:
          json['display_name']?.toString() ??
          json['customer_name']?.toString() ??
          json['party_name']?.toString() ??
          name,
      companyName: json['customer_name']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      email: contactMap['email']?.toString() ?? json['email']?.toString() ?? '',
      mobileNo:
          contactMap['mobile']?.toString() ?? json['mobile']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      workflowState: json['workflow_state']?.toString() ?? '',
      source: json['opportunity_from']?.toString() ?? '',
      lastModified: json['modified']?.toString() ?? '',
      lastUpdateDate:
          json['last_update_date']?.toString() ??
          summaryMap['last_update_date']?.toString() ??
          '',
      nextFollowUpDate:
          json['next_follow_up_date']?.toString() ??
          summaryMap['next_follow_up_date']?.toString() ??
          '',
      lastFollowUpReport:
          json['last_follow_up_report']?.toString() ??
          summaryMap['last_follow_up_report']?.toString() ??
          '',
      hasFollowUp: _toBool(
        json['has_follow_up'] ?? summaryMap['has_follow_up'],
      ),
      isOverdue: _toBool(json['is_overdue'] ?? summaryMap['is_overdue']),
      isDueToday: _toBool(json['is_due_today'] ?? summaryMap['is_due_today']),
      isDueThisWeek: _toBool(
        json['is_due_this_week'] ?? summaryMap['is_due_this_week'],
      ),
      isDueThisMonth: _toBool(
        json['is_due_this_month'] ?? summaryMap['is_due_this_month'],
      ),
      neverContacted: _toBool(
        json['never_contacted'] ?? summaryMap['never_contacted'],
      ),
    );
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    final text = value?.toString().toLowerCase() ?? '';
    return text == '1' || text == 'true' || text == 'yes';
  }
}
