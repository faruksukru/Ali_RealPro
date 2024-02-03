public with sharing class AWSFileUploadController {
    
    @AuraEnabled
    public static boolean uploadFileToAWS(Id parentId,
                                          String strfileName, String fileType,
                                          String fileContent)
    {
        System.debug('parentId=' + parentId);
        System.debug('strfileName=' + strfileName);
        System.debug('fileType=' + fileType);
        
        AWS_Setting__mdt awsSetting = [SELECT AWS_Access_Secret__c, AWS_Secret_Access_Key__c, S3_Bucket_Name__c, S3_Host__c 
                                       FROM AWS_Setting__mdt Where DeveloperName = 'AWS_Setting' Limit 1];
        HttpRequest req = new HttpRequest();
        strfileName = strfileName.replaceAll(' ', '');
        Blob base64Content = EncodingUtil.base64Decode(EncodingUtil.urlDecode(fileContent, 'UTF-8'));
        String attachmentBody =  fileContent;           
        String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        String dateString = Datetime.now().format('ddMMYYYYHHmmss');        
        String filename =  dateString + '_' + parentId + '_' + strfileName;
        
        
        //AWS specific information
        String key = awsSetting.AWS_Secret_Access_Key__c; //AWS key
        String secret = awsSetting.AWS_Access_Secret__c; //AWS Secret key
        String bucketname = awsSetting.S3_Bucket_Name__c; //AWS bucket name
        String host = awsSetting.S3_Host__c; //AWS Host 
        
        String method = 'PUT';
        String endPoint = 'https://' + bucketname + '.' + host + '/'+ filename;
        
        req.setMethod(method);
        req.setEndpoint(endPoint);
        req.setTimeout(2000);
        
        system.debug('Endpoint='+endPoint);
        //create header information
        req.setHeader('Host', bucketname + '.' + host);
        req.setHeader('Access-Control-Allow-Origin', '*');
        req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Content-type', fileType);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', formattedDateString); 
        req.setHeader('ACL', 'public-read');
        //store file as blob       
        req.setBodyAsBlob(base64Content);
        
        //prepare for signing information
        String stringToSign ='PUT\n\n' +
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
        
        if(res.getStatusCode() == 200){
            insertAttachmentRecord (parentId,strfileName,endPoint,fileType,fileName);
            return true;
        }
        return false;
    }

    //This method inserts file information to Custom Attachment object
    public static void insertAttachmentRecord (Id parentId, String fileName, String fileURL, String contentType, String awsFileName){
        Attachment__c attachment = new Attachment__c();
        attachment.Property__c = parentId;
        attachment.FileURL__c = fileURL;
        attachment.File_Name__c =  fileName;
        attachment.name = fileName;
        attachment.Content_Type__c = contentType;
        attachment.AWS_File_Name__c = awsFileName;
        insert attachment;                                           
    }
}