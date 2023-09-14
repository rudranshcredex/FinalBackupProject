public class ScheduleBulkApi implements schedulable {
    
    Private Map<String,String> objectWithJobIds;
    Private String batch;
    Private List<String> batchNames;
    Private String contexts;
    Private String Creds;
    Private String fromDate;
    Private String toDate;
    Private List<String> objects;
    Private List<String> metadatas;
    
    // This constructor is use to schedule whole data backup process
    Public ScheduleBulkApi(List<String> ObjectApiNames,String credentials,String fromDate, String toDate,String context){
        objects = ObjectApiNames;
        fromDate = fromDate;
        toDate = toDate;
        creds = credentials;
        contexts = context;
    }
    
    
    public ScheduleBulkApi(Map<String,String> objectsWithId,String batchName,String context){
        system.debug('inside schedule');
        system.debug(batchName);
        system.debug(objectsWithId);
        objectWithJobIds = objectsWithId;
        batch = batchName;
        contexts = Context;
    }
    
    public ScheduleBulkApi(List<String> batches,String Context,String Credentials){
       batchNames = batches;
       contexts = Context;
       Creds = Credentials;
    }

    Public void execute(SchedulableContext sc){
        
        if(contexts == 'ScheduleDataBackup'){
            bulkApiQuery.createDataBackup(objects,creds,fromDate,toDate);
        }
        if(contexts=='ScheduleMetaDataBackup'){
            MetadataRetriever.retreive(metadatas, creds);
        }
        if(contexts=='ReadData'){
            DataBackupCallout.readZipFiles(batchNames,Creds);
        }
        
        if(contexts=='getJobResults'){
            DataBackupCallout.getJobResults(objectWithJobIds,batch);
        }
        
                	
     }
    
}