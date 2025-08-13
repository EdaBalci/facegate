import 'package:facegate/utils/helpers.dart';
import 'package:facegate/widgets/translate_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:facegate/l10n/locale_keys.g.dart';

// Eğer kullanıcı AuthBloc üzerinden AuthSuccess("admin") durumu ile giriş yaptıysa
// GoRouter bu sayfaya yönlendirir

//Screen Utils için:
//Yatay şeyler → .w
//Dikey şeyler → .h 
//Yazı → .sp (Font boyutu)
//Kare/çember/ikon/radius → .r (Kare ölçüler, radius, ikon)

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.admin_panel_title.tr(),
        style: TextStyle(fontSize: 18.sp),
        ),
        actions: [
          TextButton(
          onPressed: () => throw Exception(),
          child: Text("Throw Test Exception",
          style: TextStyle(fontSize: 12.sp),),
      ),
          // Dil değiştirme
       translate(context),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => signOutUser(context),
          ),
        ],
      ),
      body: Padding(
        padding:  EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // butonları sola hizalamak için
          children: [
 24.verticalSpace,

            // Kayıt listesi
            ElevatedButton.icon(
              onPressed: () => context.push('/admin/logs'),
              icon:  Icon(Icons.list, size: 20.r,),
              label: Text(LocaleKeys.logs_title.tr(),
              style: TextStyle(fontSize: 16.sp),),
              style: ElevatedButton.styleFrom(//buton stillerini değiştirmek için
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h), //butonun iç boşluğu için
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),

             SizedBox(height: 16.h),

            // Onay bekleyenler
            ElevatedButton.icon(
              onPressed: () => context.push('/admin/approval'),
              icon: const Icon(Icons.pending_actions),
              label: Text(LocaleKeys.personnel_pending.tr(), //tr runtimeda çalışıyor const koyamazsın
              style: TextStyle(fontSize: 16.sp),),
              style: ElevatedButton.styleFrom(//buton stillerini değiştirmek için
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h), //butonun iç boşluğu için
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ), 
              
            ),

             SizedBox(height: 16.h),

            //rol atama
            ElevatedButton.icon(
              onPressed: () => context.push('/admin/assign-roles'),
              icon:  Icon(Icons.assignment_ind, size:20.r),
              label: Text(LocaleKeys.admin_roles_assign_role.tr(),
              style: TextStyle(fontSize: 16.sp),),
              style: ElevatedButton.styleFrom(//buton stillerini değiştirmek için
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h), //butonun iç boşluğu için
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
