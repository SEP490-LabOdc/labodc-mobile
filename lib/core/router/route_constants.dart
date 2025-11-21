class Routes {
  // Route paths
  static const String splash = '/';
  // static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String user = '/user';
  static const String admin = '/admin';
  static const String talent = '/talent';
  static const String mentor = '/mentor';
  static const String company = '/company';
  static const String postDetail = '/post/:id';
  static const String setting = '/setting';
  static const String labAdmin = '/lab-admin';

  // Route names
  static const String splashName = 'splash';
  // static const String homeName = 'home';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String userName = 'user';
  static const String adminName = 'admin';
  static const String talentName = 'talent';
  static const String mentorName = 'mentor';
  static const String companyName = '/company';
  static const String postDetailName = 'post-detail';
  static const String settingName = 'setting';
  static const String labAdminName = 'lab-admin';

  // Public routes (không cần authentication)
  static const List<String> publicRoutes = [
    splash,
    // home,
    login,
    register,
  ];
}