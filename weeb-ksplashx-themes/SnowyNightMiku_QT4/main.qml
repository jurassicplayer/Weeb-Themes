import QtQuick 1.0
import Qt.labs.particles 1.0


Rectangle {
	id: backgroundContainer
	
	// Define some miscellanous variables
	width: screenSize.width
	height: screenSize.height
	property int w: screenSize.width * 0.65
	property int stage
	property int sequence: 0
	// Image render screen resolution scaling
	property int imageH: 572 / 768 * screenSize.height
	
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
		NumberAnimation {target: beltMid; property: "width"; to: backgroundContainer.w; duration: 800 }
	}
	
	// Small snowflakes generator
	Particles {
		id: smallEmitter
		width: backgroundContainer.width; height: parent.height
		anchors.centerIn: parent
		emissionRate: 9
		count: 600
		lifeSpan: 20000; lifeSpanDeviation: 2000
		angle: 100; angleDeviation: 70; velocity: 50; velocityDeviation: 50
		source: "images/starParticleSmall.png"
		ParticleMotionWander {
			xvariance: 30
			pace: 60
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
		property int propertyX: backgroundContainer.width * 0.07
		x: propertyX
		width: backgroundContainer.imageW
		source: "images/Render.png"
	}
	// Splash text anchored to middle belt
	Text {
		id: text
		color: "#FFFFFF"
		font.pointSize: 70
		anchors.left: beltMid.right
		property int marginX: backgroundContainer.width * 0.03
		anchors.leftMargin: marginX
		anchors.verticalCenter: parent.verticalCenter
		text: "welcome"
		opacity: 0
		Behavior on opacity {NumberAnimation {duration: 1000; easing {type: Easing.InOutQuad}}}
	}
	
	// Medium snowflakes generator
	Particles {
		id: mediumEmitter
		width: backgroundContainer.width; height: parent.height
		anchors.centerIn: parent
		emissionRate: 4
		count: 600
		lifeSpan: 20000; lifeSpanDeviation: 2000
		angle: 100; angleDeviation: 70; velocity: 50; velocityDeviation: 50
		source: "images/starParticleMedium.png"
		ParticleMotionWander {
			xvariance: 30
			pace: 60
		}
	}
	// Large snowflakes generator
	Particles {
		id: largeEmitter
		width: backgroundContainer.width; height: 0
		anchors.horizontalCenter: backgroundContainer.topMargin
		emissionRate: 1
		count: 4
		lifeSpan: 10000; lifeSpanDeviation: 2000
		angle: 120; angleDeviation: 70; velocity:70; velocityDeviation: 30
		source: "images/starParticleLarge.png"
		ParticleMotionWander {
			xvariance: 100
			pace: 50
		}
	}
}
