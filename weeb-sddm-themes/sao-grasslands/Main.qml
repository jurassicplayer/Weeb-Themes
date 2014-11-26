import QtQuick 2.0
import QtQuick.Particles 2.0
import SddmComponents 2.0
import QtMultimedia 5.0

Rectangle {
    id: container
    width: 1024
    height: 768
    property int sessionIndex: session.index
    TextConstants { id: textConstants }

    Connections {
        target: sddm
        onLoginSucceeded: {
        }
        onLoginFailed: {
            txtMessage.text = textConstants.loginFailed
            listView.currentItem.password.text = ""
        }
    }

    /********************************
               Background
    *********************************/
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        Image {
            id: background
            anchors.fill: parent
            source: "background.png"
            fillMode: Image.PreserveAspectCrop
        }
    }
    Item {
        anchors.fill: parent
        MediaPlayer {
            id: mediaPlayer
            source: "resources/vid.mp4"
            autoPlay: true
            autoLoad: true
            loops: -1
        }
        VideoOutput {
            source: mediaPlayer
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectCrop
        }
    }
    Audio {
        id: musicPlayer
        autoPlay: true
        autoLoad: true
        source: "resources/bgm.ogg"
        loops: -1
    }
    ParticleSystem {
        id: bgparticle
    }

    Emitter {
        anchors.fill: parent
        system: bgparticle
        emitRate: 80
        lifeSpan: 4000
        lifeSpanVariation: 2000
        size: 3
        sizeVariation: 8
        endSize: 3
        startTime: 1000
        velocity: AngleDirection{
            angle: 270
            angleVariation: 30
            magnitude: 40
            magnitudeVariation: 20
        }
        ImageParticle {
            anchors.fill: parent
            system: bgparticle
            source: "resources/lightparticle.png"
        }
        Attractor {
            system: bgparticle
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenterOffset: parent.width*0.08
            anchors.verticalCenterOffset: -parent.height*0.1
            width: parent.width*0.5; height: 200
            pointX: parent.width*0.25
            pointY: 0
            strength: 0.2
        }
    }

    /*******************************
               Foreground
    ********************************/
    Rectangle {
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
        color: "transparent"

        /********* Login Box *********/
        Rectangle {
            id: loginBox
            anchors.fill: parent
            color: "transparent"
            Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: 200
                height: 80
                spacing: 6
            
                /*** Username ***/
                Rectangle {
                    width: parent.width
                    height: 32
                    color: "transparent"
                    Image {
                        id: userimage
                        anchors.fill: parent
                        source: "resources/user.png"
                    }
                    TextInput {
                        id: name
                        y: 8; x: 38
                        width: 160; height: 16
                        text: userModel.lastUser
                        font.pixelSize: 12
                        autoScroll: false
                        KeyNavigation.backtab: btnShutdown; KeyNavigation.tab: password
                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, session.index)
                                event.accepted = true
                            }
                        }
                    }
                }
                /*** Password ***/
                Rectangle {
                    width: parent.width
                    height: 32
                    color: "transparent"
                    Image {
                        id: passwordimage
                        anchors.fill: parent
                        source: "resources/passwd.png"
                    }
                    TextInput {
                        id: password
                        y: 8; x: 38
                        width: 160; height: 16
                        echoMode: TextInput.Password
                        font.pixelSize: 12
                        autoScroll: false
                        KeyNavigation.backtab: name; KeyNavigation.tab: session
                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, session.index)
                                event.accepted = true
                            }
                        }       
                    }
                }
            }
            /***  Buttons ***/
            Column {
                id: buttons
                anchors.top: parent.top
                anchors.topMargin: parent.height*0.10
                anchors.left: parent.left
                anchors.leftMargin: parent.width*0.05
                spacing: 4
                height: 26
                            
                ImageButton {
                    id: session
                    width: parent.height
                    source: "resources/session.png"
                    
                    onClicked: if (menu_session.state === "visible") menu_session.state = ""; else menu_session.state = "visible"
                    KeyNavigation.backtab: password; KeyNavigation.tab: btnSuspend
                }
                ImageButton {
                    id: btnSuspend
                    width: parent.height
                    source: "resources/suspend.png"

                    visible: sddm.canSuspend
                    onClicked: sddm.suspend()
                    KeyNavigation.backtab: session; KeyNavigation.tab: btnHibernate
                }
                ImageButton {
                    id: btnHibernate
                    width: parent.height
                    source: "resources/hibernate.png"

                    visible: sddm.canHibernate
                    onClicked: sddm.hibernate()
                    KeyNavigation.backtab: btnSuspend; KeyNavigation.tab: btnReboot
                }
                ImageButton {
                    id: btnReboot
                    width: parent.height
                    source: "resources/reboot.png"

                    visible: sddm.canReboot
                    onClicked: sddm.reboot()
                    KeyNavigation.backtab: btnHibernate; KeyNavigation.tab: btnShutdown
                }
                ImageButton {
                    id: btnShutdown
                    width: parent.height
                    source: "resources/power.png"

                    visible: sddm.canPowerOff
                    onClicked: sddm.powerOff()
                    KeyNavigation.backtab: btnReboot; KeyNavigation.tab: name
                }
            }
            Menu {
                id: menu_session
                anchors.left: buttons.right
                anchors.top: buttons.verticalCenter
                anchors.leftMargin: 6
                width: 100
                model: sessionModel
                index: sessionModel.lastIndex
            }
        }
    }
}
