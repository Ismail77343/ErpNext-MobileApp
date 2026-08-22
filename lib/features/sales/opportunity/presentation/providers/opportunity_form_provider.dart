import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../domain/entities/opportunity_field.dart';
import '../../domain/entities/opportunity_option_item.dart';
import '../../domain/entities/opportunity_required_field_definition.dart';
import '../../domain/usecases/create_opportunity_usecase.dart';
import '../../domain/usecases/get_opportunity_form_usecase.dart';
import '../../domain/usecases/get_opportunity_party_prefill_usecase.dart';
import '../../domain/usecases/get_opportunity_required_fields_usecase.dart';
import '../../domain/usecases/search_opportunity_link_options_usecase.dart';
import '../../domain/usecases/update_opportunity_usecase.dart';

class OpportunityFormProvider extends ChangeNotifier {
  OpportunityFormProvider(
    this._getOpportunityFormUseCase,
    this._getOpportunityPartyPrefillUseCase,
    this._getOpportunityRequiredFieldsUseCase,
    this._createOpportunityUseCase,
    this._updateOpportunityUseCase,
    this._searchOpportunityLinkOptionsUseCase,
  );

  final GetOpportunityFormUseCase _getOpportunityFormUseCase;
  final GetOpportunityPartyPrefillUseCase _getOpportunityPartyPrefillUseCase;
  final GetOpportunityRequiredFieldsUseCase
  _getOpportunityRequiredFieldsUseCase;
  final CreateOpportunityUseCase _createOpportunityUseCase;
  final UpdateOpportunityUseCase _updateOpportunityUseCase;
  final SearchOpportunityLinkOptionsUseCase
  _searchOpportunityLinkOptionsUseCase;

  final Map<String, String> _values = {};
  final Map<String, OpportunityRequiredFieldDefinition> _definitions = {};
  final Set<String> _touchedKeys = <String>{};
  final Set<String> _autoFilledKeys = <String>{};

  Timer? _requiredFieldsDebounce;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  String? _successMessage;
  String? _opportunityName;
  List<String> _requiredKeys = [];
  List<String> _missingKeys = [];

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get isEdit => _opportunityName != null && _opportunityName!.isNotEmpty;
  List<String> get missingKeys => _missingKeys;
  String get contentPreview => _buildContentPreview();

  List<OpportunityField> get fields {
    final list = _definitions.values
        .map((definition) {
          final normalized = _normalizeDefinition(definition);
          return OpportunityField(
            key: normalized.fieldname,
            label: normalized.label,
            type: normalized.fieldType,
            required:
                _requiredKeys.contains(normalized.fieldname) ||
                normalized.required,
            readOnly: normalized.readOnly,
            hidden: normalized.hidden,
            value: _values[normalized.fieldname] ?? normalized.value,
            options: normalized.options,
            linkDoctype: _resolveLinkDoctype(normalized),
            linkDoctypeField: normalized.linkDoctypeField,
          );
        })
        .where((field) => !field.hidden)
        .where(
          (field) =>
              !(isEdit && const {'id', 'name', 'doctype'}.contains(field.key)),
        )
        .where((field) => !const {'content', 'title'}.contains(field.key))
        .toList();

    for (final entry in _values.entries) {
      if (_definitions.containsKey(entry.key)) continue;
      if (entry.value.trim().isEmpty) continue;
      if (const {'content', 'title'}.contains(entry.key)) continue;
      list.add(
        OpportunityField(
          key: entry.key,
          label: _labelFromKey(entry.key),
          type: _guessType(entry.key),
          required: _requiredKeys.contains(entry.key),
          value: entry.value,
        ),
      );
    }

    list.sort((a, b) {
      final ar = a.required ? 0 : 1;
      final br = b.required ? 0 : 1;
      if (ar != br) return ar.compareTo(br);
      return a.label.compareTo(b.label);
    });
    return list;
  }

  Future<void> initialize({
    String? opportunityName,
    Map<String, dynamic>? initialData,
  }) async {
    _opportunityName = opportunityName;
    _error = null;
    _successMessage = null;
    _requiredKeys = [];
    _missingKeys = [];
    _definitions.clear();
    _values.clear();
    _touchedKeys.clear();
    _autoFilledKeys.clear();

    try {
      _isLoading = true;
      notifyListeners();

      final form = await _getOpportunityFormUseCase.call(
        opportunityName: opportunityName,
      );
      _applyDefinitions(form.definitions);
      for (final entry in form.defaultValues.entries) {
        _values.putIfAbsent(entry.key, () => entry.value);
      }
    } catch (e) {
      _error = e.toString();
      AppLogger.error('opportunity form load failed: $_error');
    } finally {
      _isLoading = false;
    }

    if (initialData != null) {
      for (final entry in initialData.entries) {
        final text = entry.value?.toString().trim() ?? '';
        if (text.isNotEmpty) {
          _values[entry.key] = text;
          if (!isEdit) {
            _touchedKeys.add(entry.key);
          }
        }
      }
    }

    if (!isEdit &&
        (_values['opportunity_from']?.trim().isNotEmpty ?? false) &&
        (_values['party_name']?.trim().isNotEmpty ?? false)) {
      await _applyPartyPrefill();
    }

    await refreshRequiredFields();
  }

