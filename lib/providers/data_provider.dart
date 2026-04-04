import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/firebase_service.dart';

class DataProvider with ChangeNotifier {
  final FirebaseService _service = FirebaseService();
  
  bool isLoading = false;
  
  AppProfile profile = AppProfile();
  AppSettings settings = AppSettings();
  int profileViews = 0;
  
  List<Project> projects = [];
  List<Certificate> certificates = [];
  List<Education> education = [];
  List<Experience> experience = [];
  List<Achievement> achievements = [];
  List<AppMessage> messages = [];
  Map<String, Map<String, int>> skills = {'technical': {}, 'soft': {}};

  int get unreadMessagesCount => messages.where((m) => !m.read).length;

  Future<void> loadAllData() async {
    isLoading = true;
    notifyListeners();

    try {
      profile = await _service.getProfile();
      settings = await _service.getSettings();
      profileViews = await _service.getProfileViews();
      
      projects = await _service.getProjects();
      certificates = await _service.getCertificates();
      education = await _service.getEducation();
      experience = await _service.getExperience();
      achievements = await _service.getAchievements();
      skills = await _service.getSkills();
      
      // Load initial messages
      messages = await _service.getMessages();
      _sortMessages();
      
      // Watch for future messages
      _service.watchMessages().listen((event) {
        if (event.snapshot.value == null) {
          messages = [];
        } else {
          final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
          messages = data.entries.map((e) => AppMessage.fromMap(e.key.toString(), e.value as Map)).toList();
        }
        _sortMessages();
        notifyListeners();
      });

    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _sortMessages() {
    messages.sort((a, b) {
      if (a.priority && !b.priority) return -1;
      if (!a.priority && b.priority) return 1;
      final da = DateTime.tryParse(a.timestamp) ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db = DateTime.tryParse(b.timestamp) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return db.compareTo(da);
    });
  }

  Future<void> deleteMessage(String id) async {
    await _service.deleteMessage(id);
  }

  Future<void> toggleMessageRead(String id, bool currentRead) async {
    await _service.updateMessageRead(id, !currentRead);
  }

  Future<void> toggleMessagePriority(String id, bool currentPri) async {
    await _service.toggleMessagePriority(id, !currentPri);
  }

  // --- CRUD Wrappers ---
  
  Future<void> updateProfile(AppProfile newProfile) async {
    await _service.updateProfile(newProfile);
    profile = newProfile;
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    await _service.updateSettings(newSettings);
    settings = newSettings;
    notifyListeners();
  }

  Future<void> updateSkills(Map<String, Map<String, int>> newSkills) async {
    await _service.updateSkills(newSkills);
    skills = newSkills;
    notifyListeners();
  }

  // Generic helper to update lists in memory
  void _updateList<T>(List<T> list, T item, String itemId, String Function(T) getId) {
    int index = list.indexWhere((element) => getId(element) == itemId);
    if (index >= 0) {
      list[index] = item;
    } else {
      list.add(item);
    }
  }

  Future<void> saveProject(Project p) async {
    p.id.isEmpty ? await _service.addProject(p) : await _service.updateProject(p);
    _updateList(projects, p, p.id, (i) => i.id);
    notifyListeners();
  }
  Future<void> deleteProject(String id) async {
    await _service.deleteProject(id);
    projects.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Future<void> saveExperience(Experience e) async {
    e.id.isEmpty ? await _service.addExperience(e) : await _service.updateExperience(e);
    _updateList(experience, e, e.id, (i) => i.id);
    notifyListeners();
  }
  Future<void> deleteExperience(String id) async {
    await _service.deleteExperience(id);
    experience.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> saveEducation(Education e) async {
    e.id.isEmpty ? await _service.addEducation(e) : await _service.updateEducation(e);
    _updateList(education, e, e.id, (i) => i.id);
    notifyListeners();
  }
  Future<void> deleteEducation(String id) async {
    await _service.deleteEducation(id);
    education.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> saveCertificate(Certificate c) async {
    c.id.isEmpty ? await _service.addCertificate(c) : await _service.updateCertificate(c);
    _updateList(certificates, c, c.id, (i) => i.id);
    notifyListeners();
  }
  Future<void> deleteCertificate(String id) async {
    await _service.deleteCertificate(id);
    certificates.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> saveAchievement(Achievement a) async {
    a.id.isEmpty ? await _service.addAchievement(a) : await _service.updateAchievement(a);
    _updateList(achievements, a, a.id, (i) => i.id);
    notifyListeners();
  }
  Future<void> deleteAchievement(String id) async {
    await _service.deleteAchievement(id);
    achievements.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}
