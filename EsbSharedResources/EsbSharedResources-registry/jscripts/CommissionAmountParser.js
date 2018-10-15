
function matchCommission(mc){
	var commission = mc.getPayloadXML()..*::COMMISSIONAMT.toString();
	var regex = new RegExp(/\d*\.?\d*$/g);
	var amountVal= regex.exec(commission);
	mc.setProperty("amountValue",  amountVal);
	var currencyVal=commission.replace(amountVal, "");
	mc.setProperty("currencyValue",  currencyVal);
}
