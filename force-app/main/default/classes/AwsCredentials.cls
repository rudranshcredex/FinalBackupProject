/*
    @description => This class is use to save and fetch the Aws credentials to custom settings.
    */
public With Sharing class AwsCredentials {
    

     /* 
    	@description => This method is use to save Creds in custom setting
    */
    
    @AuraEnabled
    Public static void saveCredentialsToCustomSetting(String AccessKey, String SecretKey, String RegionName,String credName){
        saveCred(AccessKey,SecretKey,RegionName,credName);
    }
     /*
    	@description => This method is called from LWC Component and call future method to save aws creds
    */
    @future 
 	@TestVisible
    Private static void saveCred(String AccessKey, String SecretKey, String RegionName, String credName){
        try{
            Aws_Credentials__c awsCred=new Aws_Credentials__c();
            awsCred.AccessKey__c = AccessKey;
            awsCred.SecretKey__c = SecretKey;
            
            awsCred.Region_Name__c = RegionName;
            awsCred.Name__c = credName;
            
            insert awsCred;
            system.debug('yes');
        }
        catch(Exception ex){
            system.debug(ex.getMessage()+' at '+ex.getLineNumber());
        }
    }
    /*
    	@description => This method is use to fetch saved creds based from custom setting
    */
    @AuraEnabled(cacheable=true)
    Public static List<Aws_Credentials__c> getCredentails(){
        List<Aws_Credentials__c> AwsCrdes =  [SELECT Id,Name__c,AccessKey__c,SecretKey__c,Region_Name__c FROM Aws_Credentials__c];
        return AwsCrdes;
    }
    
    /*
    	@description => This method is use to fetch saved creds based from custom setting based on name
    */
    @AuraEnabled(cacheable=true)
    Public static Aws_Credentials__c getCredentailsOnName(String name){
        Aws_Credentials__c AwsCrdes =  [SELECT Id,Name__c,AccessKey__c,SecretKey__c,Region_Name__c FROM Aws_Credentials__c Where Name__c=:name limit 1];
        return AwsCrdes;
    }
}