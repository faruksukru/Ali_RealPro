public class NDAAction {
    @InvocableMethod(label='Send NDA Deatils' category='Conga')
    public static void sendNDADetails(List<List<String>> ids) {
        List<String> accountNames = new List<String>();
        PropertyInterestedBuyers__c propertyInterestedIn = [Select Id,Status__c, Property__c, Account__c, Account__r.PersonEmail from PropertyInterestedBuyers__c Where Account__c =: ids[0][0] order by lastmodifiedDate desc Limit 1];
        Contact con = [Select Id From Contact Where AccountId =: propertyInterestedIn.Account__c limit 1];
        EmailTemplate et = [select Id, Name from EmailTemplate where DeveloperName = 'Account_NDA_Verified'];
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage ();  
        semail.setTargetObjectId(con.Id);
        semail.setTemplateId(et.Id);
        semail.setWhatId(propertyInterestedIn.Property__c);
        semail.setTreatTargetObjectAsRecipient(true);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
        propertyInterestedIn.Status__c = 'Information Sent';
        update propertyInterestedIn;
    }
}