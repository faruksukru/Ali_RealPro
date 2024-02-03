public class NDAVerifiedEmailController {
	public Property__c properties;
    public List<PropertyExpense__c> propExpences;
    public List<PropertyIncome__c> propIncomes;
    public Id property{get;set;}
    
	public Property__c getProperties() {
		return [select Name, Description__c, Listing_Status__c, Status__c, LegalDescription__c, Subdivision__c, 
                    	AssessedValue__c, PropertyType__c,Street_view__c, FinancialSummaryType__c, SalesPrice__c, EstimatedRehab__c, TotalInvestment__c 
                      	from Property__c where Id =: property][0];
	}

    public List<PropertyIncome__c> getPropIncomes() {
        return [select Name, Id, Property__c, MonthlyRent__c, Unit_Name__c, Bedrooms__c, Bathrooms__c
                      	from PropertyIncome__c where Property__c =: property];
	}

    public List<PropertyExpense__c> getPropExpences(){
        return [Select Id, MonthlyExpense__c, ExpenseType__c, Property__c from PropertyExpense__c where Property__c =: property];
    }
}