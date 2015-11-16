
/*------------------------------------------------------------------------
    File        : getSalesRep.p
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

BLOCK-LEVEL ON ERROR UNDO, THROW.
{salesrep.i}
DEF INPUT PARAM pcfilter AS CHARACTER.
DEF OUTPUT PARAM DATASET FOR dsSalesRep.

DEFINE VAR mImage AS MEMPTR NO-UNDO.


/* ***************************  Main Block  *************************** */
EMPTY TEMP-TABLE ttSalesRep.
IF pcfilter <> "" AND pcfilter <> ? THEN DO:
    FIND Salesrep WHERE Salesrep.SalesRep = pcfilter NO-ERROR.
    IF AVAILABLE Salesrep THEN DO:
        FOR EACH SalesRep WHERE Salesrep.SalesRep = pcfilter
        NO-LOCK:
        CREATE ttSalesrep.
        BUFFER-COPY Salesrep EXCEPT Image TO ttSalesrep.    
        COPY-LOB FROM SalesRep.Image TO mImage.
        ASSIGN
            ttSalesrep.Image = BASE64-ENCODE(mImage).
        END.
    END.
END.
ELSE DO:
    FOR EACH SalesRep 
        NO-LOCK:
        CREATE ttSalesrep.
        BUFFER-COPY Salesrep EXCEPT Image TO ttSalesRep.    
        COPY-LOB FROM SalesRep.Image TO mImage.
        ASSIGN
            ttSalesrep.Image = BASE64-ENCODE(mImage).
    END.    
END.
    
