import QtQuick 2.7
import SddmComponents 2.0
import QtMultimedia 5.6
import QtQuick.Window 2.2
import QtQuick.Particles 2.0

Rectangle {
    id: container
    width: Screen.width
    height: Screen.height
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
	ParticleSystem { id: spiral }
	Emitter {
		anchors.bottom: parent.bottom
		anchors.bottomMargin: parent.height*0.2
		anchors.right: parent.right
		anchors.rightMargin: parent.width*0.24
		width: parent.width*0.38
		anchors.top: parent.top
		anchors.topMargin: parent.height*0.24
		system: spiral
		emitRate: 10
		lifeSpan: 3000
		lifeSpanVariation: 2000
		size: 6
		sizeVariation: 3
		endSize: 3
		startTime: 3000
		velocity: AngleDirection{
			angle: 270
			angleVariation: 20
			magnitude: 80
			magnitudeVariation: 40
		}
		ImageParticle {
			anchors.fill: parent
			system: spiral
			source: "resources/lightparticle.png"
		}
		Wander{
			system: spiral
			height: parent.height
			width: parent.width
			y: -parent.width*0.2
			anchors.bottom: parent.bottom
			affectedParameter: Wander.Position
			pace: 1000
			xVariance: parent.width*2
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
            anchors.top: parent.top
            anchors.topMargin: parent.height*0.33
			anchors.left: parent.left
			anchors.leftMargin: parent.width*0.23
            width: 174
            height: 80
            color: "transparent"
            Image {
				anchors.fill: parent
				source: "resources/login.png"
			}
            Column {
				anchors.top: parent.top
				anchors.topMargin: 7
                width: parent.width
                height: parent.height-20
                spacing: 6
            
                /*** Username ***/
                Row {
					anchors.left: parent.left
					anchors.leftMargin: 10
                    spacing: 8
                    height: 30
                    Image {
                        id: userimage
                        width: parent.height; height: parent.height
                        source: "resources/user.png"
                    }
                    TextInput {
                        id: name
                        y: 8
                        width: 150; height: 16
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
                Row {
					anchors.left: parent.left
					anchors.leftMargin: 10
                    spacing: 8
                    height: 30
                    Image {
                        id: passwordimage
                        width: parent.height; height: parent.height
                        source: "resources/passwd.png"
                    }
                    TextInput {
                        id: password
                        y: 8
                        width: 150; height: 16
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
    }
    Component.onCompleted: {
        if (name.text == "")
            name.focus = true
        else
            password.focus = true
    }
}
