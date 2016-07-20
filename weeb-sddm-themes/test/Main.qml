import QtQuick 2.7
import SddmComponents 2.0
import QtMultimedia 5.6
import QtQuick.Window 2.2
import Qt.labs.settings 1.0

Rectangle {
    id: container
    width: Screen.width
    height: Screen.height
    state: "close"
    color: "white"
    TextConstants { id: textConstants }

	Timer {
		id: notificationResetTimer
		interval: 3000
		onTriggered: notification = ""
	}
	Connections {
		target: sddm
		onLoginSucceeded: {
		}
		onLoginFailed: {
			notificationResetTimer.restart()
			txtMessage.text = textConstants.loginFailed
            password.clear()
		}
	}

	// Regurgitate userModel information into a ListModel that I can actually grab information from.
	ListModel {
		id: userList
		property int lastIndex: userModel.lastIndex
		property string lastUser: userModel.lastUser
		property int currentIndex: userModel.lastIndex
		property bool complete: false
		function incrementCurrentIndex() {
			// Index and count are offset by 1 (index starts at zero, count starts at 1)
			if (userList.currentIndex == userList.count-1) {
				userList.currentIndex = 0;
			} else {
				userList.currentIndex += 1;
			}
		}
		function decrementCurrentIndex() {
			// Index and count are offset by 1 (index starts at zero, count starts at 1)
			if (userList.currentIndex == 0) {
				userList.currentIndex = userList.count-1;
			} else {
				userList.currentIndex -= 1;
			}
		}
		Component.onCompleted: { (userList.count == userModel.count) ? complete = true : complete = false }
	}
	ListView {
		model: userModel
		delegate: Item {
			Component.onCompleted: {
				userList.append({
					"name": (model.realName === "") ? model.name : model.realName,
					"realName": model.realName,
					"homeDir": model.homeDir,
					"icon": model.icon,
					"needsPassword": model.needsPassword
				})
			}
		}
	}

    // Background image
    Image {
		id: backgroundImage
		anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        property string imageID: (Math.floor(Math.random() * (8 - 1 + 1)) + 1);
        source: "resources/wallpapers/"+imageID
        MouseArea {
            anchors.fill: parent
            onClicked: if (root.state = "open") root.state = "close"
        }
	}

    // Login container
    Rectangle {
		id: root
		anchors.horizontalCenter: parent.horizontalCenter
        y: (parent.height - root.height) * 0.5
        width: 350
        height: 400
        color: "transparent"
		Rectangle {
            id: loginRectangleTemplate
            y: parent.height * 0.5 + avatarBorder.height * 0.3
            height: 80
            width: 150
			radius: 4
            visible: false
        }
        Rectangle {
            id: loginBorder
            x: (parent.width - loginBorder.width) * 0.5
            y: (parent.height - loginBorder.height) * 0.5
            width: avatarBorder.width
            height: loginBorder.width
            radius: loginBorder.width
            color: "white"
            MouseArea { anchors.fill: parent }
            Item {
                id: loginContainer
                visible: false
                anchors.fill: parent
                property int textMargin: 15
                Item {
                    id:loginUser
                    width: parent.width
                    height: parent.height * 0.5
                    Text {
                        id: userName
                        anchors.fill: parent
                        anchors.leftMargin: loginContainer.textMargin
                        anchors.rightMargin: loginContainer.textMargin
                        clip: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 20
                        text: if (userList.complete) (userList.get(userList.currentIndex).name == "" ? userList.get(userList.currentIndex).realName : userList.get(userList.currentIndex).name)
                    }
                }
                Item {
                    id: loginPassword
                    width: loginUser.width
                    height: loginUser.height
                    anchors.top: loginUser.bottom
                    TextInput {
                        id: password
                        anchors.fill: parent
                        anchors.leftMargin: loginContainer.textMargin
                        anchors.rightMargin: loginContainer.textMargin
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 13
                        clip: true
                        echoMode: TextInput.Password
                        Text {
                            anchors.fill: parent
                            font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                            text: password.text ? "" : "Password"
                            color: "#656565"
                        }
                    }
                }
            }
		}
        // Avatar icon
        Item {
            anchors.fill: parent
            Rectangle {
                id: prevUser
                anchors.verticalCenter: avatarBorder.verticalCenter
                x: ( parent.width - prevUser.width ) * 0.10
                width: avatarBorder.width * 0.35
                height: prevUser.width
                radius: prevUser.width
                MouseArea {
                    id: prevUserArea
                    anchors.fill: parent
                    onClicked: {
                        userList.decrementCurrentIndex()
                        password.clear()
                    }
                }
            }
            Rectangle {
                id: nextUser
                anchors.verticalCenter: avatarBorder.verticalCenter
                x: ( parent.width - nextUser.width ) * 0.90
                width: avatarBorder.width * 0.35
                height: nextUser.width
                radius: nextUser.width
                MouseArea {
                    id: nextUserArea
                    anchors.fill: parent
                    onClicked: {
                        userList.incrementCurrentIndex()
                        password.clear()
                    }
                }
            }
            Rectangle {
                id: avatarBorder
                width: 150
                height: avatarBorder.width
                radius: avatarBorder.width
                color: "white"
                x: (parent.width - avatarBorder.width) * 0.5
                y: (parent.height - avatarBorder.height) * 0.5
                MouseArea {
                    id: avatarArea
                    anchors.fill: parent
                    onClicked: root.state == "open" ? root.state = "close" : root.state = "open"
                }
            }
            Image {
                id: avatarImage
                width: avatarBorder.width * 0.95
                height: avatarImage.width
                anchors.centerIn: avatarBorder
                source: if (userList.complete) userList.get(userList.currentIndex).icon
                property bool rounded: true
                property bool adapt: true
                layer.enabled: rounded
                layer.effect: ShaderEffect {
                    property real adjustX: avatarImage.adapt ? Math.max(width / height, 1) : 1
                    property real adjustY: avatarImage.adapt ? Math.max(1 / (width / height), 1) : 1

                    fragmentShader: "
                    #ifdef GL_ES
                        precision lowp float;
                    #endif // GL_ES
                    varying highp vec2 qt_TexCoord0;
                    uniform highp float qt_Opacity;
                    uniform lowp sampler2D source;
                    uniform lowp float adjustX;
                    uniform lowp float adjustY;

                    void main(void) {
                        lowp float x, y;
                        x = (qt_TexCoord0.x - 0.5) * adjustX;
                        y = (qt_TexCoord0.y - 0.5) * adjustY;
                        float delta = adjustX != 1.0 ? fwidth(y) / 2.0 : fwidth(x) / 2.0;
                        gl_FragColor = texture2D(source, qt_TexCoord0).rgba
                            * step(x * x + y * y, 0.25)
                            * smoothstep((x * x + y * y) , 0.25 + delta, 0.25)
                            * qt_Opacity;
                    }"
                }
            }
        }

		states: [
			State {
				name: "open"
				PropertyChanges {
                    target: loginBorder
                    y: loginRectangleTemplate.y
                    radius: loginRectangleTemplate.radius
                    height: loginRectangleTemplate.height
                    width: loginRectangleTemplate.width
					anchors.margins: 0
				}
                PropertyChanges {
                    target: loginContainer
                    visible: true
                }
				PropertyChanges {
                    target: avatarBorder
                    y: (root.height - avatarBorder.height) * 0.5 - (avatarBorder.height / 3)
				}
			},
			State {
                name: "close"
			}
		]
		transitions: [
			Transition {
				PropertyAnimation {
					properties: "radius, anchors.margins, width, height, y, opacity"
                    duration: 700
                    easing.type: Easing.OutElastic
				}
			}
		]
    }

    //System Buttons
    Row {
        id: buttonContainer
        x: 15
        y: 500
        width: 100
        height: 150
        spacing: buttonContainer.height * 0.04
        state: "close"
        property string selectedButton
        Rectangle {
            id: suspend
            width: buttonContainer.height * 0.22
            height: buttonContainer.height * 0.22
            radius: buttonContainer.height * 0.22
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    buttonContainer.selectedButton = "suspend"
                    buttonContainer.state = "open"
                }
                onExited: {
                    buttonContainer.state = "close"
                }
            }
            Row {
                Image {
                    width: buttonContainer.height * 0.22
                    height: buttonContainer.height * 0.22
                    source: "resources/suspend.png"
                }
                Text {
                    id: suspendText
                    width: buttonContainer.width - (buttonContainer.height * 0.22)
                    height: buttonContainer.height * 0.22
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    text: "Suspend"
                    visible: (buttonContainer.selectedButton == "suspend" & buttonContainer.state == "open") ? true : false
                    opacity: 0
                }
            }
        }
        Rectangle {
            id: hibernate
            width: buttonContainer.height * 0.22
            height: buttonContainer.height * 0.22
            radius: buttonContainer.height * 0.22
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    buttonContainer.selectedButton = "hibernate"
                    buttonContainer.state = "open"
                }
                onExited: {
                    buttonContainer.state = "close"
                }
            }
            Row {
                Image {
                    width: buttonContainer.height * 0.22
                    height: buttonContainer.height * 0.22
                    source: "resources/hibernate.png"
                }
                Text {
                    id: hibernateText
                    width: buttonContainer.width - (buttonContainer.height * 0.22)
                    height: buttonContainer.height * 0.22
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    text: "Hibernate"
                    visible: (buttonContainer.selectedButton == "hibernate" & buttonContainer.state == "open") ? true : false
                    opacity: 0
                }
            }
        }
        Rectangle {
            id: reboot
            width: buttonContainer.height * 0.22
            height: buttonContainer.height * 0.22
            radius: buttonContainer.height * 0.22
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    buttonContainer.selectedButton = "reboot"
                    buttonContainer.state = "open"
                }
                onExited: {
                    buttonContainer.state = "close"
                }
            }
            Row {
                Image {
                    width: buttonContainer.height * 0.22
                    height: buttonContainer.height * 0.22
                    source: "resources/reboot.png"
                }
                Text {
                    id: rebootText
                    width: buttonContainer.width - (buttonContainer.height * 0.22)
                    height: buttonContainer.height * 0.22
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    text: "Reboot"
                    visible: (buttonContainer.selectedButton == "reboot" & buttonContainer.state == "open") ? true : false
                    opacity: 0
                }
            }
        }
        Rectangle {
            id: shutdown
            width: buttonContainer.height * 0.22
            height: buttonContainer.height * 0.22
            radius: buttonContainer.height * 0.22
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    buttonContainer.selectedButton = "shutdown"
                    buttonContainer.state = "open"
                }
                onExited: {
                    buttonContainer.state = "close"
                }
            }
            Row {
                Image {
                    width: buttonContainer.height * 0.22
                    height: buttonContainer.height * 0.22
                    source: "resources/power.png"
                }
                Text {
                    id: shutdownText
                    width: buttonContainer.width - (buttonContainer.height * 0.22)
                    height: buttonContainer.height * 0.22
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: 12
                    text: "Shutdown"
                    visible: (buttonContainer.selectedButton == "shutdown" & buttonContainer.state == "open") ? true : false
                    opacity: 0
                }
            }
        }
        states: [
            State {
                name: "open"

                PropertyChanges {
                    target: if (buttonContainer.selectedButton == "suspend") suspend; else if (buttonContainer.selectedButton == "hibernate") hibernate; else if (buttonContainer.selectedButton == "reboot") reboot; else if (buttonContainer.selectedButton == "shutdown") shutdown;
                    width: buttonContainer.width
                    radius: 5
                }
                PropertyChanges {
                    target: if (buttonContainer.selectedButton == "suspend") suspendText; else if (buttonContainer.selectedButton == "hibernate") hibernateText; else if (buttonContainer.selectedButton == "reboot") rebootText; else if (buttonContainer.selectedButton == "shutdown") shutdownText;
                    opacity: 1
                }
            },
            State {
                name: "close"
            }
        ]
        transitions: [
            Transition {
                PropertyAnimation {
                    properties: "radius, width, height"
                    duration: 300
                    easing.type: Easing.OutExpo
                }
                PropertyAnimation {
                    properties: "opacity"
                    duration: 700
                    easing.type: Easing.Linear
                }
            }
        ]
    }


}
