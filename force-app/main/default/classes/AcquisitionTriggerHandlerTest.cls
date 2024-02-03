@isTest
private class AcquisitionTriggerHandlerTest {
    
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
    
    static testMethod void testUpdatRecordType_SysAdmin() {
        Property__c property = [Select Id From Property__c limit 1];
        
        Acquisition__c acquisition = new Acquisition__c();
        acquisition.AcquisitionName__c = 'Test Acquisition';
        acquisition.LeadSource__c = 'AdWords';
        acquisition.Property__c = property.Id;
        
        Test.startTest();
        Insert acquisition;
        Test.stopTest();
        
        Acquisition__c updateAcquisition = [Select Id,RecordTypeId from Acquisition__c Where Id =: acquisition.Id];
        
        System.assertEquals(updateAcquisition.RecordTypeId, Schema.SObjectType.Acquisition__c.getRecordTypeInfosByDeveloperName().get('AL').getRecordTypeId(), 'Record Type not updated');
    }
    
    static testMethod void testUpdatCheckboxInsert_SysAdmin() {
        Property__c property = [Select Id From Property__c limit 1];
        
        Acquisition__c acquisition = new Acquisition__c();
        acquisition.AcquisitionName__c = 'Test Acquisition';
        acquisition.LeadSource__c = 'AdWords';
        acquisition.Property__c = property.Id;
        acquisition.Closing_Agent_Selection__c = 'Seller designates';
        acquisition.Initial_Deposit_Option__c = 'Accompanies Offer';
        acquisition.Assignability__c = 'May Assign - Released';
        acquisition.Rate_Type__c = 'Fixed';
        acquisition.Home_Warranty__c = 'Buyer';
        acquisition.Special_Assessments__c = 'Seller/Buyer';
        acquisition.Financing__c = 'Cash';
        Test.startTest();
        Insert acquisition;
        Test.stopTest();
        
        Acquisition__c updateAcquisition = [Select Financing_Cash__c, Special_Assessments_Seller_Buyer__c, Home_Warranty_Buyer_Pays__c,
                              Loan_Rate_Type_Fixed__c, May_Assign_Released__c, Accompanies_Offer__c, Closing_Agent_Seller_Designates__c 
                              from Acquisition__c Where Id =: acquisition.Id];
        
        System.assertEquals(updateAcquisition.Financing_Cash__c, true, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Special_Assessments_Seller_Buyer__c, true, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Home_Warranty_Buyer_Pays__c, true, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Loan_Rate_Type_Fixed__c, true, 'Checbox not updated');
        System.assertEquals(updateAcquisition.May_Assign_Released__c, true, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Accompanies_Offer__c, true, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Closing_Agent_Seller_Designates__c, true, 'Checbox not updated');
    }
    
    static testMethod void testUpdatCheckboxUpdate_SysAdmin() {
        Property__c property = [Select Id From Property__c limit 1];
        
        Acquisition__c acquisition = new Acquisition__c();
        acquisition.AcquisitionName__c = 'Test Acquisition';
        acquisition.LeadSource__c = 'AdWords';
        acquisition.Property__c = property.Id;
        acquisition.Closing_Agent_Selection__c = 'Seller designates';
        acquisition.Initial_Deposit_Option__c = 'Accompanies Offer';
        acquisition.Assignability__c = 'May Assign - Released';
        acquisition.Rate_Type__c = 'Fixed';
        acquisition.Home_Warranty__c = 'Buyer';
        acquisition.Special_Assessments__c = 'Seller/Buyer';
        acquisition.Financing__c = 'Cash';
        Insert acquisition;
        
        acquisition.Closing_Agent_Selection__c = 'Buyer Designates';
        acquisition.Initial_Deposit_Option__c = 'Initial Deposit at a future date';
        acquisition.Assignability__c = 'May Assign - Not Released';
        acquisition.Rate_Type__c = 'Adjustable';
        acquisition.Home_Warranty__c = 'Seller';
        acquisition.Special_Assessments__c = 'Seller Pays in Full';
        acquisition.Financing__c = 'Conventional';
        Test.startTest();
        Update acquisition;
        Test.stopTest();
        
        Acquisition__c updateAcquisition = [Select Financing_Cash__c, Special_Assessments_Seller_Buyer__c, Home_Warranty_Buyer_Pays__c,
                              Loan_Rate_Type_Fixed__c, May_Assign_Released__c, Accompanies_Offer__c, Closing_Agent_Seller_Designates__c,
                              Financing_Loan__c, Loan_Type_Conventional__c, Special_Assessments_Seller_Pays_in_Ful__c, 
                              Home_Warranty_Seller_Pays__c, Loan_Rate_Type_Adjustable__c, May_Assign_Not_Released__c, 
                              Initial_Deposit_at_a_future_date__c, Closing_Agent_Buyer_Designates__c 
                              from Acquisition__c Where Id =: acquisition.Id];
        
        System.assertEquals(updateAcquisition.Financing_Cash__c, false, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Special_Assessments_Seller_Buyer__c, false, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Home_Warranty_Buyer_Pays__c, false, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Loan_Rate_Type_Fixed__c, false, 'Checbox not updated');
        System.assertEquals(updateAcquisition.May_Assign_Released__c, false, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Accompanies_Offer__c, false, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Closing_Agent_Seller_Designates__c, false, 'Checbox not updated');
        
        System.assertEquals(updateAcquisition.Financing_Loan__c, true, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Loan_Type_Conventional__c, true, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Special_Assessments_Seller_Pays_in_Ful__c, true, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Home_Warranty_Seller_Pays__c, true, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Loan_Rate_Type_Adjustable__c, true, 'Checbox not updated');
        System.assertEquals(updateAcquisition.May_Assign_Not_Released__c, true, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Initial_Deposit_at_a_future_date__c, true, 'Checbox not updated');
        System.assertEquals(updateAcquisition.Closing_Agent_Buyer_Designates__c, true, 'Checbox not updated');
    }

}