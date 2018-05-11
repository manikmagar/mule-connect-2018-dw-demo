%dw 2.0
import failIf from dw::Runtime

fun joinAttributes(data,delimiter) = (data default {}) pluck $ joinBy delimiter	
fun getIdentity(domain,data)= (data.*Credential filter $.@domain == domain)[0].Identity
fun formatAddress(dataXml) = {
	"name": dataXml.Name,
	"address": trim(joinAttributes(dataXml.PostalAddress, ",")),
	"email": dataXml.Email,
	"phone": dataXml.*Phone default [] map {
		"type": $.@name,
		"number": formatPhoneNumber($) 
	},
	"fax": dataXml.*Fax default [] map {
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
