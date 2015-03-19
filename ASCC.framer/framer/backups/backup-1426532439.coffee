# Module
module = require "ASCC"

screenWidth = Framer.Device.screen.width
screenHeight = Framer.Device.screen.height

# Background layer
background = new BackgroundLayer
	backgroundColor: "#000000"

# Frontmost app
app = new Layer
	x: 0
	y: 0
	originX: .5
	originY: .5
	width: screenWidth
	height: screenHeight
	backgroundColor: "#ffffff"
	
app.states.add ({
	appSwitcher: {midX: 0, scale: .5}
	app: {x: 0, y: 0, scale: 1}
	})
	
# Make app draggable
# (layer, speedX, speedY)
module.makeDraggable(app, 0, 0)

originY = null
dragDirection = null

app.on Events.DragStart, ->
	app.animateStop()
	originY = event.pageY
	# Setup _updateVelocity and chooseGesture
	module.addListeners(app)

app.on Events.DragMove, ->
	# (event, layer, originY)
	dragDirection = module.calculateVelocity(event, app, originY)
	
app.on Events.DragEnd, ->
	state = switch
		when module.gesture is "Drag"
			if dragDirection > 0
				app.states.switch "appSwitcher"
				break
			else
				app.states.switch "app"
				break
		else
			break
		
	module.removeListeners()
	

	