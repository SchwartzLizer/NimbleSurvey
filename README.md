# NimbleSurvey

Information Project:
- Target iOS 10.0+
- Cocoa Pods (SkeletonView,Kingfisher(6.3.1),SideMenu)
- Fastlane (Take a screenshots, Run all unittest,Upload to testflight and appstore)

The problem should be known:
- Fastlane take a screenshots function doesn't start the simulator. Maybe there is a bug in Fastlane, you need to open the simulator manually when running a command, but the function can run normally.
- In the final test, the email and password can't login, so I decided to stop the format code. I hope you understand what I mean.

What I learned:
- Fastlane is a useful tool, I didn't know how to use it before. I can easily run all tests with one command and take screenshots of what I need with one command.
- Userinterface in Figma has quite a beautiful design, but this is my first time doing it. I hope you will like it.

Specially designed in home menu

I decided to use 2 CollectionView because it is easy to manage the view when horizontal.
