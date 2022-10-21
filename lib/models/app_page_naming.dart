import '../services/app_page.dart';

class PageName {
  PageName._();

  factory PageName() => PageName._();

  static String dashboard = 'Dashboard Page';
  static String profile = "Profile Page";
  static String categories = "Categories Page";
  static String cashInflowProjection = "Cash Inflow Projection Page";
  static String cashOutflowProjection = "Cash Outflow Projection Page";
  static String account = "Account Page";
  static String report = "Report Page";
  static String setting = "Setting Page";
  static String addCashIn = "Add Cash In Transaction Page";
  static String addCashOut = "Add Cash Out Transaction Page";
  static String createProfile = "Create Profile Page";
  static String backupPage = "Backup Page";
  static List<dynamic>? pages;

  init(List<dynamic> _pages) {
    pages = _pages;
  }
}
