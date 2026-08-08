class ApiConstants {
  static const String baseUrl = "https://erp.tecpalace.com.sa";

  static const String loginEndpoint = "/api/method/mobile_api.api.login";
  static const String sessionLoginEndpoint = "/api/method/login";
  static const String projectsEndpoint =
      "/api/method/mobile_api.api.get_my_projects";
  static const String projectDetailsEndpoint =
      "/api/method/mobile_api.api.get_project_details";
  static const String taskDetailsEndpoint =
      "/api/method/mobile_api.api.get_task_details";
  static const String addFollowUpEndpoint =
      "/api/method/mobile_api.api.add_follow_up";
  static const String leadsEndpoint =
      "/api/method/mobile_api.api.get_leads";
  static const String leadDetailsEndpoint =
      "/api/method/mobile_api.api.get_lead_details";
  static const String leadRequiredFieldsEndpoint =
      "/api/method/mobile_api.api.get_lead_required_fields";
  static const String createLeadEndpoint =
      "/api/method/mobile_api.api.create_lead";
  static const String updateLeadEndpoint =
      "/api/method/mobile_api.api.update_lead";
  static const String addLeadFollowUpEndpoint =
      "/api/method/mobile_api.api.add_lead_follow_up";
  static const String leadFollowUpsEndpoint =
      "/api/method/mobile_api.api.get_lead_follow_ups";
  static const String leadsDashboardSummaryEndpoint =
      "/api/method/mobile_api.api.get_leads_dashboard_summary";
  static const String opportunityFormEndpoint =
      "/api/method/mobile_api.api.get_opportunity_form";
  static const String opportunitiesEndpoint =
      "/api/method/mobile_api.api.get_opportunities";
  static const String opportunityDetailsEndpoint =
      "/api/method/mobile_api.api.get_opportunity_details";
  static const String opportunityRequiredFieldsEndpoint =
      "/api/method/mobile_api.api.get_opportunity_required_fields";
  static const String createOpportunityEndpoint =
      "/api/method/mobile_api.api.create_opportunity";
  static const String updateOpportunityEndpoint =
      "/api/method/mobile_api.api.update_opportunity";
  static const String addOpportunityFollowUpEndpoint =
      "/api/method/mobile_api.api.add_opportunity_follow_up";
  static const String opportunityFollowUpsEndpoint =
      "/api/method/mobile_api.api.get_opportunity_follow_ups";
  static const String opportunitiesDashboardSummaryEndpoint =
      "/api/method/mobile_api.api.get_opportunities_dashboard_summary";
  static const String opportunityWorkflowActionsEndpoint =
      "/api/method/mobile_api.api.get_opportunity_workflow_actions";
  static const String executeOpportunityWorkflowActionEndpoint =
      "/api/method/mobile_api.api.execute_opportunity_workflow_action";
  static const String sendOpportunityForApprovalEndpoint =
      "/api/method/mobile_api.api.send_opportunity_for_approval";
  static const String returnOpportunityWorkflowEndpoint =
      "/api/method/mobile_api.api.return_opportunity_workflow";
  static const String quotationsEndpoint =
      "/api/method/mobile_api.api.get_quotations";
  static const String quotationsDashboardSummaryEndpoint =
      "/api/method/mobile_api.api.get_quotations_dashboard_summary";
  static const String quotationDetailsEndpoint =
      "/api/method/mobile_api.api.get_quotation_details";
  static const String quotationPrintDataEndpoint =
      "/api/method/mobile_api.api.get_quotation_print_data";
  static const String addQuotationFollowUpEndpoint =
      "/api/method/mobile_api.api.add_quotation_follow_up";
  static const String quotationFollowUpsEndpoint =
      "/api/method/mobile_api.api.get_quotation_follow_ups";
  static const String quotationWorkflowActionsEndpoint =
      "/api/method/mobile_api.api.get_quotation_workflow_actions";
  static const String executeQuotationWorkflowActionEndpoint =
      "/api/method/mobile_api.api.execute_quotation_workflow_action";
  static const String sendQuotationForApprovalEndpoint =
      "/api/method/mobile_api.api.send_quotation_for_approval";
  static const String returnQuotationWorkflowEndpoint =
      "/api/method/mobile_api.api.return_quotation_workflow";
  static const String workflowNotificationsEndpoint =
      "/api/method/mobile_api.api.get_workflow_notifications";
  static const String workflowNotificationsSummaryEndpoint =
      "/api/method/mobile_api.api.get_workflow_notifications_summary";
  static const String searchLinkEndpoint =
      "/api/method/frappe.desk.search.search_link";

  static Uri uri(String endpoint) => Uri.parse("$baseUrl$endpoint");
}
