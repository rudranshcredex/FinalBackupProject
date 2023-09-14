/*
		@description => This class is use to perform Data Backup using Bulk api
*/
public with sharing class bulkApiQuery {

	//Constants
    Private static String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
    Private static String endpointURL = baseURL+'/services/data/v58.0/jobs/query';
    
    
    /*
		@description => This method is used to schedule backup Process at given date
	*/
  	@auraEnabled(cacheable=true)
    Public static void ScheduleDataBackup(List<String> ObjectApiNames, String credentials, String fromDate, String toDate,String scheduleDate){
        system.debug('schedule backup');
        system.debug(ObjectApiNames);
        system.debug(credentials);
        system.debug(fromDate);
        system.debug(toDate);
        system.debug(scheduleDate);
		Datetime dateTimeValue = Datetime.newInstanceGmt(Integer.valueOf(scheduleDate.substring(0, 4)), Integer.valueOf(scheduleDate.substring(5, 7)), Integer.valueOf(scheduleDate.substring(8, 10)),
                                                 Integer.valueOf(scheduleDate.substring(11, 13)), Integer.valueOf(scheduleDate.substring(14, 16)), Integer.valueOf(scheduleDate.substring(17, 19)));
		System.debug(dateTimeValue);
        
       // Datetime dateTimeValue = Datetime.parse(scheduleDate);
       
        integer scheduleDay = dateTimeValue.day();
        integer scheduleMonth = dateTimeValue.month();
        integer scheduleYear = dateTimeValue.year();
        integer scheduleHour = dateTimeValue.hour();
        integer scheduleMinute = dateTimeValue.minute();
              
        String CRON_EXPRESSION = '0 '+scheduleMinute+' '+scheduleHour+' '+scheduleDay+' '+scheduleMonth+' ? '+scheduleYear;   
        system.debug('cron exp'+CRON_EXPRESSION);
        System.schedule('Schedule Data Backup'+system.now().addminutes(2), CRON_EXPRESSION, new ScheduleBulkApi(ObjectApiNames, credentials, fromDate,  toDate,'ScheduleDataBackup'));
    }
    
    
    /*
		@description => This method will take object names and creds(if Service is AWS) and backup the data at service selected by user 
	*/
    
    @auraEnabled(cacheable=true)
    Public static void createDataBackup(List<String> ObjectApiNames,String credentials,String fromDate, String toDate){
   
        try{     
            List<String> batches = new List<String>();
            if(ObjectApiNames.size()>100)
            {    
                double batchresult = (double)(ObjectApiNames.size())/100;
                double decimalPart = batchresult - (integer)batchresult;
                integer batchSize = (integer)batchresult;
                
                if(decimalpart>0){
                    batchSize++;
                }
                for(integer i=0;i<=ObjectApiNames.size();i+=100){
                    List<String> objectBatch = new List<String>();
                    for(integer j=i;j<100+i && j<ObjectApiNames.size();j++)
                    {
                        objectBatch.add(ObjectApiNames[j]);
                    }
                    batches.add('batch'+batchSize);
                    DataBackupCallout.getQueryJobIds(objectBatch,'batch'+batchSize,fromDate,toDate); 
                    batchSize-=1;
                }
             }
             else
             {
                batches.add('batch 0');
                DataBackupCallout.getQueryJobIds(ObjectApiNames,'batch 0',fromDate,toDate);
             }
            Datetime sysTime;
            if(ObjectApiNames.size()<=20){
               sysTime = System.now().addminutes(1);
            }
            else{
                sysTime = System.now().addminutes( 7 );
            }
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            system.schedule('Salesforce Data Backup'+System.now(), chronExpression, new ScheduleBulkApi(batches,'ReadData',credentials));
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }      
}