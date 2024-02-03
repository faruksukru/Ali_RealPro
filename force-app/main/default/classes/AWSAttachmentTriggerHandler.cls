Public class AWSAttachmentTriggerHandler
{
    
    Public static void handleOperations(List<Attachment__c> newRecords, List<Attachment__c> oldRecords, Map<Id, Attachment__c> newMap, Map<Id, Attachment__c> oldMap, TriggerOperation operationType) 
    {
        Switch on operationType
        {
            When AFTER_DELETE 
            {
                afterDeleteHandler(newRecords, newMap, oldRecords, oldMap);
            }
        }
    }
    
    Public static void afterDeleteHandler(List<Attachment__c> newRecords, Map<Id, Attachment__c> newMap, List<Attachment__c> oldRecords, Map<Id, Attachment__c> oldMap)
    {
        system.debug('-newRecords-'+newRecords);
        system.debug('-oldMap-'+oldMap);
        deleteFileInAWS(oldRecords);
    }
    
    Public static void deleteFileInAWS(List<Attachment__c> oldRecords)
    {        
		//only one file at a time
        deleteInAWS(oldRecords[0].Property__c, oldRecords[0].File_Name__c, oldRecords[0].Content_Type__c, oldRecords[0].FileURL__c, oldRecords[0].AWS_File_Name__c);
    }
    
    @future (callout=true)
    public static void deleteInAWS(String parentId, String strfileName, String fileType, String endPoint, String awsFileName)
    {
        System.debug('fileName=' + strfileName);
        System.debug('fileType=' + fileType);
        AWS_Setting__mdt awsSetting = [SELECT AWS_Access_Secret__c, AWS_Secret_Access_Key__c, S3_Bucket_Name__c, S3_Host__c 
                                       FROM AWS_Setting__mdt Where DeveloperName = 'AWS_Setting' Limit 1];
        
        HttpRequest req = new HttpRequest();

        String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        String dateString = Datetime.now().format('ddMMYYYYHHmmss');        
        String filename = awsFileName;
        
        //AWS specific information
        String key = awsSetting.AWS_Secret_Access_Key__c; //AWS key
        String secret = awsSetting.AWS_Access_Secret__c; //AWS Secret key
        String bucketname = awsSetting.S3_Bucket_Name__c; //AWS bucket name
        String host = awsSetting.S3_Host__c; //AWS Host 
        String endPoint1 = 'https://' + bucketname + '.' + host + '/'+ filename;
        String method = 'DELETE';
        
        req.setMethod(method);
        req.setEndpoint(endPoint1);
        req.setTimeout(2000);
        
        system.debug('Endpoint='+endPoint1);
        //create header information
        req.setHeader('Host', bucketname + '.' + host);
        req.setHeader('Content-type', fileType);
        req.setHeader('Date', formattedDateString); 
        req.setHeader('Accept', 'application/json');
        
        //prepare for signing information
        String stringToSign ='DELETE\n\n' +
            fileType + '\n' +
            formattedDateString + '\n' + '/' + bucketname + '/' + filename;
        
        String encodedStringToSign = EncodingUtil.urlEncode(stringToSign, 'UTF-8');
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String signedKey  = EncodingUtil.base64Encode(mac);
        
        //assign Authorization information
        String authHeader = 'AWS' + ' ' + key + ':' + signedKey;                    
        req.setHeader('Authorization',authHeader);
        
        //finally send information to AWS        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        System.debug('*Resp:' + String.ValueOF(res.getBody()));
        System.debug('RESPONSE STRING: ' + res.toString());
        System.debug('RESPONSE STATUS: ' + res.getStatus());
        System.debug('STATUS_CODE: ' + res.getStatusCode());
        
        if(res.getStatusCode() == 200 || res.getStatusCode() == 204){
			system.debug('Successfully deleted!');
        }
    }
}