  Future<void> updateValue(String key, String value) async {
    _values[key] = value;
    _touchedKeys.add(key);
    _autoFilledKeys.remove(key);
    _successMessage = null;

    final dependents = _definitions.values
        .where((item) => item.linkDoctypeField == key)
        .map((item) => item.fieldname);
    for (final dependentKey in dependents) {
      _values.remove(dependentKey);
      _autoFilledKeys.remove(dependentKey);
    }

    if (key == 'party_name') {
      await _applyPartyPrefill();
    }

    notifyListeners();

    _requiredFieldsDebounce?.cancel();
    _requiredFieldsDebounce = Timer(
      const Duration(milliseconds: 350),
      refreshRequiredFields,
    );
  }

  Future<void> refreshRequiredFields() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _getOpportunityRequiredFieldsUseCase.call(
        _sanitizedValues(),
      );
      _applyDefinitions(result.definitions);
      _requiredKeys = result.requiredFields;
      _missingKeys = result.missingFields;

      for (final entry in result.defaultValues.entries) {
        _values.putIfAbsent(entry.key, () => entry.value);
      }

      AppLogger.sales(
        'opportunity required resolved required=$_requiredKeys missing=$_missingKeys',
      );
    } catch (e) {
      _error = e.toString();
      AppLogger.error('opportunity required fields failed: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<OpportunityOptionItem>> searchOptions(
    OpportunityField field, {
    String query = '',
  }) async {
    if (field.type == OpportunityFieldType.select) {
      final normalized = query.trim().toLowerCase();
      final items = field.options
          .where(
            (item) =>
                normalized.isEmpty || item.toLowerCase().contains(normalized),
          )
          .map((item) => OpportunityOptionItem(value: item, label: item))
          .toList();
      if (field.value.isNotEmpty &&
          items.every((item) => item.value != field.value)) {
        items.insert(
          0,
          OpportunityOptionItem(value: field.value, label: field.value),
        );
      }
      return items;
    }

    if (field.type == OpportunityFieldType.link ||
        field.type == OpportunityFieldType.dynamicLink) {
      final doctype = _resolveLinkDoctype(
        _definitions[field.key] ??
            OpportunityRequiredFieldDefinition(
              fieldname: field.key,
              label: field.label,
              fieldType: field.type,
              linkDoctype: field.linkDoctype,
              linkDoctypeField: field.linkDoctypeField,
            ),
      );
      if (doctype == null || doctype.isEmpty) return const [];
      final items = await _searchOpportunityLinkOptionsUseCase.call(
        doctype: doctype,
        query: query,
      );
      if (field.value.isNotEmpty &&
          items.every((item) => item.value != field.value)) {
        return [
          OpportunityOptionItem(value: field.value, label: field.value),
          ...items,
        ];
      }
      return items;
    }

    return const [];
  }

  Future<bool> submit() async {
    _isSubmitting = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      final payload = _sanitizedValues();
      final result = await _getOpportunityRequiredFieldsUseCase.call(payload);
      _applyDefinitions(result.definitions);
      _requiredKeys = result.requiredFields;
      _missingKeys = result.missingFields;

      if (_missingKeys.isNotEmpty) {
        _error = 'Please complete all required fields.';
        return false;
      }

      if (isEdit) {
        await _updateOpportunityUseCase.call(_opportunityName!, payload);
        _successMessage = 'Opportunity updated successfully.';
      } else {
        final createdOpportunityName = await _createOpportunityUseCase.call(
          payload,
        );
        if (createdOpportunityName.isNotEmpty) {
          _opportunityName = createdOpportunityName;
        }
        _successMessage = 'Opportunity created successfully.';
      }

      return true;
    } catch (e) {
      _error = e.toString();
      AppLogger.error('opportunity submit failed: $_error');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void _applyDefinitions(List<OpportunityRequiredFieldDefinition> definitions) {
    for (final definition in definitions) {
      final normalized = _normalizeDefinition(definition);
      _definitions[normalized.fieldname] = normalized;
      if (normalized.value.trim().isNotEmpty &&
          !_values.containsKey(normalized.fieldname)) {
        _values[normalized.fieldname] = normalized.value;
      }
    }
  }

  Future<void> _applyPartyPrefill() async {
    final partyType = _values['opportunity_from']?.trim() ?? '';
    final partyName = _values['party_name']?.trim() ?? '';
    if (partyType.isEmpty || partyName.isEmpty) return;

    try {
      final prefill = await _getOpportunityPartyPrefillUseCase.call(
        partyType: partyType,
        partyName: partyName,
      );
      for (final entry in prefill.entries) {
        final current = (_values[entry.key] ?? '').trim();
        final shouldReplace =
            current.isEmpty || _autoFilledKeys.contains(entry.key);
        if (shouldReplace) {
          _values[entry.key] = entry.value;
          _autoFilledKeys.add(entry.key);
        }
      }
    } catch (e) {
      AppLogger.error('opportunity prefill failed: $e');
    }
  }

  OpportunityRequiredFieldDefinition _normalizeDefinition(
    OpportunityRequiredFieldDefinition definition,
  ) {
    if (definition.fieldname == 'opportunity_from') {
      return OpportunityRequiredFieldDefinition(
        fieldname: definition.fieldname,
        label: definition.label,
        fieldType: OpportunityFieldType.select,
        required: definition.required,
        readOnly: definition.readOnly,
        hidden: definition.hidden,
        value: definition.value,
        options: const ['Lead', 'Customer'],
      );
    }

    if (definition.fieldname == 'party_name') {
      return OpportunityRequiredFieldDefinition(
        fieldname: definition.fieldname,
        label: definition.label,
        fieldType: OpportunityFieldType.dynamicLink,
        required: definition.required,
        readOnly: definition.readOnly,
        hidden: definition.hidden,
        value: definition.value,
        options: definition.options,
        linkDoctype: definition.linkDoctype,
        linkDoctypeField: definition.linkDoctypeField ?? 'opportunity_from',
      );
    }

    return definition;
  }

  String? _resolveLinkDoctype(OpportunityRequiredFieldDefinition definition) {
    if (definition.fieldType == OpportunityFieldType.dynamicLink) {
      final key = definition.linkDoctypeField;
      if (key == null || key.isEmpty) return definition.linkDoctype;
      return _values[key] ?? definition.linkDoctype;
    }
    return definition.linkDoctype;
  }

  Map<String, dynamic> _sanitizedValues() {
    final output = <String, dynamic>{};
    for (final entry in _values.entries) {
      final value = entry.value.trim();
      if (value.isEmpty) continue;

      final definition = _definitions[entry.key];
      if (entry.key == 'content') continue;

      final shouldInclude =
          isEdit ||
          _requiredKeys.contains(entry.key) ||
          definition?.required == true ||
          definition?.readOnly == true ||
          _touchedKeys.contains(entry.key) ||
          _autoFilledKeys.contains(entry.key);

      if (shouldInclude) {
        output[entry.key] = value;
      }
    }
    return output;
  }

  OpportunityFieldType _guessType(String key) {
    if (key.contains('date')) return OpportunityFieldType.date;
    if (key.contains('email')) return OpportunityFieldType.email;
    if (key.contains('mobile') || key.contains('phone')) {
      return OpportunityFieldType.phone;
    }
    if (key.contains('note') || key.contains('detail')) {
      return OpportunityFieldType.multiline;
    }
    if (key.contains('amount') || key.contains('probability')) {
      return OpportunityFieldType.number;
    }
    return OpportunityFieldType.text;
  }

  String _labelFromKey(String key) {
    return key
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _buildContentPreview() {
    final partyType = (_values['opportunity_from'] ?? '').trim();
    final partyName = (_values['party_name'] ?? '').trim();
    final title = (_values['title'] ?? '').trim();
    final customerName = (_values['customer_name'] ?? '').trim();
    final status = (_values['status'] ?? 'Open').trim();
    final amount = (_values['opportunity_amount'] ?? '').trim();
    final nextFollowUp = (_values['next_follow_up_date'] ?? '').trim();

    final primary = customerName.isNotEmpty
        ? customerName
        : (title.isNotEmpty ? title : partyName);

    final parts = <String>[
      if (primary.isNotEmpty) primary,
      if (partyType.isNotEmpty && partyName.isNotEmpty)
        '$partyType: $partyName',
      if (status.isNotEmpty) 'Status: $status',
      if (amount.isNotEmpty) 'Amount: $amount',
      if (nextFollowUp.isNotEmpty) 'Next Follow Up: $nextFollowUp',
    ];

    return parts.join(' | ');
  }

  @override
  void dispose() {
    _requiredFieldsDebounce?.cancel();
    super.dispose();
  }
}
