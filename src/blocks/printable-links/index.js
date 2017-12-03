import './index.scss';

import $ from 'jquery-slim';

$(() => {
    $('a').each(function () {
        // noinspection EqualityComparisonWithCoercionJS
        if ($(this).data('no-printable-links') != null) {
            return;
        }

        const href = $(this).attr('href');
        if (!href) {
            return;
        }

        const isHrefRelative = href.indexOf('http') !== 0 && !(href.indexOf('skype:') === 0 || href.indexOf('mailto:') === 0);
        let title = href.replace('www.', '').replace('skype:', '').replace('?add', '').replace('mailto:', '');
        if (isHrefRelative) {
            title = 'https://oleg.rocks/' + title;
        }

        const classes = $(this).attr('class');
        $(this).after(`<a class="printable-link ${classes}" href="${href}">${title}</a>`);
        $(this).addClass('not-printable-link');
    });
});
