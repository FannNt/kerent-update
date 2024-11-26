import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Rx<User?> user = Rx<User?>(null);
  
  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }
  User? get currentUser => _auth.currentUser;
  String? get userName => currentUser?.displayName;

  String? get userEmail => currentUser?.email;

  String? get userPhotoUrl => currentUser?.photoURL;
    
     Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign in with Google: $e',
      );
    }
  }
  Future<void> saveUserData(User user) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    
    await userDoc.set({
      'email': user.email,
      'username': user.displayName ?? 'New User',
      'phoneNumber': user.phoneNumber ?? 0,
      'lastSignInTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'isEmailVerified': user.emailVerified,
      'profileImageUrl': user.photoURL,
    }, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
