@RestResource(urlMapping='/NDARequest/*')
global with sharing class NDARequest {
    
    @HttpPost
    global static String doPost(String email, String propertyId, String firstName, String lastName) {
        
        List<Property__c> listProperty = new List<Property__c>();
        listProperty = [Select Id, Name from Property__c where Id =: propertyId];
        
        //Check if Property exists with the Property ID
        if(!listProperty.isEmpty()){//Property found with the Property ID
            Property__c property = listProperty[0];
            
            //Check if Account exists in Salesforce by the email.
            List<Account> listAccount = new List<Account>();
            listAccount = [Select Id, Name, Email__c, Validated__c from Account where Email__c =: email];
            if(!listAccount.isEmpty()){ //Account found with same email
                Account matchedAccount = listAccount[0];
                
                //Create junction record in PropertyInterestedBuyers__c to relate Account with the Property.
                PropertyInterestedBuyers__c propAccount = new PropertyInterestedBuyers__c();
                propAccount.Account__c = matchedAccount.Id;
                propAccount.Property__c = property.Id;
                insert propAccount;
                
                //Create NDA record
                NDA__c nda = new NDA__c();
                nda.Account__c = matchedAccount.Id;
                nda.Property__c = property.Id;
                insert nda;
                
                //Send Notifications
                if(matchedAccount.Validated__c){ //Account Verified/Qualified
                    //Send NDA Request via Conga Sign
                    //Write logic here
                }
                else{ //Account not Verified/Qualified
                    //This logic is handled in scheduled apex to sent mail. Refer to ApexScheduledClassNDANotification.
                }
                String returnString = 'Property added to Qualified : '+ matchedAccount.Validated__c + 'Existing Account :' + matchedAccount.Id;
                return returnString;
            }
            else{ //Account not present
                //Create new Account with the Email.
                Recordtype rt = [Select Id from Recordtype where Name = 'Buyer' and SObjectType = 'Account'];
                Account acc = new Account();
                acc.Name = firstName+ ' ' +lastName;
                acc.Email__c = email;
                acc.RecordTypeId = rt.Id;
                insert acc;
                
                //Send  instructions to verify ID
                //This logic is handled in scheduled apex to sent mail. Refer to ApexScheduledClassNDANotification.
                
                //Create junction record in PropertyInterestedBuyers__c to relate Account with the Property.
                PropertyInterestedBuyers__c propAccount = new PropertyInterestedBuyers__c();
                propAccount.Account__c = acc.Id;
                propAccount.Property__c = property.Id;
                insert propAccount;
                
                //Create NDA record
                NDA__c nda = new NDA__c();
                nda.Account__c = acc.Id;
                nda.Property__c = property.Id;
                insert nda;
                
                String returnString = 'Property added to New Account :' + acc.Id;
                return returnString;
            }
        }
        else{ //Property not present with the Property ID
            //Write logic here
            return 'Property Not Found';
        }
    }
    
    /*global static void sendEmailForVerification(String accountName, Id AccountId, String email) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        string [] toaddress = new List<String>{email}; 
        mail.setToAddresses(toaddress);  
        //mail.setTargetObjectId(AccountId);
        //mail.setWhatId('a35c000000042bA');
        //mail.setTemplateId('00Xc0000000MdL2');
        //mail.setSaveAsActivity(false);
      	mail.setHtmlBody('Please verify your Account :<b>' + accountName);
                         
        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
     }*/

}