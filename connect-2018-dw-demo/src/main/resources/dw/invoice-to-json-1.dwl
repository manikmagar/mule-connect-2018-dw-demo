%dw 2.0
output application/json

import failIf from dw::Runtime

fun joinAttributes(data,delimiter) = data pluck $ joinBy delimiter	
fun getIdentity(domain,data)= (data.*Credential filter $.@domain == domain).Identity
fun formatPartnerContact(invoicePartners, contactRole) = (invoicePartners.*Contact filter $.@role == contactRole) map {
	"name": $.Name,
	"address": joinAttributes($.PostalAddress, ","),
	"email": $.Email,
	"phone": $.*Phone map {
		"type": $.@name,
		"number": formatPhoneNumber($) 
	},
	"fax": $.*Fax map {
		"type": $.@name,
		"number": formatPhoneNumber($) 
	}
}

fun formatPhoneNumber(dataXml) = joinAttributes(dataXml.TelephoneNumber,"") as Number as String {format: "+"}
fun formatMoney(dataXml) = { currency: dataXml.@currency, amount: dataXml as Number}

fun mapTaxData(dataXml) = dataXml.*TaxDetail map {
	purpose: $.@purpose,
	category: $.@category,
	taxable: formatMoney($.TaxableAmount.Money),
	tax: formatMoney($.TaxAmount.Money),
	taxLocation: $.TaxLocation default ""
}

var requestHeader = payload.cXML.Request.InvoiceDetailRequest.InvoiceDetailRequestHeader

---
{
	"supplier": getIdentity("AribaNetworkUserId", payload.cXML.Header.From),
	"buyer": getIdentity("AribaNetworkUserId", payload.cXML.Header.To),
	"invoiceId": requestHeader.@invoiceID,
	"invoiceDate": requestHeader.@invoiceDate as DateTime as String {format: "MM/dd/yyyy HH:mm z"},
	"buyer": formatPartnerContact(requestHeader.*InvoicePartner, "soldTo"),
	"PhoneNumber": formatPhoneNumber(requestHeader.InvoicePartner.Contact.Phone), 
	"payee": formatPartnerContact(requestHeader.*InvoicePartner, "remitTo"),
	
	
	//This is an Invoice Partner that contains remitTo Contact
	// Using the selector .@ to get all xml attributes
	"payeeBank": 
		((requestHeader.*InvoicePartner filter $.Contact.@role == "remitTo")[0]).*IdReference.@,

	orderItems: payload.cXML.Request.InvoiceDetailRequest.*InvoiceDetailOrder.InvoiceDetailItem map 
		using (taxDataValue= mapTaxData($.Tax), subTotal = formatMoney($.SubtotalAmount.Money)) {
		itemId: $.InvoiceDetailItemReference.ItemID.SupplierPartID,
		description: trim($.InvoiceDetailItemReference.Description),
		quantity: $.@quantity as Number,
		uom: $.UnitOfMeasure,
		price: formatMoney($.UnitPrice.Money),
		subtotal: subTotal,
		taxData: taxDataValue,
		//Adding a validation to ensure the 
		grossAmount: using (grossAmount = formatMoney($.GrossAmount.Money)) 
								grossAmount failIf(grossAmount.amount == 0),
		netAmount: formatMoney($.NetAmount.Money)
	}
	
}