###

Build in response to my Medium article, "Swipe vs. drag, are they more than just a distance?" The data used to set certain values were given in said article. 

SPECIAL THANKS
––––––––––––––

To the guys at Framer – they are rockin' awesome and I appreciate their dedication in making this an amazing and powerful tool.

To the friends and family that helped make this project a reality, as well as support me and give me important feedback.

All my participants – it's not necessarily easy to open a foreign link and believe that it's just a basic experiment :).

To teehan+lax for their iOS 8 iPhone 6 .sketch file. Didn't want to have to recreate Control Center for this experiment! http://www.teehanlax.com/tools/

TO POTENTIAL USERS/TINKERERS
––––––––––––––––––––––––––––

Best place to test this is in a fullscreen browser. There are two great ones (both free):

Framer (Android) -> https://play.google.com/store/apps/details?id=com.framerjs.android
Frameless (iOS) -> https://itunes.apple.com/us/app/id933580264

In the case of Frameless, make sure to disable "Swipe up from bottom" in Settings so that you don't accidentally open the address bar.

For the sake of not making everything so strenuous, not everything is interactable. If you watch the video at the bottom of the article, it shows you what is (or just screw around and you'll figure it out pretty quickly).

–––

Other than some of export functions I use in the following code, I made a few other export variables.

 --> module.gesture – See which gesture was set during the calculation (or if you want to mess up the calculation, set it manually). 

The starting value is null and it is reset to null after certain interactions are complete.

--> module.minDistance – Set the minimum distance for detecting a drag gesture (compared along with module.minGestureVelocity). You can set this to whatever you want to see different results. 

The default value is 110.

--> module.minGestureVelocity – Set the minimum velocity value for detecting a drag gesture (compared along with module.minDistance). You can set this to whatever you want to see different results.

The default value is 1.786. 

###

### 

SETUP

###

# This imports all the layers for "ASCC" into layers
layers = Framer.Importer.load "imported/ASCC"
Utils.globalLayers(layers)

# Module
module = require "ASCC"

screenWidth = Framer.Device.screen.width
screenHeight = Framer.Device.screen.height

# Used later for distance calculations
originY = null
dragDirection = null

# Curves for states
switcherCurve = "spring(175, 30, 0)"
appCurve = "spring(350, 40, 0)"
	
calcbot.states.add ({
	app: {originX: .5, originY: .5, x: 0, y: 0, scale: 1}
	appSwitcher: {originX: .5, originY: .5, midX: -10, scale: .4867}
	})
	
# Make calcbot draggable
# (layer, speedX, speedY)
module.makeDraggable(calcbot, 0, 0)

spotify.states.add ({
	app: {originX: .5, originY: .5, scale: 1, x: screenWidth}
	appSwitcher: {originX: .5, originY: .5, midX: screenWidth/2, scale: .4867}
	})

spotify.states.switchInstant "app"

alto.states.add ({
	app: {originX: .5, originY: .5, scale: 1, x: screenWidth + alto.width}
	appSwitcher: {originX: .5, originY: .5, midX: 760, scale: .4867}
	})

alto.states.switchInstant "app"

icons.states.add({
	app: {x: screenWidth}
	appSwitcher: {x: 53}
	})
	
icons.states.switchInstant "app"

recents.states.add ({
	app: {opacity: 0}
	appSwitcher: {opacity: 1}
	})

recents.states.animationOptions.curve = "spring(650, 30, 10)"	
recents.states.switchInstant "app"
	
controlCenter.states.add({
	closed: {y: screenHeight}
	open: {y: screenHeight - controlCenter.height}
	})
	
controlCenter.states.switchInstant "closed"

# Make controlCenter draggable
module.makeDraggable(controlCenter, 0, 1)
controlCenter.draggable.maxDragFrame = 
	y: screenHeight - controlCenter.height
	
###

EVENTS

###

calcbot.on Events.DragStart, ->
	calcbot.animateStop()
	originY = event.pageY
	# Setup _updateVelocity and chooseGesture
	module.addListeners(calcbot)

calcbot.on Events.DragMove, ->
	# (event, layer, originY)
	dragDirection = module.calculateVelocity(event, calcbot, controlCenter, recents, originY)
	
calcbot.on Events.DragEnd, ->
	state = switch
		when module.gesture is "Drag"
			if dragDirection > 0 && calcbot.scale < .70
				spotify.scale = calcbot.scale
				alto.scale = calcbot.scale

				calcbot.states.switch "appSwitcher", {curve: switcherCurve}
				spotify.states.switch "appSwitcher", {curve: switcherCurve}
				alto.states.switch "appSwitcher", {curve: switcherCurve}
				icons.states.switch "appSwitcher", {curve: switcherCurve}
				
				recents.states.switch "appSwitcher"
				
				
				module.appSwitcher(calcbot, spotify, alto, recents, icons, calcbotIcon, appCurve)
				
			else if dragDirection == 0 && calcbot.scale < .70
				spotify.scale = calcbot.scale
				alto.scale = calcbot.scale
				
				calcbot.states.switch "appSwitcher", {curve: switcherCurve}
				spotify.states.switch "appSwitcher", {curve: switcherCurve}
				alto.states.switch "appSwitcher", {curve: switcherCurve}
				icons.states.switch "appSwitcher", {curve: switcherCurve}
				
				recents.states.switch "appSwitcher"

				module.appSwitcher(calcbot, spotify, recents, icons, calcbotIcon, appCurve)
			else
				calcbot.states.switch "app", {curve: appCurve}
				spotify.states.switch "app", {curve: appCurve}
				alto.states.switch "app", {curve: appCurve}
				icons.states.switch "app", {curve: appCurve}
				
				recents.states.switch "app"
		else
	
	module.removeListeners()

controlCenter.on Events.DragStart, ->
	controlCenter.animateStop()
	
controlCenter.on Events.DragEnd, ->
	if controlCenter.draggable.calculateVelocity().y > 0
		controlCenter.states.switch "closed", {curve: "spring(550, 25, 0)"} 
		calcbot.draggable.enabled = true
	else
		controlCenter.states.switch "open", {curve: "spring(550, 25, 0)"}
	module.gesture = null
	module.removeListeners() 	
