import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/apa_colors.dart';
import '../../../../core/theme/apa_fonts.dart';
import '../../../../core/widgets/apa_shared_widgets.dart';
import '../../../../data/models/contact/contact_form_model.dart';
import '../controllers/contact_controller.dart';

class ContactDynamicForm extends StatelessWidget {
  const ContactDynamicForm({
    super.key,
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final ContactController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final fields = controller.items
        .where((field) => !field.kind.isHidden)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < fields.length; i++) ...[
          if (i > 0) SizedBox(height: 20.h),
          _ContactFormField(
            field: fields[i],
            controller: controller,
            enabled: !isSubmitting,
          ),
        ],
        SizedBox(height: 24.h),
        ApaBlackPillButton(
          label: isSubmitting ? 'SENDING' : 'SEND MESSAGE',
          expanded: true,
          fontSize: 15,
          verticalPadding: 14,
          horizontalPadding: 24,
          isLoading: isSubmitting,
          onPressed: isSubmitting ? null : onSubmit,
        ),
      ],
    );
  }
}

class ContactFormLoading extends StatelessWidget {
  const ContactFormLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48.h),
      child: const Center(
        child: CircularProgressIndicator(color: ApaColors.primaryRed),
      ),
    );
  }
}

class ContactFormError extends StatelessWidget {
  const ContactFormError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: ApaFonts.inter(
              color: ApaColors.gray700,
              fontSize: 15.sp,
              height: 22 / 15,
            ),
          ),
          SizedBox(height: 16.h),
          ApaBlackPillButton(
            label: 'TRY AGAIN',
            fontSize: 13,
            verticalPadding: 10,
            horizontalPadding: 20,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class ContactFormMessage extends StatelessWidget {
  const ContactFormMessage({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Text(
        text,
        style: ApaFonts.inter(
          color: ApaColors.gray700,
          fontSize: 15.sp,
          height: 22 / 15,
        ),
      ),
    );
  }
}

class _ContactFormField extends StatelessWidget {
  const _ContactFormField({
    required this.field,
    required this.controller,
    required this.enabled,
  });

  final ContactFormField field;
  final ContactController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (field.kind.isDisplayOnly) {
      return _HtmlOrHeading(field: field);
    }

    final error = controller.fieldErrors[field.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(field.displayLabel, required: field.required),
        if (field.description.trim().isNotEmpty) ...[
          Text(
            field.description.trim(),
            style: ApaFonts.inter(
              color: ApaColors.gray500,
              fontSize: 12.sp,
              height: 18 / 12,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        _buildInput(context, error),
        if (error != null && error.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              error,
              style: ApaFonts.inter(
                color: ApaColors.primaryRed,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInput(BuildContext context, String? error) {
    final hasError = error != null && error.isNotEmpty;
    switch (field.kind) {
      case ContactFieldKind.select:
        return _ApaSelectField(
          value: _stringValue,
          options: field.options,
          placeholder: field.placeholder,
          enabled: enabled,
          hasError: hasError,
          onChanged: (value) => controller.setValue(field.id, value ?? ''),
        );
      case ContactFieldKind.radio:
        return _ApaRadioGroup(
          value: _stringValue,
          options: field.options,
          enabled: enabled,
          onChanged: (value) => controller.setValue(field.id, value),
        );
      case ContactFieldKind.checkbox:
        return _ApaCheckboxGroup(
          field: field,
          controller: controller,
          enabled: enabled,
        );
      case ContactFieldKind.date:
        return _ApaTextField(
          controller: controller.textControllerFor(field),
          placeholder: field.placeholder,
          enabled: enabled,
          hasError: hasError,
          readOnly: true,
          onTap: enabled ? () => _pickDate(context) : null,
        );
      case ContactFieldKind.textarea:
        return _ApaTextField(
          controller: controller.textControllerFor(field),
          placeholder: field.placeholder,
          enabled: enabled,
          hasError: hasError,
          maxLines: 6,
          minHeight: 180,
          keyboardType: TextInputType.multiline,
        );
      case ContactFieldKind.email:
        return _ApaTextField(
          controller: controller.textControllerFor(field),
          placeholder: field.placeholder,
          enabled: enabled,
          hasError: hasError,
          keyboardType: TextInputType.emailAddress,
        );
      case ContactFieldKind.phone:
        return _ApaTextField(
          controller: controller.textControllerFor(field),
          placeholder: field.placeholder,
          enabled: enabled,
          hasError: hasError,
          keyboardType: TextInputType.phone,
        );
      case ContactFieldKind.number:
        return _ApaTextField(
          controller: controller.textControllerFor(field),
          placeholder: field.placeholder,
          enabled: enabled,
          hasError: hasError,
          keyboardType: TextInputType.number,
        );
      case ContactFieldKind.url:
        return _ApaTextField(
          controller: controller.textControllerFor(field),
          placeholder: field.placeholder,
          enabled: enabled,
          hasError: hasError,
          keyboardType: TextInputType.url,
        );
      case ContactFieldKind.text:
      case ContactFieldKind.hidden:
      case ContactFieldKind.html:
        return _ApaTextField(
          controller: controller.textControllerFor(field),
          placeholder: field.placeholder,
          enabled: enabled,
          hasError: hasError,
        );
    }
  }

  String? get _stringValue {
    final value = controller.values[field.id]?.toString();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final parsed = DateTime.tryParse(_stringValue ?? '');
    final picked = await showDatePicker(
      context: context,
      initialDate: parsed ?? now,
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year + 25),
    );
    if (picked == null) return;
    final formatted =
        '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    controller.textControllerFor(field).text = formatted;
    controller.setValue(field.id, formatted);
  }
}

class _HtmlOrHeading extends StatelessWidget {
  const _HtmlOrHeading({required this.field});

  final ContactFormField field;

  @override
  Widget build(BuildContext context) {
    final text = field.description.trim().isNotEmpty
        ? field.description.trim()
        : field.displayLabel;
    if (text.isEmpty) return const SizedBox.shrink();
    return Text(
      text,
      style: ApaFonts.inter(
        color: ApaColors.gray700,
        fontSize: 14.sp,
        height: 20 / 14,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final labelStyle = ApaFonts.inter(
      color: ApaColors.gray700,
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      height: 20 / 13,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text.rich(
        TextSpan(
          style: labelStyle,
          children: [
            TextSpan(text: text),
            if (required)
              TextSpan(
                text: ' *',
                style: labelStyle.copyWith(color: ApaColors.primaryRed),
              ),
          ],
        ),
      ),
    );
  }
}

class _ApaTextField extends StatelessWidget {
  const _ApaTextField({
    required this.controller,
    this.keyboardType,
    this.placeholder,
    this.maxLines = 1,
    this.minHeight = 48,
    this.enabled = true,
    this.hasError = false,
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? placeholder;
  final int maxLines;
  final double minHeight;
  final bool enabled;
  final bool hasError;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight.h),
      decoration: BoxDecoration(
        color: ApaColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: hasError ? ApaColors.primaryRed : ApaColors.black,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        style: ApaFonts.inter(
          color: ApaColors.nearBlack,
          fontSize: 15.sp,
        ),
        decoration: InputDecoration(
          hintText: placeholder?.trim().isEmpty ?? true ? null : placeholder,
          hintStyle: ApaFonts.inter(
            color: ApaColors.gray400,
            fontSize: 15.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }
}

class _ApaSelectField extends StatelessWidget {
  const _ApaSelectField({
    required this.options,
    required this.onChanged,
    this.value,
    this.placeholder,
    this.enabled = true,
    this.hasError = false,
  });

  final String? value;
  final List<ContactFormOption> options;
  final String? placeholder;
  final bool enabled;
  final bool hasError;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = options
        .map((option) => option.displayLabel)
        .where((label) => label.isNotEmpty)
        .toList();
    final values = options
        .map((option) => option.submitValue)
        .where((item) => item.isNotEmpty)
        .toList();
    final selected =
        value != null && values.contains(value) ? value : null;

    return Container(
      constraints: BoxConstraints(minHeight: 48.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ApaColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: hasError ? ApaColors.primaryRed : ApaColors.black,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          highlightColor: ApaColors.primaryRed,
          focusColor: ApaColors.primaryRed,
          hoverColor: ApaColors.primaryRed,
          splashColor: ApaColors.primaryRed.withValues(alpha: 0.24),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selected,
            hint: Text(
              (placeholder?.trim().isNotEmpty ?? false)
                  ? placeholder!.trim()
                  : 'Select',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ApaFonts.inter(
                color: ApaColors.gray400,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            isExpanded: true,
            itemHeight: null,
            dropdownColor: ApaColors.black,
            icon: Icon(
              Icons.keyboard_arrow_down,
              size: 20.sp,
              color: ApaColors.nearBlack,
            ),
            style: ApaFonts.inter(
              color: ApaColors.nearBlack,
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            selectedItemBuilder: (context) => values
                .map(
                  (item) {
                    final index = values.indexOf(item);
                    final label = index >= 0 && index < labels.length
                        ? labels[index]
                        : item;
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ApaFonts.inter(
                          color: ApaColors.nearBlack,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    );
                  },
                )
                .toList(),
            items: [
              for (var i = 0; i < values.length; i++)
                DropdownMenuItem<String>(
                  value: values[i],
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: values[i] == selected
                          ? ApaColors.primaryRed
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      i < labels.length ? labels[i] : values[i],
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: ApaFonts.inter(
                        color: ApaColors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
            ],
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ),
    );
  }
}

class _ApaRadioGroup extends StatelessWidget {
  const _ApaRadioGroup({
    required this.options,
    required this.onChanged,
    this.value,
    this.enabled = true,
  });

  final String? value;
  final List<ContactFormOption> options;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<String>(
      groupValue: value,
      onChanged: (selected) {
        if (!enabled || selected == null) return;
        onChanged(selected);
      },
      child: Column(
        children: [
          for (final option in options)
            RadioListTile<String>(
              value: option.submitValue,
              enabled: enabled,
              title: Text(
                option.displayLabel,
                style: ApaFonts.inter(
                  color: ApaColors.nearBlack,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              activeColor: ApaColors.primaryRed,
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class _ApaCheckboxGroup extends StatelessWidget {
  const _ApaCheckboxGroup({
    required this.field,
    required this.controller,
    required this.enabled,
  });

  final ContactFormField field;
  final ContactController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (field.options.isEmpty) {
      final checked = controller.values[field.id] == true;
      return CheckboxListTile(
        value: checked,
        onChanged: enabled
            ? (value) => controller.setValue(field.id, value ?? false)
            : null,
        title: Text(
          field.displayLabel,
          style: ApaFonts.inter(
            color: ApaColors.nearBlack,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        activeColor: ApaColors.primaryRed,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        visualDensity: VisualDensity.compact,
      );
    }

    return Column(
      children: [
        for (final option in field.options)
          CheckboxListTile(
            value: controller.isCheckboxSelected(field, option.submitValue),
            onChanged: enabled
                ? (_) => controller.toggleCheckbox(field, option.submitValue)
                : null,
            title: Text(
              option.displayLabel,
              style: ApaFonts.inter(
                color: ApaColors.nearBlack,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            activeColor: ApaColors.primaryRed,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}
