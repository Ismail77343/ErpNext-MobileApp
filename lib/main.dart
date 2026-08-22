import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_branding.dart';

// Auth
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/navigation/presentation/pages/main_shell_page.dart';
import 'features/hr/data/datasources/attendance_remote_datasource.dart';
import 'features/hr/data/repositories/attendance_repository_impl.dart';
import 'features/hr/data/services/attendance_location_service.dart';
import 'features/hr/data/services/attendance_photo_service.dart';
import 'features/hr/data/services/attendance_security_service.dart';
import 'features/hr/data/services/mobile_device_identity_service.dart';
import 'features/hr/domain/usecases/create_employee_checkin_usecase.dart';
import 'features/hr/domain/usecases/get_attendance_context_usecase.dart';
import 'features/hr/domain/usecases/request_mobile_device_verification_usecase.dart';
import 'features/hr/presentation/providers/attendance_provider.dart';

// Projects
import 'features/projects/presentation/providers/projects_provider.dart';
import 'features/projects/presentation/providers/project_details_provider.dart';
import 'features/projects/data/datasources/project_remote_datasource.dart';
import 'features/projects/data/repositories/project_repository_impl.dart';
import 'features/projects/domain/usecases/get_projects_usecase.dart';
import 'features/projects/domain/usecases/get_project_details_usecase.dart';
import 'features/sales/lead/data/datasources/lead_remote_datasource.dart';
import 'features/sales/lead/data/repositories/lead_repository_impl.dart';
import 'features/sales/lead/domain/usecases/add_lead_follow_up_usecase.dart';
import 'features/sales/lead/domain/usecases/create_lead_usecase.dart';
import 'features/sales/lead/domain/usecases/get_lead_details_usecase.dart';
import 'features/sales/lead/domain/usecases/get_lead_required_fields_usecase.dart';
import 'features/sales/lead/domain/usecases/get_leads_usecase.dart';
import 'features/sales/lead/domain/usecases/get_leads_dashboard_summary_usecase.dart';
import 'features/sales/lead/domain/usecases/search_lead_link_options_usecase.dart';
import 'features/sales/lead/domain/usecases/upload_lead_attachment_usecase.dart';
import 'features/sales/lead/domain/usecases/update_lead_usecase.dart';
import 'features/sales/lead/presentation/providers/lead_details_provider.dart';
import 'features/sales/lead/presentation/providers/lead_form_provider.dart';
import 'features/sales/lead/presentation/providers/leads_provider.dart';
import 'features/sales/opportunity/data/datasources/opportunity_remote_datasource.dart';
import 'features/sales/opportunity/data/repositories/opportunity_repository_impl.dart';
import 'features/sales/opportunity/domain/usecases/add_opportunity_follow_up_usecase.dart';
import 'features/sales/opportunity/domain/usecases/create_opportunity_usecase.dart';
import 'features/sales/opportunity/domain/usecases/execute_opportunity_workflow_action_usecase.dart';
import 'features/sales/opportunity/domain/usecases/get_opportunities_dashboard_summary_usecase.dart';
import 'features/sales/opportunity/domain/usecases/get_opportunities_usecase.dart';
import 'features/sales/opportunity/domain/usecases/get_opportunity_details_usecase.dart';
import 'features/sales/opportunity/domain/usecases/get_opportunity_form_usecase.dart';
import 'features/sales/opportunity/domain/usecases/get_opportunity_party_prefill_usecase.dart';
import 'features/sales/opportunity/domain/usecases/get_opportunity_required_fields_usecase.dart';
import 'features/sales/opportunity/domain/usecases/get_opportunity_workflow_actions_usecase.dart';
import 'features/sales/opportunity/domain/usecases/search_opportunity_link_options_usecase.dart';
import 'features/sales/opportunity/domain/usecases/update_opportunity_usecase.dart';
import 'features/sales/opportunity/domain/usecases/upload_opportunity_attachment_usecase.dart';
import 'features/sales/opportunity/presentation/providers/opportunities_provider.dart';
import 'features/sales/opportunity/presentation/providers/opportunity_details_provider.dart';
import 'features/sales/opportunity/presentation/providers/opportunity_form_provider.dart';
import 'features/workflow_notifications/data/datasources/workflow_notifications_remote_datasource.dart';
import 'features/workflow_notifications/data/repositories/workflow_notifications_repository_impl.dart';
import 'features/workflow_notifications/domain/usecases/get_workflow_notifications_summary_usecase.dart';
import 'features/workflow_notifications/domain/usecases/get_workflow_notifications_usecase.dart';
import 'features/workflow_notifications/presentation/providers/workflow_notifications_provider.dart';
import 'features/task_follow_up/data/datasources/task_follow_up_remote_datasource.dart';
import 'features/task_follow_up/data/repositories/task_follow_up_repository_impl.dart';
import 'features/task_follow_up/domain/usecases/add_task_follow_up_update_usecase.dart';
import 'features/task_follow_up/domain/usecases/close_task_follow_up_usecase.dart';
import 'features/task_follow_up/domain/usecases/create_task_follow_up_usecase.dart';
import 'features/task_follow_up/domain/usecases/get_assigned_task_follow_ups_usecase.dart';
import 'features/task_follow_up/domain/usecases/get_my_task_follow_ups_usecase.dart';
import 'features/task_follow_up/domain/usecases/get_task_follow_up_details_usecase.dart';
import 'features/task_follow_up/domain/usecases/get_task_follow_up_notifications_usecase.dart';
import 'features/task_follow_up/domain/usecases/mark_task_follow_up_read_usecase.dart';
import 'features/task_follow_up/domain/usecases/search_task_follow_up_link_options_usecase.dart';
import 'features/task_follow_up/domain/usecases/upload_task_follow_up_attachment_usecase.dart';
import 'features/task_follow_up/presentation/providers/task_follow_up_details_provider.dart';
import 'features/task_follow_up/presentation/providers/task_follow_up_form_provider.dart';
import 'features/task_follow_up/presentation/providers/task_follow_up_notifications_provider.dart';
import 'features/task_follow_up/presentation/providers/task_follow_ups_provider.dart';
import 'features/stores/data/datasources/material_handover_remote_datasource.dart';
import 'features/stores/data/repositories/material_handover_repository_impl.dart';
import 'features/stores/data/services/material_handover_photo_service.dart';
import 'features/stores/domain/usecases/confirm_material_delivery_usecase.dart';
import 'features/stores/domain/usecases/confirm_material_pickup_usecase.dart';
import 'features/stores/domain/usecases/create_material_return_usecase.dart';
import 'features/stores/domain/usecases/get_material_handover_details_usecase.dart';
import 'features/stores/domain/usecases/get_material_handovers_usecase.dart';
import 'features/stores/domain/usecases/get_material_return_options_usecase.dart';
import 'features/stores/presentation/providers/material_handovers_provider.dart';

