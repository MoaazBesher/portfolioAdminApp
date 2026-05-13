class AppProfile {
  final String name, title, bio, greeting, email, phone, whatsapp, linkedin, coverImage, resume;

  AppProfile({
    this.name = '', this.title = '', this.bio = '', this.greeting = '',
    this.email = '', this.phone = '', this.whatsapp = '', this.linkedin = '',
    this.coverImage = '', this.resume = '',
  });

  factory AppProfile.fromMap(Map<dynamic, dynamic> map) {
    return AppProfile(
      name: map['name'] ?? '',
      title: map['title'] ?? '',
      bio: map['bio'] ?? '',
      greeting: map['greeting'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      linkedin: map['linkedin'] ?? '',
      coverImage: map['coverImage'] ?? '',
      resume: map['resume'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name, 'title': title, 'bio': bio, 'greeting': greeting,
    'email': email, 'phone': phone, 'whatsapp': whatsapp, 'linkedin': linkedin,
    'coverImage': coverImage, 'resume': resume,
  };
}

class Project {
  final String id, title, description, category, link, date;
  final bool featured;
  final List<String> tech;

  Project({
    required this.id, this.title = '', this.description = '',
    this.category = 'web', this.link = '', this.date = '',
    this.featured = false, this.tech = const [],
  });

  factory Project.fromMap(String id, Map<dynamic, dynamic> map) {
    return Project(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'web',
      link: map['link'] ?? '',
      date: map['date'] ?? '',
      featured: map['featured'] ?? false,
      tech: List<String>.from(map['tech'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title, 'description': description, 'category': category,
    'link': link, 'date': date, 'featured': featured, 'tech': tech,
  };
}

class Certificate {
  final String id, title, issuer, date, category, pdfUrl, description;
  Certificate({
    required this.id, this.title = '', this.issuer = '', this.date = '',
    this.category = 'professional', this.pdfUrl = '', this.description = '',
  });
  factory Certificate.fromMap(String id, Map<dynamic, dynamic> map) => Certificate(
    id: id, title: map['title'] ?? '', issuer: map['issuer'] ?? '',
    date: map['date'] ?? '', category: map['category'] ?? 'professional',
    pdfUrl: map['pdfUrl'] ?? '', description: map['description'] ?? '',
  );
  Map<String, dynamic> toMap() => {
    'title': title, 'issuer': issuer, 'date': date, 'category': category,
    'pdfUrl': pdfUrl, 'description': description,
  };
}

class Education {
  final String id, institution, degree, date, icon;
  final List<String> details;
  Education({
    required this.id, this.institution = '', this.degree = '',
    this.date = '', this.icon = 'graduation-cap', this.details = const [],
  });
  factory Education.fromMap(String id, Map<dynamic, dynamic> map) => Education(
    id: id, institution: map['institution'] ?? '', degree: map['degree'] ?? '',
    date: map['date'] ?? '', icon: map['icon'] ?? 'graduation-cap',
    details: List<String>.from(map['details'] ?? []),
  );
  Map<String, dynamic> toMap() => {
    'institution': institution, 'degree': degree, 'date': date,
    'icon': icon, 'details': details,
  };
}

class Experience {
  final String id, title, company, period, icon, description;
  Experience({
    required this.id, this.title = '', this.company = '', this.period = '',
    this.icon = 'briefcase', this.description = '',
  });
  factory Experience.fromMap(String id, Map<dynamic, dynamic> map) => Experience(
    id: id, title: map['title'] ?? '', company: map['company'] ?? '',
    period: map['period'] ?? '', icon: map['icon'] ?? 'briefcase',
    description: map['description'] ?? '',
  );
  Map<String, dynamic> toMap() => {
    'title': title, 'company': company, 'period': period,
    'icon': icon, 'description': description,
  };
}

class Achievement {
  final String id, text, icon, date;
  Achievement({
    required this.id, this.text = '', this.icon = 'trophy', this.date = '',
  });
  factory Achievement.fromMap(String id, Map<dynamic, dynamic> map) => Achievement(
    id: id, text: map['text'] ?? '', icon: map['icon'] ?? 'trophy', date: map['date'] ?? '',
  );
  Map<String, dynamic> toMap() => { 'text': text, 'icon': icon, 'date': date };
}

class AppMessage {
  final String id, name, email, subject, message, timestamp;
  final bool read, priority;
  
  AppMessage({
    required this.id, this.name = '', this.email = '', this.subject = '',
    this.message = '', this.timestamp = '', this.read = false, this.priority = false,
  });

  factory AppMessage.fromMap(String id, Map<dynamic, dynamic> map) => AppMessage(
    id: id, name: map['name'] ?? '', email: map['email'] ?? '',
    subject: map['subject'] ?? '', message: map['message'] ?? '',
    timestamp: map['timestamp'] ?? '',
    read: map['read'] ?? false, priority: map['priority'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'name': name, 'email': email, 'subject': subject, 'message': message,
    'timestamp': timestamp, 'read': read, 'priority': priority,
  };
}

class Skill {
  final String name;
  final int value;

  Skill({this.name = '', this.value = 0});

  factory Skill.fromMap(Map<dynamic, dynamic> map) => Skill(
    name: map['name'] ?? '',
    value: int.tryParse(map['value']?.toString() ?? '') ?? 0,
  );

  Map<String, dynamic> toMap() => {'name': name, 'value': value};
}

class AppSettings {
  final String siteTitle, defaultTheme, theme, profileViewsUrl;
  final int itemsPerPage;
  final List<String> featuredProjects;

  AppSettings({
    this.siteTitle = 'Portfolio Admin', this.defaultTheme = 'dark',
    this.theme = 'dark', this.itemsPerPage = 6, this.featuredProjects = const [],
    this.profileViewsUrl = '',
  });

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) => AppSettings(
    siteTitle: map['siteTitle'] ?? 'Portfolio Admin',
    defaultTheme: map['defaultTheme'] ?? 'dark',
    theme: map['theme'] ?? 'dark',
    itemsPerPage: map['itemsPerPage'] ?? 6,
    featuredProjects: List<String>.from(map['featuredProjects'] ?? []),
    profileViewsUrl: map['profileViewsUrl'] ?? 'https://console.firebase.google.com/',
  );

  Map<String, dynamic> toMap() => {
    'siteTitle': siteTitle, 'defaultTheme': defaultTheme, 'theme': theme,
    'itemsPerPage': itemsPerPage, 'featuredProjects': featuredProjects,
    'profileViewsUrl': profileViewsUrl,
  };
}
