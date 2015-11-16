 
 /*------------------------------------------------------------------------
    File        : salesrep
   ----------------------------------------------------------------------*/
  
@program FILE(name="salesrep.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="salesrep", URI="/salesrep", schemaName="dsSalesrep", schemaFile="Sports2000/src/AppServer/salesrep.i").

USING Progress.Lang.*.
USING OpenEdge.BusinessLogic.BusinessEntity.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS salesrep INHERITS BusinessEntity:
	/*------------------------------------------------------------------------------
			Purpose:                                                                      
			Notes:                                                                        
	------------------------------------------------------------------------------*/
	
	{"salesrep.i"}
	
	/* TODO Fill in appropriate database tables */
	DEFINE DATA-SOURCE srcttSalesrep FOR sports2000.salesrep.
    
	/*------------------------------------------------------------------------------
            Purpose:                                                                      
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC salesrep():
    	
    	DEFINE VAR hDataSourceArray AS HANDLE NO-UNDO EXTENT 1.
        DEFINE VAR cSkipListArray AS CHAR NO-UNDO EXTENT 1.
        
        SUPER (DATASET dsSalesrep:HANDLE).
        
        /* Data Source for each table in dataset. Should be in table order as defined 
     	   in DataSet */ 
     	hDataSourceArray[1] = DATA-SOURCE srcttSalesrep:HANDLE.
     	     	
     	/* Skip-list entry for each table in dataset. Should be in temp-table order 
           as defined in DataSet */
        /* Each skip-list entry is a comma-separated list of field names, to be
 	       ignored in create stmt */
     	
     	/* TODO Update cSkipListArray if required by your BusinessEntity */
     	cSkipListArray[1] = ?.
     	
     	THIS-OBJECT:ProDataSource = hDataSourceArray.
        THIS-OBJECT:SkipList = cSkipListArray.
     	        
    END CONSTRUCTOR.
    	
    /*------------------------------------------------------------------------------
            Purpose:  Get one or more records, based on a filter string                                                                     
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    METHOD PUBLIC VOID Readsalesrep(
    		INPUT filter AS CHARACTER, 
    		OUTPUT DATASET dsSalesrep):
    	
    RUN getSalesRep(filter, OUTPUT DATASET dsSalesrep).
    	      
    END METHOD.
	  
    /*------------------------------------------------------------------------------
            Purpose: Create one or more new records                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/  
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").
    METHOD PUBLIC VOID Createsalesrep(INPUT-OUTPUT DATASET dsSalesrep):    		
    	       
        SUPER:CreateData(DATASET dsSalesrep BY-REFERENCE).        
    END METHOD.    
	
    /*------------------------------------------------------------------------------
            Purpose:  Update one or more records                                                                  
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").
    METHOD PUBLIC VOID Updatesalesrep(INPUT-OUTPUT DATASET dsSalesrep):    		
	
    RUN UpdateSalesRep(INPUT DATASET dsSalesrep, OUTPUT DATASET dsSalesrep).    
                 
    END METHOD.
	
    /*------------------------------------------------------------------------------
            Purpose:    Delete a record                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").
    METHOD PUBLIC VOID Deletesalesrep(INPUT-OUTPUT DATASET dsSalesrep):     		       
	
        SUPER:DeleteData(DATASET dsSalesrep BY-REFERENCE).
    END METHOD.
    
    /*------------------------------------------------------------------------------
            Purpose:    Submit a record                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="submit", URI="/Submitsalesrep", alias="", mediaType="application/json").
    METHOD PUBLIC VOID Submitsalesrep(INPUT-OUTPUT DATASET dsSalesrep):     		       
	
      	 RUN UpdateSalesRep(INPUT DATASET dsSalesrep BY-REFERENCE, OUTPUT DATASET dsSalesrep BY-REFERENCE).    	   
    END METHOD.
	 
    
END CLASS.
