# cordova-plugin-videoaddon
Plays a video sequence with swap gestures

How to use it:

VideoPlayer.playDeskercises(function(s){alert(s)},function(e){alert(e)},["base64String","https://videodelivery.net/495fa2d6a748aef54c838e39ddcc5dc3/manifest/video.m3u8", "https://videodelivery.net/709c95e041a3532c98e175f5d3a4bddc/manifest/video.m3u8", "https://videodelivery.net/fcd0c841e36d788554d0c36a7e2caee4/manifest/video.m3u8"],["video 1", "video 2 com title maior", "video 3"],false);
        
VideoPlayer.loadBreathwork(function(s){alert(s)},function(e){alert(e)},"base64String","https://videodelivery.net/53e4716d4644ec7e2c1dc98fd60b56cd/manifest/video.m3u8",["https://biotronik-dev.outsystemsenterprise.com/DeStress_App_Res/02_OceanWaves.mp3", "https://biotronik-dev.outsystemsenterprise.com/DeStress_App_Res/01_ForestRain.mp3"],"https://biotronik-dev.outsystemsenterprise.com/DeStress_App_Res3/GM-02-De-EscalatingStress.mp3","https://azappcore.blob.core.windows.net/azappcore/sub_1632129097732.srt",10,false);

VideoPlayer.playMindfulness(function(s){alert(s)},function(e){alert(e)},"base64String",["https://videodelivery.net/53e4716d4644ec7e2c1dc98fd60b56cd/manifest/video.m3u8", "https://videodelivery.net/f496c5243c9ad7f62db8e1a0c9885afb/manifest/video.m3u8"],["https://biotronik-dev.outsystemsenterprise.com/DeStress_App_Res/02_OceanWaves.mp3", "https://biotronik-dev.outsystemsenterprise.com/DeStress_App_Res/01_ForestRain.mp3"],"https://biotronik-dev.outsystemsenterprise.com/DeStress_App_Res3/GM-02-De-EscalatingStress.mp3","https://azappcore.blob.core.windows.net/azappcore/sub_1632129097732.srt",10,false);

VideoPlayer.playMindfulnessFromLocal(function(s){alert(s)},function(e){alert(e)},"base64String",["myVideoFolder/video.mp4", "myVideoFolder/video.mp4"],["myAudioFolder/01_ForestRain.mp3"],"myAudioFolder/GM-02-De-EscalatingStress.mp3","mySubtitleFolder/sub_1632129097732.srt",10,false);

VideoPlayer.playDeskercisesFromLocal(function(s){alert(s)},function(e){alert(e)},"base64String",["myVideoFolder/video.mp4", "myVideoFolder/video.mp4"],["video 1", "video 2"],false);
        
VideoPlayer.loadBreathworkFromLocal(function(s){alert(s)},function(e){alert(e)},"base64String","myVideoFolder/video.mp4",["myAudioFolder//02_OceanWaves.mp3", "myAudioFolder/01_ForestRain.mp3"],"myAudioFolder/GM-02-De-EscalatingStress.mp3","mySubtitleFolder/sub_1632129097732.srt",10,false);

