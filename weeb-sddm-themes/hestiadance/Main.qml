import QtQuick 2.7
import SddmComponents 2.0
import QtMultimedia 5.6
import QtQuick.Window 2.2

Rectangle {
    id: container
    width: Screen.width
    height: Screen.height

    Connections {
        target: sddm
        onLoginSucceeded: {
        }
        onLoginFailed: {
            password.text = ""
        }
    }

    Item {
        anchors.fill: parent
        /********* Background *********/
        Image {
            id: background
            anchors.fill: parent
            source: "background.jpg"
            fillMode: Image.PreserveAspectCrop
        }
        /********* Video *********/
        MediaPlayer {
            id: mediaPlayer
            source: "resources/vid.webm"
            autoLoad: false
            loops: -1
        }
        VideoOutput {
            source: mediaPlayer
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectCrop
        }
        /********* Audio *********/
        Audio {
            id: musicPlayer
            autoLoad: false
            source: "resources/bgm.ogg"
            loops: -1
        }
        /********* Login Box *********/
        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            id: loginBoximage
            width: 192
            height: 79
            source: "resources/login.png"
        }
        Rectangle {
            id: loginBox
            anchors.top: loginBoximage.top
            anchors.topMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
            width: 174
            height: 90
            color: "transparent"
            
            Column {
                width: parent.width
                height: parent.height
                spacing: 6
            
                /*** Username ***/
                Row {
                    spacing: 8
                    height: 30
                    Image {
                        id: userimage
                        width: parent.height; height: parent.height
                        source: "resources/user.png"
                    }
                    TextInput {
                        id: name
                        y: 7
                        width: 150; height: 16
                        text: userModel.lastUser
                        font.pixelSize: 12
                        KeyNavigation.backtab: btnShutdown; KeyNavigation.tab: password
                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, menu_session.index)
                                event.accepted = true
                            }
                        }
                    }
                }
                /*** Password ***/
                Row {
                    spacing: 8
                    height: 30
                    Image {
                        id: passwordimage
                        width: parent.height; height: parent.height
                        source: "resources/passwd.png"
                    }
                    TextInput {
                        id: password
                        y: 7
                        width: 150; height: 16
                        echoMode: TextInput.Password
                        font.pixelSize: 12
                        autoScroll: false
                        KeyNavigation.backtab: name; KeyNavigation.tab: session
                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, menu_session.index)
                                event.accepted = true
                            }
                        }       
                    }
                }
                /***  Buttons ***/
                Row {
                    y: 30
                    spacing: 4
                    height: 26
                    anchors.horizontalCenter: parent.horizontalCenter
                    
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
                        x: 30
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
                        width: 100
                        model: sessionModel
                        index: sessionModel.lastIndex
                }
            }
        }
        Component.onCompleted: {
        if (name.text == "")
            name.focus = true
        else
            password.focus = true
        mediaPlayer.play()
        musicPlayer.play()
		}
    }
}
