window.onload = ->
	introSection = document.querySelector("#intro-section")
	tween(
		introSection.offsetHeight,
		window.innerHeight,
		0.05,
		250,
		-> introSection.offsetHeight,
		(newVal) -> introSection.setAttribute("style", "height: #{ newVal }px")
	) if window.innerHeight > 768

	document.querySelector(".scroll-btn").onclick = -> tween(
		window.pageYOffset,
		document.querySelector("#intro-section").offsetHeight,
		0.025,
		0,
		-> window.pageYOffset,
		(newVal) -> window.scrollTo(0, newVal)
	)

	return
