tween = (from, to, speed, delay, observeFunc, actionFunc) ->
	pattern = (time) -> if time < 0.5 then 4 * time * time * time else (time - 1) * (2 * time - 2) * (2 * time - 2) + 1

	setTimeout(->
		progress = 0
		distance = to - from
		descriptor = setInterval(->
			progress += speed if progress < 1
			oldVal = observeFunc()
			newVal = from + distance * pattern(progress)
			actionFunc(newVal)
			clearInterval(descriptor) if newVal >= to or oldVal == newVal
			return
		, 16)
		return
	, delay)

	return
