%dw 2.0
output application/json

import failIf from dw::Runtime

import * from dw::custom::CXMLHelper

fun formatPartnerContact(invoicePartners, contactRole) = ((invoicePartners.*Contact filter $.@role == contactRole) map formatAddress($))[0]

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