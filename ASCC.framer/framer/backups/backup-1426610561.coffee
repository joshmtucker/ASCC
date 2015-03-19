# This imports all the layers for "ASCC" into layers
layers = Framer.Importer.load "imported/ASCC"
Utils.globalLayers(layers)

# Module
module = require "ASCC"

screenWidth = Framer.Device.screen.width
screenHeight = Framer.Device.screen.height

originY = null
dragDirection = null

switcherCurve = "spring(175, 30, 0)"
appCurve = "spring(350, 40, 0)"
	
calcbot.states.add ({
	appSwitcher: {midX: 0, scale: .4733}
	app: {x: 0, y: 0, scale: 1}
	})
	
# Make calcbot draggable
# (layer, speedX, speedY)
module.makeDraggable(calcbot, 0, 0)

spotify.states.add ({
	app: {originX: .5, originY: .5, scale: 1, x: screenWidth}
	appSwitcher: {originX: .5, originY: .5, midX: screenWidth/2, scale: .4733}
	})

spotify.states.switchInstant "app"

recents.states.add ({
	hidden: {opacity: 0}
	shown: {opacity: 1}
	})

recents.states.animationOptions.curve = "spring(650, 30, 10)"	
recents.states.switchInstant "hidden"

controlCenter = new Layer
	x: 0
	y: 0
	width: screenWidth
	height: screenHeight
	backgroundColor: "#ffffff"
	
controlCenter.states.add({
	closed: {y: screenHeight}
	open: {y: screenHeight * .35}
	})
	
controlCenter.states.switchInstant "closed"

# Make controlCenter draggable
module.makeDraggable(controlCenter, 0, 1)

calcbot.on Events.DragStart, ->
	calcbot.animateStop()
	originY = event.pageY
	# Setup _updateVelocity and chooseGesture
	module.addListeners(calcbot)

calcbot.on Events.DragMove, ->
	# (event, layer, originY)
	dragDirection = module.calculateVelocity(event, calcbot, originY, controlCenter, recents)
	
calcbot.on Events.DragEnd, ->
	state = switch
		when module.gesture is "Drag"
			if dragDirection > 0 && calcbot.scale < .70
				spotify.scale = calcbot.scale
				calcbot.states.switch "appSwitcher", {curve: switcherCurve}
				spotify.states.switch "appSwitcher", {curve: switcherCurve}
				recents.states.switch "shown"
				
				module.appSwitcher(calcbot, spotify, recents, appCurve)
				
			else if dragDirection == 0 && calcbot.scale < .70
				spotify.scale = calcbot.scale
				calcbot.states.switch "appSwitcher", {curve: switcherCurve}
				spotify.states.switch "appSwitcher", {curve: switcherCurve}
				recents.states.switch "shown"

				module.appSwitcher(calcbot, spotify, recents, appCurve)
			else
				calcbot.states.switch "app", {curve: appCurve}
				spotify.states.switch "app", {curve: appCurve}
				recents.states.switch "hidden"
		else
	
	module.removeListeners()

controlCenter.on Events.DragStart, ->
	controlCenter.animateStop()
	
	
controlCenter.on Events.DragEnd, ->
	if controlCenter.draggable.calculateVelocity().y > 0
		controlCenter.states.switch "closed", {curve: "spring(550, 40, 0)"} 
		calcbot.draggable.enabled = true
	else
		controlCenter.states.switch "open", {curve: "spring(550, 25, 0)"}
	exports.gesture = null
	module.removeListeners() 	

	