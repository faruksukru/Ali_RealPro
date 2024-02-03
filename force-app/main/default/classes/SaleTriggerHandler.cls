/**
* @description       : Apex trigger handler for Sale
* @author            : Satyam Kumar
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   01-08-2021   Satyam Kumar   Initial Version
* */
public without sharing class SaleTriggerHandler {
    
    public void handler(List<Sale__c> newRecords, List<Sale__c> oldRecords, Map<Id, Sale__c> newMap, Map<Id, Sale__c> oldMap, TriggerOperation operation){
        
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
    
    public void beforeInsert(List<Sale__c> newRecords, List<Sale__c> oldRecords, Map<Id, Sale__c> newMap, Map<Id, Sale__c> oldMap){
        updateRecordType(newRecords);
        updateCheckBox(newRecords, oldMap);
    }
    
    public void beforeUpdate(List<Sale__c> newRecords, List<Sale__c> oldRecords, Map<Id, Sale__c> newMap, Map<Id, Sale__c> oldMap){
        updateCheckBox(newRecords, oldMap);
    }
    
    public void beforeDelete(List<Sale__c> newRecords, List<Sale__c> oldRecords, Map<Id, Sale__c> newMap, Map<Id, Sale__c> oldMap){
        
    }
    
    public void afterInsert(List<Sale__c> newRecords, List<Sale__c> oldRecords, Map<Id, Sale__c> newMap, Map<Id, Sale__c> oldMap){
        
    }
    
    public void afterUpdate(List<Sale__c> newRecords, List<Sale__c> oldRecords, Map<Id, Sale__c> newMap, Map<Id, Sale__c> oldMap){
        
    }
    
    public void afterDelete(List<Sale__c> newRecords, List<Sale__c> oldRecords, Map<Id, Sale__c> newMap, Map<Id, Sale__c> oldMap){
        
    }
    
    //Method to update record type
    public static void updateRecordType(List<Sale__c> newRecords) { 
        Try {
            Map<String, Id> recordTypeMap = new Map<String, Id>();
            for(RecordType recType: [SELECT Id, DeveloperName, Name, SobjectType FROM RecordType Where SobjectType = 'Sale__c']){
                recordTypeMap.put(recType.DeveloperName, recType.Id);
            }
            
            for(Sale__c sale: newRecords) 
            {
                if(String.isNotBlank(sale.state__c) && recordTypeMap!= null && recordTypeMap.containsKey(sale.state__c) ) {
                    sale.recordTypeId = recordTypeMap.get(sale.State__c);
                }
            }
            
        } catch(Exception e)
        {
            system.debug('Error in SaleTrigger: '+e.getStackTraceString()+' '+e.getMessage());
        }
    }
    
    //Method to update Checbox value based on Picklist value
    public static void updateCheckBox(List<Sale__c> newRecords, Map<Id, Sale__c> oldMap) {
        Try {
            
            for(Sale__c sale: newRecords) 
            {
                //Closing Agent Selection
                if((Trigger.isInsert && String.isNotBlank(sale.Closing_Agent_Selection__c)) 
                   || (Trigger.isUpdate && sale.Closing_Agent_Selection__c != oldMap.get(sale.Id).Closing_Agent_Selection__c)) 
                {
                    sale.Closing_Agent_Seller_Designates__c = false;
                    sale.Closing_Agent_Buyer_Designates__c = false;
                    sale.Closing_Agent_Miami_Dade_Provision__c = false;
                    
                    switch on sale.Closing_Agent_Selection__c 
                    {
                        when 'Seller designates'
                        {
                            sale.Closing_Agent_Seller_Designates__c = true;
                        }
                        when 'Buyer Designates' 
                        {
                            sale.Closing_Agent_Buyer_Designates__c = true;
                        }
                        when 'Miami-Dad/Broward Regional Provision' 
                        {
                            sale.Closing_Agent_Miami_Dade_Provision__c = true;
                        }
                    }
                }
                
                //Initial Deposit Option
                if((Trigger.isInsert && String.isNotBlank(sale.Initial_Deposit_Option__c)) 
                   || (Trigger.isUpdate && sale.Initial_Deposit_Option__c != oldMap.get(sale.Id).Initial_Deposit_Option__c)) 
                {
                    sale.Accompanies_Offer__c = false;
                    sale.Initial_Deposit_at_a_future_date__c = false;
                    
                    switch on sale.Initial_Deposit_Option__c 
                    {
                        when 'Accompanies Offer'
                        {
                            sale.Accompanies_Offer__c = true;
                        }
                        when 'Initial Deposit at a future date' 
                        {
                            sale.Initial_Deposit_at_a_future_date__c = true;
                        }
                    }
                }
                
                //Assignability
                if((Trigger.isInsert && String.isNotBlank(sale.Assignability__c)) 
                   || (Trigger.isUpdate && sale.Assignability__c != oldMap.get(sale.Id).Assignability__c)) 
                {
                    sale.May_Assign_Released__c = false;
                    sale.May_Assign_Not_Released__c = false;
                    sale.May_Not_Assign__c = false;
                    
                    switch on sale.Assignability__c 
                    {
                        when 'May Assign - Released'
                        {
                            sale.May_Assign_Released__c = true;
                        }
                        when 'May Assign - Not Released' 
                        {
                            sale.May_Assign_Not_Released__c = true;
                        }
                         when 'May Not Assign' 
                        {
                            sale.May_Not_Assign__c = true;
                        }
                    }
                }
                
                //Rate Type
                if((Trigger.isInsert && String.isNotBlank(sale.Rate_Type__c)) 
                   || (Trigger.isUpdate && sale.Rate_Type__c  != oldMap.get(sale.Id).Rate_Type__c)) 
                {
                    sale.Loan_Rate_Type_Fixed__c = false;
                    sale.Loan_Rate_Type_Adjustable__c = false;
                    sale.Loan_Rate_Type_Fixed_or_Adjustable__c = false;
                    
                    switch on sale.Rate_Type__c 
                    {
                        when 'Fixed'
                        {
                            sale.Loan_Rate_Type_Fixed__c = true;
                        }
                        when 'Adjustable' 
                        {
                            sale.Loan_Rate_Type_Adjustable__c = true;
                        }
                         when 'Fixed or Adjustable' 
                        {
                            sale.Loan_Rate_Type_Fixed_or_Adjustable__c = true;
                        }
                    }
                }
                
                //Home Warranty
                if((Trigger.isInsert && String.isNotBlank(sale.Home_Warranty__c)) 
                   || (Trigger.isUpdate && sale.Home_Warranty__c  != oldMap.get(sale.Id).Home_Warranty__c)) 
                {
                    sale.Home_Warranty_Buyer_Pays__c = false;
                    sale.Home_Warranty_Seller_Pays__c = false;
                    sale.Home_Warranty_N_A__c = false;
                    
                    switch on sale.Home_Warranty__c 
                    {
                        when 'Buyer'
                        {
                            sale.Home_Warranty_Buyer_Pays__c = true;
                        }
                        when 'Seller' 
                        {
                            sale.Home_Warranty_Seller_Pays__c = true;
                        }
                         when 'N/A' 
                        {
                            sale.Home_Warranty_N_A__c = true;
                        }
                    }
                }
                
                //Special Assessments
                if((Trigger.isInsert && String.isNotBlank(sale.Special_Assessments__c)) 
                   || (Trigger.isUpdate && sale.Special_Assessments__c  != oldMap.get(sale.Id).Special_Assessments__c)) 
                {
                    sale.Special_Assessments_Seller_Buyer__c = false;
                    sale.Special_Assessments_Seller_Pays_in_Ful__c = false;
                    
                    switch on sale.Special_Assessments__c 
                    {
                        when 'Seller/Buyer'
                        {
                            sale.Special_Assessments_Seller_Buyer__c = true;
                        }
                        when 'Seller Pays in Full' 
                        {
                            sale.Special_Assessments_Seller_Pays_in_Ful__c = true;
                        }
                    }
                }
                
                //Financing
                if((Trigger.isInsert && String.isNotBlank(sale.Financing__c)) 
                   || (Trigger.isUpdate && sale.Financing__c  != oldMap.get(sale.Id).Financing__c)) 
                {
                    sale.Financing_Cash__c = false;
                    sale.Financing_Loan__c = false;
                    sale.Loan_Type_Conventional__c = false;
                    sale.Loan_Type_FHA__c = false;
                    sale.Loan_Type_VA__c = false;
                    sale.Loan_Type_Other__c = false;
                    
                    switch on sale.Financing__c 
                    {
                        when 'Cash'
                        {
                            sale.Financing_Cash__c = true;
                        }
                        when 'Conventional' 
                        {
                            sale.Financing_Loan__c = true;
                            sale.Loan_Type_Conventional__c = true;
                        }
                        when 'FHA'
                        {
                            sale.Financing_Loan__c = true;
                            sale.Loan_Type_FHA__c = true;
                        }
                        when 'VA' 
                        {
                            sale.Financing_Loan__c = true;
                            sale.Loan_Type_VA__c = true;
                        }
                        when 'Other' 
                        {
                            sale.Financing_Loan__c = true;
                            sale.Loan_Type_Other__c = true;
                        }
                    }
                }
            }
            
        } catch(Exception e)
        {
            system.debug('Error in SaleTrigger: '+e.getStackTraceString()+' '+e.getMessage());
        }
    }

}