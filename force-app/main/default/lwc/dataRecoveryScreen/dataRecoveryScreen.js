/* eslint-disable @lwc/lwc/no-unknown-wire-adapters */
/* eslint-disable no-undef */
import { LightningElement, wire } from "lwc";
import local from "@salesforce/resourceUrl/LocalBackup";
import cloud from "@salesforce/resourceUrl/cloud";
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import NAME_FIELD from "@salesforce/schema/User.Name";
import EMAIL_FIELD from "@salesforce/schema/User.Email";
import uploadZipFile from '@salesforce/apex/BulkApiQueryExample.uploadZipFile';
import testMethods from '@salesforce/apex/BulkApiQueryExample.testMethods';
import performInsert from '@salesforce/apex/BulkApiQueryExample.performInsert';
export default class DataRecoveryScreen extends LightningElement {


  recoveryAwsText = "Your data recovery from AWS is now in the queue and will be processed shortly. We're working diligently to ensure that your requested data is recovered accurately and securely.";
  lowertext = "You will receive an email notification once the recovery is completed, along with a custom notification .";
  recoveryLocaltext = "Your data recovery is now in the queue and will be processed shortly. We're working diligently to ensure that your requested data is recovered accurately and securely.";
  userEmail;


    columns = [
        { label: 'Names', fieldName: 'objectName', type: 'text' },
        {
            label: 'External Ids',
            type: 'dropdown',
            typeAttributes: {
                options: [
                    { label: 'External ID 1', value: 'externalId1' },
                    { label: 'External ID 2', value: 'externalId2' },
                    { label: 'External ID 3', value: 'externalId3' }
                ]
            }
        }
    ];

    columns1 = [{ label: 'Names', fieldName: 'objectName', type: "text" }];

    data = [
        { objectName: 'Account',csvData: 'CSV Data 1' },
        { objectName: 'Opportunity',csvData: 'CSV Data 2' },
    ];

    selectedRecords = [];
    objectsWithExternalId = [];
  objectsWithoutExternalId = [];


  RecoveryLocalScreen = false;
  RecoveryAwsScreen = false;
  


   /* objectsWithoutExternalId = [
        {
            objectName: 'Opportunity',
            CsvData: 'Sample CSV Data for Opportunity without External ID'
        },
        {
            objectName: 'Lead',
            CsvData: 'Sample CSV Data for Lead without External ID'
        }
        
    ];*/


  local = local;
  cloud = cloud;
  date = Date();
  file;
  objectScreen =false;
  showScreen1 =true;
  showScreen2 =false;
  isModal = false;
  awsModal = false;
  isRecovery = true;
  retrievalLoading = false;
  textVariable =
    "Your export has been queued. You will receive an email and custom notification when it is completed.";
  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD,EMAIL_FIELD]
  })
  wireUser({ error, data }) {
    if (data) {
      this.username = data.fields.Name.value;
      this.userEmail = data.fields.Email.value;
    } else if (error) {
      // Handle error
      console.error(error);
    }
  }

  handleUpload(event){
    console.log(event);
    console.log(event.detail.files[0]);
    this.file = event.detail.files[0];
    console.log(this.file);
  }

  handleRecovery(){
    console.log('handle recovery');
    this.retrievalLoading = true;
  

    /*testMethods({FileData:'this.file'})
    .then(data=>{
        console.log(data);
    })
    .catch(error=>{
        console.log(error);
    })*/
    
    /*const fileReader = new FileReader();
      fileReader.onload = () => {
        const file = fileReader.result.split(',')[1];
        testMethods({FileData:file})
        .then(data=>{
          console.log('data');
          console.log(data);
        })
        .catch(error=>{
          console.log('error');
          console.log(error);
        })
        };
        fileReader.readAsDataURL(this.file);*/

    uploadZipFile({FileData:'test'})
      .then(data => {
        this.retrievalLoading = false;
        this.objectScreen =true;
        this.showScreen1 = false;
        console.log('data');
        console.log(data);
        console.log(JSON.stringify(data));
        for (var key in data) {

          let objwithoutExternalId = {};
          let objwithExternalId = {};

          console.log(data[key].objectName);
          if (data[key].ExternalIdField.length > 0) {
            console.log('yes');
            var externalId = data[key].ExternalIdField;

            if (externalId[0] == '') {
              objwithoutExternalId.objectName = data[key].objectName;
              objwithoutExternalId.CsvData = data[key].csvData;

              console.log('blank');
            }
            else {
              console.log('not blank');
              objwithExternalId.objectName = data[key].objectName;
              objwithExternalId.CsvData = data[key].csvData;
              objwithExternalId.ExternalIds = data[key].ExternalIdField;
            }
          }

          this.objectsWithoutExternalId.push(objwithoutExternalId);
          this.objectsWithExternalId.push(objwithExternalId);
          console.log(JSON.stringify(this.objectsWithExternalId));
          console.log('without ids');
          console.log(JSON.stringify(this.objectsWithoutExternalId));
          console.log(data[key].ExternalIdField);
          console.log(key);
        }
      })
      .catch(error => {
        console.log('inside error');
        console.log('error', error);
      })
   /* if (buttonId1.id === 'btn-1') {
      this.RecoveryLocalScreen = true;
    }
    else
      this.RecoveryAwsScreen = true;*/
    

  }

  handleExternalIdChange(event) {
    const selectedValue = event.detail.value;
    const selectedObject = this.objwithExternalId.find(item => item.dropdownValue === selectedValue);
    
    if (selectedObject) {
        const selectedRecord = {
            objectName: selectedObject.objectName,
            externalId: selectedValue,
            csvData: selectedObject.CsvData
        };
        
        this.selectedRecords.push(selectedRecord); // Add to the selected records array
        
        console.log('Selected Records:', this.selectedRecords);
    }
}
handleInsert(){
    this.showScreen2 = true;
  this.objectScreen = false;
 
  /*if (buttonId === 'btn-1') {
      this.RecoveryLocalScreen = true;
    }
  else if (buttonId === 'btn-2') {
    this.RecoveryAwsScreen = true;
    }*/
    
  console.log('inside insert');
    performInsert({objectsToInsert:JSON.stringify(this.objectsWithoutExternalId)})
    .then(data=>{
        console.log('data');
        console.log(data);
    })
    .catch(error=>{
        console.log(error);
    })
  
   this.RecoveryLocalScreen = true;
}
awsScreen(){
    this.isModal =true;
  this.awsModal = true;
  this.template.querySelector('c-lightning-Modal').handleIsOpenModal();
  }

  handleAWSCredentials(event) {
    console.log('handle aws creds');
    console.log(event);
    console.log(event.detail.value);
    console.log(JSON.stringify(event.detail));
  }

}