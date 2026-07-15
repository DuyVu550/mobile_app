import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Bọc FirebaseAuth. Trả thẳng User của Firebase / ném FirebaseAuthException
/// để tầng repository map sang thông điệp lỗi.
class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSource(this._firebaseAuth);

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(displayName);
    await user.reload();

    final role = email.toLowerCase().contains('admin') ? 'admin' : 'user';
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': email,
      'displayName': displayName,
      'role': role,
    });

    return _firebaseAuth.currentUser ?? user;
  }

  Future<void> signOut() => _firebaseAuth.signOut();

  Future<void> sendPasswordReset({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Chưa đăng nhập.',
      );
    }
    // Xác thực lại trước khi đổi mật khẩu (Firebase yêu cầu phiên gần đây).
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<User> updateProfile({
    required String displayName,
    required String photoUrl,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Chưa đăng nhập.',
      );
    }
    await user.updateDisplayName(displayName);
    
    // Chỉ cập nhật photoURL của Firebase Auth nếu đó là URL thông thường (không phải base64)
    if (photoUrl.isNotEmpty && !photoUrl.startsWith('data:')) {
      await user.updatePhotoURL(photoUrl);
    } else if (photoUrl.isEmpty) {
      await user.updatePhotoURL(null);
    }
    
    await user.reload();

    // Đồng bộ thông tin lên Firestore users collection (luôn lưu đầy đủ)
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'displayName': displayName,
      'photoUrl': photoUrl.trim().isEmpty ? null : photoUrl,
    });

    return _firebaseAuth.currentUser ?? user;
  }
}
