#!/bin/sh

cp fb_chatbot_danny_gui_v10 ./chatbot-danny.AppDir/usr/bin/
rm chatbot-danny-x86_64.AppImage
ARCH=x86_64 ~/appimagetool/appimagetool-x86_64.AppImage ./chatbot-danny.AppDir

