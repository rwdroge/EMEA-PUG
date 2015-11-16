
/*------------------------------------------------------------------------
    File        : push_admin.p
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

DEFINE VARIABLE oAdminSvc AS TelerikPushNotificationAdmin NO-UNDO.
DEFINE VARIABLE oResult AS JsonObject NO-UNDO.
DEFINE VARIABLE iLoop AS INTEGER NO-UNDO.


oAdminSvc = NEW TelerikPushNotificationAdmin(
                '<insert api here>', /* api */
                '<insert master key here>' /* master */
            ).

oAdminSvc:Initialize().

oResult = oAdminSvc:GetNotifications(NEW JsonObject()).
oResult:writefile('c:\openedge\wrk\notifications.json', TRUE).

iLoop = oAdminSvc:GetDeviceCount().

MESSAGE "Number of registered devices: " iLoop
VIEW-AS ALERT-BOX.

DEFINE VARIABLE oPayload    AS JsonObject   NO-UNDO.
DEFINE VARIABLE oMessage    AS JsonObject   NO-UNDO.
DEFINE VARIABLE oFilter     AS JsonObject   NO-UNDO.
DEFINE VARIABLE aData       AS JsonArray    NO-UNDO.
DEFINE VARIABLE cPN         AS CHARACTER    NO-UNDO.
DEFINE VARIABLE cFilter     AS CHARACTER    NO-UNDO.

cPN     = "test for push to make sure".

aData   = NEW JsonArray().
oMessage= NEW JsonObject().
oFilter = NEW JsonObject().

oMessage:ADD("Message", cPN).
oFilter:ADD("Filter", cFilter).
aData:add(oMessage).

oPayload = NEW JsonObject().

/* send immediately */
oAdminSvc:SendNotification(oMessage). 

CATCH eNSE AS NotificationServiceError:
    MESSAGE 
    STRING(eNSE:GetErrorMessage())
    VIEW-AS ALERT-BOX TITLE 'NotificationServiceError'.     
END CATCH.