void main() {
  final authRepo = AuthRepositoryImpl();
  final loginUseCase = LoginUseCase(authRepo);

  final remoteDataSource = ProjectRemoteDataSource();
  final projectsRepo = ProjectRepositoryImpl(remoteDataSource);
  final getProjectsUseCase = GetProjectsUseCase(projectsRepo);
  final getProjectDetailsUseCase = GetProjectDetailsUseCase(projectsRepo);

  final leadRemoteDataSource = LeadRemoteDataSource();
  final leadsRepo = LeadRepositoryImpl(leadRemoteDataSource);
  final getLeadsUseCase = GetLeadsUseCase(leadsRepo);
  final getLeadsDashboardSummaryUseCase = GetLeadsDashboardSummaryUseCase(
    leadsRepo,
  );
  final getLeadDetailsUseCase = GetLeadDetailsUseCase(leadsRepo);
  final getLeadRequiredFieldsUseCase = GetLeadRequiredFieldsUseCase(leadsRepo);
  final createLeadUseCase = CreateLeadUseCase(leadsRepo);
  final updateLeadUseCase = UpdateLeadUseCase(leadsRepo);
  final addLeadFollowUpUseCase = AddLeadFollowUpUseCase(leadsRepo);
  final searchLeadLinkOptionsUseCase = SearchLeadLinkOptionsUseCase(leadsRepo);
  final uploadLeadAttachmentUseCase = UploadLeadAttachmentUseCase(leadsRepo);

  final opportunityRemoteDataSource = OpportunityRemoteDataSource();
  final opportunitiesRepo = OpportunityRepositoryImpl(
    opportunityRemoteDataSource,
  );
  final getOpportunitiesUseCase = GetOpportunitiesUseCase(opportunitiesRepo);
  final getOpportunitiesDashboardSummaryUseCase =
      GetOpportunitiesDashboardSummaryUseCase(opportunitiesRepo);
  final getOpportunityDetailsUseCase = GetOpportunityDetailsUseCase(
    opportunitiesRepo,
  );
  final getOpportunityFormUseCase = GetOpportunityFormUseCase(
    opportunitiesRepo,
  );
  final getOpportunityPartyPrefillUseCase = GetOpportunityPartyPrefillUseCase(
    opportunitiesRepo,
  );
  final getOpportunityRequiredFieldsUseCase =
      GetOpportunityRequiredFieldsUseCase(opportunitiesRepo);
  final createOpportunityUseCase = CreateOpportunityUseCase(opportunitiesRepo);
  final updateOpportunityUseCase = UpdateOpportunityUseCase(opportunitiesRepo);
  final getOpportunityWorkflowActionsUseCase =
      GetOpportunityWorkflowActionsUseCase(opportunitiesRepo);
  final executeOpportunityWorkflowActionUseCase =
      ExecuteOpportunityWorkflowActionUseCase(opportunitiesRepo);
  final addOpportunityFollowUpUseCase = AddOpportunityFollowUpUseCase(
    opportunitiesRepo,
  );
  final searchOpportunityLinkOptionsUseCase =
      SearchOpportunityLinkOptionsUseCase(opportunitiesRepo);
  final uploadOpportunityAttachmentUseCase = UploadOpportunityAttachmentUseCase(
    opportunitiesRepo,
  );
  final workflowNotificationsRemoteDataSource =
      WorkflowNotificationsRemoteDataSource();
  final workflowNotificationsRepo = WorkflowNotificationsRepositoryImpl(
    workflowNotificationsRemoteDataSource,
  );
  final getWorkflowNotificationsUseCase = GetWorkflowNotificationsUseCase(
    workflowNotificationsRepo,
  );
  final getWorkflowNotificationsSummaryUseCase =
      GetWorkflowNotificationsSummaryUseCase(workflowNotificationsRepo);
  final attendanceRemoteDataSource = AttendanceRemoteDataSource();
  final attendanceRepo = AttendanceRepositoryImpl(attendanceRemoteDataSource);
  final getAttendanceContextUseCase = GetAttendanceContextUseCase(
    attendanceRepo,
  );
  final createEmployeeCheckinUseCase = CreateEmployeeCheckinUseCase(
    attendanceRepo,
  );
  final requestMobileDeviceVerificationUseCase =
      RequestMobileDeviceVerificationUseCase(attendanceRepo);
  final taskFollowUpRemoteDataSource = TaskFollowUpRemoteDataSource();
  final taskFollowUpRepo = TaskFollowUpRepositoryImpl(
    taskFollowUpRemoteDataSource,
  );
  final getMyTaskFollowUpsUseCase = GetMyTaskFollowUpsUseCase(taskFollowUpRepo);
  final getAssignedTaskFollowUpsUseCase = GetAssignedTaskFollowUpsUseCase(
    taskFollowUpRepo,
  );
  final getTaskFollowUpDetailsUseCase = GetTaskFollowUpDetailsUseCase(
    taskFollowUpRepo,
  );
  final createTaskFollowUpUseCase = CreateTaskFollowUpUseCase(taskFollowUpRepo);
  final addTaskFollowUpUpdateUseCase = AddTaskFollowUpUpdateUseCase(
    taskFollowUpRepo,
  );
  final closeTaskFollowUpUseCase = CloseTaskFollowUpUseCase(taskFollowUpRepo);
  final getTaskFollowUpNotificationsUseCase =
      GetTaskFollowUpNotificationsUseCase(taskFollowUpRepo);
  final markTaskFollowUpReadUseCase = MarkTaskFollowUpReadUseCase(
    taskFollowUpRepo,
  );
  final searchTaskFollowUpLinkOptionsUseCase =
      SearchTaskFollowUpLinkOptionsUseCase(taskFollowUpRepo);
  final uploadTaskFollowUpAttachmentUseCase =
      UploadTaskFollowUpAttachmentUseCase(taskFollowUpRepo);
  final materialHandoverRemoteDataSource = MaterialHandoverRemoteDataSource();
  final materialHandoverRepo = MaterialHandoverRepositoryImpl(
    materialHandoverRemoteDataSource,
  );
  final getMaterialHandoversUseCase = GetMaterialHandoversUseCase(
    materialHandoverRepo,
  );
  final getMaterialHandoverDetailsUseCase = GetMaterialHandoverDetailsUseCase(
    materialHandoverRepo,
  );
  final confirmMaterialPickupUseCase = ConfirmMaterialPickupUseCase(
    materialHandoverRepo,
  );
  final confirmMaterialDeliveryUseCase = ConfirmMaterialDeliveryUseCase(
    materialHandoverRepo,
  );
  final getMaterialReturnOptionsUseCase = GetMaterialReturnOptionsUseCase(
    materialHandoverRepo,
  );
  final createMaterialReturnUseCase = CreateMaterialReturnUseCase(
    materialHandoverRepo,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(loginUseCase)..restoreSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjectsProvider(getProjectsUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjectDetailsProvider(getProjectDetailsUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              LeadsProvider(getLeadsUseCase, getLeadsDashboardSummaryUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => LeadDetailsProvider(
            getLeadDetailsUseCase,
            addLeadFollowUpUseCase,
            uploadLeadAttachmentUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LeadFormProvider(
            getLeadRequiredFieldsUseCase,
            createLeadUseCase,
            updateLeadUseCase,
            searchLeadLinkOptionsUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OpportunitiesProvider(
            getOpportunitiesUseCase,
            getOpportunitiesDashboardSummaryUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OpportunityDetailsProvider(
            getOpportunityDetailsUseCase,
            addOpportunityFollowUpUseCase,
            getOpportunityWorkflowActionsUseCase,
            executeOpportunityWorkflowActionUseCase,
            uploadOpportunityAttachmentUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OpportunityFormProvider(
            getOpportunityFormUseCase,
            getOpportunityPartyPrefillUseCase,
            getOpportunityRequiredFieldsUseCase,
            createOpportunityUseCase,
            updateOpportunityUseCase,
            searchOpportunityLinkOptionsUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkflowNotificationsProvider(
            getWorkflowNotificationsUseCase,
            getWorkflowNotificationsSummaryUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(
            getAttendanceContextUseCase: getAttendanceContextUseCase,
            createEmployeeCheckinUseCase: createEmployeeCheckinUseCase,
            requestMobileDeviceVerificationUseCase:
                requestMobileDeviceVerificationUseCase,
            securityService: AttendanceSecurityService(),
            locationService: AttendanceLocationService(),
            deviceIdentityService: MobileDeviceIdentityService(),
            photoService: AttendancePhotoService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskFollowUpsProvider(
            getMyTaskFollowUpsUseCase,
            getAssignedTaskFollowUpsUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskFollowUpDetailsProvider(
            getTaskFollowUpDetailsUseCase,
            addTaskFollowUpUpdateUseCase,
            closeTaskFollowUpUseCase,
            markTaskFollowUpReadUseCase,
            uploadTaskFollowUpAttachmentUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskFollowUpFormProvider(
            createTaskFollowUpUseCase,
            searchTaskFollowUpLinkOptionsUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskFollowUpNotificationsProvider(
            getTaskFollowUpNotificationsUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MaterialHandoversProvider(
            getHandoversUseCase: getMaterialHandoversUseCase,
            getDetailsUseCase: getMaterialHandoverDetailsUseCase,
            confirmPickupUseCase: confirmMaterialPickupUseCase,
            confirmDeliveryUseCase: confirmMaterialDeliveryUseCase,
            getReturnOptionsUseCase: getMaterialReturnOptionsUseCase,
            createReturnUseCase: createMaterialReturnUseCase,
            photoService: MaterialHandoverPhotoService(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppBranding.electricBlue,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: AppBranding.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF4F8FB),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: AppBranding.navy,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isInitializing) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return auth.isAuthenticated
              ? const MainShellPage()
              : const LoginPage();
        },
      ),
    );
  }
}
