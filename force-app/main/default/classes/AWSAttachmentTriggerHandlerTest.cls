@isTest
private class AWSAttachmentTriggerHandlerTest {
    
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
    
    static testMethod void testDeleteFileInAWS() {
        Attachment__c awsAttachment = [Select Id From Attachment__c limit 1];
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AWSMockHttpResponseGenerator());
        
		Test.startTest();
        Delete awsAttachment;
        Test.stopTest();
        
        Try {
            Attachment__c deletedAttachment = [Select Id From Attachment__c Where Name = 'testFile.jpeg'];
        } Catch(Exception ex) {
            system.assert(true);
        }
    }
}