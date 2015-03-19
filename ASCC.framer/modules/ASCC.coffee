# Store changes in y and time for velocity
_deltas = []

# Velocity timeout
timeOut = 100

# Distance variable
distance = 0

# Which gesture was used
exports.gesture = null

# Set distance threshold
exports.minDistance = 110

# Set velocity threshold
exports.minGestureVelocity = 1.786

# ––– EXPORT FUNCTIONS

# Interaction for appSwitcher
exports.appSwitcher = (calcbot, spotify, alto, recents, icons, calcbotIcon, curve) ->
	calcbot.draggable.enabled = false
	calcbot.on Events.Click, ->
		calcbot.animateStop()
		spotify.animateStop()
		alto.animateStop()
		icons.animateStop()

		recents.animateStop()


		calcbot.states.switch "app", {curve: curve}
		spotify.states.switch "app", {curve: curve}
		alto.states.switch "app", {curve: curve}
		icons.states.switch "app", {curve: curve}

		recents.states.switch "app"

		calcbot.draggable.enabled = true

		return

	calcbotIcon.on Events.Click, ->
		calcbot.animateStop()
		spotify.animateStop()
		alto.animateStop()
		icons.animateStop()

		recents.animateStop()
		
		calcbot.states.switch "app", {curve: curve}
		spotify.states.switch "app", {curve: curve}
		alto.states.switch "app", {curve: curve}
		icons.states.switch "app", {curve: curve}

		recents.states.switch "app"

		calcbot.draggable.enabled = true

		return

# Calculate how fast gesture moves (includes direction)
exports.calculateVelocity = (event, calcbot, controlCenter, recents, originY) ->
	if _deltas.length < 2
		return 0

	curr = _deltas[-2..-2][0]
	prev = _deltas[-1..-1][0]
	time = curr.t - prev.t

	velocity = ((curr.y - prev.y)/time) * -1

	timeSinceLastMove = (new Date().getTime() - prev.t)

	if timeSinceLastMove > timeOut
		return 0

	if isNaN(velocity) is true
		return 0
	
	calcbot.emit "calculateDistance", event, calcbot, recents, originY
	calcbot.emit "chooseGesture", velocity, calcbot, controlCenter

	return velocity

# Give a layer draggable properties
exports.makeDraggable = (layer, speedX, speedY) ->
	layer.draggable.enabled = true
	layer.draggable.speedX = speedX
	layer.draggable.speedY = speedY

# Remove listeners for updating values
exports.removeListeners = ->
	document.removeEventListener Events.TouchMove, _updateVelocity
	exports.gesture = null
	_deltas = []
	velocity = 0

# Add listeners for updating values
exports.addListeners = (calcbot) ->
	document.addEventListener Events.TouchMove, _updateVelocity
	calcbot.once "chooseGesture", _chooseGesture
	calcbot.on "calculateDistance", _calculateDistance


# ––– LOCAL FUNCTIONS

_calculateDistance = (event, calcbot, recents, originY) ->
	distance = originY - event.pageY

	if exports.gesture is "Drag"
		_drag(distance, calcbot, recents)
	else

_drag = (distance, calcbot, recents) ->
	calcbot.scale = Utils.modulate(distance, [0, 657], [1, .4867], true)
	recents.opacity = Utils.modulate(calcbot.scale, [.70, .4867], [0, 1], true)

_chooseGesture = (velocity, calcbot, controlCenter) ->
	if velocity < exports.minGestureVelocity && distance < exports.minDistance
		exports.gesture = "Drag"
	else
		calcbot.draggable.enabled = false
		controlCenter.states.switch "open", {curve: "spring(550, 25, 0)"} 

_updateVelocity = (event) ->
	updatedDelta = 
		y: event.pageY
		t: event.timeStamp

	_deltas.push updatedDelta
