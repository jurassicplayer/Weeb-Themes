import QtQuick 2.7
import QtQuick.Particles 2.0
import QtQuick.Window 2.2


Rectangle {
	id: backgroundContainer
	
	// Define some miscellanous variables
	width: Screen.width
	height: Screen.height
	property int stage
	property int sequence: 0
	
	// Get KDE splash screen stages
	onStageChanged: {
		if (stage==1) {
		}
		if (stage==2) {
		}
		if (stage==3) {
			beltTop.opacity=0.3
			beltMid.opacity=0.3
			beltBot.opacity=0.3
		}
		if (stage==4) {
		}
		if (stage==5) {
			backgroundContainer.sequence=1.0
			text.opacity=0.3
			beltMid2.opacity=0.3
		}
		if (stage==6) {
		}
	}
	
	// Create background gradient
	Rectangle {
		anchors.margins: 0
		anchors.fill: parent
		gradient: Gradient {
			GradientStop { position: 0.0; color: "#202020" }
			GradientStop { position: 1.0; color: "#330066" }
		}
	}
	
	// Secondary Animation
	Behavior on sequence {
		NumberAnimation {target: beltMid; property: "width"; to: Screen.width * 0.62; duration: 1000 }
	}
	
	ParticleSystem {
	    id: backgroundParticles
		anchors.centerIn: parent
		ImageParticle {
            source: "images/starParticleSmall.png"
            anchors.fill: parent
        }
	}
	// Small snowflakes generator
	Emitter {
	    id: smallEmitter
	    system: backgroundParticles
		anchors.fill: backgroundContainer
		emitRate: 60
		lifeSpan: 4000; lifeSpanVariation: 400
		size: 10
		velocity: PointDirection {xVariation: 60; y:50; yVariation: 30;}
        shape: MaskShape {
            source: "images/starParticleSmall.png" 
        }
	}
	
	// Top bar of the belt (acts on opacity)
	Rectangle {
		id: beltTop
		anchors.bottom: beltMid.top
		anchors.bottomMargin: 15
		anchors.left: parent.left
		width: 0; height: 20
		color: "#FFFFFF"
		opacity: 0
		Behavior on opacity {
			NumberAnimation {target: beltTop; property: "width"; to: backgroundContainer.width; duration: 2000 
			}
		}
	}
	// Middle bar of the belt (acts on opacity)
	Rectangle {
		id: beltMid
		anchors.verticalCenter: parent.verticalCenter
		anchors.left: parent.left
		width: 0; height: 150
		color: "#FFFFFF"
		opacity: 0
		Behavior on opacity {
			NumberAnimation {target: beltMid; property: "width"; to: backgroundContainer.width; duration: 2000 
			}
		}
	}
	// Bottom bar of the belt (acts on opacity)
	Rectangle {
		id: beltBot
		anchors.top: beltMid.bottom
		anchors.topMargin: 15
		anchors.left: parent.left
		width: 0; height: 20
		color: "#FFFFFF"
		opacity: 0
		Behavior on opacity {
			NumberAnimation {target: beltBot; property: "width"; to: backgroundContainer.width; duration: 2000 
			}
		}
	}
	// Character foreground image (above previous layers)
	Image {
		id: renderForeground
		anchors.bottom: parent.bottom
		// Image render screen resolution scaling
		x: Screen.width * 0.05
		width: Screen.width * 0.50; height: renderForeground.width / 736 * 572
		source: "images/Render.png"
	}
	// Splash text anchored to middle belt
	Text {
		id: text
		color: "#FFFFFF"
		font.pointSize: 70
		anchors.left: beltMid.right
		anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
		width: Screen.width * 0.31
		text: "welcome"
		opacity: 0
		Behavior on opacity {NumberAnimation {duration: 1000; easing {type: Easing.InOutQuad}}}
	}
	Rectangle {
        id: beltMid2
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: text.right
        width: Screen.width * 0.5; height: 150
		color: "#FFFFFF"
		opacity: 0
    }
    ParticleSystem {
	    id: foregroundParticles
		anchors.centerIn: parent
		ImageParticle {
			source: "images/starParticleMedium.png"
            anchors.fill: parent
        }
	}
	// Medium snowflakes generator
    Emitter {
	    id: mediumEmitter
	    system: foregroundParticles
		anchors.fill: backgroundContainer
		emitRate: 13
		lifeSpan: 4000; lifeSpanVariation: 400
		size: 20
		velocity: PointDirection {xVariation: 60; y:50; yVariation: 25;}
        shape: MaskShape {
            source: "images/starParticleMedium.png" 
        }
	}
	// Large snowflakes generator
	Emitter {
	    id: largeEmitter
	    system: foregroundParticles
		anchors.fill: backgroundContainer
		emitRate: 3
		lifeSpan: 3000; lifeSpanVariation: 300
		size: 30
		velocity: PointDirection {xVariation: 60; y:70; yVariation: 20;}
        shape: MaskShape {
            source: "images/starParticleLarge.png" 
        }
	}
}
