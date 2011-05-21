/**
 * This work is licensed under a Creative Commons Attribution 3.0 Unported License
 * 
 * Read the full license here:
 * http://creativecommons.org/licenses/by/3.0/
 * 
 * Author:  Sebastiaan Holtrop
 * Blog:    http://www.sebastiaanholtrop.com
 */
package com.sebastiaanholtrop.components.coverflow.event {
	
	import flash.events.Event;
	
	/**
	 * @private
	 * @author Sebastiaan Holtrop
	 * 
	 */	
	public class CoverFlowEvent extends Event {
		
		public static const CREATIONCOMPLETE:String = "creationComplete";
		public static const COVERCLICKED:String = "coverClicked";
		public static const COVERMOUSEDOVER:String = "coverMousedOver";
		
		public function CoverFlowEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			
		}
		
	}
}