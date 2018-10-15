function getFormattedDate(mc){
	var timestampString = mc.getPayloadXML()..*::TIMESTAMP.toString();
	var timestamp = new Date(timestampString);
    var month = format(timestamp.getMonth() + 1);
    var day = format(timestamp.getDate());
    var year = format(timestamp.getFullYear());
    var hours = format(timestamp.getHours());
    var minutes = format(timestamp.getMinutes());
    return year + "-" + month + "-" + day + "T" + hours + ":" + minutes+ ":00+01:00";
}