/* eslint-disable @lwc/lwc/no-unknown-wire-adapters */
/* eslint-disable no-undef */
import { LightningElement, wire } from "lwc";
import local from "@salesforce/resourceUrl/LocalBackup";
import cloud from "@salesforce/resourceUrl/cloud";
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import NAME_FIELD from "@salesforce/schema/User.Name";
import EMAIL_FIELD from "@salesforce/schema/User.Email";
import uploadZipFile from '@salesforce/apex/DataRecovery.uploadZipFile';
import performInsert from '@salesforce/apex/DataRecovery.performInsert';
import performUpsert from '@salesforce/apex/DataRecovery.performUpsert';

export default class DataRecoveryScreen extends LightningElement {


  recoveryAwsText = "Your data recovery from AWS is now in the queue and will be processed shortly. We're working diligently to ensure that your requested data is recovered accurately and securely.";
  lowertext = "You will receive an email notification once the recovery is completed, along with a custom notification .";
  recoveryLocaltext = "Your data recovery is now in the queue and will be processed shortly. We're working diligently to ensure that your requested data is recovered accurately and securely.";
  userEmail;
  selecetdStringData = [];
  selectedObjectDataString = [];

  columns1 = [{ label: 'Names', fieldName: 'objectName', type: "text" }];

  dummyData = [
    { objectName: 'Account', csvData: 'CSV Data 1', externalId: ['id 1', 'id 2', 'id 3', 'id 4'] },
    { objectName: 'Opportunity', csvData: 'CSV Data 2', externalId: ['id 1', 'id 2', 'id 3', 'id 4'] },
    { objectName: 'Contact', csvData: 'CSV Data 3', externalId: ['id 1', 'id 2', 'id 3', 'id 4'] },
    { objectName: 'Case', csvData: 'CSV Data 4', externalId: ['id 1', 'id 2', 'id 3', 'id 4'] }
  ];

  selectedRecords = [];
  objectsWithExternalId = [];
  objectsWithoutExternalId = [];
  RecoveryLocalScreen = false;
  RecoveryAwsScreen = false;

  local = local;
  cloud = cloud;
  date = Date();
  file;
  objectScreen = false;
  showScreen1 = true;
  showScreen2 = false;
  isModal = false;
  awsModal = false;
  isRecovery = true;
  retrievalLoading = false;
  tableWithId = true;
  tableWithoutId = true;


  selectedId;
  selectedDataMap = {};

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD, EMAIL_FIELD]
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

  
  
  // handlePicklistChange(event) {
  //   const selectedId = event.target.value;
  //   const objectIndex = event.target.getAttribute('data-index');
  //   //  const selectedObject = this.objectsWithExternalId[objectIndex];
  //   const selectedObject = this.dummyData[objectIndex];


  //   if (!this.selectedDataMap[selectedObject.objectName]) {
  //     this.selectedDataMap[selectedObject.objectName] = [];
  //   }
  //   const isDuplicate = this.selectedDataMap[selectedObject.objectName].findIndex(item => {
  //     return item.objectName === selectedObject.objectName;
  //   });

  //   if (isDuplicate !== -1) {
  //     this.selectedDataMap[selectedObject.objectName][isDuplicate] = {
  //       externalId: selectedId,
  //       objectName: selectedObject.objectName,
  //       // csvData: selectedObject.CsvData
  //       csvData: selectedObject.csvData
  //     };
  //   } else {
  //     this.selectedDataMap[selectedObject.objectName].push({
  //       externalId: selectedId,
  //       objectName: selectedObject.objectName,
  //       csvData: selectedObject.csvData
  //       // csvData: selectedObject.CsvData
  //     });
  //   }
  //   console.log('selected Obejcts>>>>>', JSON.stringify(this.selectedDataMap));

    
  //   const selectedString = JSON.stringify(this.selectedDataMap[selectedObject.objectName]);
    
    
  //   console.log('selectedString', selectedString);

  //   this.selecetdStringData.push(selectedString);
  //   console.log('this.selecetdStringData', JSON.stringify(this.selecetdStringData));
    
  //   console.log('selectedObjectDataString', JSON.stringify(selectedObjectDataString));

  //   //console.log('selected objects>>>>>', JSON.parse(JSON.stringify(this.selectedDataMap)));
  // }
  
