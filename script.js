// giraffe
(function () {

    var width = null;
    var height = null;
    var isWithGiraffe = null;

    function reInit() {
        width = $(window).width();
        height = $(window).height();

        var wasWithGiraffe = isWithGiraffe;
        isWithGiraffe = width > 992;

        if (wasWithGiraffe !== isWithGiraffe) {
            if (isWithGiraffe) {
                $('.giraffe-background--mobile').remove();
                $(document.body).append('<div class="giraffe-background giraffe-background--back">');
                $(document.body).append('<img class="giraffe-background giraffe-background--giraffe" src="images/giraffe.png">');
                $(document.body).append(`<div class="giraffe-background giraffe-background--dialog">Приветик</div>`);
            } else {
                $('.giraffe-background--giraffe').remove();
                $('.giraffe-background--dialog').remove();
                $('.giraffe-background--back').remove();
                $(document.body).append('<img class="giraffe-background giraffe-background--mobile" src="images/giraffe-mobile.jpg">');
            }
        }
    }

    function moveGiraffe(percentX, percentY) {
        var $dialog = $('.giraffe-background--dialog');
        $dialog.css('right', `${100 + percentX * 140}px`);
        $dialog.css('top', `${250 + -percentY * 75}px`);

        var $giraffe = $('.giraffe-background--giraffe');
        $giraffe.css('right', `${-50 + percentX * 50}px`);
        $giraffe.css('bottom', `${-25 + percentY * 25}px`);

        var $back = $('.giraffe-background--back');
        $back.css('background-position', `${-50 + -percentX * 20}px ${-50 + -percentY * 5}px`);
    }

    $(document).mousemove(function (e) {
        if (isWithGiraffe) {
            var percentX = e.clientX / width;
            var percentY = e.clientY / height;
            moveGiraffe(percentX, percentY);
        }
    });

    $(window).resize(function () {
        reInit();
    });

    $(function () {
        reInit();
        if (isWithGiraffe) {
            moveGiraffe(0, 0);
        }
    });

})();


// printable links
(function () {

    $(function () {
        $('a').each(function () {
            if ($(this).data('no-printable-links') != null) {
                return;
            }

            const href = $(this).attr('href');
            if (!href) {
                return;
            }

            const isHrefRelative = href.indexOf('http') !== 0 && !(href.indexOf('skype:') === 0 || href.indexOf('mailto:') === 0);
            let linkPrettified = href.replace('www.', '').replace('skype:', '').replace('?add', '').replace('mailto:', '');
            if (isHrefRelative) {
                linkPrettified = 'https://oleg.rocks/' + linkPrettified;
            }

            const originalHtml = $(this).html();

            const classes = $(this).attr('class');
            $(this).after(`
                <a class="printable-link ${classes}" href="${href}">
                    <span class="printable-link__original">${originalHtml}</span>
                    <span class="printable-link__transcript"> (${linkPrettified})</span>
                </a>
            `);
            $(this).addClass('not-printable-link');
        });
    });

})();
