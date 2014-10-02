import QtQuick 2.0
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
    Repeater {
        model: screenModel
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
    }

    /*******************************
               Foreground
    ********************************/
    Rectangle {
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
        color: "transparent"

        /********* Hashtag *********/
        Image {
            id: hashtag
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 60
            source: "resources/Illya-Dance.png"
        }
        
        /********* Login Box *********/
        Image {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            id: loginBoximage
            width: 180
            height: 68
            source: "resources/login.png"
        }
        Rectangle {
            id: loginBox
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: 174
            height: 62
            color: "transparent"
            Row {
                width: parent.width
                spacing: 2
                Column {
                    width: 30
                    spacing: 2
                    Image {
                        id: userimage
                        source: "resources/power.png"
                    }
                    Image {
                        id: passwordimage
                        source: "resources/reboot.png"
                    }
                }
                Column {
                    y: 6
                    width: 140
                    spacing: 18
                    TextInput {
                        id: name
                        width: parent.width; height: 16
                        horizontalAlignment: TextInput.AlignHCenter
                        text: userModel.lastUser
                        font.pixelSize: 12
                        KeyNavigation.backtab: btnShutdown; KeyNavigation.tab: password
                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, session.index)
                                event.accepted = true
                            }
                        }
                    }
                    TextInput {
                        id: password
                        width: parent.width; height: 16
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
        }
        
        Rectangle {
            id: actionBar
            anchors.top: parent.top;
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width; height: 20

            Row {
                anchors.left: parent.left
                anchors.margins: 0
                height: parent.height
                spacing: 3

                ComboBox {
                    id: session
                    width: 80
                    anchors.verticalCenter: parent.verticalCenter

                    arrowIcon: "resources/arrow_down.png"

                    model: sessionModel
                    index: sessionModel.lastIndex

                    font.pixelSize: 10

                    KeyNavigation.backtab: password; KeyNavigation.tab: btnReboot
                }
            }

            Row {
                height: parent.height
                anchors.right: parent.right
                anchors.margins: 5
                spacing: 5

                ImageButton {
                    id: btnReboot
                    height: parent.height
                    source: "resources/reboot.png"

                    visible: sddm.canReboot

                    onClicked: sddm.reboot()

                    KeyNavigation.backtab: session; KeyNavigation.tab: btnShutdown
                }

                ImageButton {
                    id: btnShutdown
                    height: parent.height
                    source: "resources/power.png"

                    visible: sddm.canPowerOff

                    onClicked: sddm.powerOff()

                    KeyNavigation.backtab: btnReboot; KeyNavigation.tab: name
                }
            }
        }
    }
}
