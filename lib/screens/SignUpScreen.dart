import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../network/rest_apis.dart';
import '../utils/app_widgets.dart';
import '../utils/common.dart';
import '../utils/constants.dart';
import '../utils/images.dart';

import '../app_localizations.dart';
import '../main.dart';
import 'DashBoardScreen.dart';

class SignUpScreen extends StatefulWidget {
  static String tag = '/SignUpScreen';
  final String? userName;

  const SignUpScreen({Key? key, this.userName}) : super(key: key);

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController usernameCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController confirmPasswordCont = TextEditingController();

  FocusNode lNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode usernameFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  signUpApi({required String email, required String password}) async {
    var appLocalization = AppLocalizations.of(context)!;
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      var request = {
        'first_name': fNameCont.text,
        'last_name': lNameCont.text,
        'user_email': emailCont.text,
        'user_login': widget.userName != null
            ? widget.userName!.isNotEmpty
                ? widget.userName
                : usernameCont.text
            : usernameCont.text,
        'user_pass': widget.userName != null
            ? widget.userName!.isNotEmpty
                ? widget.userName
                : passwordCont.text
            : passwordCont.text
      };
      log("Request" + request.toString());
      setState(() {
        appStore.isLoading = true;
      });
      createCustomer(request).then((res) async {
        if (!mounted) return;
        if (widget.userName != null) {
          if (widget.userName!.isNotEmpty) {
            var request = {
              "username": widget.userName,
              "password": widget.userName
            };
            log("Request" + request.toString());
            signInApi(request);
            //createAccountFireBase(email: email, password: password);
            Navigator.pop(context);
          } else {
            //createAccountFireBase(email: email, password: password);
            // await FirebaseAuth.instance.createUserWithEmailAndPassword(
            //   email: email,
            //   password: password,
            // );
            toast(appLocalization.translate("toast_registered"));
            finish(context);
          }
        } else {
          //createAccountFireBase(email: email, password: password);

          toast(appLocalization.translate("toast_registered"));
          Navigator.pop(context);
        }
        setState(() {
          appStore.isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          appStore.isLoading = false;
        });
        toast(error.toString());
      });
    }
  }

  void socialLogin(req) async {
    setState(() {
      appStore.isLoading = true;
    });
    await socialLoginApi(req).then((res) async {
      if (!mounted) return;
      await getCustomer(res['user_id']).then((response) async {
        if (!mounted) return;

        await setValue(IS_SOCIAL_LOGIN, true);
        await setValue(AVATAR, req['photoURL']);
        await setValue(USER_ID, res['user_id']);
        await setValue(FIRST_NAME, res['first_name']);
        await setValue(LAST_NAME, res['last_name']);
        await setValue(USER_EMAIL, res['user_email']);
        await setValue(USERNAME, res['user_nicename']);
        await setValue(TOKEN, res['token']);
        await setValue(USER_DISPLAY_NAME, res['user_display_name']);
        await setValue(IS_LOGGED_IN, true);
        setState(() {
          appStore.isLoading = false;
        });
        DashBoardScreen().launch(context, isNewTask: true);
      }).catchError((error) {
        setState(() {
          appStore.isLoading = false;
        });
        toast(error.toString());
      });
    }).catchError((error) {
      setState(() {
        appStore.isLoading = false;
      });
      toast(error.toString());
    });
  }

  void signInApi(req) async {
    setState(() {
      appStore.isLoading = true;
    });
    await login(req).then((res) async {
      if (!mounted) return;
      await setValue(USER_ID, res['user_id']);
      setStringAsync(FIRST_NAME, res['first_name']);
      setStringAsync(LAST_NAME, res['last_name']);
      setStringAsync(USER_EMAIL, res['user_email']);
      setStringAsync(USERNAME, res['user_nicename']);
      setStringAsync(TOKEN, res['token']);
      setStringAsync(AVATAR, res['avatar']);
      if (res['profile_image'] != null) {
        await setValue(PROFILE_IMAGE, res['profile_image']);
      }
      await setValue(USER_DISPLAY_NAME, res['user_display_name']);
      await setValue(BILLING, jsonEncode(res['billing']));
      await setValue(SHIPPING, jsonEncode(res['shipping']));
      setBoolAsync(IS_LOGGED_IN, true);
      if (widget.userName!.isNotEmpty) {
        setBoolAsync(IS_SOCIAL_LOGIN, true);
      }
      setState(() {
        appStore.isLoading = false;
      });
      DashBoardScreen().launch(context, isNewTask: true);
    }).catchError((error) {
      print("Error" + error.toString());
      setState(() {
        appStore.isLoading = false;
      });
      toast(error.toString());
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
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, appLocalization.translate('lbl_create_account')!,
            showBack: true) as PreferredSizeWidget?,
        body: Stack(
          children: <Widget>[
            Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      16.height,
                      Image.asset(ic_sign_in_up,
                          height: 40,
                          fit: BoxFit.cover,
                          color: primaryColor!.withOpacity(0.5)),
                      16.height,
                      Text(appLocalization.translate('lbl_sign_up_link')!,
                              style: boldTextStyle(size: 34))
                          .paddingOnly(right: 16, left: 16),
                      10.height,
                      Row(
                        children: <Widget>[
                          Text(
                              appLocalization
                                  .translate('lbl_already_have_account')!,
                              style: primaryTextStyle(
                                  size: 18,
                                  color: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .color)),
                          4.width,
                          GestureDetector(
                              child: Text(
                                  appLocalization.translate('lbl_sign_in')!,
                                  style: TextStyle(
                                      fontSize: 18, color: primaryColor)),
                              onTap: () {
                                finish(context);
                              })
                        ],
                      ).paddingOnly(right: 16, left: 16),
                      28.height,
                      Row(
                        children: [
                          AppTextField(
                                  cursorColor:
                                      appStore.isDarkMode! ? whiteColor : black,
                                  textFieldType: TextFieldType.NAME,
                                  controller: fNameCont,
                                  decoration: inputDecoration(context,
                                      hint: appLocalization
                                          .translate('hint_first_name')),
                                  nextFocus: lNameFocus)
                              .expand(),
                          16.width,
                          AppTextField(
                            cursorColor:
                                appStore.isDarkMode! ? whiteColor : black,
                            textFieldType: TextFieldType.NAME,
                            controller: lNameCont,
                            focus: lNameFocus,
                            nextFocus: emailFocus,
                            decoration: inputDecoration(context,
                                hint: appLocalization
                                    .translate('hint_last_name')),
                          ).expand(),
                        ],
                      ).paddingOnly(right: 16, left: 16),
                      spacing_standard_new.height,
                      AppTextField(
                        cursorColor: appStore.isDarkMode! ? whiteColor : black,
                        textFieldType: TextFieldType.EMAIL,
                        controller: emailCont,
                        focus: emailFocus,
                        nextFocus: usernameFocus,
                        decoration: inputDecoration(context,
                            hint: appLocalization.translate('lbl_email')),
                      ).paddingOnly(right: 16, left: 16),
                      spacing_standard_new.height,
                      AppTextField(
                        cursorColor: appStore.isDarkMode! ? whiteColor : black,
                        textFieldType: TextFieldType.NAME,
                        controller: usernameCont,
                        focus: usernameFocus,
                        nextFocus: passwordFocus,
                        decoration: inputDecoration(context,
                            hint: appLocalization.translate('hint_Username')),
                      )
                          .paddingOnly(right: 16, left: 16)
                          .visible(widget.userName.isEmptyOrNull),
                      spacing_standard_new.height,
                      AppTextField(
                        cursorColor: appStore.isDarkMode! ? whiteColor : black,
                        textFieldType: TextFieldType.PASSWORD,
                        controller: passwordCont,
                        focus: passwordFocus,
                        nextFocus: confirmPasswordFocus,
                        decoration: inputDecoration(context,
                            hint: appLocalization.translate('hint_password')),
                      )
                          .paddingOnly(right: 16, left: 16)
                          .visible(widget.userName.isEmptyOrNull),
                      spacing_standard_new.height,
                      AppTextField(
                              cursorColor:
                                  appStore.isDarkMode! ? whiteColor : black,
                              textFieldType: TextFieldType.PASSWORD,
                              controller: confirmPasswordCont,
                              focus: confirmPasswordFocus,
                              decoration: inputDecoration(context,
                                  hint: appLocalization
                                      .translate('hint_confirm_password')),
                              validator: (v) {
                                if (confirmPasswordCont.text !=
                                    passwordCont.text)
                                  return appLocalization
                                      .translate('error_pwd_not_match');
                              })
                          .visible(widget.userName.isEmptyOrNull)
                          .paddingOnly(right: 16, left: 16),
                      32.height,
                      AppButton(
                          width: context.width(),
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          text: appLocalization.translate('lbl_sign_up_link'),
                          textStyle: primaryTextStyle(color: white),
                          color: primaryColor,
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              appStore.isLoading = true;
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: emailCont.text,
                                      password: passwordCont.text)
                                  .then((value) => signUpApi(
                                      email: emailCont.text,
                                      password: passwordCont.text));
                            }
                          }).paddingOnly(right: 16, left: 16),
                      16.height
                    ],
                  ),
                ),
              ),
            ),
            appStore.isLoading!
                ? Container(child: mProgress(), alignment: Alignment.center)
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
