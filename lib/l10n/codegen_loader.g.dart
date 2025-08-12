// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> _tr = {
  "app": {
    "title": "FaceGate"
  },
  "common": {
    "ok": "Tamam",
    "cancel": "İptal",
    "save": "Kaydet",
    "search": "Ara",
    "search_by_email": "Email ile ara",
    "no_results": "Sonuç bulunamadı.",
    "unknown": "Bilinmeyen"
  },
  "auth": {
    "login": "Giriş",
    "logout": "Çıkış",
    "email": "E-posta",
    "password": "Şifre",
    "sign_in_error": "Giriş yapılamadı",
    "login_title": "Giriş Yap",
    "login_button": "Giriş Yap",
    "register_link": "Hesabın yok mu? Kayıt ol",
    "email_invalid": "Geçerli bir email girin",
    "password_min_chars": "En az 6 karakter girin",
    "register_title": "Kayıt Ol",
    "register_button": "Kayıt Ol",
    "login_link": "Zaten hesabın var mı? Giriş yap",
    "waiting_title": "Onay Bekleniyor",
    "waiting_message": "Başvurunuz admin onayı bekliyor"
  },
  "admin": {
    "panel_title": "Yönetici Paneli",
    "roles": {
      "operator": "Sunucu Odası Operatörü",
      "security": "Veri Güvenliği Uzmanı",
      "assign_role": "Rol Ata",
      "current_role": "Mevcut Rol: {role}",
      "assign_role_title": "Görev Atama",
      "assign_role_hint": "Görev ata",
      "not_assigned": "Atanmadı",
      "assigned_success": "Görev başarıyla atandı."
    }
  },
  "logs": {
    "title": "Giriş / Çıkış Kayıtları",
    "entry": "Giriş",
    "exit": "Çıkış",
    "empty": "Henüz kayıt yok",
    "count": "Toplam: {n}",
    "filter": "Filtrele",
    "close_filter": "Filtreyi Kapat",
    "search_by_email": "Email ile ara",
    "pick_date": "Tarih seç",
    "no_date_selected": "Tarih seçilmedi",
    "no_results": "Sonuç bulunamadı.",
    "unknown_email": "Bilinmeyen"
  },
  "personnel": {
    "list_title": "Onaylı Personel",
    "approve": "Onayla",
    "reject": "Reddet",
    "pending": "Onay Bekleyen Personeller",
    "pending_empty": "Onay bekleyen personel yok.",
    "approved_success": "Kullanıcı onaylandı.",
    "rejected_success": "Kullanıcı reddedildi.",
    "panel_title": "Personel Paneli",
    "home_welcome": "Girişiniz kaydedildi."
  },
  "errors": {
    "network": "Ağ hatası",
    "unknown": "Beklenmeyen hata"
  }
};
static const Map<String,dynamic> _en = {
  "app": {
    "title": "FaceGate"
  },
  "common": {
    "ok": "OK",
    "cancel": "Cancel",
    "save": "Save",
    "search": "Search",
    "search_by_email": "Search by email",
    "no_results": "No results found.",
    "unknown": "Unknown"
  },
  "auth": {
    "login": "Login",
    "logout": "Logout",
    "email": "Email",
    "password": "Password",
    "sign_in_error": "Could not sign in",
    "login_title": "Sign In",
    "login_button": "Sign In",
    "register_link": "Don't have an account? Register",
    "email_invalid": "Enter a valid email",
    "password_min_chars": "Enter at least 6 characters",
    "register_title": "Register",
    "register_button": "Register",
    "login_link": "Already have an account? Sign in",
    "waiting_title": "Pending Approval",
    "waiting_message": "Your application is awaiting admin approval"
  },
  "admin": {
    "panel_title": "Admin Panel",
    "roles": {
      "operator": "Server Room Operator",
      "security": "Data Security Specialist",
      "assign_role": "Assign Role",
      "current_role": "Current Role: {role}",
      "assign_role_title": "Assign Role",
      "assign_role_hint": "Assign role",
      "not_assigned": "Not assigned",
      "assigned_success": "Role assigned successfully."
    }
  },
  "logs": {
    "title": "Access Logs",
    "entry": "Entry",
    "exit": "Exit",
    "empty": "No logs yet",
    "count": "Total: {n}",
    "filter": "Filter",
    "close_filter": "Close Filter",
    "search_by_email": "Search by email",
    "pick_date": "Pick a date",
    "no_date_selected": "No date selected",
    "no_results": "No results found.",
    "unknown_email": "Unknown"
  },
  "personnel": {
    "list_title": "Approved Personnel",
    "approve": "Approve",
    "reject": "Reject",
    "pending": "Pending Approvals",
    "pending_empty": "No personnel awaiting approval.",
    "approved_success": "User approved.",
    "rejected_success": "User rejected.",
    "panel_title": "Personnel Panel",
    "home_welcome": "Your entry has been logged."
  },
  "errors": {
    "network": "Network error",
    "unknown": "Unexpected error"
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"tr": _tr, "en": _en};
}
