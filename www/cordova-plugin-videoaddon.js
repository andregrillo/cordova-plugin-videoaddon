var exec = require('cordova/exec');

exports.playDeskercises = function (success, error, videoArray, videoTitle, liked) {
    exec(success, error, 'VideoPlayer', 'loadDeskercises', [videoArray,videoTitle,liked]);
};

exports.playMindfulness = function (success, error, backgroundVideoURL,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked) {
    exec(success, error, 'VideoPlayer', 'loadMindfullness', [backgroundVideoURL,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked]);
};
