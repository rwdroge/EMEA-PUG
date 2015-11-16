
/*------------------------------------------------------------------------
    File        : salesrep.i
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
@openapi.openedge.entity.primarykey (fields="SalesRep").
    
DEFINE TEMP-TABLE ttSalesrep NO-UNDO BEFORE-TABLE bttSalesrep  
FIELD SalesRep      AS CHARACTER    
FIELD RepName       AS CHARACTER    
FIELD Region        AS CHARACTER    
FIELD MonthQuota    AS INTEGER      EXTENT 12 INITIAL "0" 
FIELD Image         AS CLOB
FIELD Email         AS CHARACTER
INDEX SalesRep IS  PRIMARY  UNIQUE  SalesRep  ASCENDING.

DEFINE DATASET dsSalesrep FOR ttSalesrep.
