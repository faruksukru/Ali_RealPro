@isTest
private class SaleTriggerHandlerTest {
    
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
        
        Sale__c sale = new Sale__c();
       // sale.Name = 'Test Sale';
        //sale.Deal_Type__c = 'Sale';
        sale.Property__c = property.Id;
        
        Test.startTest();
        Insert sale;
        Test.stopTest();
        
        Sale__c updateSale = [Select Id,RecordTypeId from Sale__c Where Id =: sale.Id];
        
       // System.assertEquals(updateSale.RecordTypeId, Schema.SObjectType.Sale__c.getRecordTypeInfosByDeveloperName().get('AL').getRecordTypeId(), 'Record Type not updated');
    }
    
    static testMethod void testUpdatCheckboxInsert_SysAdmin() {
        Property__c property = [Select Id From Property__c limit 1];
        
        Sale__c sale = new Sale__c();
        //sale.Name = 'Test Sale';
        sale.Property__c = property.Id;
        sale.Closing_Agent_Selection__c = 'Seller designates';
        sale.Initial_Deposit_Option__c = 'Accompanies Offer';
        sale.Assignability__c = 'May Assign - Released';
        sale.Rate_Type__c = 'Fixed';
        sale.Home_Warranty__c = 'Buyer';
        sale.Special_Assessments__c = 'Seller/Buyer';
        sale.Financing__c = 'Cash';
        Test.startTest();
        Insert sale;
        Test.stopTest();
        
        Sale__c updateSale = [Select Financing_Cash__c, Special_Assessments_Seller_Buyer__c, Home_Warranty_Buyer_Pays__c,
                              Loan_Rate_Type_Fixed__c, May_Assign_Released__c, Accompanies_Offer__c, Closing_Agent_Seller_Designates__c 
                              from Sale__c Where Id =: sale.Id];
        
       // System.assertEquals(updateSale.Financing_Cash__c, true, 'Checbox not updated');
        //System.assertEquals(updateSale.Special_Assessments_Seller_Buyer__c, true, 'Checbox not updated');
//System.assertEquals(updateSale.Home_Warranty_Buyer_Pays__c, true, 'Checbox not updated');
       // System.assertEquals(updateSale.Loan_Rate_Type_Fixed__c, true, 'Checbox not updated');
       // System.assertEquals(updateSale.May_Assign_Released__c, true, 'Checbox not updated');
       // System.assertEquals(updateSale.Accompanies_Offer__c, true, 'Checbox not updated');
      //  System.assertEquals(updateSale.Closing_Agent_Seller_Designates__c, true, 'Checbox not updated');
    }
    
    static testMethod void testUpdatCheckboxUpdate_SysAdmin() {
        Property__c property = [Select Id From Property__c limit 1];
        
        Sale__c sale = new Sale__c();
        //sale.Name = 'Test Sale';
        sale.Property__c = property.Id;
        sale.Closing_Agent_Selection__c = 'Seller designates';
        sale.Initial_Deposit_Option__c = 'Accompanies Offer';
        sale.Assignability__c = 'May Assign - Released';
        sale.Rate_Type__c = 'Fixed';
        sale.Home_Warranty__c = 'Buyer';
        sale.Special_Assessments__c = 'Seller/Buyer';
        sale.Financing__c = 'Cash';
        Insert sale;
        
        sale.Closing_Agent_Selection__c = 'Buyer Designates';
        sale.Initial_Deposit_Option__c = 'Initial Deposit at a future date';
        sale.Assignability__c = 'May Assign - Not Released';
        sale.Rate_Type__c = 'Adjustable';
        sale.Home_Warranty__c = 'Seller';
        sale.Special_Assessments__c = 'Seller Pays in Full';
        sale.Financing__c = 'Conventional';
        Test.startTest();
        Update sale;
        Test.stopTest();
        
        Sale__c updateSale = [Select Financing_Cash__c, Special_Assessments_Seller_Buyer__c, Home_Warranty_Buyer_Pays__c,
                              Loan_Rate_Type_Fixed__c, May_Assign_Released__c, Accompanies_Offer__c, Closing_Agent_Seller_Designates__c,
                              Financing_Loan__c, Loan_Type_Conventional__c, Special_Assessments_Seller_Pays_in_Ful__c, 
                              Home_Warranty_Seller_Pays__c, Loan_Rate_Type_Adjustable__c, May_Assign_Not_Released__c, 
                              Initial_Deposit_at_a_future_date__c, Closing_Agent_Buyer_Designates__c 
                              from Sale__c Where Id =: sale.Id];
        
      //  System.assertEquals(updateSale.Financing_Cash__c, false, 'Checbox not updated');
       // System.assertEquals(updateSale.Special_Assessments_Seller_Buyer__c, false, 'Checbox not updated');
//System.assertEquals(updateSale.Home_Warranty_Buyer_Pays__c, false, 'Checbox not updated');
       // System.assertEquals(updateSale.Loan_Rate_Type_Fixed__c, false, 'Checbox not updated');
      //  System.assertEquals(updateSale.May_Assign_Released__c, false, 'Checbox not updated');
      //  System.assertEquals(updateSale.Accompanies_Offer__c, false, 'Checbox not updated');
      //  System.assertEquals(updateSale.Closing_Agent_Seller_Designates__c, false, 'Checbox not updated');
        
      //  System.assertEquals(updateSale.Financing_Loan__c, true, 'Checbox not updated');
      //  System.assertEquals(updateSale.Loan_Type_Conventional__c, true, 'Checbox not updated');
     //   System.assertEquals(updateSale.Special_Assessments_Seller_Pays_in_Ful__c, true, 'Checbox not updated');
     //   System.assertEquals(updateSale.Home_Warranty_Seller_Pays__c, true, 'Checbox not updated');
     //   System.assertEquals(updateSale.Loan_Rate_Type_Adjustable__c, true, 'Checbox not updated');
     //   System.assertEquals(updateSale.May_Assign_Not_Released__c, true, 'Checbox not updated');
     //   System.assertEquals(updateSale.Initial_Deposit_at_a_future_date__c, true, 'Checbox not updated');
     //   System.assertEquals(updateSale.Closing_Agent_Buyer_Designates__c, true, 'Checbox not updated');
    }

}