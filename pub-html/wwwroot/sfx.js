function playSfx(sfx) {
    let audio = document.getElementById(sfx);
    audio.currentTime = 0;
    audio.play();
}