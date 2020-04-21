import 'package:dreader/common/utils/common_utils.dart';
import 'package:dreader/common/utils/navigator_utils.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:rxdart/rxdart.dart';

import 'd_reader_state.dart';
import 'middleware/epic.dart';
import 'middleware/epic_store.dart';


final LoginReducer = combineReducers<bool>([
  TypedReducer<bool, LoginSuccessAction>(_loginResult),
  TypedReducer<bool, LogoutAction>(_logoutResult),
]);

bool _loginResult(bool result, LoginSuccessAction action) {
  if (action.success == true) {
    NavigatorUtils.goHome(action.context);
  }
  return action.success;
}

bool _logoutResult(bool result, LogoutAction action) {
  return true;
}

class LoginSuccessAction {
  final BuildContext context;
  final bool success;

  LoginSuccessAction(this.context, this.success);
}

class LogoutAction {
  final BuildContext context;

  LogoutAction(this.context);
}

class LoginAction {
  final BuildContext context;
  final String username;
  final String password;

  LoginAction(this.context, this.username, this.password);
}

class OAuthAction {
  final BuildContext context;
  final String code;

  OAuthAction(this.context, this.code);
}

class LoginMiddleware implements MiddlewareClass<DReaderState> {
  @override
  void call(Store<DReaderState> store, dynamic action, NextDispatcher next) {
    if (action is LogoutAction) {
//      UserDao.clearAll(store);
//      SqlManager.close();
      NavigatorUtils.goLogin(action.context);
    }
    // Make sure to forward actions to the next middleware in the chain!
    next(action);
  }
}

class LoginEpic implements EpicClass<DReaderState> {
  @override
  Stream<dynamic> call(Stream<dynamic> actions, EpicStore<DReaderState> store) {
    return Stream.value(actions)
        .whereType<LoginAction>()
        .switchMap((action) => _loginIn(action, store));
  }

  Stream<dynamic> _loginIn(
      LoginAction action, EpicStore<DReaderState> store) async* {
    CommonUtils.showLoadingDialog(action.context);
//    var res = await UserDao.login(
//        action.username.trim(), action.password.trim(), store);
    Navigator.pop(action.context);
    yield LoginSuccessAction(action.context, true);
  }
}

class OAuthEpic implements EpicClass<DReaderState> {
  @override
  Stream<dynamic> call(Stream<dynamic> actions, EpicStore<DReaderState> store) {
    return Stream.value(actions)
        .whereType<OAuthAction>()
        .switchMap((action) => _loginIn(action, store));
  }

  Stream<dynamic> _loginIn(
      OAuthAction action, EpicStore<DReaderState> store) async* {
    CommonUtils.showLoadingDialog(action.context);
//    var res = await UserDao.oauth(action.code, store);
    Navigator.pop(action.context);
    yield LoginSuccessAction(action.context, true);
  }
}
