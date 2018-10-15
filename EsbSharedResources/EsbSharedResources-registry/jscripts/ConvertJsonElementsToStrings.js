function transform(mc) {
	// get payload in JSON format
    payload = mc.getPayloadJSON();
    
    keys = payload.keys;
    for (k=0; k < keys.length; k++) {
    	currentKey = keys[k];
    	if (currentKey.length > 0) {
    		currentKey = "" + currentKey;
    	}
    }
    
    mc.setPayloadJSON(payload);
}
