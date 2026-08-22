import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/network/auth_session.dart';
import '../../../../../core/utils/app_logger.dart';
import '../models/opportunity_dashboard_summary_model.dart';
import '../models/opportunity_details_model.dart';
import '../models/opportunity_follow_up_model.dart';
import '../models/opportunity_model.dart';
import '../models/opportunity_option_item_model.dart';
import '../models/opportunity_required_fields_result_model.dart';
import '../models/opportunity_workflow_info_model.dart';

class OpportunityRemoteDataSource {
  Future<OpportunityRequiredFieldsResultModel> getOpportunityForm({
    String? opportunityName,
  }) async {
    final uri = ApiConstants.uri(ApiConstants.opportunityFormEndpoint).replace(
      queryParameters: {
        if (opportunityName != null && opportunityName.isNotEmpty)
          'opportunity_name': opportunityName,
      },
    );

    final response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.sales(
      'opportunity form response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback: 'Opportunity form API is not available on the server.',
        ),
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    _throwIfApiPayloadError(
      decoded,
      fallback: 'Opportunity form API returned an error.',
    );
    return OpportunityRequiredFieldsResultModel.fromJson(decoded);
  }

  Future<List<OpportunityModel>> getOpportunities({
    required int start,
    required int limit,
    String? status,
    String? search,
    String? followUpFilter,
    String? sortBy,
  }) async {
    final uri = ApiConstants.uri(ApiConstants.opportunitiesEndpoint).replace(
      queryParameters: {
        'limit_start': '$start',
        'limit_page_length': '$limit',
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (followUpFilter != null && followUpFilter.isNotEmpty)
          'follow_up_filter': followUpFilter,
        if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
      },
    );

    AppLogger.sales(
      'load opportunities start=$start limit=$limit status=$status',
    );
    final response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.sales(
      'load opportunities response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback: 'Opportunity list API is not available on the server.',
        ),
      );
    }

    final decoded = jsonDecode(response.body);
    _throwIfApiPayloadError(
      decoded,
      fallback: 'Opportunity list API returned an error.',
    );
    final list = _extractList(decoded);

    return list
        .whereType<Map<String, dynamic>>()
        .map(OpportunityModel.fromJson)
        .toList();
  }

  Future<OpportunityDashboardSummaryModel> getDashboardSummary({
    String? status,
    String? search,
  }) async {
    final uri =
        ApiConstants.uri(
          ApiConstants.opportunitiesDashboardSummaryEndpoint,
        ).replace(
          queryParameters: {
            if (status != null && status.isNotEmpty) 'status': status,
            if (search != null && search.isNotEmpty) 'search': search,
          },
        );

    final response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.sales(
      'opportunities dashboard summary response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback:
              'Opportunity dashboard summary API is not available on the server.',
        ),
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    _throwIfApiPayloadError(
      decoded,
      fallback: 'Opportunity dashboard summary API returned an error.',
    );
    return OpportunityDashboardSummaryModel.fromJson(decoded);
  }

  Future<OpportunityDetailsModel> getOpportunityDetails(
    String opportunityName,
  ) async {
    final uri = ApiConstants.uri(
      ApiConstants.opportunityDetailsEndpoint,
    ).replace(queryParameters: {'opportunity_name': opportunityName});

    AppLogger.sales(
      'opportunity details request opportunity_name=$opportunityName',
    );
    var response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.sales(
      'opportunity details GET response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      response = await http.post(
        ApiConstants.uri(ApiConstants.opportunityDetailsEndpoint),
        headers: AuthSession.authHeaders(withJson: false),
        body: {'opportunity_name': opportunityName},
      );
      AppLogger.sales(
        'opportunity details POST response=${response.statusCode} body=${_preview(response.body)}',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback: 'Opportunity details API is not available on the server.',
        ),
      );
    }

    final decoded = jsonDecode(response.body);
    _throwIfApiPayloadError(
      decoded,
      fallback: 'Opportunity details API returned an error.',
    );
    final payload = _extractMap(decoded);
    return OpportunityDetailsModel.fromJson(payload);
  }

  Future<OpportunityRequiredFieldsResultModel> getRequiredFields(
    Map<String, dynamic> data,
  ) async {
    AppLogger.sales(
      'opportunity required fields payload=${jsonEncode({'data': data})}',
    );
    final response = await http.post(
      ApiConstants.uri(ApiConstants.opportunityRequiredFieldsEndpoint),
      headers: AuthSession.authHeaders(),
      body: jsonEncode({'data': data}),
    );
    AppLogger.sales(
      'opportunity required fields response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback:
              'Opportunity required fields API is not available on the server.',
        ),
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    _throwIfApiPayloadError(
      decoded,
      fallback: 'Opportunity required fields API returned an error.',
    );
    return OpportunityRequiredFieldsResultModel.fromJson(decoded);
  }

  Future<String> createOpportunity(Map<String, dynamic> data) async {
    AppLogger.sales('create opportunity payload=${jsonEncode({'data': data})}');
    final response = await http.post(
      ApiConstants.uri(ApiConstants.createOpportunityEndpoint),
      headers: AuthSession.authHeaders(),
      body: jsonEncode({'data': data}),
    );
    AppLogger.sales(
      'create opportunity response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback: 'Create Opportunity API is not available on the server.',
        ),
      );
    }

    final decoded = jsonDecode(response.body);
    _throwIfApiPayloadError(
      decoded,
      fallback: 'Create Opportunity API returned an error.',
    );
    final payload = _extractMap(decoded);
    final messageMap =
        decoded is Map<String, dynamic> &&
            decoded['message'] is Map<String, dynamic>
        ? decoded['message'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final createdName =
        messageMap['opportunity_name']?.toString() ??
        decoded['opportunity_name']?.toString() ??
        payload['name']?.toString() ??
        payload['id']?.toString() ??
        payload['opportunity_name']?.toString() ??
        '';
    AppLogger.sales(
      'create opportunity parsed result=$createdName payload=$payload',
    );
    return createdName;
  }

  Future<void> updateOpportunity(
    String opportunityName,
    Map<String, dynamic> data,
  ) async {
    AppLogger.sales(
      'update opportunity payload=${jsonEncode({'opportunity_name': opportunityName, 'data': data})}',
    );
    final response = await http.post(
      ApiConstants.uri(ApiConstants.updateOpportunityEndpoint),
      headers: AuthSession.authHeaders(),
      body: jsonEncode({'opportunity_name': opportunityName, 'data': data}),
    );
    AppLogger.sales(
      'update opportunity response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback: 'Update Opportunity API is not available on the server.',
        ),
      );
    }

    _throwIfApiPayloadError(
      jsonDecode(response.body),
      fallback: 'Update Opportunity API returned an error.',
    );
  }

  Future<OpportunityWorkflowInfoModel> getWorkflowActions(
    String opportunityName,
  ) async {
    final uri = ApiConstants.uri(
      ApiConstants.opportunityWorkflowActionsEndpoint,
    ).replace(queryParameters: {'opportunity_name': opportunityName});

    final response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.sales(
      'opportunity workflow actions response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback:
              'Opportunity workflow actions API is not available on the server.',
        ),
      );
    }

    final decoded = jsonDecode(response.body);
    _throwIfApiPayloadError(
      decoded,
      fallback: 'Opportunity workflow actions API returned an error.',
    );
    return OpportunityWorkflowInfoModel.fromJson(
      decoded as Map<String, dynamic>,
    );
  }

  Future<OpportunityWorkflowInfoModel> executeWorkflowAction({
    required String opportunityName,
    required String action,
  }) async {
    final response = await http.post(
      ApiConstants.uri(ApiConstants.executeOpportunityWorkflowActionEndpoint),
      headers: AuthSession.authHeaders(),
      body: jsonEncode({'opportunity_name': opportunityName, 'action': action}),
    );
    AppLogger.sales(
      'execute opportunity workflow response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback:
              'Execute opportunity workflow API is not available on the server.',
        ),
      );
    }

    final decoded = jsonDecode(response.body);
    _throwIfApiPayloadError(
      decoded,
      fallback: 'Execute opportunity workflow API returned an error.',
    );
    return OpportunityWorkflowInfoModel.fromJson(
      decoded as Map<String, dynamic>,
    );
  }

  Future<void> addOpportunityFollowUp({
    required String opportunityName,
    required String followUpDate,
    required String expectedResultDate,
    required String details,
    String? attachment,
  }) async {
    final body = {
      'opportunity_name': opportunityName,
      'follow_up_date': followUpDate,
      'expected_result_date': expectedResultDate,
      'details': details,
      if (attachment != null && attachment.isNotEmpty) 'attachment': attachment,
    };
    AppLogger.sales('add opportunity follow up payload=${jsonEncode(body)}');

    final response = await http.post(
      ApiConstants.uri(ApiConstants.addOpportunityFollowUpEndpoint),
      headers: AuthSession.authHeaders(),
      body: jsonEncode(body),
    );
    AppLogger.sales(
      'add opportunity follow up response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback: 'Opportunity follow up API is not available on the server.',
        ),
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final payload = decoded['message'] ?? decoded['data'] ?? decoded;
      if (payload is Map<String, dynamic>) {
        final status = payload['status']?.toString().toLowerCase();
        if (status == 'error') {
          throw Exception(
            payload['message']?.toString() ??
                'Add opportunity follow up failed',
          );
        }
      }
    }
  }

  Future<String> uploadAttachment({
    required String filePath,
    required String opportunityName,
  }) async {
    AppLogger.sales(
      'opportunity upload attachment start path=$filePath opportunity=$opportunityName',
    );

    final request = http.MultipartRequest(
      'POST',
      ApiConstants.uri('/api/method/upload_file'),
    );

    request.headers.addAll(AuthSession.authHeaders(withJson: false));
    request.fields['doctype'] = 'Opportunity';
    request.fields['docname'] = opportunityName;
    request.fields['is_private'] = '0';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    AppLogger.sales(
      'opportunity upload attachment response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to upload attachment: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid upload response format');
    }

    final payload = decoded['message'] ?? decoded['data'] ?? decoded;
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid upload payload');
    }

    final fileUrl = payload['file_url']?.toString();
    if (fileUrl == null || fileUrl.isEmpty) {
      throw Exception('Upload succeeded but file_url missing');
    }

    AppLogger.sales('opportunity upload attachment success url=$fileUrl');
    return fileUrl;
  }

  Future<List<OpportunityFollowUpModel>> getOpportunityFollowUps(
    String opportunityName,
  ) async {
    final uri = ApiConstants.uri(
      ApiConstants.opportunityFollowUpsEndpoint,
    ).replace(queryParameters: {'opportunity_name': opportunityName});

    final response = await http.get(uri, headers: AuthSession.authHeaders());

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback:
              'Opportunity follow ups API is not available on the server.',
        ),
      );
    }

    final decoded = jsonDecode(response.body);
    _throwIfApiPayloadError(
      decoded,
      fallback: 'Opportunity follow ups API returned an error.',
    );
    final list = _extractList(decoded);
    return list
        .whereType<Map<String, dynamic>>()
        .map(OpportunityFollowUpModel.fromJson)
        .toList();
  }

  Future<Map<String, String>> getPartyPrefill({
    required String partyType,
    required String partyName,
  }) async {
    if (partyType == 'Lead') {
      return _getLeadPrefill(partyName);
    }
    if (partyType == 'Customer') {
      return _getCustomerPrefill(partyName);
    }
    return const {};
  }

  Future<List<OpportunityOptionItemModel>> searchLinkOptions({
    required String doctype,
    String query = '',
  }) async {
    if (doctype == 'DocType') {
      return _staticOpportunityFromOptions(query);
    }
    if (doctype == 'Lead') {
      return _searchLeadParties(query);
    }
    if (doctype == 'Customer') {
      return _searchCustomerParties(query);
    }

    final uri = ApiConstants.uri(ApiConstants.searchLinkEndpoint).replace(
      queryParameters: {'doctype': doctype, 'txt': query, 'page_length': '20'},
    );

    final response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.sales(
      'search link doctype=$doctype query="$query" response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback: 'Link search API is not available on the server.',
        ),
      );
    }

    final list = _extractList(jsonDecode(response.body));
    return list.map(OpportunityOptionItemModel.fromDynamic).toList();
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is! Map<String, dynamic>) return const [];

    final directKeys = [
      'data',
      'message',
      'result',
      'opportunities',
      'follow_ups',
    ];
    for (final key in directKeys) {
      final value = decoded[key];
      if (value is List) return value;
    }

    for (final key in directKeys) {
      final value = decoded[key];
      if (value is Map<String, dynamic>) {
        for (final nestedKey in [
          'items',
          'results',
          'data',
          'opportunities',
          'follow_ups',
        ]) {
          final nested = value[nestedKey];
          if (nested is List) return nested;
        }
      }
    }

    return const [];
  }

  Map<String, dynamic> _extractMap(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        final nestedData = data['data'];
        if (nestedData is Map<String, dynamic>) return nestedData;
        return data;
      }

      final message = decoded['message'];
      if (message is Map<String, dynamic>) {
        final nestedData = message['data'];
        if (nestedData is Map<String, dynamic>) return nestedData;
        return message;
      }

      final result = decoded['result'];
      if (result is Map<String, dynamic>) {
        final nestedData = result['data'];
        if (nestedData is Map<String, dynamic>) return nestedData;
        return result;
      }

      return decoded;
    }

    return <String, dynamic>{};
  }

  String _preview(String body, {int max = 500}) {
    if (body.length <= max) return body;
    return '${body.substring(0, max)}...';
  }

  Future<List<OpportunityOptionItemModel>> _staticOpportunityFromOptions(
    String query,
  ) async {
    final normalized = query.trim().toLowerCase();
    const values = ['Lead', 'Customer'];
    return values
        .where(
          (item) =>
              normalized.isEmpty || item.toLowerCase().contains(normalized),
        )
        .map((item) => OpportunityOptionItemModel(value: item, label: item))
        .toList();
  }

  Future<List<OpportunityOptionItemModel>> _searchLeadParties(
    String query,
  ) async {
    final uri = ApiConstants.uri(ApiConstants.leadsEndpoint).replace(
      queryParameters: {
        'limit_start': '0',
        'limit_page_length': '20',
        if (query.trim().isNotEmpty) 'search': query.trim(),
      },
    );

    final response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.sales(
      'search opportunity lead parties query="$query" response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback: 'Lead list API is not available on the server.',
        ),
      );
    }

    final list = _extractList(jsonDecode(response.body));
    return list
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final value =
              item['id']?.toString() ?? item['name']?.toString() ?? '';
          final label =
              item['display_name']?.toString() ??
              item['company_name']?.toString() ??
              value;
          return OpportunityOptionItemModel(
            value: value,
            label: label,
            description: item['status']?.toString() ?? '',
          );
        })
        .where((item) => item.value.isNotEmpty)
        .toList();
  }

  Future<List<OpportunityOptionItemModel>> _searchCustomerParties(
    String query,
  ) async {
    final normalized = query.trim();
    final filters = normalized.isEmpty
        ? '[]'
        : '[["Customer","name","like","%$normalized%"],["Customer","customer_name","like","%$normalized%"]]';
    final uri = ApiConstants.uri('/api/resource/Customer').replace(
      queryParameters: {
        'fields': '["name","customer_name","customer_group"]',
        'limit_page_length': '20',
        'or_filters': filters,
      },
    );

    final response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.sales(
      'search opportunity customer parties query="$query" response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback: 'Customer API is not available on the server.',
        ),
      );
    }

    final list = _extractList(jsonDecode(response.body));
    return list
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final value = item['name']?.toString() ?? '';
          final label = item['customer_name']?.toString() ?? value;
          return OpportunityOptionItemModel(
            value: value,
            label: label,
            description: item['customer_group']?.toString() ?? '',
          );
        })
        .where((item) => item.value.isNotEmpty)
        .toList();
  }

  String _extractApiError(String body, {required String fallback}) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final exception = decoded['exception']?.toString() ?? '';
        final message = decoded['message']?.toString() ?? '';
        final combined = '$exception $message'.trim().toLowerCase();
        if (combined.contains('has no attribute')) {
          return fallback;
        }
        if (message.isNotEmpty) return message;
        if (exception.isNotEmpty) return exception;
      }
    } catch (_) {
      // Ignore parse failure and return fallback.
    }
    return fallback;
  }

  void _throwIfApiPayloadError(dynamic decoded, {required String fallback}) {
    if (decoded is! Map<String, dynamic>) return;

    final candidates = [
      decoded,
      if (decoded['message'] is Map<String, dynamic>) decoded['message'],
      if (decoded['data'] is Map<String, dynamic>) decoded['data'],
    ];

    for (final candidate in candidates) {
      if (candidate is! Map<String, dynamic>) continue;
      final status = candidate['status']?.toString().toLowerCase();
      if (status == 'error') {
        throw Exception(candidate['message']?.toString() ?? fallback);
      }
    }
  }

  Future<Map<String, String>> _getLeadPrefill(String leadName) async {
    final uri = ApiConstants.uri(
      ApiConstants.leadDetailsEndpoint,
    ).replace(queryParameters: {'lead_name': leadName});
    final response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.sales(
      'opportunity lead prefill response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback: 'Lead details API is not available on the server.',
        ),
      );
    }

    final decoded = jsonDecode(response.body);
    _throwIfApiPayloadError(
      decoded,
      fallback: 'Lead details API returned an error.',
    );
    final payload = _extractMap(decoded);

    String read(String key) => payload[key]?.toString() ?? '';

    final contact = payload['contact'] is Map<String, dynamic>
        ? payload['contact'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final address = payload['address'] is Map<String, dynamic>
        ? payload['address'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final identity = payload['identity'] is Map<String, dynamic>
        ? payload['identity'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final status = payload['status'] is Map<String, dynamic>
        ? payload['status'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final displayName =
        identity['display_name']?.toString() ??
        identity['lead_name']?.toString() ??
        identity['first_name']?.toString() ??
        '';
    final companyName = identity['company_name']?.toString() ?? '';
    final mobile = contact['mobile']?.toString() ?? '';
    final email = contact['email']?.toString() ?? '';
    var contactPerson =
        contact['contact_person']?.toString() ??
        payload['contact_person']?.toString() ??
        '';
    final city = address['city']?.toString() ?? '';
    final leadSource =
        status['source']?.toString() ?? payload['source']?.toString() ?? '';
    final salesPerson =
        payload['sales_person']?.toString() ??
        payload['opportunity_owner']?.toString() ??
        '';
    final shortAddress = read('short_address');
    final title = companyName.isNotEmpty ? companyName : displayName;
    final customerName = companyName.isNotEmpty ? companyName : displayName;
    if (contactPerson.isEmpty) {
      contactPerson = await _findContactPerson(
        mobile: mobile,
        email: email,
        name: displayName,
      );
    }

    return {
      if (read('company').isNotEmpty) 'company': read('company'),
      if (title.isNotEmpty) 'title': title,
      if (customerName.isNotEmpty) 'customer_name': customerName,
      if (displayName.isNotEmpty) 'contact_display_name': displayName,
      if ((contact['phone']?.toString() ?? '').isNotEmpty)
        'phone': contact['phone'].toString(),
      if (mobile.isNotEmpty) 'mobile_no': mobile,
      if (mobile.isNotEmpty) 'contact_mobile': mobile,
      if (email.isNotEmpty) 'email_id': email,
      if (email.isNotEmpty) 'contact_email': email,
      if (contactPerson.isNotEmpty) 'contact_person': contactPerson,
      if (city.isNotEmpty) 'city': city,
      if ((address['country']?.toString() ?? '').isNotEmpty)
        'country': address['country'].toString(),
      if ((address['territory']?.toString() ?? '').isNotEmpty)
        'territory': address['territory'].toString(),
      if (shortAddress.isNotEmpty) 'short_address': shortAddress,
      if (shortAddress.isNotEmpty) 'custom_address_site': shortAddress,
      if (leadSource.isNotEmpty) 'source': leadSource,
      if (salesPerson.isNotEmpty) 'sales_person': salesPerson,
    };
  }

  Future<String> _findContactPerson({
    required String mobile,
    required String email,
    required String name,
  }) async {
    final candidates = [
      mobile,
      email,
      name,
    ].map((item) => item.trim()).where((item) => item.isNotEmpty).toList();

    for (final query in candidates) {
      final contact = await _searchContactResource(query);
      if (contact.isNotEmpty) return contact;
    }

    final query = candidates.isEmpty ? '' : candidates.first;
    if (query.isEmpty) return '';

    try {
      final items = await searchLinkOptions(doctype: 'Contact', query: query);
      if (items.isEmpty) return '';
      return items.first.value;
    } catch (e) {
      AppLogger.error('opportunity contact prefill failed: $e');
      return '';
    }
  }

  Future<String> _searchContactResource(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return '';

    final orFilters = [
      ['Contact', 'name', 'like', '%$normalized%'],
      ['Contact', 'first_name', 'like', '%$normalized%'],
      ['Contact', 'mobile_no', 'like', '%$normalized%'],
      ['Contact', 'phone', 'like', '%$normalized%'],
      ['Contact', 'email_id', 'like', '%$normalized%'],
    ];

    final uri = ApiConstants.uri('/api/resource/Contact').replace(
      queryParameters: {
        'fields': jsonEncode([
          'name',
          'first_name',
          'mobile_no',
          'phone',
          'email_id',
        ]),
        'or_filters': jsonEncode(orFilters),
        'limit_page_length': '1',
      },
    );

    try {
      final response = await http.get(uri, headers: AuthSession.authHeaders());
      AppLogger.sales(
        'opportunity contact resource prefill query="$query" response=${response.statusCode} body=${_preview(response.body)}',
      );
      if (response.statusCode != 200) return '';

      final list = _extractList(jsonDecode(response.body));
      for (final item in list.whereType<Map<String, dynamic>>()) {
        final contactName = item['name']?.toString() ?? '';
        if (contactName.trim().isNotEmpty) return contactName;
      }
    } catch (e) {
      AppLogger.error('opportunity contact resource prefill failed: $e');
    }
    return '';
  }

  Future<Map<String, String>> _getCustomerPrefill(String customerName) async {
    final uri = ApiConstants.uri('/api/resource/Customer/$customerName');
    final response = await http.get(uri, headers: AuthSession.authHeaders());
    AppLogger.sales(
      'opportunity customer prefill response=${response.statusCode} body=${_preview(response.body)}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(
          response.body,
          fallback: 'Customer details API is not available on the server.',
        ),
      );
    }

    final decoded = jsonDecode(response.body);
    _throwIfApiPayloadError(
      decoded,
      fallback: 'Customer details API returned an error.',
    );
    final payload = _extractMap(decoded);
    final displayName = payload['customer_name']?.toString() ?? customerName;
    final territory = payload['territory']?.toString() ?? '';

    return {
      if (displayName.isNotEmpty) 'title': displayName,
      if (displayName.isNotEmpty) 'customer_name': displayName,
      if (territory.isNotEmpty) 'territory': territory,
    };
  }
}
