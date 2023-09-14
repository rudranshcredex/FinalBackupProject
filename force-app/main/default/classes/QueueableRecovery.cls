public class QueueableRecovery implements Queueable,Database.AllowsCallouts {

    private  List<BulkApiQueryExample.ObjectsJobIdCSVWrapper> ObjectsJobIdCSV;
    Private Map<String,String> ObjectsJobId;
    Private String Contexts;
    Private string queryDataWithIds;
    Private List<BulkApiQueryExample.ObjectsExternalIdCSVWrapper> ObjectsExternalIdCSV;
    
    Public QueueableRecovery(List<BulkApiQueryExample.ObjectsExternalIdCSVWrapper> ObjectsJobIdCSVWrapper,String context){
        ObjectsExternalIdCSV = ObjectsJobIdCSVWrapper;
        contexts = context;
        system.debug(contexts);
    }
    
    Public QueueableRecovery(List<BulkApiQueryExample.ObjectsJobIdCSVWrapper> ObjectsJobIdCSVWrapper,String context){
        ObjectsJobIdCSV = ObjectsJobIdCSVWrapper;
        contexts = context;
        system.debug(contexts);
    }
    
    
    Public QueueableRecovery(String ObjectsWithJobId,String context){
        queryDataWithIds = ObjectsWithJobId;
        contexts = context;
    }
    Public QueueableRecovery(Map<String,String> ObjectsWithJobId,String context){
        system.debug(ObjectsWithJobId);
        system.debug('Map');
        ObjectsJobId = ObjectsWithJobId;
        contexts = context;
        system.debug(contexts);
    }
    
    Public  void execute(QueueableContext Qc)
    {
        
        //system.debug('inside execute');
        if(Contexts=='createUpsertJob'){
            DataRecoveryCallout.createUpsertJob(ObjectsExternalIdCSV);
        }
        if(Contexts=='UploadData'){
            DataRecoveryCallout.UploadJobData(ObjectsJobIdCSV);
        }
        if(Contexts=='checkBatchStatus'){
           // system.debug('inside checkBatchStatus');
			DataRecoveryCallout.checkBatchStatus(queryDataWithIds);        
        }
     }
}