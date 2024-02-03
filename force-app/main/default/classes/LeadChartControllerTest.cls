@isTest
public class LeadChartControllerTest {
    
    @isTest
    public static void testGetLeadChartData() {
        List<Lead> leads = new List<Lead>();
        leads.add(new Lead(LastName = 'Name', LeadSource = 'AdWords'));
        insert leads;
        
        List<LeadChartController.LeadChartData> chartDataList = LeadChartController.getLeadChartData();
        
        System.assertEquals(2, chartDataList.size());
        for (LeadChartController.LeadChartData data : chartDataList) {
            System.assertNotEquals(null, data.label);
            System.assertNotEquals(null, data.count);
        }
    }
    
    @isTest
    public static void testGetInventoryData() {
        List<Property__c> properties = new List<Property__c>();
        
        // Create test Property__c records with required fields
        properties.add(new Property__c(
            Name = 'Property 1',
            City__c = 'Test City 1',
            State__c = 'FL',
            Zip__c = '12345'
        ));
        properties.add(new Property__c(
            Name = 'Property 2',
            City__c = 'Test City 2',
            State__c = 'FL',
            Zip__c = '67890'
        ));
        
        insert properties;
        
        List<Property__c> inventoryData = LeadChartController.getInventoryData();
        
        for (Property__c prop : inventoryData) {
            System.assertNotEquals(null, prop.Id);
            System.assertNotEquals(null, prop.Name);
        }
    }
    
    @isTest
    public static void testSendData() {
        // Mock the API_Setting__c custom settings records
        API_Setting__c emailSetting = new API_Setting__c(
            Name = 'DataAPIEmail',
            Inventory_Data_Endpoint__c = 'https://example.com/email'
        );
        API_Setting__c smsSetting = new API_Setting__c(
            Name = 'DataAPISMS',
            Inventory_Data_Endpoint__c = 'https://example.com/sms'
        );
        insert new List<API_Setting__c> {emailSetting, smsSetting};
        
        List<String> inventory = new List<String> {'Property 1', 'Property 2'};
        String leadSource = 'Source 1';
        String channel = 'Email';
        String message = 'Test message';
        String template = 'Test message';
        String freeText = 'Test freeText';
        
        Test.startTest();
        Boolean result = LeadChartController.sendData(inventory, leadSource, channel, message, template, freeText);
        Test.stopTest();
    }
    
    @isTest
    public static void testSendDataWithException() {
        // Simulate an exception in the APIUtility.sendHttpRequest method
        Test.startTest();
        Boolean result = LeadChartController.sendData(new List<String>(), 'Source 1', 'SMS', 'Test message', 'template', 'freeText');
        Test.stopTest();
        
        System.assertEquals(false, result);
    }
}