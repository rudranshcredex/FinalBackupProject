/******************************************************************************
* Author: Nikhil Garg
* Date: June 21, 2023
* Descpription: AWS Service for uploading and fetching files & buckets Data

*/
public WITH SHARING class AwsS3Integration {
    
    private static String awsKey {get;set;}
    private static String awsSecret {get;set;}
    private static String bucketName {get;set;}
    private static String methodName {get;set;}
    private static String hostName = 's3.amazonaws.com';
    private static String algorithm='AWS4-HMAC-SHA256';
    private static String service='s3';
    Private static String regionName {get;set;}
    Private static List<String> buckets=new List<String>();
    Private static List<String> Files=new List<String>();
    
    Private static string ContentType(string fileType)
    {
        switch on fileType.toLowerCase()
        {
            when 'docx'
            {
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            }
            when 'csv'
            {
                return 'application/vnd.ms-excel';
            }
            when 'wav'
            {
                return 'audio/wav';
            }
            when 'wmv'
            {
                return 'video/x-ms-wmv';
            }
            when 'mp3'
            {
                return 'audio/mpeg';
            }
            when 'mp4'
            {
                return 'video/mp4';
            }
            when 'png'
            {
                return 'image/png';
                
            }
            when 'pdf'
            {
                return 'application/pdf';
                
            }
            when else {
                return 'image/jpeg';
            }
        }
    }
    
    
    private static string CreateAuthHeader(String type,String formattedDateString,String longDate,String dateStamp )
    {
        String canonicalRequest;
        if(type=='Buckets'){
            canonicalRequest = methodName +'\n' + '/'+'\n\n'+'date:'+ longDate + '\n' +'host:'+'s3'+'.'+regionName+'.amazonaws.com' + '\n' +'x-amz-content-sha256:UNSIGNED-PAYLOAD'+'\n'+'x-amz-date:'+formattedDateString +'\n\n'+'date;host;x-amz-content-sha256;x-amz-date'+'\n'+'UNSIGNED-PAYLOAD';
        }
        if(type=='Files'){
            canonicalRequest = methodName +'\n' + '/'+ '\n\n'+'date:'+ longDate + '\n' +'host:'+ bucketName+'.s3'+'.'+RegionName+'.amazonaws.com' + '\n' +'x-amz-content-sha256:UNSIGNED-PAYLOAD'+'\n'+'x-amz-date:'+formattedDateString +'\n\n'+'date;host;x-amz-content-sha256;x-amz-date'+'\n'+'UNSIGNED-PAYLOAD';
        }
        system.debug(canonicalRequest);
        
        Blob canonicalHash = Crypto.generateDigest('SHA-256', Blob.valueof(canonicalRequest));
        String canonicalHashString = EncodingUtil.convertToHex(canonicalHash);
        
        String stringToSign = algorithm + '\n' + formattedDateString + '\n' + dateStamp + '/' + regionName + '/'+ service + '/aws4_request\n' + canonicalHashString;
        
        String kSecret = 'AWS4' + awsSecret;
        Blob kDate = Crypto.generateMac('HmacSHA256', Blob.valueOf(dateStamp), Blob.valueOf(kSecret));
        Blob kRegion = Crypto.generateMac('HmacSHA256', Blob.valueOf(regionName), kDate);
        Blob kService = Crypto.generateMac('HmacSHA256', Blob.valueOf(service), kRegion);
        Blob kSigning = Crypto.generateMac('HmacSHA256', Blob.valueOf('aws4_request'), kService);
        Blob blobSignature  = Crypto.generateMac('HmacSHA256', Blob.valueOf(stringToSign), kSigning);
        
        string signature=EncodingUtil.convertToHex(blobSignature );
        string headersInSignature='date;host;x-amz-content-sha256;x-amz-date';
        return (algorithm + ' Credential=' + awsKey + '/' + dateStamp + '/' + regionName + '/' + service + '/aws4_request, SignedHeaders='+headersInSignature+', Signature=' + signature);
    }
    @TestVisible
    private static string CreateAuthHeaderForFileKey(String fileKey, String formattedDateString, String longDate,String dateStamp )
    {
        String canonicalRequest = methodName + '\n/' + fileKey+'\n\n'+'date:'+ longDate + '\n' +'host:'+ bucketName+'.s3'+'.'+RegionName+'.amazonaws.com' + '\n' +'x-amz-content-sha256:UNSIGNED-PAYLOAD'+'\n'+'x-amz-date:'+formattedDateString +'\n\n'+'date;host;x-amz-content-sha256;x-amz-date'+'\n'+'UNSIGNED-PAYLOAD';
        Blob canonicalHash = Crypto.generateDigest('SHA-256', Blob.valueof(canonicalRequest));
        String canonicalHashString = EncodingUtil.convertToHex(canonicalHash);
        
        String stringToSign = algorithm + '\n' + formattedDateString + '\n' + dateStamp + '/' + regionName + '/' + service + '/aws4_request\n' + canonicalHashString;
        
        String kSecret = 'AWS4' + awsSecret;
        Blob kDate = Crypto.generateMac('HmacSHA256', Blob.valueOf(dateStamp), Blob.valueOf(kSecret));
        Blob kRegion = Crypto.generateMac('HmacSHA256', Blob.valueOf(regionName), kDate);
        Blob kService = Crypto.generateMac('HmacSHA256', Blob.valueOf(service), kRegion);
        Blob kSigning = Crypto.generateMac('HmacSHA256', Blob.valueOf('aws4_request'), kService);
        Blob blobSignature  = Crypto.generateMac('HmacSHA256', Blob.valueOf(stringToSign), kSigning);
        
        string signature=EncodingUtil.convertToHex(blobSignature );
        string headersInSignature='date;host;x-amz-content-sha256;x-amz-date';
        return (algorithm + ' Credential=' + awsKey + '/' + dateStamp + '/' + regionName + '/' + service + '/aws4_request, SignedHeaders='+headersInSignature+', Signature=' + signature);
    }
    
    Private static string CreateAuthHeaderForPUT(String contentType,String filename, String formattedDateString,String longDate,string fileExtension,blob content,String dateStamp )
    {
        Blob  contentHash = Crypto.generateDigest('SHA-256', content);
        String hashedPaylod = EncodingUtil.convertToHex(contentHash);
        String canonicalRequest = methodName + '\n/' + filename.toLowerCase() + '.' + fileExtension.toLowerCase() +'\n\n'+'date:'+ longDate + '\n' +'host:'+ bucketName+'.s3'+'.'+RegionName+'.amazonaws.com' + '\n' +'x-amz-content-sha256:'+hashedPaylod+'\n'+'x-amz-date:'+formattedDateString +'\n\n'+'date;host;x-amz-content-sha256;x-amz-date'+'\n'+hashedPaylod;
        
        Blob canonicalHash = Crypto.generateDigest('SHA-256', Blob.valueof(canonicalRequest));
        String canonicalHashString = EncodingUtil.convertToHex(canonicalHash);        
        String stringToSign = algorithm + '\n' + formattedDateString + '\n' + dateStamp + '/' + regionName + '/' + service + '/aws4_request\n' + canonicalHashString;
        
        String kSecret = 'AWS4' + awsSecret;
        Blob kDate = Crypto.generateMac('HmacSHA256', Blob.valueOf(dateStamp), Blob.valueOf(kSecret));
        Blob kRegion = Crypto.generateMac('HmacSHA256', Blob.valueOf(regionName), kDate);
        Blob kService = Crypto.generateMac('HmacSHA256', Blob.valueOf(service), kRegion);
        Blob kSigning = Crypto.generateMac('HmacSHA256', Blob.valueOf('aws4_request'), kService);
        Blob blobSignature  = Crypto.generateMac('HmacSHA256', Blob.valueOf(stringToSign), kSigning);
        
        string signature=EncodingUtil.convertToHex(blobSignature );
        string headersInSignature='date;host;x-amz-content-sha256;x-amz-date';                     
        
        return (algorithm + ' Credential=' + awsKey + '/' + dateStamp + '/' + regionName + '/' + service + '/aws4_request, SignedHeaders='+headersInSignature+', Signature=' + signature);
    }
    
    
    
    @auraEnabled(cacheable=true)
    public static List<String> getBuckets(string accessKey, String secretKey,String awsRegion)
    {
        awsKey = accessKey;
        awsSecret = secretKey;
        regionName = awsRegion;
        methodName = 'GET';
        String remoteSiteSettingName ='AwsBucket';
        String exceptionMessage ='Exception';
        try
        {
            
            String longDate = Datetime.now().formatGMT('E, dd MMM yyyy HH:mm:ss z');                
            String formattedDateString = Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');              
            String dateStamp = Datetime.now().formatGMT('yyyyMMdd');
            
            string fileUrl='https://'+'s3.'+regionName+'.amazonaws.com/';
            
            //createRemoteSite(remoteSiteSettingName,fileUrl,'This remote site setting is use to fetch Buckets');
            
            HttpRequest req = new HttpRequest();
            req.setMethod(methodName);
            req.setEndpoint(fileurl);
            
            req.setHeader('host', 's3.'+regionName+'.amazonaws.com');
            req.setHeader('content-type', 'application/xml');
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('date', longDate);
            req.setHeader('x-amz-date', formattedDateString);
            req.setHeader('x-amz-content-sha256','UNSIGNED-PAYLOAD');
            req.setHeader('Authorization',CreateAuthHeader('Buckets',formattedDateString,longDate,dateStamp));
            
            Http http = new Http();
            
            HTTPResponse response = http.send(req);
            
            
            if (response.getStatusCode() == 200 || response.getStatusCode()==201) 
            {
                system.debug(response.getHeader('Content-Type'));
                system.debug(response.getBody());
                
                Dom.Document doc = new Dom.Document();
                doc.load(response.getbody());
                Dom.XmlNode rootNode = doc.getRootElement();
                
                for(Dom.XmlNode childElement:rootNode.getChildElements())
                {
                    for(Dom.XmlNode detailElement:childElement.getChildElements())
                    {
                        for(Dom.XmlNode detailElement1:detailElement.getChildElements()){
                            if(detailElement1.getName()=='Name'){
                                Buckets.add(detailElement1.getText());
                            }
                        }
                    }
                }
                system.debug('Buckets'+Buckets);
            }
            if(response.getStatusCode() == 403){
                system.debug('error code');
                system.debug(response.getStatusCode());
                Dom.Document doc = new Dom.Document();
                doc.load(response.getbody());
                Dom.XmlNode rootNode = doc.getRootElement();
                for(Dom.XmlNode childElement:rootNode.getChildElements()){
                    system.debug(childElement);
                    if(childElement.getName()=='Code'){
                        system.debug('inside id');
                        system.debug(childElement.getText());
                        exceptionMessage =childElement.getText();
                        throw new AuraHandledException(childElement.getText());
                    }
                    
                    system.debug(childElement.getText());
                }
                system.debug(response.getbody());
            }
            /*else{
                system.debug('inside else');
                system.debug(response);
                system.debug(response.getBody());
            }*/
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
            
            //throw new BaseException(ex);
           /* system.debug(ex.getMessage()+' at '+ex.getLineNumber());
            if ( String.isNotBlank( ex.getMessage() ) && ex.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(ex.getMessage().split('error:')[1].split(':')[0] + '.');
            }
            else {
                throw new AuraHandledException(ex.getMessage());
            }*/ 
            //exceptionMessage ='Exception';
            throw new AuraHandledException(exceptionMessage);
        }
        
        system.debug('Buckets>>>>>>>>');
        system.debug(Buckets);
        
       // deleteRemoteSite(remoteSiteSettingName);
       // 
       system.debug('b ucketer.   '+ buckets);
        return Buckets;
    }
    
    
    @auraEnabled
    public static List<String> getFiles(string accessKey, String secretKey,String awsRegion, String bucket)
    {
        awsKey = accessKey;
        awsSecret = secretKey;
        regionName = awsRegion;
        bucketName = bucket;
        methodName = 'GET';
        
        String remoteSiteSettingName = 'Aws Files';
        
        try
        {
            
            String longDate = Datetime.now().formatGMT('E, dd MMM yyyy HH:mm:ss z');                
            String formattedDateString = Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');              
            String dateStamp = Datetime.now().formatGMT('yyyyMMdd');
            
            string fileUrl='https://' + bucketName + '.' +hostName;
            
            //createRemoteSite(remoteSiteSettingName,fileUrl,'This remote site setting is use to fetch all files within the bucket');
            HttpRequest req = new HttpRequest();
            req.setMethod(methodName);
            req.setEndpoint(fileurl);
            
            req.setHeader('host',bucketName+'.s3'+'.'+regionName+'.amazonaws.com');
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('date', longDate);
            req.setHeader('x-amz-date', formattedDateString);
            req.setHeader('x-amz-content-sha256','UNSIGNED-PAYLOAD');
            req.setHeader('Authorization',CreateAuthHeader( 'Files', formattedDateString,longDate,dateStamp));
            system.debug(req);
            Http http = new Http();
            
            HTTPResponse response = http.send(req);
            system.debug('res'+response);
            system.debug(response.getBody());
            
            if (response.getStatusCode() == 200 || response.getStatusCode()==201) 
            {
                
                Dom.Document doc = new Dom.Document();
                doc.load(response.getbody());
                
                Dom.XmlNode rootNode = doc.getRootElement();
                for(Dom.XmlNode childElement:rootNode.getChildElements())
                {
                    for(Dom.XmlNode detailElement:childElement.getChildElements())
                    {
                        
                        if(detailElement.getName()=='Key'){
                            Files.add(detailElement.getText());
                        }
                        
                    }
                }
                system.debug('Files>>>>>>>>>>>>>>>'+Files);
            }
        }
        catch(Exception ex)
        {
            //throw new BaseException(ex);
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
        
        system.debug(files.size());
        //deleteRemoteSite(remoteSiteSettingName);
        return Files;
    }
    
    
    @auraEnabled
    public static String getFile(string accessKey, String secretKey,String awsRegion, String bucket,String FileKey){
        awsKey = accessKey;
        awsSecret = secretKey;
        regionName = awsRegion;
        bucketName = bucket;
        methodName = 'GET';
        String remoteSiteSettingName = 'Aws File';
        String FileData;
        
        try
        {
            
            String longDate = Datetime.now().formatGMT('E, dd MMM yyyy HH:mm:ss z');                
            String formattedDateString = Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');              
            String dateStamp = Datetime.now().formatGMT('yyyyMMdd');
            
            string fileUrl='https://' + bucketName + '.' + hostName + '/' +FileKey;
            
            //createRemoteSite(remoteSiteSettingName,fileUrl,'This remote site setting is use to fetch the data of the file selected by user');
            
            HttpRequest req = new HttpRequest();
            req.setMethod(methodName);
            req.setEndpoint(fileurl);
            
            //Headers for the request
            req.setHeader('host',bucketName+'.s3'+'.'+regionName+'.amazonaws.com');
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('date', longDate);
            req.setHeader('content-type', 'application/x-zip-compressed');
            req.setHeader('x-amz-date', formattedDateString);
            req.setHeader('x-amz-content-sha256','UNSIGNED-PAYLOAD');
            req.setHeader('Authorization',CreateAuthHeaderForFileKey( FileKey, formattedDateString,longDate,dateStamp));
            
            Http http = new Http();
            
            HTTPResponse res = http.send(req);
            system.debug(res.getHeaderKeys());
            system.debug(res.getHeader('x-amz-server-side-encryption'));
            system.debug(res.getHeader('Last-Modified'));
                
            system.debug('res'+res);
            system.debug(res.getBodyAsBlob());
            //system.debug(res.getBodyDocument());
            
            if (res.getStatusCode() == 200 || res.getStatusCode()==201) 
            {
               blob blobData = res.getBodyAsBlob();
               FileData = EncodingUtil.base64Encode(blobData);
               // FileData = res.getBody();
                system.debug('response'+res.getBody());
            }
        }
        catch(Exception ex)
        {
            //throw new BaseException(ex);
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
        //deleteRemoteSite(remoteSiteSettingName);
        
        
        system.debug('filedata'+FileData);
       																				
        return FileData;
    }    
    
    public static String filePUT(String fileName, string accessKey, String secretKey,String awsRegion, String bucket,blob zipData) {
        
        system.debug(accessKey);
        system.debug(secretKey);
        system.debug(awsRegion);
        system.debug(zipData);
        system.debug(bucket);
        
        String remoteSiteSettingName = 'upload File';
        awsKey = accessKey;
        awsSecret = secretKey;
        regionName = awsRegion;
        bucketName = bucket;
        methodName = 'PUT';
        system.debug('region');
        system.debug(regionName);
        //blob blobData=EncodingUtil.base64Decode(ZipData);
        //system.debug(blobData);
        String messageToReturn;
        /* List<ContentDocumentLink> links=[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId=:recordId];
Set<Id> ids=new Set<Id>();
for(ContentDocumentLink link:links)
{
ids.add(link.ContentDocumentId);
}
List<ContentVersion> versions=[SELECT VersionData,Title,ContentDocumentId,FileExtension FROM ContentVersion WHERE ContentDocumentId = :ids AND IsLatest = true];

for(ContentVersion attach:versions)
{*/
        
        try
        {
            // system.debug('content version'+attach);
            //File Content
            // String attachmentBody = EncodingUtil.base64Encode(attach.VersionData);
            //String attachmentBody = EncodingUtil.base64Encode(blobData);
            String attachmentBody = EncodingUtil.base64Encode(zipData);
            String longDate = Datetime.now().formatGMT('E, dd MMM yyyy HH:mm:ss z');  
            String formattedDateString = Datetime.now().formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
            String dateStamp = Datetime.now().formatGMT('yyyyMMdd');
            
            //String filename = attach.Title;
            //String filename = fileName;
            // string contentType=ContentType(attach.FileExtension);
            // system.debug('contentType:'+contentType);
            
            //string fileUrl='https://' + bucketName + '.' + hostName + '/' + filename.toLowerCase()+ '.'+attach.FileExtension.toLowerCase();
            //String fileName = 'salesforce(09/20/22)';
			//String encodedFileName = EncodingUtil.urlEncode(fileName, 'UTF-8');
            string fileUrl='https://' + bucketName + '.' + hostName + '/' + filename.toLowerCase()+ '.'+'zip';
            //string fileUrl='https://' + bucketName + '.' + hostName + '/' + encodedFileName+ '.'+'zip';
            system.debug('fileurl'+fileurl);
            
            //createRemoteSite(remoteSiteSettingName,fileUrl,'This remote site setting is use to upload data to aws Bucket');
            
            HttpRequest req = new HttpRequest();
            req.setMethod(methodName);
            req.setEndpoint(fileurl);
            
            
            req.setHeader('host', bucketName+'.s3'+'.'+regionName+'.amazonaws.com');
            req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));                
            req.setHeader('Content-Encoding', 'UTF-8');
            //  req.setHeader('Content-type', contentType);
            req.setHeader('Content-type', 'application/zip');
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('date', longDate);
            req.setHeader('x-amz-date', formattedDateString);
            
            Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);
            req.setBodyAsBlob(pdfBlob); 
            
            String contentHash = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', pdfBlob));
            req.setHeader('x-amz-content-sha256',contentHash);
            req.setHeader('Authorization',CreateAuthHeaderForPUT('application/zip', filename, formattedDateString,longDate,'zip',pdfBlob,dateStamp));
            
            system.debug('request'+req);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            system.debug('res'+res);
            system.debug('response body'+res.getBody());
            system.debug('response code'+res.getStatusCode());
            if (res.getStatusCode() == 200 || res.getStatusCode()==201) 
            {
                messageToReturn = 'success';
                system.debug('response'+res.getBody());
            }
            else{
                messageToReturn = 'Error With Code '+res.getStatusCode();
            }
        }
        catch(Exception ex)
        {
            //throw new BaseException(ex);
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
            messageToReturn = 'Exception in Code : '+ex.getMessage()+' at '+ex.getLineNumber();
        }
        
        //deleteRemoteSite(remoteSiteSettingName);
        
        system.debug('messageToReturn' + messageToReturn);
        return messageToReturn;
    }
 	
    @testVisible
    Private static void createRemoteSite(String fullName, String url,String description) {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = getSessionId();
    
        
        //Metadata for remote site settings
        MetadataService.RemoteSiteSetting remoteSiteSettings = new MetadataService.RemoteSiteSetting();
        remoteSiteSettings.fullName = fullName;
        remoteSiteSettings.url = url;
        remoteSiteSettings.description = description;
        remoteSiteSettings.isActive = true;
        remoteSiteSettings.disableProtocolSecurity = false;
        MetadataService.SaveResult[] results = service.createMetadata(
          new List<MetadataService.Metadata>{ remoteSiteSettings }
        );
    
        for (MetadataService.SaveResult result : results){
          if (result.success) {
            System.debug(result);
          } else {
            System.debug(result.errors[0].message);
          }
        }
  }
    
    
    public static void deleteRemoteSite(String fullName)
    {
        // Metadata Service
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = getSessionId();
    
        // Construct a RemoteSiteSetting object with the fullName you want to delete
        MetadataService.RemoteSiteSetting remoteSiteSettings = new MetadataService.RemoteSiteSetting();
        remoteSiteSettings.fullName = fullName;
    
        // Create a DeleteMetadata object and add the RemoteSiteSetting for deletion
        /*MetadataService.DeleteMetadata deleteMetadata = new MetadataService.DeleteMetadata();
        deleteMetadata.metadata = new List<MetadataService.Metadata> { remoteSiteSettings };*/
    
        // Call the deleteMetadata() method
        MetadataService.DeleteResult[] deleteResults = service.deleteMetadata('RemoteSiteSetting', new List<String> { fullName });
    
        for (MetadataService.DeleteResult result : deleteResults) {
            if (result.success) {
                // Success
                System.debug('Remote Site Setting ' + fullName + ' deleted successfully.');
            } else {
                // Failed
                System.debug('Failed to delete Remote Site Setting ' + fullName + ': ' + result.errors[0].message);
            }
        }
	}
    @testVisible
     private static String getSessionId(){
         String vfContent =Page.getSessionId.getContent().toString(); 
         Integer startPosition = vfContent.indexOf('Start') + 'Start'.length();
         Integer endPosition = vfContent.indexOf('End');
         String SessionId = vfContent.substring(startPosition, endPosition);
         system.debug('session id'+ sessionID);
         return SessionId;
    }

}