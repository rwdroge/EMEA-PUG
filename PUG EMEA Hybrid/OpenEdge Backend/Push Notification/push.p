
/*------------------------------------------------------------------------
    File        : pushd.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Sat Oct 31 15:21:22 CET 2015
    Notes       :
  ----------------------------------------------------------------------*/
BLOCK-LEVEL ON ERROR UNDO, THROW.

USING OpenEdge.Mobile.TelerikPushNotificationAdmin.
USING Progress.Json.ObjectModel.*.
USING OpenEdge.Mobile.*.

DEFINE INPUT PARAMETER  pcMessage   AS CHARACTER NO-UNDO.
DEFINE OUTPUT PARAMETER pcError     AS CHARACTER NO-UNDO.    
DEFINE VARIABLE oAdminSvc   AS TelerikPushNotificationAdmin NO-UNDO.
DEFINE VARIABLE oResult     AS JsonObject NO-UNDO.
DEFINE VARIABLE iLoop       AS INTEGER NO-UNDO.
DEFINE VARIABLE oMessage    AS JsonObject   NO-UNDO.



oAdminSvc = NEW TelerikPushNotificationAdmin(
                '<insert api key>', /* api */
                '<insert master key>' /* master */
            ).

oAdminSvc:Initialize().

oMessage= NEW JsonObject().
oMessage:ADD("Message", pcMessage).

/* send immediately */
oAdminSvc:SendNotification(oMessage). 

CATCH eNSE AS NotificationServiceError:
    pcError =  STRING(eNSE:GetErrorMessage()).    
END CATCH.