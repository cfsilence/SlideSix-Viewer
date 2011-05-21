import flash.events.TimerEvent;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.utils.Timer;

public var percentComplete:Number;
public var percentLoaded:Number;
public var isLoaded:Boolean = false;
public var videoContents:Video;
public var nc:NetConnection;
public var ns:NetStream;
public var vidProgressTimer:Timer;
public var vidMeta:Object;
public var thumbWasGenerated:Boolean = false;

public var client:Object;

[Bindable] public var hasMedia:Boolean;
[Bindable] public var hasVideo:Boolean = true;
[Bindable] public var isPlaying:Boolean = false;
[Bindable] public var isPaused:Boolean = false;
[Bindable] public var mediaStatus:String = '';


/*
   <mx:VideoDisplay
   progress="setLoaded(event);"
   playheadUpdate="updateTime(event);"
   backgroundAlpha="0.5"
   id="videoContents"
   width="130"
   height="{hasMedia &amp;&amp; hasVideo ? 96 : 0}"
   autoPlay="false"
   ready="vidReadyHandler(event)"
   bufferTime="0.5"
   autoRewind="false"
   playheadUpdateInterval="1" />
 */


public function initVideo():void {
	client = new Object();
	client.onMetaData = metaReceivedHandler;
		
	nc = new NetConnection();
	nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
	nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
	nc.connect(null);
	
	vidProgressTimer = new Timer(10);
	vidProgressTimer.addEventListener(TimerEvent.TIMER, vidTimerHandler);
}

public function netStatusHandler(event:NetStatusEvent):void {
	 /* if(event.info.code.indexOf('NetStream.Buffer') == -1){
		Alert.show(event.info.code)
	} */ 
	switch (event.info.code) {
		case "NetConnection.Connect.Success":
			connectStream();
			break;
		case "NetStream.Play.StreamNotFound":
			break;
		case "NetStream.Play.Start":
			vidProgressTimer.start();
			break;
		case "NetStream.Play.Stop":
			vidComplete();
			break;
		case "NetStream.Buffer.Full":
			try{
				//slideNotes.text += '\n'+ns.time + ' ' + vidMeta.duration;
			}
			catch(e:Error){
			}
			if(!thumbWasGenerated){
				ns.pause();
				ns.soundTransform.volume = 1;
				playProgressBar.setProgress(0,0);
				thumbWasGenerated = true;
			}
			break;
	}
}

public function connectStream():void {
	ns = new NetStream(nc);
	ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
	ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
	ns.client = client;
	
	videoContents = new Video();
	videoContents.width = 130;
	videoContents.height = 98;
	videoContainer.addChild(videoContents);
	videoContents.attachNetStream(ns);
}

public function generateThumbPreview():void{
	thumbWasGenerated = false;
	ns.soundTransform.volume = 0;
	ns.play(slideMediaURL);
}

public function securityErrorHandler(event:SecurityErrorEvent):void {
	//trace("securityErrorHandler: " + event);
}

public function asyncErrorHandler(event:AsyncErrorEvent):void {
	// ignore AsyncErrorEvent events.
}

public function vidTimerHandler(e:TimerEvent):void{
	try{
		playProgressBar.setProgress(ns.time, vidMeta.duration);
		//playPosition.text = ns.time.toFixed(0) + ' of ' + vidMeta.duration.toFixed(0);
	}
	catch(e:Error){
	
	}
}

public function metaReceivedHandler(m:Object):void{
	isLoaded = true;
	vidMeta = m;
	if(vidMeta.videocodecid > 1){
		hasVideo = true;
		videoContainer.visible = true;
	}
	else{
		hasVideo = false;
		videoContainer.visible = false;
	}
}

public function vidComplete():void {
	vidProgressTimer.stop();
	videoContainer.visible = false;
	if (isSlidePlaying) {
		stopMedia();
		transition('next');
	}
	else {
		//audio only files get wonky and wont report 100% done so we transition them here
		if (!hasVideo && hasNext) transition('next');
		if (!hasNext) isSlidePlaying = false;
	}
}

public function playMedia():void {
	if (!isPlaying && !isPaused) {
		ns.play(slideMediaURL);
		isPlaying = true;
		isPaused = false;
		mediaStatus = 'playing';
	}
	else if(!isPlaying && isPaused){
		ns.resume();
		isPlaying = true;
		mediaStatus = 'playing';
		isPaused = false;
	}
	else {
		isPlaying = false;
		isPaused = true;
		ns.pause();
		mediaStatus = 'paused';
	}	
}

public function stopMedia():void {	
	playProgressBar.setProgress(0, 0);
	if (isPlaying) {
		ns.close();
		connectStream();
		mediaStatus = 'stopped';
	}
	playProgressBar.setProgress(0,0);
	isPlaying = false;
	isPaused = false;
}
