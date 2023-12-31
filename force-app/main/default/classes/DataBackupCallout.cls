public With Sharing class DataBackupCallout {

    Private static Final String endpointURL = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v58.0/jobs/query';
    
    /*
		@description => This method will create Bulk query job and return Job Id for every object
	*/
    @future(callout=true)
    public static void getQueryJobIds(List<String> ObjectApiNames,String batchName,String fromDate, String ToDate){
      		        
        String query;
        List<HttpResponse> responses= new List<HttpResponse>();
        Map<String,String> jobIdsWithApiNames = new Map<String,String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
     try
      { 
        for(String objectApiname: ObjectApiNames)
        {            
            List<String> queryableFieldNames = new List<String>();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectApiname).getDescribe().fields.getMap();
            
            //fields those are accessible in during recovery of records
            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
                if(fieldDescribe.isCreateable() && fieldDescribe.isUpdateable() && fieldDescribe.isAccessible()) { 
                    queryableFieldNames.add(fieldName);
                }             
            }
            if(fromDate!=null && toDate!=null){
                
                String startDateString = fromDate+'T00:00:00';
                String EndDateString;
                if(Date.valueOf(toDate)==System.today()){
                    DateTime currentDateTime= Datetime.now(); 
                   EndDateString = toDate+currentDateTime.time();
                }
                else{
                   EndDateString = toDate+'T23:59:59';
                }
                DateTime startDate = DateTime.valueOf(startDateString);
				DateTime endDate = DateTime.valueOf(endDateString);
                //String EndDateString = toDate+'T23:59:59';
                Date dateFrom = Date.valueOf(fromDate);
                Date dateTo = Date.valueOf(toDate);
                
                DateTime fromDateValue = Datetime.newInstance(dateFrom, Time.newInstance(0, 0, 0, 0));
                DateTime toDateValue = Datetime.newInstance(dateTo, Time.newInstance(0, 0, 0, 0));
                
                
                system.debug('fromDateValue');
                system.debug(fromDateValue);
                system.debug(toDateValue);
                query = 'SELECT ' + String.join(queryableFieldNames, ',') + ' FROM '+objectApiname+' WHERE createdDate>=\''+startDate+'\''+' AND CreatedDate <=\''+endDate+'\'' ;
                //query = 'SELECT ' + String.join(queryableFieldNames, ',') + ' FROM '+objectApiname+' WHERE createdDate>=\''+fromDateValue+'\''+' AND CreatedDate <=\''+toDateValue+'\'' ;
                //query = 'SELECT ' + String.join(queryableFieldNames, ',') + ' FROM '+objectApiname+' WHERE createdDate>=:fromDateValue AND CreatedDate <=:toDateValue' ;
            }
            else{
                query = 'SELECT ' + String.join(queryableFieldNames, ',') + ' FROM '+objectApiname;
            }
            //system.debug(query);
			String requestBody = JSON.serialize(getJobRequest(query));  
        
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpointURL);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + userinfo.getSessionId());
            request.setHeader('Content-Type', 'application/json');
            request.setBody(requestBody);
            
            HttpResponse response = new Http().send(request);   
            responses.add(response);
            system.debug('give body');
            system.debug(response.getBody());
            
            if(response.getstatusCode()==200 || response.getstatusCode()==201)
            {
                Map<String,Object> responseMap = (Map<String,object>)Json.deserializeUntyped(response.getBody());
                jobIdsWithApiNames.put(objectApiname,(String)responseMap.get('id'));
            }
            else{
                system.debug('objectname>>>>>>>');
                system.debug(response);
                system.debug(objectApiname);
                system.debug('response Body');
                system.debug(response.getBody());
            }     
        }
        
      
        system.debug('jobIdsWithApiNames>>>>>');
          system.debug(jobIdsWithApiNames);
        if(jobIdsWithApiNames.size()>0)
        {
           // Datetime sysTime = System.now().addminutes( 1 ); 
            Datetime sysTime = System.now().addseconds( 10 );
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            system.schedule('Salesforce Data Backup'+System.now().addMinutes(1), chronExpression, new ScheduleBulkApi(jobIdsWithApiNames,batchName,'getJobResults'));
        }
      }
        catch(Exception ex){
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
    }
    
	  /*
		@description => This method fetch the results based on jobIds and store result as a batches in content Version of Salesforce
	  */    
     @future(callout=true)
    Public static void getJobResults(Map<String,String> objectWithJobIds,String batchName){
      try
      {
          system.debug('objectWithJobIds');
          system.debug(objectWithJobIds);
         Zippex sampleZip = new Zippex();
        
         for(string objects:objectWithJobIds.keySet())
         {
            String endpoint = endpointURL+'/'+objectWithJobIds.get(objects)+'/results';
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            request.setHeader('Content-Type', 'application/json');
            HttpResponse response = new Http().send(request);
             
             if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                 system.debug('response in 200');
                 system.debug(response);
                 system.debug('response body');
             	 system.debug(response.getBody());
                  
                 Blob fileData = Blob.valueOf(response.getBody());
            	 sampleZip.addFile(objects+'.csv', fileData, null);
             }
             else{
                 system.debug('error at 128 with code');
                 system.debug(response);
                 //system.debug(response.get);
             }
            
         }
        	
        Blob zipData = sampleZip.getZipArchive();
       
         String currentDateTime = DateTime.now().format('yyyy/MM/dd hh:mm:ss');
         ContentVersion contentVersion = new ContentVersion(
                    Title = batchName,
                    VersionData = zipData,
                    PathOnClient = '/' + batchName+'.zip'
             );
         insert contentVersion;
      }
        catch(Exception ex){
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
    }
    /*
		@description => This method is use to fetch zip files from different content versions and create one Zip file  to send the data to AWS or Email as required, also send custom Notification after confirmation 
	*/
     @future(callout=true)
    Public static void readZipFiles(List<String> fileNames,String Credentials){
        /*system.debug('creds');
        system.debug(Credentials);*/
     try{
        Map<String,Object> creds = (Map<String,Object>)JSON.deserializeUntyped(credentials);
        string accessKey = (String)creds.get('accessKey');
        String SecretKey = (String)creds.get('SecretKey');
        String Bucket = (String)creds.get('Bucket');
        String awsRegion = (String)creds.get('awsRegion');
        boolean backupTos3 = (boolean)creds.get('backupTos3');
        boolean backupToLocal = (boolean)creds.get('backupToLocal');
       
        Zippex zip= new Zippex();
        
        set<Id> LinkedIds = new set<Id>();
        for(ContentDocumentLink link: [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId=:userinfo.getUserId()]){
                LinkedIds.add(link.ContentDocumentId);
        }
        /*system.debug('LinkedIds');
        system.debug(LinkedIds);*/
        List<ContentVersion> versions=[SELECT VersionData,Title,ContentDocumentId,FileExtension FROM ContentVersion WHERE ContentDocumentId = :LinkedIds and Title In:fileNames];
       /* system.debug('content versions');
        system.debug(versions);*/
        List<String> ContentDocumentIdsToDelete = new List<String>();
        for(ContentVersion version: versions)
        {
          	ContentDocumentIdsToDelete.add(version.ContentDocumentId);
            Zippex myzip= new Zippex(version.VersionData);
            for(String fileName: myzip.getFileNames())
            {
              String fileData= myzip.getFile(fileName).toString();
              system.debug('file data'+myzip.getFile(fileName));
              zip.addFile(fileName, myzip.getFile(fileName), null);
            }
        }
        
        Blob zipData = zip.getZipArchive();
        
        /*Attachment attachment = new Attachment();
        attachment.ParentId = '0015i00000oYvsvAAC';
        attachment.Name = 'Salesforce Whole Data';
        attachment.Body = zipData;
        insert attachment;*/
        
       // system.debug(versions.size());
        List<contentDocument> ContentDocumentIds= [select id from contentDocument where id In:ContentDocumentIdsToDelete];
        if(backupTos3){
            system.debug('backup s3');	
            system.debug(awsRegion);
            String response = AwsS3Integration.filePUT('salesforce(09/20/22)', accessKey, secretKey, awsRegion, Bucket, zipData);
            if(response =='success'){
                EmailAndNotification.sendCustomNotification('Data','Aws');
                if(ContentDocumentIds.size()>0){
            		delete contentDocumentIds;
        		}
            }
        }
        if(backupToLocal){
            if(ContentDocumentIds.size()>0)
            {
            	delete contentDocumentIds;
        		}
            String EmailStatus = EmailAndNotification.sendEmailToCurrentUser(zipData, 'Data');
            if(EmailStatus == 'Success'){
                system.debug('email sent');
             	EmailAndNotification.sendCustomNotification('Data','Local');   
            }
        }
     }
     catch(Exception ex){
            system.debug(ex.getMessage()+'at '+ex.getLineNumber());
     }
    }
    
    /*
		@description => This method is use to create job request for Bulk api
	*/
    Private static Map<String, Object> getJobRequest(String query){
        Map<String, Object> jobRequest = new Map<String, Object>{
            'operation' => 'query',
            'query' => query
             };
         return jobRequest;
    }
}