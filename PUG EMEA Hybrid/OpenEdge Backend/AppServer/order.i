
 /*------------------------------------------------------------------------
    File        : order
   ----------------------------------------------------------------------*/
  
 /* ***************************  Definitions  ************************** */
   
@openapi.openedge.entity.primarykey (fields="Ordernum").
	
DEFINE TEMP-TABLE ttOrder BEFORE-TABLE bttOrder
FIELD id AS CHARACTER
FIELD seq AS INTEGER
FIELD Ordernum AS INTEGER INITIAL "0" LABEL "Order Num"
FIELD CustNum AS INTEGER INITIAL "0" LABEL "Cust Num"
FIELD CustName LIKE Customer.Name
FIELD OrderDate AS DATE INITIAL "TODAY" LABEL "Ordered"
FIELD ShipDate AS DATE LABEL "Shipped"
FIELD PromiseDate AS DATE LABEL "Promised"
FIELD Carrier AS CHARACTER LABEL "Carrier"
FIELD Instructions AS CHARACTER LABEL "Instructions"
FIELD PO AS CHARACTER LABEL "PO"
FIELD Terms AS CHARACTER INITIAL "Net30" LABEL "Terms"
FIELD SalesRep AS CHARACTER LABEL "Sales Rep"
FIELD BillToID AS INTEGER INITIAL "0" LABEL "Bill To ID"
FIELD ShipToID AS INTEGER INITIAL "0" LABEL "Ship To ID"
FIELD OrderStatus AS CHARACTER INITIAL "Ordered" LABEL "Order Status"
FIELD WarehouseNum AS INTEGER INITIAL "0" LABEL "Warehouse Num"
FIELD Creditcard AS CHARACTER INITIAL "Visa" LABEL "Credit Card"
INDEX seq IS PRIMARY UNIQUE seq
INDEX CustOrder IS  UNIQUE  CustNum  ASCENDING  Ordernum  ASCENDING 
INDEX OrderDate  OrderDate  ASCENDING 
INDEX OrderNum IS  UNIQUE  Ordernum  ASCENDING 
INDEX OrderStatus  OrderStatus  ASCENDING 
INDEX SalesRep  SalesRep  ASCENDING . 

DEFINE TEMP-TABLE ttOrderLine BEFORE-TABLE bttOrderLine
FIELD Ordernum AS INTEGER INITIAL "0" LABEL "Order Num"
FIELD Linenum AS INTEGER INITIAL "0" LABEL "Line Num"
FIELD Itemnum AS INTEGER INITIAL "0" LABEL "Item Num"
FIELD Price AS DECIMAL INITIAL "0" LABEL "Price"
FIELD Qty AS INTEGER INITIAL "0" LABEL "Qty"
FIELD Discount AS INTEGER INITIAL "0" LABEL "Discount"
FIELD ExtendedPrice AS DECIMAL INITIAL "0" LABEL "Extended Price"
FIELD OrderLineStatus AS CHARACTER INITIAL "Ordered" LABEL "Order Line Status"
INDEX itemnum  Itemnum  ASCENDING 
INDEX orderline IS  PRIMARY  UNIQUE  Ordernum  ASCENDING  Linenum  ASCENDING 
INDEX OrderLineStatus  OrderLineStatus  ASCENDING .

DEFINE TEMP-TABLE ttCustomer NO-UNDO
FIELD CustNum    AS INTEGER
FIELD Name       AS CHARACTER
INDEX CustNumIdx IS UNIQUE PRIMARY CustNum.

DEFINE DATASET dsOrder
    FOR ttOrder, ttOrderLine,ttCustomer
    DATA-RELATION OrdLinesRel FOR ttOrder, ttOrderLine  RELATION-FIELDS(Ordernum, Ordernum) NESTED
    DATA-RELATION CustOrd FOR ttCustomer, ttOrder   RELATION-FIELDS(CustNum, CustNum)
    .