import 'package:flutter/material.dart';
import 'package:social_sphere/features/feed/feed_screen.dart';
import 'package:social_sphere/features/post/screens/add_post_screen.dart';

class Constants {
  static const logopath = 'assets/images/logo.png';
  static const logopath2 = 'assets/images/logo2.png';
  static const loginEmotepath = 'assets/images/loginEmote.png';
  static const googlePath = 'assets/images/google.png';
  static const bannerDefault =
      'https://preview.redd.it/g9i03fsmwmq91.png?width=1200&format=png&auto=webp&s=77cc7832debbbc344881d52d09953f71985a620c';
  static const avatarDefault =
      'https://w7.pngwing.com/pngs/893/183/png-transparent-user-avatar-profile-person-man-people-account-instagram-icon.png';

  static const tabWidgets = [FeedScreen(), AddPostScreen()];

  static const IconData up = IconData(
    0xe800,
    fontFamily: 'MyFlutterApp',
    fontPackage: null,
  );
  static const IconData down = IconData(
    0xe801,
    fontFamily: 'MyFlutterApp',
    fontPackage: null,
  );

  static const awardsPath = 'assets/images/awards';

  static const awards = {
    'awesomeAns': '${Constants.awardsPath}/awesomeanswer.png',
    'gold': '${Constants.awardsPath}/gold.png',
    'platinum': '${Constants.awardsPath}/platinum.png',
    'helpful': '${Constants.awardsPath}/helpful.png',
    'plusone': '${Constants.awardsPath}/plusone.png',
    'rocket': '${Constants.awardsPath}/rocket.png',
    'thankyou': '${Constants.awardsPath}/thankyou.png',
    'til': '${Constants.awardsPath}/til.png',
  };
}
