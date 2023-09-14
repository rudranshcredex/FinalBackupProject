public class DataRecoveryCallout {

    Private static Final String endpointURL = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v58.0/jobs/ingest';
    
    @future(callout=true)
    public static void createInsertJob(Map<String,Blob> objectWithData) {
        List<BulkApiQueryExample.ObjectsJobIdCSVWrapper> ObjectsJobIdCSVWrapperList = new List<BulkApiQueryExample.ObjectsJobIdCSVWrapper>();
        List<String> objectApiNames = new List<String>(objectWithData.keyset());
        
        for(String objectApiName:objectApiNames)
        {
            String endpoint = endpointURL;
            String requestBody = JSON.serialize(getJobRequestForInsert(objectApiName));
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            request.setHeader('Content-Type', 'application/json');
            request.setBody(requestBody);
            HttpResponse response = new Http().send(request);
            
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201)
            {
                Map<String, Object> jobResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                BulkApiQueryExample.ObjectsJobIdCSVWrapper objWrapper = new BulkApiQueryExample.ObjectsJobIdCSVWrapper();
                objWrapper.objectName = objectApiName;
                objWrapper.jobId = (String)jobResponse.get('id');
                objWrapper.csvData = objectWithData.get(objectApiName);
                objWrapper.DmlType ='insert';
                ObjectsJobIdCSVWrapperList.add(objWrapper);
            }
            else{
                system.debug('Fault response');
                system.debug(response);
                system.debug(response.getBody());
            }
        }
        system.debug(ObjectsJobIdCSVWrapperList);
        system.debug(ObjectsJobIdCSVWrapperList.size());
        if(ObjectsJobIdCSVWrapperList.size()>0){
            system.enqueueJob(new QueueableRecovery(ObjectsJobIdCSVWrapperList,'UploadData'));
        }        
    }
    
    
    public static void createUpsertJob(List<BulkApiQueryExample.ObjectsExternalIdCSVWrapper> objectsWithExternalIdAndCsv) {
        List<BulkApiQueryExample.ObjectsJobIdCSVWrapper> ObjectsJobIdCSVWrapperList = new List<BulkApiQueryExample.ObjectsJobIdCSVWrapper>();
       
        for(BulkApiQueryExample.ObjectsExternalIdCSVWrapper objects:objectsWithExternalIdAndCsv)
        {
            String endpoint = endpointURL;
            String requestBody = JSON.serialize(getJobRequestForUpsert(objects.objectName,objects.ExternalId));
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            request.setHeader('Content-Type', 'application/json');
            request.setBody(requestBody);
            HttpResponse response = new Http().send(request);
            
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201)
            {
                Map<String, Object> jobResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
               
                BulkApiQueryExample.ObjectsJobIdCSVWrapper objWrapper = new BulkApiQueryExample.ObjectsJobIdCSVWrapper();
                objWrapper.objectName = objects.objectName;
                objWrapper.jobId = (String)jobResponse.get('id');
                objWrapper.csvData = objects.csvData;
                objWrapper.DmlType = 'upsert';
                ObjectsJobIdCSVWrapperList.add(objWrapper);
                    
            }
            else{
                system.debug('Fault response');
                system.debug(response);
                system.debug(response.getBody());
            }
        }
        system.debug(ObjectsJobIdCSVWrapperList);
        system.debug(ObjectsJobIdCSVWrapperList.size());
        if(ObjectsJobIdCSVWrapperList.size()>0){
            system.enqueueJob(new QueueableRecovery(ObjectsJobIdCSVWrapperList,'UploadData'));
        }        
    }
    
    
    public static void UploadJobData(List<BulkApiQueryExample.ObjectsJobIdCSVWrapper> objectsWithJobIdsAndcsv) {
        
        List<BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper> objectsWithJobIdsList = new List<BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper>();
        set<Id> LinkedIds= new set<Id>();
       /* for(ContentDocumentLink link: [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink where LinkedEntityId=:userinfo.getUserId()]){
                LinkedIds.add(link.ContentDocumentId);
        }
        
        ContentVersion versions=[SELECT VersionData,Title,ContentDocumentId,FileExtension FROM ContentVersion WHERE ContentDocumentId = :LinkedIds and Title='ContactCopy' limit 1];*/
       
        for(BulkApiQueryExample.ObjectsJobIdCSVWrapper objWrapper : objectsWithJobIdsAndcsv)
        {
                String endpoint = endpointURL+'/' + objWrapper.jobId + '/batches';
        
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('PUT');
                request.setHeader('Authorization', 'Bearer ' + userinfo.getSessionId());
                request.setHeader('Content-Type', 'text/csv');
                request.setBodyAsBlob(objWrapper.csvData);
                HttpResponse response = new Http().send(request);
            
                if(response.getStatusCode() == 200 || response.getStatusCode() == 201)
                {                   
                    BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper JobIdWrapper = new BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper();
                    JobIdWrapper.jobId = objWrapper.jobId;
                    JobIdWrapper.objectName = objWrapper.objectName;
                    JobIdWrapper.DmlType =  objWrapper.DmlType;
                    objectsWithJobIdsList.add(JobIdWrapper);
                }
            else{
                system.debug('error');
                system.debug('unExpected');
            }
        }
        system.debug(objectsWithJobIdsList);
        if(objectsWithJobIdsList.size()>0){
            closeOrAbortJob(JSON.serialize(objectsWithJobIdsList));
        }
    }
    
    
     @future(Callout=true)
    public static void closeOrAbortJob(String objectsWithJobIds) {
        
        List<BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper> objectsWithJobIdsWithDml = (List<BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper>) JSON.deserialize(objectsWithJobIds, List<BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper>.class);
        system.debug('inside close abort');
        List<BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper> objectsWithDmlTypes = new List<BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper>();
 
        for(BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper objects:objectsWithJobIdsWithDml)
        {
                    
            String endpoint = endpointURL+'/' + objects.jobId;
            system.debug(endpoint);
            string body = '{"state":"UploadComplete"}';
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('PATCH');
            request.setHeader('Content-Type', 'application/json; charset=UTF-8');
            request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            request.setBody(body);
            HttpResponse response = new Http().send(request);
            if(response.getStatusCode()==201 || response.getStatusCode()==200){
                BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper JobIdWrapper = new BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper();
                    JobIdWrapper.jobId = objects.jobId;
                    JobIdWrapper.objectName = objects.objectName;
                    JobIdWrapper.DmlType =  objects.DmlType;
                	objectsWithDmlTypes.add(JobIdWrapper);
            }
            else{
                system.debug(response);
                system.debug('error');
                system.debug(response.getBody());
            }
        }
        system.debug('objectsWithDmlTypes');
        system.debug(objectsWithDmlTypes);
        if(objectsWithDmlTypes.size()>0){
            system.enqueueJob(new QueueableRecovery(JSON.serialize(objectsWithDmlTypes),'checkBatchStatus'));
        }
    }
  
    @future(Callout=true)
    public static void checkBatchStatus(String objectsWithJobIds) {
    
      try
      {     
        List<BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper> objectsWithJobIdsWithDml = (List<BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper>) JSON.deserialize(objectsWithJobIds, List<BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper>.class);
        system.debug(objectsWithJobIdsWithDml);
        for(BulkApiQueryExample.objectsWithJobIdsDmlTypesWrapper objects:objectsWithJobIdsWithDml)
        {
            String endpoint = endpointURL+'/' +  objects.jobId;
        
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json; charset=UTF-8');
            request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            
            HttpResponse response = new Http().send(request);
            
            if(response.getStatusCode()==201 || response.getStatusCode()==200)
            {  
                Map<String,object> responseResult = (Map<String,object>)JSON.deserializeUntyped(response.getBody());
	
				system.debug(responseResult.get('numberRecordsProcessed'));                
                system.debug(responseResult.get('numberRecordsFailed'));
                //storing result in custom setting
                dataRecoveryResponse__c responseData = new dataRecoveryResponse__c();
				responseData.numberRecordsProcessed__c = String.valueOf((Integer)responseResult.get('numberRecordsProcessed'));
                responseData.numberRecordsFailed__c = String.valueOf((Integer)responseResult.get('numberRecordsFailed'));
                responseData.objectName__c = objects.objectName;
                responseData.DmlType__c = objects.DmlType;
                insert responseData;
                system.debug('responseData');
                system.debug(responseData);
            }
            else{
                system.debug('error');
                system.debug(response);
                system.debug(response.getBody());
            }
        }
      }
      catch(Exception ex)
      {
            system.debug(ex.getmessage()+' at '+ex.getLineNumber());
       }
    }
    
    
    Private static Map<String, Object> getJobRequestForInsert(String objectApiName)
    {
        Map<String, Object> jobRequest = new Map<String, Object>{
            'operation' => 'insert',
            'object' => objectApiName,
            'contentType' => 'CSV',
            'lineEnding'=> 'LF'
        };
        return jobRequest;
    }
    
    Private static Map<String, Object> getJobRequestForUpsert(String objectApiName,String ExternalIdField)
    {
        Map<String, Object> jobRequest = new Map<String, Object>{
            'operation' => 'upsert',
            'object' => objectApiName,
            'externalIdFieldName' => ExternalIdField,
            'contentType' => 'CSV',
            'lineEnding'=> 'LF'
        };
        return jobRequest;
    }
}