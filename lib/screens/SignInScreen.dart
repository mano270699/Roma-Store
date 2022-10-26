import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import '../network/rest_apis.dart';
import '../service/LoginService.dart';
import '../utils/app_widgets.dart';
import '../utils/common.dart';
import '../utils/constants.dart';
import '../utils/images.dart';
import '../app_localizations.dart';
import '../main.dart';
import 'DashBoardScreen.dart';
import 'SignUpScreen.dart';

class SignInScreen extends StatefulWidget {
  static String tag = '/SignInScreen';

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? smsOTP;
  String? data;
  late String _verificationId;
  late String phoneNo;
  late String code;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool? isRemember = false;
  bool? isSocial = false;

  TextEditingController usernameCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController passwordCount = TextEditingController();
  TextEditingController email = TextEditingController();

  FocusNode passwordFocus = FocusNode();

  void verifyPhoneNumber() async {
    var appLocalization = AppLocalizations.of(context)!;
    PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) async {
      // await _auth.signInWithCredential(phoneAuthCredential);
    };
    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      if (authException.code == 'invalid-phone-number') {
        throw 'The provided phone number is not valid.';
      } else {
        toast(authException.toString());
        throw authException.toString();
      }
    };
    PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      toast(appLocalization.translate("toast_txt_profile_saved"));
      _verificationId = verificationId;
      smsOTPDialog(context).then((value) {});
    };
    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      //_verificationId = verificationId;
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: this.phoneNo,
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      toast("Failed to Verify Phone Number: $e");
    }
  }

  void signInWithPhoneNumber() async {
    appStore.isLoading = true;
    setState(() {});

    AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId, smsCode: smsOTP.validate());

    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((result) async {
      var request = {"username": this.data, "password": this.data};
      signInApi(request);
    }).catchError((e) {
      log(e);
      toast(e.toString());
      appStore.isLoading = false;
      setState(() {});
    });
  }

  Future<bool?> smsOTPDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
              AppLocalizations.of(context)!.translate('lbl_enter_sms_code')!,
              style: boldTextStyle()),
          content: Container(
            height: 85,
            child: Column(
              children: [
                OTPTextField(
                  pinLength: 6,

                  // length: 6,
                  // width: MediaQuery.of(context).size.width,
                  // textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldWidth: 30,
                  // style: TextStyle(fontSize: 16),
                  onChanged: (pin) {
                    log("Changed: " + pin);
                  },
                  onCompleted: (pin) {
                    this.smsOTP = pin;
                    log("Completed: " + pin);
                  },
                ),
              ],
            ),
          ),
          contentPadding: EdgeInsets.all(10),
          actions: <Widget>[
            AppButton(
              width: context.width(),
              text: AppLocalizations.of(context)!.translate('lbl_done'),
              onTap: () {
                hideKeyboard(context);
                finish(context);
                signInWithPhoneNumber();
              },
              textStyle: primaryTextStyle(color: white),
              color: primaryColor,
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    if (Platform.isIOS) {
      //check for ios if developing for both android & ios
      TheAppleSignIn.onCredentialRevoked!.listen((_) {
        log("Credentials revoked");
      });
    }
    if (!getBoolAsync(IS_SOCIAL_LOGIN) && getBoolAsync(IS_REMEMBERED)) {
      usernameCont.text = getStringAsync(USER_EMAIL);
      passwordCont.text = getStringAsync(PASSWORD);
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void forgotPwdApi() async {
    appStore.isLoading = true;
    setState(() {});
    hideKeyboard(context);
    var request = {'email': email.text};
    forgetPassword(request).then((res) {
      if (!mounted) return;
      appStore.isLoading = false;
      toast(res['message'].toString());
      setState(() {});
    }).catchError((error) {
      if (!mounted) return;
      appStore.isLoading = false;
      toast(error.toString());
      setState(() {});
    });
  }

  void signInApi(req) async {
    appStore.setLoading(true);
    await login1(req).then((res) async {
      if (!mounted) return;
      setStringAsync(PASSWORD, passwordCont.text.toString());
      appStore.setLoading(false);
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: req['username'], password: req['password']);
      if (credential.user!.email.isEmptyOrNull) {
        toast(AppLocalizations.of(context)!.translate('msg_email_not_found'));
      } else {
        DashBoardScreen().launch(context, isNewTask: true);
      }
    }).catchError((error) {
      log("Error" + error.toString());
      appStore.setLoading(false);
      if (isSocial == true) {
        if (error
            .toString()
            .contains("The username or password you entered is incorrect.")) {
          finish(context);
          SignUpScreen(userName: this.data.toString()).launch(context);
        } else {
          toast(error.toString());
        }
      } else {
        toast(error.toString());
      }
      setState(() {});
    });
  }

  void socialLogin(req) async {
    appStore.setLoading(true);
    setState(() {});
    await login1(req, isSocialLogin: true).then((res) async {
      if (!mounted) return;
      appStore.setLoading(false);
      DashBoardScreen().launch(context, isNewTask: true);
    }).catchError((error) {
      toast(error.toString());
    });
    appStore.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    void onGoogleSignInTap() async {
      var service = LoginService();
      await service.signInWithGoogle().then((res) {
        socialLogin(res);
      }).catchError((e) {
        toast(e.toString());
      });
    }

    saveAppleDataWithoutEmail() async {
      await getSharedPref().then((pref) {
        log(getStringAsync('appleEmail'));
        log(getStringAsync('appleGivenName'));
        log(getStringAsync('appleFamilyName'));

        var req = {
          'email': getStringAsync('appleEmail'),
          'firstName': getStringAsync('appleGivenName'),
          'lastName': getStringAsync('appleFamilyName'),
          'photoURL': '',
          'accessToken': '12345678',
          'loginType': 'apple',
        };
        socialLogin(req);
      });
    }

    saveAppleData(result) async {
      setStringAsync('appleEmail', result.credential.email);
      setStringAsync('appleGivenName', result.credential.fullName.givenName);
      setStringAsync('appleFamilyName', result.credential.fullName.familyName);

      log('Email:- ${getStringAsync('appleEmail')}');
      log('appleGivenName:- ${getStringAsync('appleGivenName')}');
      log('appleFamilyName:- ${getStringAsync('appleFamilyName')}');

      var req = {
        'email': result.credential.email,
        'firstName': result.credential.fullName.givenName,
        'lastName': result.credential.fullName.familyName,
        'photoURL': '',
        'accessToken': '12345678',
        'loginType': 'apple',
      };
      socialLogin(req);
    }

    void appleLogIn() async {
      if (await TheAppleSignIn.isAvailable()) {
        final AuthorizationResult result =
            await TheAppleSignIn.performRequests([
          AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
        ]);
        switch (result.status) {
          case AuthorizationStatus.authorized:
            log("Result: $result"); //All the required credentials
            if (result.credential!.email == null) {
              saveAppleDataWithoutEmail();
            } else {
              saveAppleData(result);
            }
            break;
          case AuthorizationStatus.error:
            log("Sign in failed: ${result.error!.localizedDescription}");
            break;
          case AuthorizationStatus.cancelled:
            log('User cancelled');
            break;
        }
      } else {
        toast(appLocalization.translate("toast_not_available"));
      }
    }

    Widget mForgotPWd() {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: radius(10)),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(16),
          width: MediaQuery.of(context).size.width,
          decoration: boxDecorationWithRoundedCorners(
              borderRadius: radius(10),
              backgroundColor: Theme.of(context).cardTheme.color!),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: Icon(Icons.close).onTap(() {
                    finish(context);
                  }),
                ),
                Image.asset(ic_password,
                        height: 50,
                        width: 50,
                        color: primaryColor!.withOpacity(0.7))
                    .center(),
                22.height,
                Text(appLocalization.translate('lbl_forgot_password_msg')!,
                    style: boldTextStyle()),
                4.height,
                Text(appLocalization.translate("forgot_password_msg")!,
                    style: secondaryTextStyle(size: 12)),
                24.height,
                AppTextField(
                  textFieldType: TextFieldType.EMAIL,
                  controller: email,
                  cursorColor: appStore.isDarkMode! ? whiteColor : black,
                  decoration: inputDecoration(context,
                      hint: appLocalization
                          .translate('hint_enter_your_email_id')),
                  validator: (v) {
                    if (v!.trim().isEmpty)
                      return appLocalization.translate('error_email_required');
                    if (!v.trim().validateEmail())
                      return appLocalization.translate('error_wrong_email');
                    return null;
                  },
                ),
                16.height,
                AppButton(
                    width: context.width(),
                    shapeBorder:
                        RoundedRectangleBorder(borderRadius: radius(8)),
                    text: appLocalization.translate('lbl_submit'),
                    textStyle: primaryTextStyle(color: white),
                    color: primaryColor,
                    onTap: () {
                      if (!accessAllowed) {
                        toast(appLocalization.translate('txt_sorry'));
                        return;
                      }
                      if (email.text.isEmpty)
                        toast(appLocalization.translate('hint_Email')! +
                            (' ') +
                            appLocalization.translate('error_field_required')!);
                      else if (!email.text.validateEmail()) {
                        toast(appLocalization.translate('error_wrong_email'));
                      } else
                        Navigator.pop(context);
                      forgotPwdApi();
                    }),
                16.height,
              ],
            ),
          ),
        ),
      );
    }

    Widget socialButtons = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
                padding: EdgeInsets.all(8),
                child: Image.asset(ic_google, width: 35, height: 35))
            .onTap(() {
          onGoogleSignInTap();
        }).visible(enableSignWithGoogle == true),
        8.width,
        Container(
          padding: EdgeInsets.all(8),
          child: Image.asset(ic_mobile,
              width: 35,
              height: 35,
              color: appStore.isDarkModeOn
                  ? white
                  : Theme.of(context).iconTheme.color),
        ).onTap(() {
          showDialog(
              context: context,
              builder: (BuildContext context) => Dialog(
                    elevation: 0.0,
                    insetPadding: EdgeInsets.all(16),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: radius(10)),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      width: MediaQuery.of(context).size.width,
                      decoration: boxDecorationWithRoundedCorners(
                          borderRadius: radius(10),
                          backgroundColor: Theme.of(context).cardTheme.color!),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.topRight,
                              child: Icon(Icons.close).onTap(() {
                                finish(context);
                              }),
                            ),
                            16.height,
                            Image.asset(ic_mobile,
                                height: 50,
                                width: 50,
                                color: primaryColor!.withOpacity(0.7)),
                            16.height,
                            Text(
                                appLocalization
                                    .translate('lbl_log_in_with_mobile')!,
                                style: boldTextStyle()),
                            24.height,
                            Container(
                              decoration: boxDecorationWithRoundedCorners(
                                backgroundColor:
                                    Theme.of(context).cardTheme.color!,
                                borderRadius: radius(8),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .textTheme
                                        .subtitle1!
                                        .color!),
                              ),
                              child: Row(
                                children: <Widget>[
                                  CountryCodePicker(
                                    onChanged: (value) {
                                      log("Value" + value.dialCode!);
                                      this.code = value.dialCode.toString();
                                    },
                                    padding: EdgeInsets.all(0),
                                    backgroundColor: Colors.transparent,
                                    showFlag: false,
                                    dialogBackgroundColor:
                                        Theme.of(context).cardTheme.color,
                                    textStyle: primaryTextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .color),
                                  ),
                                  Container(
                                      height: 30.0,
                                      width: 1.0,
                                      color: primaryColor,
                                      margin: EdgeInsets.only(left: 8.0)),
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      maxLength: 10,
                                      cursorColor: appStore.isDarkMode!
                                          ? whiteColor
                                          : black,
                                      style: secondaryTextStyle(size: 16),
                                      controller: passwordCount,
                                      decoration: InputDecoration(
                                          counterText: "",
                                          contentPadding:
                                              EdgeInsets.fromLTRB(16, 0, 16, 0),
                                          hintText: appLocalization.translate(
                                              'lbl_enter_mobile_number'),
                                          hintStyle:
                                              secondaryTextStyle(size: 16),
                                          border: InputBorder.none),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            16.height,
                            AppButton(
                                width: context.width(),
                                text:
                                    appLocalization.translate('lbl_verify_now'),
                                onTap: () async {
                                  Navigator.pop(context);
                                  hideKeyboard(context);
                                  this.phoneNo =
                                      this.code + passwordCount.text.toString();
                                  this.data = passwordCount.text.toString();
                                  await setValue(IS_SOCIAL_LOGIN, true);
                                  verifyPhoneNumber();
                                  isSocial = true;
                                  setState(() {});
                                },
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius: radius(8)),
                                textStyle: primaryTextStyle(color: white),
                                color: primaryColor),
                            16.height,
                          ],
                        ).center(),
                      ),
                    ),
                  ));
        }).visible(enableSignWithOtp == true),
        8.width,
        Container(
          padding: EdgeInsets.all(8),
          child: Image.asset(ic_apple,
              width: 35,
              height: 35,
              color: !appStore.isDarkModeOn ? black : white),
        ).onTap(() {
          appleLogIn();
        }).visible(Platform.isIOS && enableSignWithApple),
      ],
    );

    return SafeArea(
      top: isIos ? false : true,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: mTop(context, "", showBack: true) as PreferredSizeWidget?,
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    16.height,
                    Image.asset(
                      ic_sign_in_up,
                      height: 40,
                      color: primaryColor!.withOpacity(0.5),
                    ),
                    Text(
                      appLocalization.translate('lbl_welcome_back')!,
                      style: boldTextStyle(size: 34),
                    ).paddingAll(16),
                    Row(
                      children: <Widget>[
                        Text(appLocalization.translate('lbl_new')!,
                            style: primaryTextStyle(
                                size: 18,
                                color: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .color)),
                        Container(
                          margin: EdgeInsets.only(left: 4),
                          child: GestureDetector(
                              child: Text(
                                  appLocalization.translate('lbl_create_new')!,
                                  style: TextStyle(
                                      fontSize: 18, color: primaryColor)),
                              onTap: () {
                                SignUpScreen().launch(context);
                              }),
                        )
                      ],
                    ).paddingOnly(right: 16, left: 16),
                    40.height,
                    AppTextField(
                      controller: usernameCont,
                      cursorColor: appStore.isDarkMode! ? whiteColor : black,
                      textFieldType: TextFieldType.NAME,
                      decoration: inputDecoration(context,
                          hint: appLocalization.translate('hint_Username')),
                      nextFocus: passwordFocus,
                    ).paddingOnly(left: 16, right: 16),
                    16.height,
                    AppTextField(
                      cursorColor: appStore.isDarkMode! ? whiteColor : black,
                      controller: passwordCont,
                      textFieldType: TextFieldType.PASSWORD,
                      focus: passwordFocus,
                      decoration: inputDecoration(context,
                          hint: appLocalization.translate('hint_password')),
                    ).paddingOnly(left: 16, right: 16),
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CustomTheme(
                              child: Checkbox(
                                value: getBoolAsync(IS_REMEMBERED,
                                    defaultValue: false),
                                checkColor: white,
                                activeColor: primaryColor,
                                onChanged: (v) async {
                                  await setValue(IS_REMEMBERED, v);
                                  setState(() {});
                                },
                              ),
                            ),
                            Text(appLocalization.translate('lbl_remember_me')!,
                                    style: secondaryTextStyle(size: 16))
                                .onTap(() async {
                              await setValue(
                                  IS_REMEMBERED, !getBoolAsync(IS_REMEMBERED));
                              setState(() {});
                            })
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                                  appLocalization
                                      .translate('lbl_forgot_password')!,
                                  style: secondaryTextStyle(
                                      size: 16, color: primaryColor))
                              .onTap(() {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    mForgotPWd());
                          }),
                        ).expand(),
                      ],
                    ).paddingRight(16),
                    20.height,
                    AppButton(
                            width: context.width(),
                            shapeBorder:
                                RoundedRectangleBorder(borderRadius: radius(8)),
                            textStyle: primaryTextStyle(color: white),
                            text: appLocalization.translate('lbl_sign_in'),
                            onTap: () {
                              hideKeyboard(context);
                              if (formKey.currentState!.validate()) {
                                formKey.currentState!.save();
                                var request = {
                                  "username": "${usernameCont.text}",
                                  "password": "${passwordCont.text}"
                                };
                                appStore.isLoading = true;
                                signInApi(request);
                              }
                            },
                            color: primaryColor)
                        .paddingOnly(left: 16, right: 16),
                    20.height,
                    //  socialButtons.visible(enableSocialSign == true)
                  ],
                ).paddingOnly(top: 16, bottom: 16),
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
