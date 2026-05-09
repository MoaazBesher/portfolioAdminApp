import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/app_models.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // Admin verification
      if (userCredential.user?.email != 'mo3azbe4er@gmail.com') {
        await signOut();
        throw Exception('Unauthorized user. Admin access required.');
      }
      
      return userCredential;
    } catch (e) {
      print('Auth Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Generic fetch
  Future<Map<dynamic, dynamic>?> _fetchData(String path) async {
    final snapshot = await _db.child(path).get();
    return snapshot.value as Map<dynamic, dynamic>?;
  }

  Future<AppProfile> getProfile() async {
    final data = await _fetchData('profile');
    return data != null ? AppProfile.fromMap(data) : AppProfile();
  }

  Future<AppSettings> getSettings() async {
    final data = await _fetchData('settings');
    return data != null ? AppSettings.fromMap(data) : AppSettings();
  }

  Future<int> getProfileViews() async {
    final snapshot = await _db.child('profileViews').get();
    return (snapshot.value as int?) ?? 0;
  }

  // Get generic lists
  List<T> _mapToList<T>(Map<dynamic, dynamic>? data, T Function(String key, Map<dynamic, dynamic> val) fromMap) {
    if (data == null) return [];
    return data.entries.map((e) => fromMap(e.key.toString(), e.value as Map<dynamic, dynamic>)).toList();
  }

  Future<List<Project>> getProjects() async => _mapToList(await _fetchData('projects'), Project.fromMap);
  Future<List<Certificate>> getCertificates() async => _mapToList(await _fetchData('certificates'), Certificate.fromMap);
  Future<List<Education>> getEducation() async => _mapToList(await _fetchData('education'), Education.fromMap);
  Future<List<Experience>> getExperience() async => _mapToList(await _fetchData('experience'), Experience.fromMap);
  Future<List<Achievement>> getAchievements() async => _mapToList(await _fetchData('achievements'), Achievement.fromMap);
  Future<List<AppMessage>> getMessages() async => _mapToList(await _fetchData('messages'), AppMessage.fromMap);

  Future<Map<String, Map<String, int>>> getSkills() async {
    final data = await _fetchData('skills');
    if (data == null) return {'technical': {}, 'soft': {}};
    Map<String, Map<String, int>> result = {'technical': {}, 'soft': {}};
    
    if (data['technical'] != null) {
      (data['technical'] as Map).forEach((k, v) => result['technical']![k.toString()] = int.parse(v.toString()));
    }
    if (data['soft'] != null) {
      (data['soft'] as Map).forEach((k, v) => result['soft']![k.toString()] = int.parse(v.toString()));
    }
    return result;
  }

  // Updates
  Future<void> updateMessageRead(String id, bool read) async {
    await _db.child('messages/$id').update({'read': read});
  }
  
  Future<void> toggleMessagePriority(String id, bool priority) async {
    await _db.child('messages/$id').update({'priority': priority});
  }

  Future<void> deleteMessage(String id) async {
    await _db.child('messages/$id').remove();
  }

  Stream<DatabaseEvent> watchMessages() {
    return _db.child('messages').onValue;
  }

  // --- New CRUD Operations ---

  Future<void> updateProfile(AppProfile profile) async => await _db.child('profile').set(profile.toMap());
  
  Future<void> updateSettings(AppSettings settings) async => await _db.child('settings').set(settings.toMap());
  
  Future<void> updateSkills(Map<String, Map<String, int>> skills) async => await _db.child('skills').set(skills);

  Future<void> addProject(Project p) async => _db.child('projects/${p.id}').set(p.toMap());
  Future<void> updateProject(Project p) async => _db.child('projects/${p.id}').update(p.toMap());
  Future<void> deleteProject(String id) async => _db.child('projects/$id').remove();

  Future<void> addExperience(Experience e) async => _db.child('experience/${e.id}').set(e.toMap());
  Future<void> updateExperience(Experience e) async => _db.child('experience/${e.id}').update(e.toMap());
  Future<void> deleteExperience(String id) async => _db.child('experience/$id').remove();

  Future<void> addEducation(Education ed) async => _db.child('education/${ed.id}').set(ed.toMap());
  Future<void> updateEducation(Education ed) async => _db.child('education/${ed.id}').update(ed.toMap());
  Future<void> deleteEducation(String id) async => _db.child('education/$id').remove();

  Future<void> addCertificate(Certificate c) async => _db.child('certificates/${c.id}').set(c.toMap());
  Future<void> updateCertificate(Certificate c) async => _db.child('certificates/${c.id}').update(c.toMap());
  Future<void> deleteCertificate(String id) async => _db.child('certificates/$id').remove();

  Future<void> addAchievement(Achievement a) async => _db.child('achievements/${a.id}').set(a.toMap());
  Future<void> updateAchievement(Achievement a) async => _db.child('achievements/${a.id}').update(a.toMap());
  Future<void> deleteAchievement(String id) async => _db.child('achievements/$id').remove();

  // --- Firebase Storage Uploads ---

  /// Core upload: uses putData(bytes) to avoid Scoped Storage issues on Android.
  Future<String> _uploadBytes(
    Uint8List bytes,
    String storagePath,
    SettableMetadata metadata, {
    void Function(double progress)? onProgress,
  }) async {
    final ref = FirebaseStorage.instance.ref(storagePath);
    final task = ref.putData(bytes, metadata);

    if (onProgress != null) {
      task.snapshotEvents.listen((snap) {
        if (snap.totalBytes > 0) {
          onProgress(snap.bytesTransferred / snap.totalBytes);
        }
      });
    }

    await task;
    return await ref.getDownloadURL();
  }

  /// Uploads the profile image (XFile from image_picker) and saves URL to DB.
  Future<String> uploadProfileImage(
    XFile imageFile, {
    void Function(double)? onProgress,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final url = await _uploadBytes(
      bytes,
      'profile/profile_image.jpg',
      SettableMetadata(contentType: 'image/jpeg'),
      onProgress: onProgress,
    );
    await _db.child('profile/coverImage').set(url);
    return url;
  }

  /// Uploads the CV/Resume (PlatformFile from file_picker) and saves URL to DB.
  Future<String> uploadResumePDF(
    PlatformFile platformFile, {
    void Function(double)? onProgress,
  }) async {
    final bytes = platformFile.bytes ?? await platformFile.xFile.readAsBytes();
    final url = await _uploadBytes(
      bytes,
      'profile/resume.pdf',
      SettableMetadata(contentType: 'application/pdf'),
      onProgress: onProgress,
    );
    await _db.child('profile/resume').set(url);
    return url;
  }

  /// Uploads a Certificate PDF and returns the URL.
  Future<String> uploadCertificatePDF(
    PlatformFile platformFile,
    String certId, {
    void Function(double)? onProgress,
  }) async {
    final bytes = platformFile.bytes ?? await platformFile.xFile.readAsBytes();
    final url = await _uploadBytes(
      bytes,
      'certificates/$certId.pdf',
      SettableMetadata(contentType: 'application/pdf'),
      onProgress: onProgress,
    );
    return url;
  }
}
