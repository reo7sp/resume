import './index.scss';

const $ = require('jquery-slim');

let width = null;
let height = null;
let isWithGiraffe = null;
let giraffeHiText = null;

function reInit() {
    width = $(window).width();
    height = $(window).height();

    const wasWithGiraffe = isWithGiraffe;
    isWithGiraffe = width > 992;

    if (wasWithGiraffe !== isWithGiraffe) {
        if (isWithGiraffe) {
            $('.giraffe-background--mobile').remove();
            $(document.body).append('<div class="giraffe-background giraffe-background--back">');
            $(document.body).append('<img class="giraffe-background giraffe-background--giraffe" src="images/giraffe.png">');
            $(document.body).append(`<div class="giraffe-background giraffe-background--dialog">${giraffeHiText}</div>`);
        } else {
            $('.giraffe-background--giraffe').remove();
            $('.giraffe-background--dialog').remove();
            $('.giraffe-background--back').remove();
            $(document.body).append('<img class="giraffe-background giraffe-background--mobile" src="images/giraffe-mobile.jpg">');
        }
    }
}

function moveGiraffe(percentX, percentY) {
    const $dialog = $('.giraffe-background--dialog');
    $dialog.css('right', `${100 + percentX * 140}px`);
    $dialog.css('top', `${250 + -percentY * 75}px`);

    const $giraffe = $('.giraffe-background--giraffe');
    $giraffe.css('right', `${-50 + percentX * 50}px`);
    $giraffe.css('bottom', `${-25 + percentY * 25}px`);

    const $back = $('.giraffe-background--back');
    $back.css('background-position', `${-50 + -percentX * 20}px ${-50 + -percentY * 5}px`);
}

$(document).mousemove((e) => {
    if (isWithGiraffe) {
        const percentX = e.clientX / width;
        const percentY = e.clientY / height;
        moveGiraffe(percentX, percentY);
    }
});

$(window).resize(() => {
    reInit();
});

$(() => {
    giraffeHiText = $('#giraffe-hi-text').text();
    reInit();
    if (isWithGiraffe) {
        moveGiraffe(0, 0);
    }
});
