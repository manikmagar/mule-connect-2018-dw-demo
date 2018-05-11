%dw 2.0
output application/json

import * from dw::custom::CXMLHelper

var orderHeader = payload.cXML.Request.OrderRequest.OrderRequestHeader

---
{
	"orderNo": "",
	"orderDate": "",
	"totalAmount": formatMoney(orderHeader.Total.Money),
	"shipTo": formatAddress(orderHeader.ShipTo.Address),
	"billTo": formatAddress(orderHeader.BillTo.Address),
	"orderItems": (payload.cXML.Request.OrderRequest.*ItemOut map {
		"itemId": $.ItemID.SupplierPartID,
		"quantity": $.@quantity as Number,
		"unitPrice": formatMoney($.ItemDetail.UnitPrice.Money),
		"unitOfMeasure": $.ItemDetail.UnitOfMeasure,
		"mfPartId": $.ItemDetail.ManufacturerPartID,
		"mfName": $.ItemDetail.ManufacturerName
	})
	
}