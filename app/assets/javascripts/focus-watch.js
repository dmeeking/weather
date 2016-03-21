var blurred = false;
var timeOfBlur = 0;
window.onblur = function() {
    blurred = true;
    timeOfBlur = new Date().getTime();
};
window.onfocus = function() {
    if(blurred && timeOfBlur > 0){
        var now = new Date().getTime();
        var refreshTime = 5*60*1000; //5 minutes
        if(now - timeOfBlur >= refreshTime)
            location.reload();
    }
    blurred = false;
    timeOfBlur = 0;

};
