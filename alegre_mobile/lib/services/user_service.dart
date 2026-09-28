import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

class UserService {
  static const _profileCollection = 'userProfiles';
  static const _loginTypeKey = 'loginType';

  final firebase_auth.FirebaseAuth? _providedAuth;
  final FirebaseFirestore? _providedFirestore;

  UserService({firebase_auth.FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _providedAuth = auth,
      _providedFirestore = firestore;

  firebase_auth.FirebaseAuth get _auth =>
      _providedAuth ?? firebase_auth.FirebaseAuth.instance;

  FirebaseFirestore get _firestore =>
      _providedFirestore ?? FirebaseFirestore.instance;

  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;

  Future<User> loginUser(String username, String password) async {
    if (username == 'arkkali' && password == 'arkkali123') {
      const user = User(
        id: 1,
        username: 'arkkali',
        email: 'arkkali@email.com',
        firstName: 'Arkkali',
        lastName: '',
        gender: 'female',
        image: '',
        accessToken: 'arkkali-demo-token',
        refreshToken: '',
      );
      await saveUserData(user);
      return user;
    }

    final response = await http.post(
      Uri.parse('$host/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 60,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Invalid username or password');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final user = User.fromJson(data);
    await saveUserData(user);
    return user;
  }

  // Activity 5: Sign in with Firebase email/password authentication.
  Future<User> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) throw StateError('Firebase did not return a user.');
    await _saveLoginType(LoginType.firebase);
    final profile = await getUserData(loginType: LoginType.firebase);
    return profile ?? _userFromFirebase(user, const {});
  }

  // Activity 5: Create the Firebase account and store extended profile data by UID.
  Future<User> createAccount({
    required String firstName,
    required String lastName,
    required int age,
    required String contactNo,
    required String username,
    required String email,
    required String password,
  }) async {
    final credential = await _auth
        .createUserWithEmailAndPassword(email: email.trim(), password: password)
        .timeout(const Duration(seconds: 20));
    final authUser = credential.user;
    if (authUser == null) throw StateError('Firebase did not create a user.');

    await authUser.updateDisplayName(username.trim());
    await authUser.reload();
    final profile = <String, dynamic>{
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'age': age,
      'contactNo': contactNo.trim(),
      'username': username.trim(),
      'email': email.trim(),
      'loginType': LoginType.firebase.name,
    };
    await _firestore
        .collection(_profileCollection)
        .doc(authUser.uid)
        .set(profile)
        .timeout(const Duration(seconds: 20));
    await _saveLoginType(LoginType.firebase);
    final refreshedUser = _auth.currentUser ?? authUser;
    return _userFromFirebase(refreshedUser, profile);
  }

  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    await prefs.setInt('userId', user.id);
    await prefs.setString('accessToken', user.accessToken);
    await prefs.setString(_loginTypeKey, user.loginType.name);
  }

  Future<User?> getUserData({LoginType? loginType}) async {
    final prefs = await SharedPreferences.getInstance();
    final type =
        loginType ?? _loginTypeFromName(prefs.getString(_loginTypeKey));

    if (type == LoginType.firebase) {
      final authUser = _auth.currentUser;
      if (authUser == null) return null;
      final snapshot = await _firestore
          .collection(_profileCollection)
          .doc(authUser.uid)
          .get();
      return _userFromFirebase(authUser, snapshot.data() ?? const {});
    }

    final savedUser = prefs.getString('user');
    if (savedUser == null || savedUser.isEmpty) return null;
    return User.fromJson(jsonDecode(savedUser) as Map<String, dynamic>);
  }

  Future<User?> getUser() => getUserData();

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final type = _loginTypeFromName(prefs.getString(_loginTypeKey));
    if (type == LoginType.firebase) return _auth.currentUser != null;
    final token = prefs.getString('accessToken');
    return token != null && token.isNotEmpty;
  }

  Future<void> updateUsername(String username) async {
    final authUser = _requireFirebaseUser();
    final updatedUsername = username.trim();
    await authUser.updateDisplayName(updatedUsername);
    await _firestore.collection(_profileCollection).doc(authUser.uid).set({
      'username': updatedUsername,
    }, SetOptions(merge: true));
  }

  // Activity 5: Reauthenticate before changing a sensitive Firebase credential.
  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final authUser = _requireFirebaseUser();
    await _reauthenticate(authUser, currentPassword);
    await authUser.updatePassword(newPassword);
  }

  // Activity 5: Reauthenticate before deleting the Firebase account and profile.
  Future<void> deleteAccount({required String currentPassword}) async {
    final authUser = _requireFirebaseUser();
    await _reauthenticate(authUser, currentPassword);
    await _firestore.collection(_profileCollection).doc(authUser.uid).delete();
    await authUser.delete();
    await _clearLocalSession();
  }

  // Activity 5: Sign out from Firebase and clear the local session.
  Future<void> signOut() async {
    await _auth.signOut();
    await _clearLocalSession();
  }

  Future<void> logout() => signOut();

  firebase_auth.User _requireFirebaseUser() {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw StateError('Sign in with a Firebase account to use this action.');
    }
    return user;
  }

  Future<void> _reauthenticate(
    firebase_auth.User user,
    String currentPassword,
  ) async {
    final credential = firebase_auth.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
  }

  User _userFromFirebase(
    firebase_auth.User authUser,
    Map<String, dynamic> profile,
  ) {
    return User(
      id: 0,
      username: profile['username'] as String? ?? authUser.displayName ?? '',
      email: authUser.email ?? profile['email'] as String? ?? '',
      firstName: profile['firstName'] as String? ?? '',
      lastName: profile['lastName'] as String? ?? '',
      age: profile['age'] as int?,
      contactNo: profile['contactNo'] as String? ?? '',
      gender: '',
      image: authUser.photoURL ?? '',
      accessToken: '',
      refreshToken: '',
      loginType: LoginType.firebase,
    );
  }

  LoginType _loginTypeFromName(String? name) => name == LoginType.firebase.name
      ? LoginType.firebase
      : LoginType.dummyJson;

  Future<void> _saveLoginType(LoginType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginTypeKey, type.name);
  }

  Future<void> _clearLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
