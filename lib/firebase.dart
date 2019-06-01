import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

export 'package:firebase_auth/firebase_auth.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_storage/firebase_storage.dart';

final auth = FirebaseAuth.instance;
final db = Firestore.instance;
final storage = FirebaseStorage.instance;
final _googleAuthService = GoogleSignIn();

/// Generate's the ID for a new document.
/// [path] points to the document's parent collection.
String generateDocID([String path = '']) =>
    db.collection(path).document().documentID;

Future<DocumentSnapshot> fetchDoc(String path) => db.document(path).get();
Future<QuerySnapshot> fetchCollection(String path) =>
    db.collection(path).getDocuments();

/// Gets the current user or signs in anonymously.
/// If `null` is returned, there was likely a network error.
Future<FirebaseUser> getUser() async =>
    (await auth.currentUser()) ?? auth.signInAnonymously();

/// Upgrade an anonymous account by linking it to a Google account.
Future<FirebaseUser> googleSignIn() async {
  final credential = await _getGoogleAuthCredential();
  if (credential != null) {
    try {
      return auth.signInWithCredential(credential);
    } catch (e) {
      print(e);
    }
  }
  return null;
}

/// Tries to sign-in silently first. May return `null`.
Future<AuthCredential> _getGoogleAuthCredential() async {
  GoogleSignInAccount account;
  try {
    account = await _googleAuthService.signInSilently() ??
        await _googleAuthService.signIn();
  } catch (e) {
    print(e);
  }
  final googleAuth = await account?.authentication;
  if (account == null) {
    print('Unable to retrieve Google account.');
  } else if (googleAuth == null) {
    print('Unable to authenticate to Google account (${account.email}).');
  } else {
    print(
        'accessToken: ${googleAuth.accessToken}, idToken: ${googleAuth.idToken}');
    return GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
  }
  return null;
}

Future<String> uploadImage() async {
  File image = await ImagePicker.pickImage(
      source: ImageSource.gallery, maxWidth: 600, maxHeight: 400);
  StorageReference reference = storage.ref().child("images/");
  StorageUploadTask uploadTask = reference.putFile(image);
  return await (await uploadTask.onComplete).ref.getDownloadURL();
}
