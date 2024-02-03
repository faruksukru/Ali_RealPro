public class NDATriggerHandler {
   
    Public static void handleOperations(List<NDA__c> newRecords, List<NDA__c> oldRecords, Map<Id, NDA__c> newMap, Map<Id, NDA__c> oldMap, TriggerOperation operationType) 
    {
        Switch on operationType
        {
            When AFTER_UPDATE 
            {
                afterUpdateHandler(newRecords, newMap, oldRecords, oldMap);
            }
        }
    }
    
    Public static void afterUpdateHandler(List<NDA__c> newRecords, Map<Id, NDA__c> newMap, List<NDA__c> oldRecords, Map<Id, NDA__c> oldMap)
    {
        system.debug('-newRecords-'+newRecords);
        system.debug('-oldMap-'+oldMap);
        sendNDAToRealpro(newRecords,oldMap);
    }
    
    public static void sendNDAToRealpro(List<NDA__c> newRecords, Map<Id, NDA__c> oldMap) 
    {
        List<Id> eligibleNDAIds = new List<Id>();
        
        for(NDA__c nda: newRecords) 
        {
            if(nda.ID_Verified__c != oldMap.get(nda.Id).ID_Verified__c && nda.ID_Verified__c == 'Yes') {
                eligibleNDAIds.add(nda.Id);
            }
        }
        
        if(!eligibleNDAIds.isEmpty()) {
            sendToRealpro(eligibleNDAIds);
        }
    }
    
    @future (callout=true)
    public static void sendToRealpro(List<Id> eligibleNDAIds)
    {
        //Assuming there will be only one NDA ID Verified at a time
        NDA__c nda = [Select Id, Account__c, Property__c, ID_Verification_Message__c, Approval_Status__c From NDA__c Where Id IN: eligibleNDAIds LIMIT 1];
        
        API_Setting__c apiCustomSetting = API_Setting__c.getInstance('ndaAPI');
        // Create the JSON payload
        Map<String, Object> payload = new Map<String, Object>();
        String endpointUrl = apiCustomSetting.Inventory_Data_Endpoint__c;
        
        payload.put('ndaId', nda.Id);
        payload.put('accountId', nda.Account__c);
        payload.put('propertyId', nda.Property__c);
        payload.put('approvalStatus', nda.Approval_Status__c);
        payload.put('message', nda.ID_Verification_Message__c);
        payload.put('accessToken', 'gf3xVju03YKfK8ranQ1sHY745L2BzDIkL9qifa');
        
        // Convert the payload to JSON string
        String payloadJson = JSON.serialize(payload);
        APIUtility.sendHttpRequest(endpointUrl, payloadJson);
    }
}