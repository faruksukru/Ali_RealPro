@isTest
private class PropertyTriggerHandlerTest {
    
     @testSetup
    static void testSetup() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        Insert acc;
        
		Property__c property = new Property__c();
        property.Name = 'Test Property';
        property.State__c = 'AL';
        property.Owner__c = acc.Id;
        property.Address__c = 'Test Street';
        property.City__c = 'Miami';
        property.Zip__c = '12345';
        Insert property;
    }
    
    static testMethod void testUpdateRecordType_SysAdmin() {
        Property__c property = [Select Id,State__c From Property__c limit 1];
        
        Acquisition__c acquisition = new Acquisition__c();
        acquisition.AcquisitionName__c = 'Test Acquisition';
        acquisition.LeadSource__c = 'AdWords';
        acquisition.Property__c = property.Id;
        Insert acquisition;
        
        Sale__c sale = new Sale__c();
        //sale.Name = 'Test Sale';
        //sale.Deal_Type__c = 'Sale';
        sale.Property__c = property.Id;
        Insert sale;
        
        property.State__c = 'OH';
        Test.startTest();
        update property;
        Test.stopTest();
        
        //Acquisition__c updateAcquisition = [Select Id,RecordTypeId from Acquisition__c Where Id =: acquisition.Id];
        Sale__c updatedSale = [Select Id,RecordTypeId from Sale__c Where Id =: sale.Id];
        
        //System.assertEquals(updateAcquisition.RecordTypeId, Schema.SObjectType.Acquisition__c.getRecordTypeInfosByDeveloperName().get('OH').getRecordTypeId(), 'Record Type not updated');
        //System.assertEquals(updatedSale.RecordTypeId, Schema.SObjectType.Sale__c.getRecordTypeInfosByDeveloperName().get('OHSale').getRecordTypeId(), 'Record Type not updated');
    }
}