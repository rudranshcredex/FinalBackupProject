public With Sharing class scheduleDataRecovery implements Schedulable{

    Private static String DmlTypes;
    Public scheduleDataRecovery(String DmlType){
        DmlTypes = DmlType;
    }
    Public static void execute(system.SchedulableContext sc){
        
        if(DmlTypes == 'Insert'){
            List<dataRecoveryResponse__c> ObjectsToInsert = [SELECT id,objectName__c,numberRecordsProcessed__c,numberRecordsFailed__c from dataRecoveryResponse__c where DmlType__c='Insert'];
            String csvContent = 'objectName__c,numberRecordsProcessed__c,numberRecordsFailed__c\n';
            for (dataRecoveryResponse__c objects : ObjectsToInsert) 
            {
            	csvContent += objects.objectName__c + ',' + objects.numberRecordsProcessed__c +','+ objects.numberRecordsFailed__c+'\n';
       	     }
            EmailAndNotification.sendEmailToCurrentUser(Blob.valueOf(csvContent), 'LogInsert');
        }
        if(DmlTypes == 'Upsert'){
        	List<dataRecoveryResponse__c> ObjectsToUpsert = [SELECT id,objectName__c,numberRecordsProcessed__c,numberRecordsFailed__c from dataRecoveryResponse__c where DmlType__c='Upsert'];
            String csvContent = 'objectName__c,numberRecordsProcessed__c,numberRecordsFailed__c\n';
            for (dataRecoveryResponse__c objects : ObjectsToUpsert) 
            {
            	csvContent += objects.objectName__c + ',' + objects.numberRecordsProcessed__c +','+ objects.numberRecordsFailed__c+'\n';
       	     }
            EmailAndNotification.sendEmailToCurrentUser(Blob.valueOf(csvContent), 'LogUpsert');
        }
    }
}