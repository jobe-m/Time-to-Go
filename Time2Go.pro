# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = Time2Go

CONFIG += sailfishapp

SOURCES += src/Time2Go.cpp

OTHER_FILES += qml/Time2Go.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    rpm/Time2Go.changes.in \
    rpm/Time2Go.spec \
    rpm/Time2Go.yaml \
    translations/*.ts \
    Time2Go.desktop

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/Time2Go-de.ts

