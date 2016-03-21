var blurred = false;
var timeOfBlur = 0;
window.onblur = function() {
    console.log('blur');
    blurred = true;
    timeOfBlur = new Date().getTime();
};
window.onfocus = function() {
    console.log('focus',blurred,timeOfBlur );
    if(blurred && timeOfBlur > 0){
        var now = new Date().getTime();
        var refreshTime = 5*60*1000; //5 minutes
        if(now - timeOfBlur >= refreshTime)
            location.reload();
    }
    blurred = false;
    timeOfBlur = 0;

};
