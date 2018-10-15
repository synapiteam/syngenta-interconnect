function getPathValues( uri, template){
    var searchString = '';
    var pathParams = '';
    var value = '';

    while( template.indexOf('{') > 0){
    	searchString = template.substring(0,template.indexOf('{') );
    	pathParams += '"'+ template.substring(template.indexOf('{')+1, template.indexOf('}') ) +'":';
    	value = uri.substring(uri.indexOf(searchString)+searchString.length);
    	
        if(value.indexOf('/') > 0)
           value = value.substring(0,value.indexOf('/') );
           
        pathParams += '"'+value+'",';
           
        template = searchString + value + template.substring(template.indexOf('}')+1);
    }
 
	return pathParams.substring(0,pathParams.length -1);
}

function yenloSplit(value, char){

   if( value.indexOf(char) > 0){
      var ret = [value.substring(0,value.indexOf(char) ),value.substring(value.indexOf(char) + 1) ];
   }else{
      var ret = [value];
   }
   
   return ret;
}

function getPathAndQuery(mc){
var uri_template = String(mc.getProperty('YLO_URI_TEMPLATE') );
var uri_received = String(mc.getProperty('YLO_URI') );
var httpMethod = String(mc.getProperty('YLO_HTTP_METHOD') );
    
var uri = yenloSplit(uri_received, '?');   
var queryParams = '';
var pathParams = '';
if (uri.length > 1){ 
    var queryParams = uri[1].split('&'); 
	for(var i = 0; i < queryParams.length; i++){
		queryParams[i] = '"'+ queryParams[i].replace('=', '":"') + '"';
	}
}

pathParams = getPathValues(uri[0], yenloSplit(uri_template,'?')[0] );
var json = '';
if(pathParams.trim().length > 0){
  json += pathParams;

  if(queryParams.length > 0){
     json += (','+queryParams).replace(/""/g,'"');
  }
} 
else{

	if(queryParams.length > 0){
	     json += (''+queryParams).replace(/""/g,'"');
	 }
}

if( json.length <= 0){
	json = '{"object" : "null"}';
}else{
	json = '{' + json +'}';
}

mc.setProperty("YLO_URI_PARAMS", json);

if("POST" != httpMethod){
   mc.setPayloadJSON(json);
}
}