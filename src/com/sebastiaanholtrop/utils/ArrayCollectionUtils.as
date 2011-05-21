/**
 * This work is licensed under a Creative Commons Attribution 3.0 Unported License
 * 
 * Read the full license here:
 * http://creativecommons.org/licenses/by/3.0/
 * 
 * Author:  Sebastiaan Holtrop
 * Blog:    http://www.sebastiaanholtrop.com
 */
package com.sebastiaanholtrop.utils {
	
	import mx.collections.ArrayCollection;
	
	/**
	 * Some util methods for ArrayCollections
	 * @author Sebastiaan Holtrop
	 */	
	public class ArrayCollectionUtils {
		
		/**
		 * For cloning arrayCollections
		 * @param source The arrayCollection to clone
		 * @return ArrayCollection the clone arrayCollection of the source
		 */		
		public static function clone(source:ArrayCollection):ArrayCollection {
			
			var destination:ArrayCollection = new ArrayCollection();
			
			for (var i:uint = 0; i < source.length; i++) {
				destination.addItem(source.getItemAt(i));
			}
			
			return destination;
		}
	}
}