 
 /*------------------------------------------------------------------------
    File        : order
   ----------------------------------------------------------------------*/
  
@program FILE(name="order.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="order", URI="/order", schemaName="dsOrder", schemaFile="Sports2000/src/AppServer/order.i").

USING Progress.Lang.*.
USING OpenEdge.BusinessLogic.BusinessEntity.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS order INHERITS BusinessEntity:
	/*------------------------------------------------------------------------------
			Purpose:                                                                      
			Notes:                                                                        
	------------------------------------------------------------------------------*/
	
	{"order.i"}
	
	DEFINE DATA-SOURCE srcOrder        FOR sports2000.Order.
	DEFINE DATA-SOURCE srcOrderLine    FOR sports2000.OrderLine.
	DEFINE DATA-SOURCE srcCustomer     FOR sports2000.Customer.
	
	DEFINE VARIABLE iSeq AS INTEGER NO-UNDO.
	
    DEFINE TEMP-TABLE ttSales NO-UNDO
    FIELD SalesRep  AS CHARACTER LABEL "Sales Representative"
    FIELD Month     AS INTEGER
    FIELD Sales     AS DECIMAL          
    INDEX idx1 IS UNIQUE SalesRep Month
    . 

	/*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC order():
    	
    	DEFINE VAR hDataSourceArray AS HANDLE NO-UNDO EXTENT 3.
        DEFINE VAR cSkipListArray AS CHAR NO-UNDO EXTENT 3.
        
        SUPER (DATASET dsOrder:HANDLE).
        
        /* Data Source for each table in dataset. Should be in table order as defined 
     	   in DataSet */     
     	hDataSourceArray[1] =  DATA-SOURCE srcOrder:HANDLE.
     	hDataSourceArray[2] =  DATA-SOURCE srcOrderLine:HANDLE.
     	hDataSourceArray[3] =  DATA-SOURCE srcCustomer:HANDLE.  
     	
     	     	
     	/* Skip-list entry for each table in dataset. Should be in temp-table order 
           as defined in DataSet */
        /* Each skip-list entry is a comma-separated list of field names, to be
 	       ignored in create stmt */
     	    
     	cSkipListArray[1] = "".
     	cSkipListArray[2] = "".
     	cSkipListArray[3] = "".
     	
     	THIS-OBJECT:ProDataSource = hDataSourceArray.
        THIS-OBJECT:SkipList = cSkipListArray.
     	        
    END CONSTRUCTOR.
    	
    /*------------------------------------------------------------------------------
            Purpose:  Get one or more records, based on a filter string                                                                     
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json").
    @openapi.openedge.method.property(name="mappingType",value="JFP").
    @openapi.openedge.method.property(name="capabilities",value="ablFilter,top,skip,id,orderBy"). 
    METHOD PUBLIC VOID Readorder(
    		INPUT filter AS CHARACTER, 
    		OUTPUT DATASET dsOrder):
    	
    DEFINE VARIABLE jsonParser      AS ObjectModelParser NO-UNDO.
    DEFINE VARIABLE jsonObject      AS JsonObject NO-UNDO.
    DEFINE VARIABLE cablFilter      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE corderBy        AS CHARACTER INITIAL "" NO-UNDO.
    DEFINE VARIABLE cwhere          AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cquery          AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cid             AS CHARACTER INITIAL ?  NO-UNDO.
    DEFINE VARIABLE iMaxRows        AS INTEGER INITIAL ?    NO-UNDO.
    DEFINE VARIABLE iSkipRows       AS INTEGER INITIAL ?    NO-UNDO.
    DEFINE VARIABLE iCount          AS INTEGER NO-UNDO.
    DEFINE VARIABLE lUseReposition  AS LOGICAL NO-UNDO.
    DEFINE VARIABLE hQuery          AS HANDLE.
    

    MESSAGE filter.
    
    
    
    IF filter BEGINS "~{" THEN DO:
    
         
        EMPTY TEMP-TABLE ttOrder.
        EMPTY TEMP-TABLE ttOrderLine.
        EMPTY TEMP-TABLE ttCustomer.
        
        jsonParser = NEW ObjectModelParser().
        jsonObject = CAST(jsonParser:Parse(filter), jsonObject).
    
        iMaxRows    = jsonObject:GetInteger("top") NO-ERROR.
        iSkipRows   = jsonObject:GetInteger("skip") NO-ERROR.
        cablFilter  = jsonObject:GetCharacter("ablFilter") NO-ERROR.
        cOrderBy    = jsonObject:GetCharacter("orderBy") NO-ERROR.
        cid         = jsonObject:GetCharacter("id") NO-ERROR.
        cwhere      = "WHERE " + cablFilter NO-ERROR.
         
        IF cOrderBy > "" THEN DO:
            cOrderBy = REPLACE(cOrderBy, ",", " by ").
            cOrderBy = "by " + cOrderBy + " ".
            /* NOTE: id and seq fields should be removed from
            cWhere and cOrderBy */
            cOrderBy = REPLACE(cOrderBy, "by id desc", "").
            cOrderBy = REPLACE(cOrderBy, "by id ", "").
            cOrderBy = REPLACE(cOrderBy, "by seq desc", "").
            cOrderBy = REPLACE(cOrderBy, "by seq ", "").
        END. 
        
        lUseReposition = iSkipRows <> ?.
        IF iMaxRows <> ? AND iMaxRows > 0 THEN DO:
            BUFFER ttOrder:HANDLE:BATCH-SIZE = iMaxRows.
        END.
        ELSE DO:
            IF cid > "" THEN DO:
                BUFFER ttOrder:HANDLE:BATCH-SIZE = 1.
                END.
            ELSE
                BUFFER ttOrder:HANDLE:BATCH-SIZE = 0.
        END.
        
        BUFFER ttOrder:ATTACH-DATA-SOURCE(DATA-SOURCE srcOrder:HANDLE).
        BUFFER ttOrderLine:ATTACH-DATA-SOURCE(DATA-SOURCE srcOrderLine:HANDLE).
        BUFFER ttCustomer:ATTACH-DATA-SOURCE(DATA-SOURCE srcCustomer:HANDLE).
        
        IF cOrderBy = ? THEN cOrderBy = "".
        
        cWhere = IF cWhere > "" THEN (cWhere + " " + cOrderBy)
        ELSE ("WHERE " + cOrderBy).
        DATA-SOURCE srcOrder:FILL-WHERE-STRING = cWhere.
        IF lUseReposition THEN DO:
            hQuery = DATA-SOURCE srcOrder:QUERY.
            hQuery:QUERY-OPEN. 
            
        IF cid > "" AND cid <> "?" THEN DO:
            hQuery:REPOSITION-TO-ROWID(TO-ROWID(cid)).
        END.
        ELSE IF iSkipRows <> ? AND iSkipRows > 0 THEN DO:
            hQuery:REPOSITION-TO-ROW(iSkipRows).
            IF NOT AVAILABLE Order THEN
                hQuery:GET-NEXT() NO-ERROR.
        END.
        
        iCount = 0.
        REPEAT WHILE NOT hQuery:QUERY-OFF-END AND iCount < iMaxRows:
            hQuery:GET-NEXT () NO-ERROR.
            IF AVAILABLE Order THEN DO:
                CREATE ttOrder.
                BUFFER-COPY Order TO ttOrder.
                ASSIGN  ttOrder.id = STRING(ROWID(Order))
                        iSeq = iSeq + 1
                        ttOrder.seq = iSeq.
                /* IF NOT AVAILABLE ttCustomer OR ttCustomer.CustNum <> ttOrder.Custnum THEN DO: */
                FIND ttCustomer WHERE ttCustomer.CustNum = ttOrder.CustNum NO-ERROR.
                IF NOT AVAILABLE ttCustomer THEN DO:
                    FOR EACH Customer WHERE Customer.CustNum = ttOrder.CustNum NO-LOCK: 
                        CREATE ttCustomer.
                        BUFFER-COPY Customer TO ttCustomer.
                    END.
                END.
                    
                IF AVAILABLE ttCustomer THEN DO:
                    FOR EACH ttOrder WHERE ttOrder.CustNum = ttCustomer.CustNum NO-LOCK:
                        ASSIGN ttOrder.CustName = ttCustomer.Name.
                    END.
                END.           
                FOR EACH OrderLine WHERE OrderLine.OrderNum = Order.OrderNum
                NO-LOCK:
                CREATE ttOrderLine.
                BUFFER-COPY OrderLine TO ttOrderLine.
                END.        
            END.
            iCount = iCount + 1.
            END.
        END.
        ELSE DO:
            IF cid > "" THEN DATA-SOURCE srcOrder:RESTART-ROWID(1)
                        = TO-ROWID ((cid)).
            BUFFER ttOrder:SET-CALLBACK ("AFTER-ROW-FILL", "AddIdField").
            DATASET dsOrder:FILL().
        END.
    END.
    ELSE DO:
    BUFFER ttOrder:HANDLE:BATCH-SIZE = 5.
    SUPER:ReadData(filter). 
    END.
    FINALLY:
        BUFFER ttOrder:DETACH-DATA-SOURCE().
        BUFFER ttOrderLine:DETACH-DATA-SOURCE().
        BUFFER ttCustomer:DETACH-DATA-SOURCE().
    END FINALLY.
          
    END METHOD.
	
    METHOD PUBLIC VOID AddIdField (INPUT DATASET dsOrder):
        ASSIGN ttOrder.id = STRING(ROWID(Order))
        iSeq = iSeq + 1
        ttOrder.seq = iSeq.
    END METHOD.
        
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="invoke",URI="/count?filter=~{filter~}", alias="", mediaType="application/json").
    METHOD PUBLIC VOID count(
            INPUT filter AS CHARACTER,
            OUTPUT numRecs AS INTEGER):

    DEFINE VARIABLE jsonParser AS ObjectModelParser NO-UNDO.
    DEFINE VARIABLE jsonObject AS JsonObject NO-UNDO.
    DEFINE VARIABLE ablFilter AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cWhere AS CHARACTER NO-UNDO.
    DEFINE VARIABLE qh AS HANDLE NO-UNDO.
    
    IF filter BEGINS "WHERE " THEN
        cWhere = filter.
    ELSE IF filter BEGINS "~{" THEN
    DO:
        jsonParser = NEW ObjectModelParser().
        jsonObject = CAST(jsonParser:Parse(filter), jsonObject).
        ablFilter = jsonObject:GetCharacter("ablFilter") NO-ERROR.
        cWhere = "WHERE " + ablFilter.
    END.
    ELSE IF filter NE "" THEN
    DO:
        /* Use filter as WHERE clause */
        cWhere = "WHERE " + filter.
    END.
    CREATE QUERY qh.
    qh:SET-BUFFERS(BUFFER Order:HANDLE).
    qh:QUERY-PREPARE("PRESELECT EACH Order " + cWhere).
    qh:QUERY-OPEN ().
    numRecs = qh:NUM-RESULTS.
    
    END METHOD.	
    
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="false").
    @progress.service.resourceMapping(type="REST", operation="invoke", URI="/MonthlySales", alias="", mediaType="application/json").
    METHOD PUBLIC VOID MonthlySales( 
            INPUT piYear AS INTEGER, 
            INPUT pcSalesRep AS CHARACTER,            
            OUTPUT TABLE ttSales ):

        DEFINE VARIABLE totalOrder  AS DECIMAL      NO-UNDO.

        IF pcSalesRep = ? THEN pcSalesRep = "".
        EMPTY TEMP-TABLE ttSales.                     
        FOR EACH Order 
            WHERE Year(OrderDate) = piYear
                AND (pcSalesRep = "" OR Order.SalesRep = pcSalesRep) NO-LOCK:

            totalOrder = 0.
            FOR EACH OrderLine OF Order NO-LOCK:
                totalOrder = totalOrder + OrderLine.ExtendedPrice.
            END.
            
            FIND ttSales WHERE ttSales.SalesRep = Order.SalesRep 
                           AND ttSales.Month    = MONTH(Order.OrderDate) NO-ERROR.
            IF NOT AVAILABLE ttSales THEN DO:
                CREATE ttSales.            
                ASSIGN 
                    ttSales.SalesRep    = Order.SalesRep
                    ttSales.Month       = MONTH(Order.OrderDate).
            END.                        
            ASSIGN 
                ttSales.Sales       = ttSales.Month + totalOrder.    
        END.        

    END METHOD.
	
	 
    
END CLASS.
