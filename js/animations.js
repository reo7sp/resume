$(document).ready(function() {
	var animationTime = 250;
	var i = 0;
	$('.gblock').each(function() {
		$(this).delay(250 * (i++)).animate({ opacity: 1 }, 500);
	});
	$('.gblock').hover(
		function() {
			if ($(document).width() < 640) return;
			$(this).find('.gblock-background').stop().fadeTo(animationTime, 0.25);
			$(this).find('.gblock-content').stop().fadeIn(animationTime);
		},
		function() {
			if ($(document).width() < 640) return;
			$(this).find('.gblock-background').stop().fadeTo(animationTime, 1);
			$(this).find('.gblock-content').stop().fadeOut(animationTime);
		}
	);
	$('.hcontactbtn').hover(function() {
		if ($(document).width() < 640) return;
		$(this).find('span').stop().animate({ width: 'toggle' }, animationTime);
	});
	$('.gblock').click(function() {
		if ($(document).width() > 640) return;
		window.location.href = $(this).find('a').attr('href');
	});
});
