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
  static const String projectDetail = '/projects/:id';
  static const String myProjectDetail = '/my-projects/:id';

  static const String milestoneDetail = '/milestoneDetail/:id';

  static const String projectFund = '/project-fund';

  static const String setting = '/setting';
  static const String labAdmin = '/lab-admin';
  static const String uploadCv = '/upload-cv';
  static const String editProfile = '/edit-profile';
  static const String notifications = '/notifications';


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
  static const String projectDetailName = 'project-detail';
  static const String myProjectDetailName = 'my-project-detail';
  static const String settingName = 'setting';
  static const String labAdminName = 'lab-admin';
  static const String uploadCvName = 'upload-cv';
  static const String editProfileName = 'edit-profile';
  static const String notificationsName = 'notifications';

  static const String milestoneDetailName = 'milestone-detail';

  static const String projectFundName = 'project-fund';


  // Public routes (không cần authentication)
  static const List<String> publicRoutes = [
    splash,
    // home,
    login,
    register,
  ];
}