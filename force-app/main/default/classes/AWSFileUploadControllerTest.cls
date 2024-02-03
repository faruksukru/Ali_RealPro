@isTest
private class AWSFileUploadControllerTest {
    
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
        
        AWSFileUploadController.insertAttachmentRecord(property.Id, 'Test File', 'Https://testawsrealpro.com', 'image/jpeg', 'testFile.jpeg');
    }
    
    static testMethod void testUploadFileToAWS() {
        Property__c property = [Select Id From Property__c limit 1];
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AWSMockHttpResponseGenerator());
        
        Test.startTest();
        AWSFileUploadController.uploadFileToAWS(property.Id, 'testFile.jpeg', 'image/jpeg', 'dsdsdsd');
        Test.stopTest();
        
        Attachment__c insertedAttachment = [Select Id From Attachment__c limit 1];
        system.assert(insertedAttachment != null);
    }
}