/**
* @description       : Apex trigger handler for property
* @author            : Satyam Kumar
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   04-08-2021   Satyam Kumar   Initial Version
* */
public without sharing class PropertyTriggerHandler {
    
    public void handler(List<Property__c> newRecords, List<Property__c> oldRecords, Map<Id, Property__c> newMap, Map<Id, Property__c> oldMap, TriggerOperation operation){
        
        switch on operation 
        {
            when BEFORE_INSERT 
            {
                beforeInsert(newRecords, oldRecords, newMap, oldMap);
            }
            when BEFORE_UPDATE 
            {
                beforeUpdate(newRecords, oldRecords, newMap, oldMap);
            }
            when BEFORE_DELETE
            {
                beforeDelete(newRecords, oldRecords, newMap, oldMap);
            }
            when AFTER_INSERT 
            {
                afterInsert(newRecords, oldRecords, newMap, oldMap);
            }
            when AFTER_UPDATE 
            {
                afterUpdate(newRecords, oldRecords, newMap, oldMap);
            }
            when AFTER_DELETE
            {
                afterDelete(newRecords, oldRecords, newMap, oldMap);
            }
        }
        
    }
    
    public void beforeInsert(List<Property__c> newRecords, List<Property__c> oldRecords, Map<Id, Property__c> newMap, Map<Id, Property__c> oldMap){

    }
    
    public void beforeUpdate(List<Property__c> newRecords, List<Property__c> oldRecords, Map<Id, Property__c> newMap, Map<Id, Property__c> oldMap){

    }
    
    public void beforeDelete(List<Property__c> newRecords, List<Property__c> oldRecords, Map<Id, Property__c> newMap, Map<Id, Property__c> oldMap){

    }
    
    public void afterInsert(List<Property__c> newRecords, List<Property__c> oldRecords, Map<Id, Property__c> newMap, Map<Id, Property__c> oldMap){

    }
    
    public void afterUpdate(List<Property__c> newRecords, List<Property__c> oldRecords, Map<Id, Property__c> newMap, Map<Id, Property__c> oldMap){
        updateRecordType(newRecords,oldMap);
    }
    
    public void afterDelete(List<Property__c> newRecords, List<Property__c> oldRecords, Map<Id, Property__c> newMap, Map<Id, Property__c> oldMap){
        
    }
    
    //Method to update record type
    public static void updateRecordType(List<Property__c> newRecords, Map<Id,Property__c> oldMap ) {
        Try {
            Map<String, Id> saleRecordTypeMap = new Map<String, Id>();
            Map<String, Id> AcqRecordTypeMap = new Map<String, Id>();
            List<Id> propertyIdList = new List<Id>();
            List<Sale__c> salesToUpdateList = new List<Sale__c>();
            List<Acquisition__c> acqToUpdateList = new List<Acquisition__c>();
            
            for(RecordType recType: [SELECT Id, DeveloperName, Name, SobjectType FROM RecordType Where SobjectType = 'Sale__c'])
            {
                saleRecordTypeMap.put(recType.DeveloperName, recType.Id);
            }
            
            for(RecordType recType: [SELECT Id, DeveloperName, Name, SobjectType FROM RecordType Where SobjectType = 'Acquisition__c'])
            {
                AcqRecordTypeMap.put(recType.DeveloperName, recType.Id);
            }

            for(Property__c property: newRecords) 
            {
                if(property.State__c != oldMap.get(property.Id).State__c && String.isNotBlank(property.state__c) && saleRecordTypeMap!= null && saleRecordTypeMap.containsKey(property.state__c)) 
                {
                    propertyIdList.add(property.Id);
                }
            }

            if(propertyIdList != null && !propertyIdList.isEmpty()) 
            {
                for(Sale__c sale: [Select Id, recordTypeId, Property__r.State__c from Sale__c where Property__c IN: propertyIdList]) 
                {
                        sale.recordTypeId = saleRecordTypeMap.get(sale.Property__r.State__c);
                        salesToUpdateList.add(sale);
                }
                
                for(Acquisition__c acq: [Select Id, recordTypeId, Property__r.State__c from Acquisition__c where Property__c IN: propertyIdList]) 
                {
                        acq.recordTypeId = acqRecordTypeMap.get(acq.Property__r.State__c);
                        acqToUpdateList.add(acq);
                }
            }
            
            if(salesToUpdateList != null && !salesToUpdateList.isEmpty()) 
            {
                update salesToUpdateList;
            }
            
            if(acqToUpdateList != null && !acqToUpdateList.isEmpty()) 
            {
                update acqToUpdateList;
            }
            
        } catch(Exception e)
        {
            system.debug('Error in PropertyTrigger: '+e.getStackTraceString()+' '+e.getMessage());
        }
    }
}