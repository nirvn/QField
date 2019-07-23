

TARGET = test
QT += testlib xml widgets
TEMPLATE = app
CONFIG += qt

android {
    QT += androidextras
}

include( ../qfield.pri )
include( ../qgis.pri )
include( ../version.pri )

INCLUDEPATH += ../3rdparty/tessellate \
               ../src/qgsquick \
               ../src/core

DEPENDPATH += ../src/qgsquick ../src/core

LIBS += ../3rdparty/tessellate/libtessellate.a \
       -L$$OUT_PWD/../src/core -lcore \
       -L$$OUT_PWD/../src/qgsquick -lqgsquick


SOURCES += \
    test_vertexmodel.cpp \
    test_referencingfeaturelistmodel.cpp \
    main.cpp

HEADERS +=