handlePicklistChange(event) {
  const selectedId = event.target.value;
  const objectIndex = event.target.getAttribute('data-index');
  const selectedObject = this.dummyData[objectIndex];

  if (!this.selectedDataMap[selectedObject.objectName]) {
    this.selectedDataMap[selectedObject.objectName] = [];
  }

  const isDuplicateIndex = this.selectedDataMap[selectedObject.objectName].findIndex(item => {
    return item.objectName === selectedObject.objectName;
  });

  const newObject = {
    externalId: selectedId,
    objectName: selectedObject.objectName,
    csvData: selectedObject.csvData
  };

  if (isDuplicateIndex !== -1) {
    this.selectedDataMap[selectedObject.objectName][isDuplicateIndex] = newObject;
  } else {
    this.selectedDataMap[selectedObject.objectName].push(newObject);
  }

  this.selectedObjectDataString = Object.values(this.selectedDataMap).flat();
  
  console.log('this.selectedObjectDataString', JSON.stringify(this.selectedObjectDataString));
}







  handleUpload(event) {
    console.log(event);
    console.log(event.detail.files[0]);
    this.file = event.detail.files[0];
    console.log(this.file);
    // const expectedFileName = 'SF Data.zip';
    // if (this.file.name !== expectedFileName) {
    //   this.showToast('Error', 'Invalid file name. Please upload ' + expectedFileName, 'error');
    //   return;
    // }
    // else {
    //   this.showToast('Success', 'File Uploaded Successfully', 'success');
    // }
  }

  handleRecovery() {
    console.log('handle recovery');
    this.retrievalLoading = true;


    /*testMethods({FileData:'this.file'})
    .then(data=>{
        console.log(data);
    })
    .catch(error=>{
        console.log(error);
    })*/
    const fileReader = new FileReader();
    fileReader.onload = () => {
      const file = fileReader.result.split(',')[1];
      console.log('files');
      console.log(file);

      uploadZipFile({ FileData: file })
        .then(data => {
          this.retrievalLoading = false;
          this.objectScreen = true;
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
            if (this.objectsWithExternalId.length === 0) {
              console.log('objectsWithExternalId');
              this.tableWithId = false;
            }
            console.log('without ids');
            console.log('length', this.objectsWithoutExternalId.length);
            console.log(JSON.stringify(this.objectsWithoutExternalId));
            if (this.objectsWithoutExternalId.length === 0) {
              console.log('objectsWithoutExternalId');
              this.tableWithoutId = false;
            }
            console.log(data[key].ExternalIdField);
            console.log(key);
          }
        })
        .catch(error => {
          console.log('inside error');
          console.log('error', error);
        })

    };
    fileReader.readAsDataURL(this.file);



  }

  // handleExternalIdChange(event) {
  //   const selectedValue = event.detail.value;
  //   const selectedObject = this.objwithExternalId.find(item => item.dropdownValue === selectedValue);

  //   if (selectedObject) {
  //     const selectedRecord = {
  //       objectName: selectedObject.objectName,
  //       externalId: selectedValue,
  //       csvData: selectedObject.CsvData
  //     };

  //     this.selectedRecords.push(selectedRecord); // Add to the selected records array

  //     console.log('Selected Records:', this.selectedRecords);
  //   }
  // }
  handleInsert() {
    this.showScreen2 = true;
    this.objectScreen = false;

    /*if (buttonId === 'btn-1') {
        this.RecoveryLocalScreen = true;
      }
    else if (buttonId === 'btn-2') {
      this.RecoveryAwsScreen = true;
      }*/

    console.log('inside insert');
    performInsert({ objectsToInsert: JSON.stringify(this.objectsWithoutExternalId) })
      .then(data => {
        console.log('data');
        console.log(data);
      })
      .catch(error => {
        console.log(error);
      })

    this.RecoveryLocalScreen = true;
  }
  awsScreen() {
    this.isModal = true;
    this.awsModal = true;
    this.template.querySelector('c-lightning-Modal').handleIsOpenModal();
  }

  handleAWSCredentials(event) {
    console.log('handle aws creds');
    console.log(event);
    console.log(event.detail.value);
    console.log(JSON.stringify(event.detail));
  }

  handleUpsert() {
    console.log('upsert');
    performUpsert({ objectsToUpsert: JSON.stringify(this.selecetdStringData) })
      .then(data => {
        console.log('data');
        console.log(data);
      })
      .catch(error => {
        console.log(error);
      })
  }


}