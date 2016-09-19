import QtQuick 2.0
import SddmComponents 2.0
import QtMultimedia 5.0
import QtQuick.Window 2.0
import Qt.labs.settings 1.0

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
		
		MediaPlayer {
			id: mediaPlayer
			source: "resources/vid.webm"
			autoLoad: false
			loops: -1
		}
		VideoOutput {
			id: videoPlayer
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
		/********* Toggle *********/
		Column {
			anchors.bottom: parent.bottom
			x: 16
			height: 68
			spacing: 6
			Row {
				spacing: 8
				Image {
					id: musicToggle
					source: musictogglearea.musicPlay ? (musictogglearea.containsMouse || musictogglearea.focus ? "resources/unchecked-hover.png" : "resources/unchecked-unpressed.png") : (musictogglearea.containsMouse || musictogglearea.focus ? "resources/checked-hover.png" : "resources/checked-unpressed.png")
					
					MouseArea {
						id: musictogglearea
						anchors.top: parent.top
						anchors.bottom: parent.bottom
						width: 120
						property bool musicPlay: true
						hoverEnabled: true
						onPressed: if (musicPlay) { 
							musicPlay = false
							musicPlayer.stop();
						} else {
							musicPlay = true
							musicPlayer.play();
						}
						KeyNavigation.backtab: bgtogglearea; KeyNavigation.tab: bgtogglearea
						Settings {
							property alias musicPlay: musictogglearea.musicPlay
						}
					}
				}
				Text {
					y: 2
					font.pixelSize: 10
					color: "white"
					text: "Disable Login Music"
				}
			}
			Row {
				spacing: 8
				Image {
					id: bgToggle
					source: bgtogglearea.bgAnimation ? ( bgtogglearea.containsMouse || bgtogglearea.focus ? "resources/unchecked-hover.png" : "resources/unchecked-unpressed.png" ) : ( bgtogglearea.containsMouse || bgtogglearea.focus ? "resources/checked-hover.png" : "resources/checked-unpressed.png" )
					MouseArea {
						id: bgtogglearea
						anchors.top: parent.top
						anchors.bottom: parent.bottom
						width: 150
						property bool bgAnimation: true
						hoverEnabled: true
						onPressed: if (bgAnimation) { 
							bgAnimation = false
							mediaPlayer.stop()
						} else {
							bgAnimation = true
							mediaPlayer.play()
						}
						KeyNavigation.backtab: musictogglearea; KeyNavigation.tab: musictogglearea
						Settings {
							property alias bgAnimation: bgtogglearea.bgAnimation
						}
					}
				}
				Text {
					y: 2
					font.pixelSize: 10
					color: "white"
					text: "Disable Menu Animations"
				}
			}
		}		
        /********* Logo *********/
        Image {
            id: logo
            anchors.horizontalCenter: loginBoximage.horizontalCenter
            anchors.bottom: loginBoximage.top
            anchors.bottomMargin: 20
            width: 287
            source: "resources/logo.png"
        }
        /********* Login Box *********/
        Image {
            id: loginBoximage
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 60
            width: 333
            height: 242
            source: "resources/login.png"
        }
        Rectangle {
            id: loginBox
            anchors.top: loginBoximage.top
            anchors.topMargin: 6
            anchors.horizontalCenter: loginBoximage.horizontalCenter
            width: 312
            height: 90
            color: "transparent"
            
            Column {
				y: 12
                width: parent.width
                height: parent.height
                spacing: 6
            
				Text{
					text: "Account Login"
					font.pixelSize: 12
					color: "white"
					x: 18
					height: 17
				}
				
				/********* Separator **********/
				Image {
					source: "resources/separator.png"
					width: parent.width; height: 1
				}
				Text{
					text: "Username"
					font.pixelSize: 10
					color: "white"
					x: 20; height: 16
					verticalAlignment: Text.AlignBottom
				}
				Rectangle {
					id: userbox
					width: 270
					height: 27
					color: "white"
					x: 20
					radius: 1
					TextInput {
						id: name
						x: 6; y: 6
						width: parent.width
						font.pixelSize: 14
						text: userModel.lastUser
					}
				}
				Text{
					text: "Password"
					font.pixelSize: 10
					color: "white"
					x: 20; height: 20
					verticalAlignment: Text.AlignBottom
				}
				Rectangle {
					id: passwordbox
					width: 270
					height: 27
					color: "white"
					x: 20
					radius: 1
					TextInput {
						id: password
						x: 6; y: 6
						width: parent.width
						font.pixelSize: 14
						echoMode: TextInput.Password
                        autoScroll: false
                        KeyNavigation.backtab: name; KeyNavigation.tab: btnLogin
                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, menu_session.index)
                                event.accepted = true
                            }
                        }
					}
				}
				Row {
					height: 30
					anchors.right: passwordbox.right
					Image {
						anchors.verticalCenter: parent.verticalCenter
						width: 81; height: 24
						source: name.text && password.text ? (btnLogin.containsMouse || btnLogin.focus ? "resources/loginbutton-hover.png" : "resources/loginbutton-unpressed.png") : "resources/loginbutton-disabled.png" 
						MouseArea {
							id: btnLogin
							anchors.fill: parent
							hoverEnabled: true
							KeyNavigation.backtab: password; KeyNavigation.tab: session
                            onClicked: sddm.login(name.text, password.text, menu_session.index)
							Keys.onPressed: {
								if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    sddm.login(name.text, password.text, menu_session.index)
									event.accepted = true
								}
							}
						}
						Text {
							anchors.verticalCenter: btnLogin.verticalCenter
							anchors.horizontalCenter: btnLogin.horizontalCenter
							font.pixelSize: 12
							text: "Log In"
							color: name.text && password.text ? (btnLogin.containsMouse || btnLogin.focus ? "white" : "white") : "gray"
						}
					}
				}
				
				/********* Separator **********/
				Image {
					source: "resources/separator.png"
					width: parent.width
					height: 1
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
                        KeyNavigation.backtab: btnLogin; KeyNavigation.tab: btnSuspend
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
                        focus: true
                }
            }
        }
        Component.onCompleted: {
			if (name.text == "")
				name.focus = true
			else
				password.focus = true
			if (bgtogglearea.bgAnimation) {
				mediaPlayer.play()
			} else {
				mediaPlayer.stop()
			}
			if (musictogglearea.musicPlay) {
				musicPlayer.play()
			} else {
				musicPlayer.stop()
			}
		}
    }
}
