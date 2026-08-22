class Opportunity {
  final String name;
  final String opportunityName;
  final String partyName;
  final String firstName;
  final String companyName;
  final String content;
  final String email;
  final String mobileNo;
  final String status;
  final String? workflowState;
  final String source;
  final String lastModified;
  final String lastUpdateDate;
  final String nextFollowUpDate;
  final String lastFollowUpReport;
  final bool hasFollowUp;
  final bool isOverdue;
  final bool isDueToday;
  final bool isDueThisWeek;
  final bool isDueThisMonth;
  final bool neverContacted;

  const Opportunity({
    required this.name,
    required this.opportunityName,
    required this.partyName,
    required this.firstName,
    required this.companyName,
    required this.content,
    required this.email,
    required this.mobileNo,
    required this.status,
    this.workflowState,
    required this.source,
    required this.lastModified,
    required this.lastUpdateDate,
    required this.nextFollowUpDate,
    required this.lastFollowUpReport,
    required this.hasFollowUp,
    required this.isOverdue,
    required this.isDueToday,
    required this.isDueThisWeek,
    required this.isDueThisMonth,
    required this.neverContacted,
  });
}
