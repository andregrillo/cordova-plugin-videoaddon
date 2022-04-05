var exec = require('cordova/exec');

exports.playDeskercises = function (success, error, splashImage, videoArray, videoTitle, liked) {
    exec(success, error, 'VideoPlayer', 'loadDeskercises', [splashImage, videoArray,videoTitle,liked]);
};

exports.playMindfulness = function (success, error, splashImage, videoArray,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked) {
    exec(success, error, 'VideoPlayer', 'loadMindfullness', [splashImage, videoArray,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked]);
};

exports.loadBreathwork = function (success, error, splashImage, backgroundVideoURL,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked) {
    exec(success, error, 'VideoPlayer', 'loadBreathwork', [splashImage, backgroundVideoURL,audioArray,subtitleURL,secondsToSkip,isLiked,isMuted]);
};

exports.playMindfulnessFromLocal = function (success, error, splashImage, videoArray,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked) {
    exec(success, error, 'VideoPlayer', 'loadMindfullnessVideosFromData', [splashImage, videoArray,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked]);
};

exports.loadBreathworkFromLocal = function (success, error, splashImage, backgroundVideoURL,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked) {
    exec(success, error, 'VideoPlayer', 'loadBreathworkFromData', [splashImage, backgroundVideoURL,audioArray,subtitleURL,secondsToSkip,isLiked,isMuted]);
};

exports.playDeskercisesFromLocal = function (success, error, splashImage, videoArray, videoTitle, liked) {
    exec(success, error, 'VideoPlayer', 'loadDeskercisesFromData', [splashImage, videoArray,videoTitle,liked]);
};
