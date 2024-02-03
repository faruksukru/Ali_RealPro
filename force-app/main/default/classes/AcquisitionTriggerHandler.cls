/**
* @description       : Apex trigger handler for Acquisition
* @author            : Satyam Kumar
* Modifications Log 
* Ver   Date         Author          Modification
* 1.0   01-08-2021   Satyam Kumar   Initial Version
* */
public without sharing class AcquisitionTriggerHandler {
    
    public void handler(List<Acquisition__c> newRecords, List<Acquisition__c> oldRecords, Map<Id, Acquisition__c> newMap, Map<Id, Acquisition__c> oldMap, TriggerOperation operation){
        
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
    
    public void beforeInsert(List<Acquisition__c> newRecords, List<Acquisition__c> oldRecords, Map<Id, Acquisition__c> newMap, Map<Id, Acquisition__c> oldMap){
        updateRecordType(newRecords);
        updateCheckBox(newRecords, oldMap);
    }
    
    public void beforeUpdate(List<Acquisition__c> newRecords, List<Acquisition__c> oldRecords, Map<Id, Acquisition__c> newMap, Map<Id, Acquisition__c> oldMap){
        updateCheckBox(newRecords, oldMap);
    }
    
    public void beforeDelete(List<Acquisition__c> newRecords, List<Acquisition__c> oldRecords, Map<Id, Acquisition__c> newMap, Map<Id, Acquisition__c> oldMap){
        
    }
    
    public void afterInsert(List<Acquisition__c> newRecords, List<Acquisition__c> oldRecords, Map<Id, Acquisition__c> newMap, Map<Id, Acquisition__c> oldMap){
        
    }
    
    public void afterUpdate(List<Acquisition__c> newRecords, List<Acquisition__c> oldRecords, Map<Id, Acquisition__c> newMap, Map<Id, Acquisition__c> oldMap){
        
    }
    
    public void afterDelete(List<Acquisition__c> newRecords, List<Acquisition__c> oldRecords, Map<Id, Acquisition__c> newMap, Map<Id, Acquisition__c> oldMap){
        
    }
    
    //Method to update record type
    public static void updateRecordType(List<Acquisition__c> newRecords) {
        Try {
            Map<String, Id> recordTypeMap = new Map<String, Id>();
            for(RecordType recType: [SELECT Id, DeveloperName, Name, SobjectType FROM RecordType Where SobjectType = 'Acquisition__c']){
                recordTypeMap.put(recType.DeveloperName, recType.Id);
            }
            
            for(Acquisition__c acquisition: newRecords) 
            {
                if(String.isNotBlank(acquisition.state__c) && recordTypeMap!= null && recordTypeMap.containsKey(acquisition.state__c)) {
                    acquisition.recordTypeId = recordTypeMap.get(acquisition.State__c);
                }
            }
            
        } catch(Exception e)
        {
            system.debug('Error in AcquisitionTrigger: '+e.getStackTraceString()+' '+e.getMessage());
        }
    }
    
    //Method to update Checbox value based on Picklist value
    public static void updateCheckBox(List<Acquisition__c> newRecords, Map<Id, Acquisition__c> oldMap) {
        Try {
            
            for(Acquisition__c acquisition: newRecords) 
            {
                //Closing Agent Selection
                if((Trigger.isInsert && String.isNotBlank(acquisition.Closing_Agent_Selection__c)) 
                   || (Trigger.isUpdate && acquisition.Closing_Agent_Selection__c != oldMap.get(acquisition.Id).Closing_Agent_Selection__c)) 
                {
                    acquisition.Closing_Agent_Seller_Designates__c = false;
                    acquisition.Closing_Agent_Buyer_Designates__c = false;
                    acquisition.Closing_Agent_Miami_Dade_Provision__c = false;
                    
                    switch on acquisition.Closing_Agent_Selection__c 
                    {
                        when 'Seller designates'
                        {
                            acquisition.Closing_Agent_Seller_Designates__c = true;
                        }
                        when 'Buyer Designates' 
                        {
                            acquisition.Closing_Agent_Buyer_Designates__c = true;
                        }
                        when 'Miami-Dad/Broward Regional Provision' 
                        {
                            acquisition.Closing_Agent_Miami_Dade_Provision__c = true;
                        }
                    }
                }
                
                //Initial Deposit Option
                if((Trigger.isInsert && String.isNotBlank(acquisition.Initial_Deposit_Option__c)) 
                   || (Trigger.isUpdate && acquisition.Initial_Deposit_Option__c != oldMap.get(acquisition.Id).Initial_Deposit_Option__c)) 
                {
                    acquisition.Accompanies_Offer__c = false;
                    acquisition.Initial_Deposit_at_a_future_date__c = false;
                    
                    switch on acquisition.Initial_Deposit_Option__c 
                    {
                        when 'Accompanies Offer'
                        {
                            acquisition.Accompanies_Offer__c = true;
                        }
                        when 'Initial Deposit at a future date' 
                        {
                            acquisition.Initial_Deposit_at_a_future_date__c = true;
                        }
                    }
                }
                
                //Assignability
                if((Trigger.isInsert && String.isNotBlank(acquisition.Assignability__c)) 
                   || (Trigger.isUpdate && acquisition.Assignability__c != oldMap.get(acquisition.Id).Assignability__c)) 
                {
                    acquisition.May_Assign_Released__c = false;
                    acquisition.May_Assign_Not_Released__c = false;
                    acquisition.May_Not_Assign__c = false;
                    
                    switch on acquisition.Assignability__c 
                    {
                        when 'May Assign - Released'
                        {
                            acquisition.May_Assign_Released__c = true;
                        }
                        when 'May Assign - Not Released' 
                        {
                            acquisition.May_Assign_Not_Released__c = true;
                        }
                         when 'May Not Assign' 
                        {
                            acquisition.May_Not_Assign__c = true;
                        }
                    }
                }
                
                //Rate Type
                if((Trigger.isInsert && String.isNotBlank(acquisition.Rate_Type__c)) 
                   || (Trigger.isUpdate && acquisition.Rate_Type__c  != oldMap.get(acquisition.Id).Rate_Type__c)) 
                {
                    acquisition.Loan_Rate_Type_Fixed__c = false;
                    acquisition.Loan_Rate_Type_Adjustable__c = false;
                    acquisition.Loan_Rate_Type_Fixed_or_Adjustable__c = false;
                    
                    switch on acquisition.Rate_Type__c 
                    {
                        when 'Fixed'
                        {
                            acquisition.Loan_Rate_Type_Fixed__c = true;
                        }
                        when 'Adjustable' 
                        {
                            acquisition.Loan_Rate_Type_Adjustable__c = true;
                        }
                         when 'Fixed or Adjustable' 
                        {
                            acquisition.Loan_Rate_Type_Fixed_or_Adjustable__c = true;
                        }
                    }
                }
                
                //Home Warranty
                if((Trigger.isInsert && String.isNotBlank(acquisition.Home_Warranty__c)) 
                   || (Trigger.isUpdate && acquisition.Home_Warranty__c  != oldMap.get(acquisition.Id).Home_Warranty__c)) 
                {
                    acquisition.Home_Warranty_Buyer_Pays__c = false;
                    acquisition.Home_Warranty_Seller_Pays__c = false;
                    acquisition.Home_Warranty_N_A__c = false;
                    
                    switch on acquisition.Home_Warranty__c 
                    {
                        when 'Buyer'
                        {
                            acquisition.Home_Warranty_Buyer_Pays__c = true;
                        }
                        when 'Seller' 
                        {
                            acquisition.Home_Warranty_Seller_Pays__c = true;
                        }
                         when 'N/A' 
                        {
                            acquisition.Home_Warranty_N_A__c = true;
                        }
                    }
                }
                
                //Special Assessments
                if((Trigger.isInsert && String.isNotBlank(acquisition.Special_Assessments__c)) 
                   || (Trigger.isUpdate && acquisition.Special_Assessments__c  != oldMap.get(acquisition.Id).Special_Assessments__c)) 
                {
                    acquisition.Special_Assessments_Seller_Buyer__c = false;
                    acquisition.Special_Assessments_Seller_Pays_in_Ful__c = false;
                    
                    switch on acquisition.Special_Assessments__c 
                    {
                        when 'Seller/Buyer'
                        {
                            acquisition.Special_Assessments_Seller_Buyer__c = true;
                        }
                        when 'Seller Pays in Full' 
                        {
                            acquisition.Special_Assessments_Seller_Pays_in_Ful__c = true;
                        }
                    }
                }
                
                //Financing
                if((Trigger.isInsert && String.isNotBlank(acquisition.Financing__c)) 
                   || (Trigger.isUpdate && acquisition.Financing__c  != oldMap.get(acquisition.Id).Financing__c)) 
                {
                    acquisition.Financing_Cash__c = false;
                    acquisition.Financing_Loan__c = false;
                    acquisition.Loan_Type_Conventional__c = false;
                    acquisition.Loan_Type_FHA__c = false;
                    acquisition.Loan_Type_VA__c = false;
                    acquisition.Loan_Type_Other__c = false;
                    
                    switch on acquisition.Financing__c 
                    {
                        when 'Cash'
                        {
                            acquisition.Financing_Cash__c = true;
                        }
                        when 'Conventional' 
                        {
                            acquisition.Financing_Loan__c = true;
                            acquisition.Loan_Type_Conventional__c = true;
                        }
                        when 'FHA'
                        {
                            acquisition.Financing_Loan__c = true;
                            acquisition.Loan_Type_FHA__c = true;
                        }
                        when 'VA' 
                        {
                            acquisition.Financing_Loan__c = true;
                            acquisition.Loan_Type_VA__c = true;
                        }
                        when 'Other' 
                        {
                            acquisition.Financing_Loan__c = true;
                            acquisition.Loan_Type_Other__c = true;
                        }
                    }
                }
            }
            
        } catch(Exception e)
        {
            system.debug('Error in AcquisitionTrigger: '+e.getStackTraceString()+' '+e.getMessage());
        }
    }
}