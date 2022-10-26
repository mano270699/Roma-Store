import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../network/rest_apis.dart';
import '../utils/app_widgets.dart';
import '../utils/common.dart';
import '../utils/constants.dart';
import '../utils/images.dart';

import '../app_localizations.dart';
import '../main.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePasswordScreen';

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  var formKey = GlobalKey<FormState>();
  var passwordCont = TextEditingController();
  var oldPasswordCont = TextEditingController();
  var newPasswordCont = TextEditingController();
  var confirmPasswordCont = TextEditingController();

  String userName = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setState(() {
      userName = getStringAsync(USERNAME);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return SafeArea(
      top: isIos ? false : true,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, '', showBack: true) as PreferredSizeWidget?,
        body: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    Image.asset(
                      ic_sign_in_up,
                      height: 40,
                      color: primaryColor!.withOpacity(0.5),
                    ),
                    Text(appLocalization.translate('update_password')!,
                            style: boldTextStyle(size: 22))
                        .paddingAll(16),
                    20.height,
                    AppTextField(
                      textFieldType: TextFieldType.PASSWORD,
                      controller: oldPasswordCont,
                      decoration: inputDecoration(context,
                          hint: appLocalization.translate('hint_old_password')),
                      validator: (v) {
                        if (v!.trim().isEmpty)
                          return appLocalization
                              .translate('error_old_pwd_require');
                        return null;
                      },
                    ).paddingOnly(right: 16, left: 16),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.PASSWORD,
                      controller: newPasswordCont,
                      decoration: inputDecoration(context,
                          hint: appLocalization.translate('lbl_new_pwd')),
                      validator: (v) {
                        if (v!.trim().isEmpty)
                          return appLocalization
                              .translate('error_new_pwd_require');
                        return null;
                      },
                    ).paddingOnly(right: 16, left: 16),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.PASSWORD,
                      controller: confirmPasswordCont,
                      decoration: inputDecoration(context,
                          hint: appLocalization
                              .translate('hint_confirm_password')),
                      validator: (v) {
                        if (v!.trim().isEmpty)
                          return appLocalization
                              .translate('error_confirm_pwd_require');
                        if (!newPasswordCont.text
                            .toString()
                            .contains(confirmPasswordCont.text.toString()))
                          return appLocalization.translate('error_pwd_match');
                        return null;
                      },
                    ).paddingOnly(right: 16, left: 16),
                    28.height,
                    AppButton(
                            width: context.width(),
                            textStyle: primaryTextStyle(color: white),
                            shapeBorder:
                                RoundedRectangleBorder(borderRadius: radius(8)),
                            text: appLocalization.translate('lbl_change_now'),
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();
                                var request = {
                                  'old_password': oldPasswordCont.text,
                                  'new_password': passwordCont.text,
                                  'username': userName
                                };
                                appStore.isLoading = true;
                                setState(() {});
                                changePassword(request).then((res) async {
                                  appStore.isLoading = false;
                                  setState(() {});
                                  await setValue(
                                      PASSWORD, passwordCont.text.trim());
                                  hideKeyboard(context);
                                  toast(res["message"]);
                                  finish(context);
                                }).catchError((error) {
                                  appStore.isLoading = false;
                                  setState(() {});
                                  toast(error.toString());
                                });
                              } else {
                                toast(appLocalization
                                    .translate("toast_txt_change_pass"));
                              }
                            },
                            color: primaryColor)
                        .paddingOnly(right: 16, left: 16)
                  ],
                ),
              ),
              mProgress().visible(appStore.isLoading!).center()
            ],
          ),
        ),
      ),
    );
  }
}
