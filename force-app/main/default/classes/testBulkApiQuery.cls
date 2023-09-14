@isTest
private class testBulkApiQuery{
@isTest
public static void testScheduleDataBackup() {
    List<String> objectApiNames = new List<String>{'Account', 'Contact'};

        
         String credentials = 'AWS_Credentials';
    	String fromDate = '2023-09-11';
    	String toDate = '2023-09-11';
        String ScheduleDate = '2023-09-11';
    

    Test.startTest();
    bulkApiQuery.ScheduleDataBackup(objectApiNames, credentials, fromDate, toDate, ScheduleDate); 
    Test.stopTest();

    Integer scheduledJobsCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = 'Schedule Data Backup'];
    System.assertEquals(1, scheduledJobsCount, 'Scheduled job count should be 1');
}

    @isTest
    static void testCreateDataBackup() {
        List<String> objectApiNames = new List<String>{'Account', 'Contact'};
        String credentials = 'AWS_Credentials';
        String fromDate = '2023-09-07';
        String toDate = '2023-09-07';

        try {
            Test.startTest();
            bulkApiQuery.createDataBackup(objectApiNames, credentials, fromDate, toDate);
            Test.stopTest();
        }
        catch (AuraHandledException ex) {
            System.assertEquals('Invalid input: ObjectApiNames cannot be empty', ex.getMessage());
        }

        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger];
        System.assertNotEquals(0, cronTriggers.size());
    }
   
    /* @isTest
	public static void testCreateDataforMoreThan100Objects() {
    	List<String> objectApiNames = new List<String>();
    	for (Integer i = 0; i < 110; i++) {
        	objectApiNames.add('account' + i);
    	}

    	String credentials = 'AWS_Credentials';
    	String fromDate = '2023-09-11';
    	String toDate = '2023-09-11';

    	Test.startTest();
    	bulkApiQuery.createDataBackup(objectApiNames, credentials, fromDate, toDate);
    	Test.stopTest();

    List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger];
    System.assertNotEquals(0, cronTriggers.size(), 'A job should be created for more than 100 objects');
	}*/
    
    
    @isTest
    public static void testCreatedatabackupfor100objects(){
        list<string> objectsNames = new List<string>();
        FOR(schema.SObjectType obj:Schema.getGlobalDescribe().values())
        {
            Schema.DescribeSObjectResult objResult = obj.getDescribe();
            system.debug( 'Sobject: ' + objResult );
            system.debug( 'Sobject API Name: ' + objResult.getName() );
            system.debug( 'Sobject Label Name: ' + objResult.getLabel() );
            if (objResult.isCreateable() && objResult.isupdateable() && objResult.isqueryable()) {
                objectsNames.add(objResult.getName());
            }
        }
        String credentials = 'AWS_Credentials';
    	String fromDate = '2023-09-11';
    	String toDate = '2023-09-11';

    	Test.startTest();
    	bulkApiQuery.createDataBackup(objectsNames, credentials, fromDate, toDate);
    	Test.stopTest();

    List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger];
    System.assertNotEquals(0, cronTriggers.size(), 'A job should be created for more than 100 objects');
        
    }
}