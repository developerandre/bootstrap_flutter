import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'theme.dart';

Map<String, int> stats = {};

titleCase(String str) {
  if (str.isEmpty) return '';
  return str
      .toLowerCase()
      .split(' ')
      .map((x) => x[0].toUpperCase() + x.substring(1))
      .join(' ');
}

String getUserName(Map user) {
  return (user['firstName'] ?? "") + ' ' + (user['lastName'] ?? "");
}

Widget buildLabel(String msg,
    {EdgeInsets? padding, bool mandatory = false, Color? textColor}) {
  List<TextSpan> children = [TextSpan(text: msg)];
  if (mandatory) {
    children.add(const TextSpan(
        text: ' *', style: TextStyle(color: Colors.redAccent, fontSize: 12)));
  }
  return Padding(
      padding: padding ?? const EdgeInsets.only(left: 3.0, top: 20, bottom: 4),
      child: SelectableText.rich(TextSpan(children: children),
          style: TextStyle(
              color: textColor, fontSize: 15, fontWeight: FontWeight.w600)));
}

showLoading(context, [String? msg]) {
  FocusScope.of(context).requestFocus(FocusNode());
  return showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 20.0),
            content: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(msg ?? 'loading',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.0),
                      textAlign: TextAlign.center))
            ]));
      });
}

Future<T?> navigateToBoard<T>(BuildContext context,
    {bool canBack = false,
    required String routeName,
    required Widget page,
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    dynamic extra}) {
  return context.pushNamed(routeName,
      pathParameters: params, queryParameters: queryParams, extra: extra);
}

Widget buildField(String? label,
    {TextEditingController? controller,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    AutovalidateMode? autovalidateMode,
    String? Function(String?)? validator,
    FloatingLabelBehavior? floatingLabelBehavior,
    bool? filled,
    Color? fillColor,
    double? radius,
    FocusNode? focusNode,
    int? maxLines = 1,
    int? minLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool required = false,
    String? hint,
    Widget? icon,
    Widget? suffixIcon,
    Widget? prefixIcon,
    Widget? prefix,
    int? maxLength,
    String? counterText,
    bool? obscureText,
    String? help,
    Widget? suffix,
    bool? enabled,
    EdgeInsets? contentPadding,
    bool autofocus = false,
    bool noBorder = false,
    TextStyle? helperStyle,
    TextStyle? hintStyle,
    double? borderSide,
    Color? borderColor,
    String? errorText,
    TextAlign? textAlign,
    Function()? onEditingComplete,
    Function(String)? onFieldSubmitted}) {
  return Padding(
      padding: const EdgeInsets.only(left: 2.0, right: 2.0, top: 5.0),
      child: TextFormField(
          autovalidateMode: autovalidateMode,
          validator: validator,
          enabled: enabled ?? true,
          maxLines: (minLines ?? 1) > 1 ? null : (maxLines),
          minLines: minLines ?? 1,
          maxLength: maxLength,
          autofocus: autofocus,
          controller: controller,
          focusNode: focusNode,
          textAlign: textAlign ?? TextAlign.start,
          onEditingComplete: onEditingComplete,
          onFieldSubmitted: onFieldSubmitted,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText ?? false,
          onChanged: onChanged,
          //onSubmitted: onSubmitted,
          decoration: InputDecoration(
              fillColor: fillColor,
              filled: filled,
              floatingLabelBehavior:
                  floatingLabelBehavior ?? FloatingLabelBehavior.always,
              contentPadding: contentPadding,
              hintText: hint,
              hintMaxLines: 5,
              hintStyle: hintStyle ??
                  const TextStyle(fontSize: 14.5, color: Colors.black26),
              icon: icon,
              enabledBorder: noBorder
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius ?? 4),
                      borderSide: BorderSide(
                          color: fillColor != null
                              ? borderColor ?? appPrimaryColor
                              : Colors.black,
                          width: borderSide ?? 1)),
              disabledBorder: noBorder
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius ?? 4),
                      borderSide: BorderSide(
                          color: fillColor != null
                              ? borderColor ?? appPrimaryColor
                              : Colors.black,
                          width: borderSide ?? 1)),
              focusedBorder: noBorder
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius ?? 6),
                      borderSide: BorderSide(
                          color: fillColor != null
                              ? borderColor ?? appPrimaryColor
                              : Colors.black,
                          width: borderSide ?? 1)),
              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon,
              prefix: prefix,
              suffix: suffix,
              labelText: label != null ? label + (required ? ' *' : '') : null,
              counterText: counterText,
              isDense: true,
              helperText: help,
              helperMaxLines: 5,
              helperStyle: helperStyle,
              errorText: errorText)));
}

Widget buildSelect(BuildContext context,
    {hint,
    List? selectedMenus,
    value,
    String? fieldValue,
    String? fieldLibelle,
    EdgeInsets? padding,
    Function? item,
    bool mandatory = false,
    int? maxLines,
    bool? isExpanded,
    TextStyle? style,
    Widget? icon,
    Color? borderColor,
    Color? dropdownColor,
    Color? bgColor,
    void Function(dynamic)? onChanged}) {
  if (selectedMenus == null) {
    return const SizedBox();
  }
  return DropdownButtonHideUnderline(
      child: Container(
          padding: padding ??
              const EdgeInsets.only(
                  left: 3.0, right: 3.0, top: 1.0, bottom: 1.0),
          decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                  color: borderColor ??
                      Colors.black)), //Theme.of(context).primaryColor
          child: DropdownButton(
              dropdownColor: dropdownColor,
              style: style ??
                  const TextStyle(fontSize: 14.0, color: Colors.black87),
              isExpanded: isExpanded ?? true,
              iconEnabledColor: style?.color,
              icon: icon,
              hint: hint is Widget
                  ? hint
                  : Text(hint ?? '',
                      maxLines: 1,
                      style: style ?? const TextStyle(fontSize: 12.0)),
              items: selectedMenus.map((value) {
                return DropdownMenuItem(
                    value: fieldValue != null ? value[fieldValue] : value,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: item != null
                            ? item(value)
                            : AutoSizeText(
                                '${fieldLibelle != null ? value[fieldLibelle] : value}',
                                maxLines: maxLines ?? 2,
                                overflow: TextOverflow.ellipsis)));
              }).toList(),
              value: value,
              onChanged: onChanged)));
}

Future<String?> showAlert(context, msg,
    {ShapeBorder? shape,
    bool barrier = true,
    bool cancel = false,
    String? cancelMsg,
    String? okMsg,
    EdgeInsets? contentPadding,
    EdgeInsets? titlePadding,
    Color? bgColor,
    Color? okTextColor,
    List<Widget> btns = const []}) {
  FocusScope.of(context).requestFocus(FocusNode());
  return showDialog<String>(
      context: context,
      barrierDismissible: barrier,
      builder: (cxt) {
        return AlertDialog(
            backgroundColor: bgColor,
            shape: shape ??
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            contentPadding: contentPadding ??
                const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0.0),
            titlePadding: titlePadding,
            content:
                msg is String ? SingleChildScrollView(child: Text(msg)) : msg,
            actions: <Widget>[
              ...btns,
              Visibility(
                  visible: cancel,
                  child: TextButton(
                      child: Text(cancelMsg ?? 'Annuler',
                          style: const TextStyle(color: Colors.red)),
                      onPressed: () {
                        Navigator.of(cxt).pop();
                      })),
              TextButton(
                  child:
                      Text(okMsg ?? 'Ok', style: TextStyle(color: okTextColor)),
                  onPressed: () {
                    Navigator.of(cxt).pop('Ok');
                  })
            ]);
      });
}
