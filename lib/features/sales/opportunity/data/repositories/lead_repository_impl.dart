import '../../domain/entities/opportunity.dart';
import '../../domain/entities/opportunity_dashboard_summary.dart';
import '../../domain/entities/opportunity_details.dart';
import '../../domain/entities/opportunity_follow_up.dart';
import '../../domain/entities/opportunity_option_item.dart';
import '../../domain/entities/opportunity_required_fields_result.dart';
import '../../domain/entities/opportunity_workflow_info.dart';
import '../../domain/repositories/opportunity_repository.dart';
import '../datasources/opportunity_remote_datasource.dart';

class OpportunityRepositoryImpl implements OpportunityRepository {
  final OpportunityRemoteDataSource remoteDataSource;

  OpportunityRepositoryImpl(this.remoteDataSource);

  @override
  Future<OpportunityRequiredFieldsResult> getOpportunityForm({
    String? opportunityName,
  }) {
    return remoteDataSource.getOpportunityForm(
      opportunityName: opportunityName,
    );
  }

  @override
  Future<Map<String, String>> getPartyPrefill({
    required String partyType,
    required String partyName,
  }) {
    return remoteDataSource.getPartyPrefill(
      partyType: partyType,
      partyName: partyName,
    );
  }

  @override
  Future<void> addOpportunityFollowUp({
    required String opportunityName,
    required String followUpDate,
    required String expectedResultDate,
    required String details,
    String? attachment,
  }) {
    return remoteDataSource.addOpportunityFollowUp(
      opportunityName: opportunityName,
      followUpDate: followUpDate,
      expectedResultDate: expectedResultDate,
      details: details,
      attachment: attachment,
    );
  }

  @override
  Future<String> createOpportunity(Map<String, dynamic> data) {
    return remoteDataSource.createOpportunity(data);
  }

  @override
  Future<OpportunityDetails> getOpportunityDetails(String opportunityName) {
    return remoteDataSource.getOpportunityDetails(opportunityName);
  }

  @override
  Future<List<OpportunityFollowUp>> getOpportunityFollowUps(
    String opportunityName,
  ) {
    return remoteDataSource.getOpportunityFollowUps(opportunityName);
  }

  @override
  Future<List<Opportunity>> getOpportunities({
    required int start,
    required int limit,
    String? status,
    String? search,
    String? followUpFilter,
    String? sortBy,
  }) {
    return remoteDataSource.getOpportunities(
      start: start,
      limit: limit,
      status: status,
      search: search,
      followUpFilter: followUpFilter,
      sortBy: sortBy,
    );
  }

  @override
  Future<OpportunityDashboardSummary> getDashboardSummary({
    String? status,
    String? search,
  }) {
    return remoteDataSource.getDashboardSummary(status: status, search: search);
  }

  @override
  Future<OpportunityWorkflowInfo> getWorkflowActions(String opportunityName) {
    return remoteDataSource.getWorkflowActions(opportunityName);
  }

  @override
  Future<OpportunityWorkflowInfo> executeWorkflowAction({
    required String opportunityName,
    required String action,
  }) {
    return remoteDataSource.executeWorkflowAction(
      opportunityName: opportunityName,
      action: action,
    );
  }

  @override
  Future<OpportunityRequiredFieldsResult> getRequiredFields(
    Map<String, dynamic> data,
  ) {
    return remoteDataSource.getRequiredFields(data);
  }

  @override
  Future<void> updateOpportunity(
    String opportunityName,
    Map<String, dynamic> data,
  ) {
    return remoteDataSource.updateOpportunity(opportunityName, data);
  }

  @override
  Future<List<OpportunityOptionItem>> searchLinkOptions({
    required String doctype,
    String query = '',
  }) {
    return remoteDataSource.searchLinkOptions(doctype: doctype, query: query);
  }

  @override
  Future<String> uploadAttachment({
    required String filePath,
    required String opportunityName,
  }) {
    return remoteDataSource.uploadAttachment(
      filePath: filePath,
      opportunityName: opportunityName,
    );
  }
}
