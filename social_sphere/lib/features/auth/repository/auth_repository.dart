import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/failure.dart';
import 'package:social_sphere/core/providers/firebase_providers.dart';
import 'package:social_sphere/core/type_defs.dart';
import 'package:social_sphere/models/user_model.dart';
import 'package:social_sphere/core/constants/constants.dart';
import 'package:social_sphere/core/constants/firebase_constants.dart';
import 'package:flutter/foundation.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider),
  ),
);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  }) : _auth = auth,
       _firestore = firestore,
       _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  // FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
  //   try {
  //     UserCredential userCredential;

  //     if (kIsWeb) {
  //       GoogleAuthProvider googleProvider = GoogleAuthProvider();
  //       googleProvider.addScope(
  //         'https://www.googleapis.com/auth/contacts.readonly',
  //       );
  //       userCredential = await _auth.signInWithPopup(googleProvider);
  //     } else {
  //       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

  //       final googleAuth = await googleUser?.authentication;

  //       final credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth?.accessToken,
  //         idToken: googleAuth?.idToken,
  //       );

  //       if (isFromLogin) {
  //         userCredential = await _auth.signInWithCredential(credential);
  //       } else {
  //         userCredential = await _auth.currentUser!.linkWithCredential(
  //           credential,
  //         );
  //       }
  //     }

  //     UserModel userModel;
  //     final uid = userCredential.user!.uid;
  //     final name = userCredential.user!.displayName ?? 'No Name';
  //     final profilePic =
  //         userCredential.user!.photoURL ?? Constants.avatarDefault;

  //     final userDoc = await _users.doc(uid).get();

  //     if (!userDoc.exists) {
  //       // User document does not exist, create it
  //       userModel = UserModel(
  //         name: name,
  //         profilePic: profilePic,
  //         banner: Constants.bannerDefault,
  //         uid: uid,
  //         isAuthenticated: true,
  //         karma: 0,
  //         awards: [
  //           'awesomeAns',
  //           'gold',
  //           'platinum',
  //           'helpful',
  //           'plusone',
  //           'rocket',
  //           'thankyou',
  //           'til',
  //         ],
  //       );

  //       await _users.doc(uid).set(userModel.toMap());
  //     } else {
  //       // User exists, fetch from Firestore
  //       userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
  //     }

  //     return right(userModel);
  //   } on FirebaseException catch (e) {
  //     throw e.message!;
  //   } catch (e) {
  //     return left(Failure(e.toString()));
  //   }
  // }

  //   FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
  //   try {
  //     UserCredential userCredential;

  //     if (kIsWeb) {
  //       GoogleAuthProvider googleProvider = GoogleAuthProvider();
  //       googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
  //       userCredential = await _auth.signInWithPopup(googleProvider);
  //     } else {
  //       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //       final googleAuth = await googleUser?.authentication;

  //       final credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth?.accessToken,
  //         idToken: googleAuth?.idToken,
  //       );

  //       if (isFromLogin) {
  //         userCredential = await _auth.signInWithCredential(credential);
  //       } else {
  //         userCredential = await _auth.currentUser!.linkWithCredential(credential);
  //       }
  //     }

  //     final uid = userCredential.user!.uid;
  //     final fullName = userCredential.user!.displayName ?? 'No Name';
  //     final email = userCredential.user!.email ?? '';
  //     final profilePic = userCredential.user!.photoURL ?? Constants.avatarDefault;

  //     // Get first name only
  //     final firstName = fullName.split(' ').first;

  //     // Generate unique username
  //     final randomNumber = DateTime.now().millisecondsSinceEpoch.remainder(10000); // e.g., 4821
  //     //final username = '${firstName.toLowerCase()}$randomNumber';

  //     final userDoc = await _users.doc(uid).get();

  //     UserModel userModel;
  //     if (!userDoc.exists) {
  //       String username = await _generateUniqueUsername(firstName);
  //       username=username.toLowerCase();
  //       userModel = UserModel(
  //         name: firstName,
  //         username: username,
  //         email: email,
  //         profilePic: profilePic,
  //         banner: Constants.bannerDefault,
  //         uid: uid,
  //         isAuthenticated: true,
  //         karma: 0,
  //         awards: [
  //           'awesomeAns',
  //           'gold',
  //           'platinum',
  //           'helpful',
  //           'plusone',
  //           'rocket',
  //           'thankyou',
  //           'til',
  //         ],
  //       );

  //       await _users.doc(uid).set(userModel.toMap());
  //     } else {
  //       userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
  //     }

  //     return right(userModel);
  //   } on FirebaseException catch (e) {
  //     throw e.message!;
  //   } catch (e) {
  //     return left(Failure(e.toString()));
  //   }
  // }

  // FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
  //   late final String email;
  //   try {
  //     UserCredential userCredential;

  //     if (kIsWeb) {
  //       GoogleAuthProvider googleProvider = GoogleAuthProvider();
  //       googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
  //       userCredential = await _auth.signInWithPopup(googleProvider);
  //     } else {
  //       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //       email = googleUser?.email ?? '';
  //       if (!email.endsWith('1034@gmail.com')) {
  //       // Sign out to prevent keeping invalid session
  //       await _auth.signOut();
  //       await _googleSignIn.signOut();
  //       return  left(Failure('Only company emails (@company.pk) are allowed.'));
  //     }

  //       final googleAuth = await googleUser?.authentication;

  //       final credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth?.accessToken,
  //         idToken: googleAuth?.idToken,
  //       );

  //       if (isFromLogin) {
  //         userCredential = await _auth.signInWithCredential(credential);
  //       } else {
  //         userCredential = await _auth.currentUser!.linkWithCredential(credential);
  //       }
  //     }

  //     // Get and check email
  //     // final email = userCredential.user?.email ?? '';
  //     // if (!email.endsWith('1034@gmail.com')) {
  //     //   // Sign out to prevent keeping invalid session
  //     //   await _auth.signOut();
  //     //   await _googleSignIn.signOut();
  //     //   return  left(Failure('Only company emails (@company.pk) are allowed.'));
  //     // }

  //     // Proceed only if email is valid
  //     final uid = userCredential.user!.uid;
  //     final fullName = userCredential.user!.displayName ?? 'No Name';
  //     final profilePic = userCredential.user!.photoURL ?? Constants.avatarDefault;
  //     final firstName = fullName.split(' ').first;

  //     final userDoc = await _users.doc(uid).get();

  //     UserModel userModel;
  //     if (!userDoc.exists) {
  //       String username = await _generateUniqueUsername(firstName);
  //       username = username.toLowerCase();

  //       userModel = UserModel(
  //         name: firstName,
  //         username: username,
  //         email: email,
  //         profilePic: profilePic,
  //         banner: Constants.bannerDefault,
  //         uid: uid,
  //         isAuthenticated: true,
  //         karma: 0,
  //         awards: [
  //           'awesomeAns',
  //           'gold',
  //           'platinum',
  //           'helpful',
  //           'plusone',
  //           'rocket',
  //           'thankyou',
  //           'til',
  //         ],
  //       );

  //       await _users.doc(uid).set(userModel.toMap());
  //     } else {
  //       userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
  //     }

  //     return right(userModel);
  //   } on FirebaseException catch (e) {
  //     throw e.message!;
  //   } catch (e) {
  //     return left(Failure(e.toString()));
  //   }
  // }

  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    late final String email;
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope(
          'https://www.googleapis.com/auth/contacts.readonly',
        );
        userCredential = await _auth.signInWithPopup(googleProvider);

        // Safely get email
        email = userCredential.user?.email ?? '';
        if (!email.endsWith('@gmail.com')) {
          await _auth.signOut();
          return left(
            Failure('Only company emails (@company.pk) are allowed.'),
          );
        }
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          return left(Failure('Google Sign-In aborted by user.'));
        }

        email = googleUser.email;

        if (!email.endsWith('@gmail.com')) {
          await _auth.signOut();
          await _googleSignIn.signOut();
          return left(
            Failure('Only company emails (@company.pk) are allowed.'),
          );
        }

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        if (isFromLogin) {
          userCredential = await _auth.signInWithCredential(credential);
        } else {
          final currentUser = _auth.currentUser;
          if (currentUser == null) {
            return left(Failure('No current user to link credentials.'));
          }
          userCredential = await currentUser.linkWithCredential(credential);
        }
      }

      final user = userCredential.user;
      if (user == null) {
        return left(Failure('Google sign-in failed. No user found.'));
      }

      final uid = user.uid;
      final fullName = user.displayName ?? 'No Name';
      final profilePic = user.photoURL ?? Constants.avatarDefault;
      final firstName = fullName.split(' ').first;

      final userDoc = await _users.doc(uid).get();

      UserModel userModel;

      if (!userDoc.exists) {
        String username = await _generateUniqueUsername(firstName);
        username = username.toLowerCase();

        userModel = UserModel(
          name: firstName,
          username: username,
          email: email,
          profilePic: profilePic,
          banner: Constants.bannerDefault,
          uid: uid,
          isAuthenticated: true,
          karma: 0,
          awards: [
            'awesomeAns',
            'gold',
            'platinum',
            'helpful',
            'plusone',
            'rocket',
            'thankyou',
            'til',
          ],
        );

        await _users.doc(uid).set(userModel.toMap());
      } else {
        userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }

      return right(userModel);
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? 'Firebase error occurred.'));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<String> _generateUniqueUsername(String baseName) async {
    String username;
    bool isUnique = false;

    do {
      final randomDigits =
          (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
      username = '$baseName$randomDigits';

      final querySnapshot =
          await _users.where('name', isEqualTo: username).get();

      if (querySnapshot.docs.isEmpty) {
        isUnique = true;
      }
    } while (!isUnique);

    return username;
  }

  FutureEither<UserModel> signInAsGuest() async {
    try {
      var userCredential = await _auth.signInAnonymously();

      UserModel userModel = UserModel(
        name: 'Guest',
        username: 'Guest',
        email: '',
        profilePic: Constants.avatarDefault,
        banner: Constants.bannerDefault,
        uid: userCredential.user!.uid,
        isAuthenticated: false,
        karma: 0,
        awards: [],
      );

      await _users.doc(userCredential.user!.uid).set(userModel.toMap());

      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Stream<UserModel> getUserData(String uid) {
  //   return _users
  //       .doc(uid)
  //       .snapshots()
  //       .map(
  //         (event) => UserModel.fromMap(event.data() as Map<String, dynamic>),
  //       );
  // }

  //   Stream<UserModel> getUserData(String uid) {
  //   return _users.doc(uid).snapshots().map((event) {
  //     final data = event.data();
  //     if (data == null) {
  //       // Handle the null case gracefully
  //       throw Exception('User data not found for UID: $uid');
  //     }
  //     return UserModel.fromMap(data as Map<String, dynamic>);
  //   });
  // }

  // Stream<UserModel> getUserData(String uid) async* {
  //   final docRef = _users.doc(uid);

  //   final snapshot = await docRef.get();

  //   if (!snapshot.exists) {
  //     // Try to fetch the current Firebase user
  //     final user = _auth.currentUser;
  //     if (user == null) {
  //       throw Exception('No authenticated user found');
  //     }

  //     // Create new userModel using user info
  //     final fullName = user.displayName ?? 'No Name';
  //     final firstName = fullName.split(' ').first;
  //     final email = user.email ?? '';
  //     final profilePic = user.photoURL ?? Constants.avatarDefault;

  //     final userModel = UserModel(
  //       name: firstName,
  //       username: await _generateUniqueUsername(firstName),
  //       email: email,
  //       profilePic: profilePic,
  //       banner: Constants.bannerDefault,
  //       uid: uid,
  //       isAuthenticated: !user.isAnonymous,
  //       karma: 0,
  //       awards: [
  //         'awesomeAns',
  //         'gold',
  //         'platinum',
  //         'helpful',
  //         'plusone',
  //         'rocket',
  //         'thankyou',
  //         'til',
  //       ],
  //     );

  //     await docRef.set(userModel.toMap());
  //     yield userModel;
  //   } else {
  //     yield* docRef.snapshots().map((event) {
  //       final data = event.data();
  //       return UserModel.fromMap(data as Map<String, dynamic>);
  //     });
  //   }
  // }

  Stream<UserModel> getUserData(String uid) {
    if (_auth.currentUser == null) {
      throw Exception('No authenticated user found');
    }

    return _users.doc(uid).snapshots().map((event) {
      final data = event.data();
      if (data == null) {
        throw Exception('User data not found for UID: $uid');
      }
      return UserModel.fromMap(data as Map<String, dynamic>);
    });
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
