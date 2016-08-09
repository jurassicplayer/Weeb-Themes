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
            source: "background.png"
            fillMode: Image.PreserveAspectCrop
        }
        /********* Video *********/
        MediaPlayer {
            id: mediaPlayer
            source: "resources/vid.mp4"
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
                                sddm.login(name.text, password.text, menu_session.index)
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
                                sddm.login(name.text, password.text, menu_session.index)
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
