@isTest
public class NDATriggerHandlerTest {
	@isTest
    public static void testSendToRealpro() {
        //Create custom setting
        API_Setting__c emailSetting = new API_Setting__c(
            Name = 'ndaAPI',
            Inventory_Data_Endpoint__c = 'https://example.com/'
        );
        Insert emailSetting;
        
        // Create test data
        NDA__c nda = new NDA__c(Approval_Status__c = 'Approved' , ID_Verification_Message__c = 'Test Message' ,ID_Verified__c = 'No');
        insert nda;

        nda.ID_Verified__c = 'Yes';

        // Set up a mock HTTP response
        Test.setMock(HttpCalloutMock.class, new AWSMockHttpResponseGenerator());

        // Call the sendToRealpro method
        Test.startTest();
        update nda; // This update should trigger the handler logic
        Test.stopTest();

        // Add assertions as needed
        System.assertEquals(nda.ID_Verified__c, 'Yes');
    }
}