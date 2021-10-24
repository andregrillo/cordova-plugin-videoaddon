var exec = require('cordova/exec');

exports.playDeskercises = function (success, error, videoArray, videoTitle, liked) {
    exec(success, error, 'VideoPlayer', 'loadDeskercises', [videoArray,videoTitle,liked]);
};

exports.playMindfulness = function (success, error, videoArray,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked) {
    exec(success, error, 'VideoPlayer', 'loadMindfullness', [videoArray,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked]);
};

exports.loadBreathwork = function (success, error, backgroundVideoURL,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked) {
    exec(success, error, 'VideoPlayer', 'loadBreathwork', [backgroundVideoURL,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked]);
};

exports.playMindfulnessFromLocal = function (success, error, videoArray,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked) {
    exec(success, error, 'VideoPlayer', 'loadMindfullnessVideosFromData', [videoArray,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked]);
};

exports.loadBreathworkFromLocal = function (success, error, backgroundVideoURL,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked) {
    exec(success, error, 'VideoPlayer', 'loadBreathworkFromData', [backgroundVideoURL,audioArray,audioVoiceURL,subtitleURL,secondsToSkip,isLiked]);
};

exports.playDeskercisesFromLocal = function (success, error, videoArray, videoTitle, liked) {
    exec(success, error, 'VideoPlayer', 'loadDeskercisesFromData', [videoArray,videoTitle,liked]);
};
