import 'dart:math';

import 'package:flutter/material.dart';
import 'package:friendly_card_teacher/controllers/learner_controller.dart';
import 'package:friendly_card_teacher/controllers/teacher_controller.dart';
import 'package:friendly_card_teacher/controllers/topic_controller.dart';
import 'package:friendly_card_teacher/models/users.dart';
import 'package:friendly_card_teacher/screens/learner/learner_managment_screen.dart';
import 'package:friendly_card_teacher/screens/statistic/overview_screent.dart';
import 'package:friendly_card_teacher/screens/topic/topic_managment_screen.dart';
import 'package:friendly_card_teacher/screens/teacher/teacher_managment_screen.dart';
import 'package:get/get.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class MainController extends GetxController {
  RxInt numPageAdmin = 1.obs;
  RxInt numPageTeacher = 1.obs;

  List<String> titleAdmin = [
    'Tổng quan',
    'Giáo viên chuyên môn',
    'Quản lý chủ đề',
    'Quản lý người học',
  ];
  List<String> titleTeacher = ['Tổng quan', 'Quản lý chủ đề'];

  List<Widget> pageAdmin = [
    const OverviewScreen(),
    const TeacherManagmentScreen(),
    const TopicManagmentScreen(),
    const LearnerManagmentScreen(),
  ];

  List<Widget> pageTeacher = [
    const OverviewScreen(),
    const TopicManagmentScreen(),
  ];

  Future<void> loadAllDataForAdmin() async {
    await Get.find<TeacherController>().loadAllData();
    await Get.find<TopicController>().loadAllTopic();
    await Get.find<LearnerController>().loadLearner();
  }

  RxString otpCode = ''.obs;

  Future<void> sendOtp(String email, String uname) async {
    // isLoading.value = true;
    otpCode.value = (100000 + Random().nextInt(899999)).toString();

    String htmlTxt =
        '''
        <div style="text-align:center; color:#5BC0DE;">
          <div style="max-width:600px; margin:auto; border:1px solid #dadce0; background-color:#f8fbff;
                  border-radius:8px; padding:40px 20px; text-align:left;">
                  <div style="text-align:center;">
                        <img src="https://res.cloudinary.com/drir6xyuq/image/upload/v1752483066/logo-removebg.png"
                                height="100" style="margin-bottom:16px; max-width:100%;" alt="Friendly Card Logo">
                  </div>
                  <div style="border-bottom:1px solid #dadce0; padding-bottom:24px; text-align:center;">
                        <span style="font-size:24px;">
                                Xin chào
                                <strong style="font-size:24px; font-weight:600;">
                                      $uname
                                </strong>!
                        </span>
                  </div>
                  <div style="margin-top:24px;">
                        <div style="font-size:20px;">
                                Bạn vừa thực hiện chức năng <strong>quên mật khẩu</strong> của ứng dụng
                                <strong>Friendly Card</strong>. Vui lòng sử dụng mã OTP dưới đây để tạo mật khẩu mới.
                        </div>
                        <div style="font-size:20px; margin-top:12px;">
                                Mã OTP của bạn là:
                                <strong style="font-size:24px; font-weight:700; color:#d9534f;">
                                      ${otpCode.value}
                                </strong>
                        </div>
                        <div style="font-size:16px; color:red; font-style:italic; margin-top:12px;">
                                Xin vui lòng không cung cấp OTP cho bất kỳ ai!
                        </div>
                  </div>
          </div>
    </div>''';
    await sendMail(email, '[MÃ OTP] Quên mật khẩu', htmlTxt);
  }

  Future<void> sendMailWelcome(Users users) async {
    final String emailHtml =
        '''
                <div style="text-align:center; color:#5BC0DE;">
       <div style="width:600px; margin:auto; border:1px solid #dadce0; background-color:#f8fbff;
              border-radius:8px; padding:40px 20px; font-family:Arial, sans-serif;">
              <img src="https://res.cloudinary.com/drir6xyuq/image/upload/v1752483066/logo-removebg.png" height="100"
                     style="margin-bottom:16px" alt="Friendly Card logo" aria-hidden="true">

              <div style="border-bottom:1px solid #dadce0; color:rgba(0,0,0,0.87); line-height:32px;
                padding-bottom:24px; word-break:break-word; font-size:24px;color:#5BC0DE;">
                     Chào mừng bạn đến với
                     <span style="font-size:32px; font-weight:600; color:#5BC0DE;">Friendly Card</span>
              </div>
              <div style="margin-top:24px; font-size:24px; color:#5BC0DE;">
                     Chúc mừng bạn đăng ký tài khoản thành công!
              </div>
              <div style="margin-top:16px; font-size:24px; color:#5BC0DE;">
                     Tên tài khoản giáo viên của bạn là: <strong>${users.username}</strong>
              </div>
              <div style="margin-top:16px; font-size:24px; color:#5BC0DE;">
                     Mật khẩu: <strong>${users.password}</strong>
              </div>
       </div>
</div>''';

    await sendMail(
      users.email ?? 'vdkhanh3112@gmail.com',
      'CHÀO MỪNG BẠN ĐẾN VỀ FRIENDLY CARD',
      emailHtml,
    );
  }

  Future<void> sendMail(String mailUser, String subject, String html) async {
    // Thông tin đăng nhập và cấu hình SMTP (ví dụ sử dụng Gmail SMTP)
    const String username = 'friendlycard2025@gmail.com';
    const String password = 'qstj qtzq docl ebrn';

    // Cấu hình SMTP cho Gmail (hoặc thay đổi cho các nhà cung cấp khác)
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = const Address(username, 'Friendly Card')
      ..recipients.add(mailUser)
      ..subject = subject
      // ..text = text
      ..html = html;

    try {
      // Gửi email
      await send(message, smtpServer);
    } on MailerException catch (e) {
      for (var p in e.problems) {
        // ignore: avoid_print
        print('Lỗi: ${p.code}: ${p.msg}');
      }
    }
  }
}
