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

  static Uri uri(String endpoint) => Uri.parse("$baseUrl$endpoint");
}
