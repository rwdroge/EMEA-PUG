
/*------------------------------------------------------------------------
    File        : getSalesRep.p
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.
{salesrep.i}
DEF INPUT PARAM DATASET FOR dsSalesrep.
DEF OUTPUT PARAM DATASET FOR dsSalesRep.

DEFINE BUFFER bSalesrep FOR Salesrep.
DEFINE VAR mImage AS MEMPTR NO-UNDO.
DEFINE VAR lcImage AS LONGCHAR NO-UNDO.

/* ***************************  Main Block  *************************** */
FOR EACH ttSalesrep NO-LOCK:
FIND Salesrep WHERE Salesrep.SalesRep = ttSalesrep.Salesrep NO-ERROR.   
MESSAGE Salesrep.SalesRep ttsalesrep.repname.
    ASSIGN
        Salesrep.Email      = ttSalesrep.Email
        Salesrep.RepName    = ttSalesrep.RepName
        Salesrep.Region     = ttSalesrep.Region
        .
    lcImage = ttSalesrep.Image.    
    mImage = BASE64-DECODE(lcImage).
    COPY-LOB FROM mImage TO SalesRep.Image. 
END.   
       
    
