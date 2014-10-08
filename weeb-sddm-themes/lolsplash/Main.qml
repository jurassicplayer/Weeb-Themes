import QtQuick 2.0
import SddmComponents 2.0
import QtMultimedia 5.0
import Qt.labs.settings 1.0

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
    /********** Save Settings ***********/
    Item {
			id: page
			state: settings.state
			states: [
				State {
				    name: "active"
				},
				State {
					name: "inactive"
				}
			]
			Settings {
				id: settings
				property string state: " active"
			}
			Component.onDestruction: {
				settings.state = page.state
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
    Repeater {
        model: screenModel
        Item {
            anchors.fill: parent
            MediaPlayer {
                id: mediaPlayer
                source: "resources/vid.mp4"
                autoPlay: bgtogglearea.bgAnimation ? false : true
                autoLoad: bgtogglearea.bgAnimation ? false : true
                loops: -1
            }
            VideoOutput {
				id: videoPlayer
                source: mediaPlayer
                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectCrop
            }
            Audio {
				id: musicPlayer
				autoPlay: musictogglearea.musicPlay ? false : true
				autoLoad: musictogglearea.musicPlay ? false : true
				source: "resources/bgm.ogg"
				loops: -1
            }
            Column {
				anchors.bottom: parent.bottom
				x: 16
				height: 68
				spacing: 6
				Row {
					spacing: 8
					Image {
						id: musicToggle
						source: musictogglearea.musicPlay ? (musictogglearea.containsMouse || musictogglearea.focus ? "resources/checked-hover.png" : "resources/checked-unpressed.png") : (musictogglearea.containsMouse || musictogglearea.focus ? "resources/unchecked-hover.png" : "resources/unchecked-unpressed.png")
						MouseArea {
							id: musictogglearea
							anchors.top: parent.top
							anchors.bottom: parent.bottom
							width: 120
							property string musicPlay
							hoverEnabled: true
							onPressed: if (musicPlay) { 
								musicPlay = ""
								musicPlayer.play();
							} else {
								musicPlay = "true"
								musicPlayer.stop();
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
						source: bgtogglearea.bgAnimation ? ( bgtogglearea.containsMouse || bgtogglearea.focus ? "resources/checked-hover.png" : "resources/checked-unpressed.png" ) : ( bgtogglearea.containsMouse || bgtogglearea.focus ? "resources/unchecked-hover.png" : "resources/unchecked-unpressed.png" )
						MouseArea {
							id: bgtogglearea
							anchors.top: parent.top
							anchors.bottom: parent.bottom
							width: 150
							property string bgAnimation
							hoverEnabled: true
							onPressed: if (bgAnimation) { 
								bgAnimation = ""
								mediaPlayer.play();
							} else {
								bgAnimation = "true"
								mediaPlayer.stop();
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
        }
    }

    /*******************************
               Foreground
    ********************************/
    Rectangle {
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x; y: geometry.y; width: geometry.width; height: geometry.height
        color: "transparent"
		
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
				
				/*********     Separator      **********/
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
                                sddm.login(name.text, password.text, session.index)
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
							onClicked: sddm.login(name.text, password.text, session.index)
							Keys.onPressed: {
								if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
									sddm.login(name.text, password.text, session.index)
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
				
				/*********     Separator      **********/
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
    }
}
