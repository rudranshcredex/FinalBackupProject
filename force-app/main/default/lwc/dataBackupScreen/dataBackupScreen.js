/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable eqeqeq */
import { LightningElement, wire, track } from "lwc";
//import getObjects from "@salesforce/apex/ObjectHelper.getObjects";
import getObjectsApiNames2 from '@salesforce/apex/dataBackup.getObjectsApiNames2';
import local from "@salesforce/resourceUrl/LocalBackup";
import cloud from "@salesforce/resourceUrl/cloud";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import NAME_FIELD from "@salesforce/schema/User.Name";
import Email_FIELD from "@salesforce/schema/User.Email";
import createDataBackup from '@salesforce/apex/bulkApiQuery.createDataBackup';
import ScheduleDataBackup from '@salesforce/apex/bulkApiQuery.ScheduleDataBackup';

export default class DataBackupScreen1 extends LightningElement {
  @track objectList;
  @track objectNames = [];
  @track numberOfObjectSelected = 0;



  selectedObjectNames = [];
  showScreen1 = true;
  showScreen2 = false;
  showScreen3 = false;
  showCloudScreen = false;
  currentStep = "1";
  step = 1;
  isLoading = true;
  date = Date();
  columns1 = [{ label: "Name", fieldName: "objectName", type: "text" }];
  local = local;
  cloud = cloud;
  homepage = false;

  username;
  userEmail;
  filterByDate = false;
  openModal = false;
  openModal1 = false;
  awsModal = false;
  isModal = false;
  awsAccessKey = null;
  awsSecretKey = null;
  awsRegion = null;
  awsBucket = null;
  isbackupToS3 = false;
  isbackupToLocal = false;
  retrievalLoading = false;
  fromDate = null;
  toDate = null;
  ScheduleDateLocal = null;
  ScheduleDateAws = null;
  isscheduleSpinner =false;
  todayDate = new Date().toISOString().split('T')[0];
  backupAws =true;

  dataExportText1 = "Your data export is now in the queue and will be processed shortly. We're working diligently to ensure that your requested data is exported accurately and securely.";
  lowerText = "You will receive an email notification once the export is completed, along with a custom notification.";
  dataScheduleText = "Your export is now scheduled and will be processed shortly. We're working diligently to ensure that your requested data is exported accurately and on time.";
  dataAwsText = "Your data backup to AWS is now in the queue and will be uploaded shortly. We're working diligently to ensure that your requested data is uploaded accurately and securely.";
  dataAwsScheduleText = "Your data backup to AWS is now scheduled and will be uploaded shortly. We're working diligently to ensure that your requested data is uploaded accurately and securely.";

  exportNowScreen = false;
  exportScheduleScreen = false;
  AwsNowScreen = false;
  AwsScheduleScreen = false;

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD,Email_FIELD]
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

  connectedCallback() {
    getObjectsApiNames2({})
      .then((result) => {
        this.objectList = structuredClone(result);
        this.isSpinnerLoading(false);
        this.objectNames = this.objectList;
      })
      .catch((error) => {
        this.showToast("Error fetching objects", error.message.body, "error");
      });
  }

  handleSearchChange(event) {
    if (this.objectList && event.target.value.length >= 2) {
      this.filterObjectNames(event.target.value);
    } else {
      this.isSpinnerLoading(true);
      this.objectList = this.objectNames;
      this.isSpinnerLoading(false);
    }
  }

  async filterObjectNames(searchKeyword) {
    let newObjectList = [];
    this.isSpinnerLoading(true);
    for (let i = 0; i < this.objectList.length; i++) {
      if (
        this.objectList[i].objectName
          .toLowerCase()
          .substring(0, searchKeyword.length)
          .localeCompare(searchKeyword.toLowerCase()) == 0
      ) {
        newObjectList.push(this.objectList[i]);
      }
    }
    this.objectList = newObjectList;
    this.isSpinnerLoading(false);
  }

  nextButton() {
    let dates = this.template.querySelectorAll('lightning-input');
    console.log(dates);
      dates.forEach(function(date){
        if(date.name=='fromDate'){
            this.fromDate=date.value
        }
        else if(date.name=='toDate'){
            this.toDate=date.value;
        }
    });

    const selectedFromDate = new Date(this.fromDate);
    const selectedToDate = new Date(this.toDate);
    const currentDate = new Date();
    /*if (selectedFromDate > currentDate || selectedToDate>currentDate) {
      this.showToast(
          "Error",
        "Entered Date cannot be more than today's date.",
          "error"
        );
    }*/

    console.log('dates');
    console.log(this.fromDate);
    console.log(this.toDate);
    if (this.step === 1) {
      const selectedObjects = this.objectList.filter((obj) => obj.isSelected);

      
      if (selectedObjects.length === 0 && (this.fromDate ==null && this.toDate == null)) {
        this.showToast(
          "Required",
          "Please select at least one object.",
          "error"
        );
        return;
      }

      if (selectedObjects.length > 0 && (this.fromDate ==null && this.toDate == null)) {
         this.showToast(
          "Kindly Review!",
          "You have selected "+ selectedObjects.length +" object to backup",
          "success"
        );
      }

      if (selectedObjects.length === 0 && (selectedFromDate > currentDate || selectedToDate > currentDate)) {
        this.showToast(
          "Required",
          "Please select at least one object and you can't select date to filter records greater than today.",
          "error"
        );
        return;
      }
      
      if (selectedObjects.length>0 && (selectedFromDate > currentDate || selectedToDate>currentDate)) {
        this.showToast(
          "Required",
          " You can't select date to filter records greater than today",
          "error"
        );
        return;
      }

      if (selectedObjects.length === 0 && (selectedFromDate <= currentDate && selectedToDate <= currentDate)) {
        this.showToast(
          "Required",
          "Please select at least one object.",
          "error"
        );
        return;
      }
      
   
      if (selectedObjects.length>0 && (selectedFromDate <= currentDate && selectedToDate <= currentDate)) {
        this.showToast(
          "Kindly Review!",
          "You have selected "+ selectedObjects.length +" object to backup",
          "success"
        );
      }

      console.log('selected Objects');
     // console.log(selectedObjects);
      console.log(JSON.stringify(selectedObjects));
      //console.log(JSON.stringify(JSON.parse(selectedObjects)));
      console.log(selectedObjects.length);
      
      let ObjectsArray = selectedObjects;
      console.log('obj Array');
      console.log(JSON.stringify(ObjectsArray));
      for(var i=0;i<ObjectsArray.length;i++){
          console.log(ObjectsArray[i]);
          console.log('stringify');
          console.log(JSON.stringify(ObjectsArray[i]));
          console.log(ObjectsArray[i].objectName);
          this.selectedObjectNames.push(ObjectsArray[i].objectName);
      }
      console.log(JSON.stringify(this.selectedObjectNames));
    }

    if (this.step !== 3) {
      this.step++;
    }
    this.handleStepUp();

  }

  ExportData(event){
    console.log(event);
    console.log('data export');
    console.log(event.target);
    console.log('id');
    console.log(event.target.dataset.id);
    console.log('current');
    const dataId = event.currentTarget.getAttribute('data-id');
    console.log(dataId);
    let divId =event.currentTarget.getAttribute('data-id');
     this.retrievalLoading =true;
     if(divId=='LocalNow'){
         this.isbackupToLocal = true;
         this.isbackupToS3 = false;
       this.exportNowScreen = true;
       this.showScreen2 = false; 
       this.showScreen1 = false;
     }
     console.log(divId);
     if(divId=='AwsNow'){
         this.isbackupToS3 = true;
         this.isbackupToLocal = false;
       this.AwsNowScreen = true;
       this.showScreen2 = false;
       this.showScreen1 = false;
     }
   
     if(this.isbackupToS3 &&(this.awsAccessKey===null && this.awsSecretKey===null && this.awsRegion===null && this.awsBucket)){
        this.showToast('Required','To Backup Data to S3 Kindly select Credentials','error');
        this.retrievalLoading =false;
        return;
     }
     console.log('dates');
     console.log(this.fromDate);
     console.log(this.toDate);
     console.log(this.awsAccessKey);
     console.log(this.awsSecretKey);
      var credential = { "accessKey": this.awsAccessKey, "SecretKey": this.awsSecretKey, "Bucket": this.awsBucket, "awsRegion": this.awsRegion, "backupTos3": this.isbackupToS3, "backupToLocal": this.isbackupToLocal };
      createDataBackup({ObjectApiNames:this.selectedObjectNames,credentials:JSON.stringify(credential),fromDate:this.fromDate,toDate:this.toDate})
      .then(data=>{
        console.log('data>>>>>>>');
        console.log(data);
        this.retrievalLoading = false;
        this.showScreen3 = true;
        this.showScreen1 = false;
        this.showScreen2 = false;
      })
      .catch(error=>{
        console.log(error);
        console.log('error');
      })   
    this.step=3;
    this.handleStepUp();
  }
  
  ScheduleBackup(event){

    this.isscheduleSpinner = true;
    const currDate = new Date();

    if(event.target.name=='ScheduleLocal'){
      this.isbackupToLocal =true;
      this.isbackupToS3 =false;
  }
  if(event.target.name=='ScheduleAws'){
      this.isbackupToLocal =false;
      this.isbackupToS3 =true;
  }
  if(this.isbackupToS3 ||(this.awsAccessKey===null && this.awsSecretKey===null && this.awsRegion===null && this.awsBucket)){
      this.showToast('Required','To Backup Data to S3 Kindly select Credentials','error');
      this.isscheduleSpinner =false;
      return;
   }

    let scheduleDates = this.template.querySelectorAll('lightning-input');
    scheduleDates.forEach(function(date){
      if (date.name === 'ScheduleDateLocal') {
        if (date.value) {
          this.ScheduleDateLocal=date.value;
        }
          
      }
      if (date.name === 'ScheduleDateAws') {
        if (date.value) {
          this.ScheduleDateAws=date.value;
        }
      }
  },this);
    let awsDate=null;
    let localDate=null;
    
    if (this.ScheduleDateAws!=null) {
     awsDate =  new Date(this.ScheduleDateAws);
    }
    if (this.ScheduleDateLocal!=null) {
     localDate = new Date(this.ScheduleDateLocal);
    }
    console.log('dates');
    console.log(currDate);
    console.log(this.ScheduleDateLocal);
    console.log(this.ScheduleDateAws);
    if (this.ScheduleDateLocal < currDate) {
      console.log('true');
    }
    
    if (this.isbackupToLocal && this.ScheduleDateLocal === null) {
      this.showToast('Required', 'Please Select Date to schedule the Backup Process', 'error');
      this.isscheduleSpinner = false;
      return;
    }
    else if (this.isbackupToLocal && localDate < currDate) {
      this.showToast('Validation', 'You can\'t select previous Date than today to schedule the Backup Process', 'error');
      this.isscheduleSpinner = false;
      return;
    }
    else if (this.isbackupToS3 && this.ScheduleDateAws === null) {
      this.showToast('Required', 'Please Select Date to schedule the Backup Process', 'error');
      this.isscheduleSpinner = false;
      return;
    }
    else if (this.isbackupToS3 &&  awsDate < currDate) {
      this.showToast('Validation', 'You can\'t select previous Date than today to schedule the Backup Process', 'error');
      this.isscheduleSpinner = false;
      return;
    }
    else{
      this.openModal = false;
      let scheduleDate=null;
     console.log(this.awsAccessKey);
      var credential = { "accessKey": this.awsAccessKey, "SecretKey": this.awsSecretKey, "Bucket": this.awsBucket, "awsRegion": this.awsRegion, "backupTos3": this.isbackupToS3, "backupToLocal": this.isbackupToLocal };
      if (this.isbackupToLocal) {
        scheduleDate = this.ScheduleDateLocal;
      }
      if (this.isbackupToS3) {
        scheduleDate = this.ScheduleDateAws;
      }
    ScheduleDataBackup({ObjectApiNames:this.selectedObjectNames,credentials:JSON.stringify(credential),fromDate:this.fromDate,toDate:this.toDate,scheduleDate:scheduleDate})
    .then(data=>{
      this.isscheduleSpinner =false;
      console.log('data');
      console.log(data);
      if (event.target.name == 'ScheduleLocal') {
        this.exportScheduleScreen = true;
      }
      else if (event.target.name == 'ScheduleAws') {
        this.AwsScheduleScreen = true;
      }

      this.showScreen2 = false;
      this.showScreen1 = false;
    })
    .catch(error=>{
      this.openModal = false;
      this.isscheduleSpinner =false;
      console.log('error in schedule');
      this.showToast('Error', 'some error occuring Please check or contact support', 'error');
      console.log(error);
    })
  }   
  }

  previousButton() {
    this.showScreen2 = false;
    this.showScreen1 = true;
    this.step = 1;
    this.handleStepUp();
    this.isLoading = true;
    this.isSpinnerLoading(false);
    this.objectList = this.objectNames;
  }

  handlecheckboxChange(event) {
    this.changeObjectSelectionNumber(event);
    for (let i = 0; i < this.objectList.length; i++) {
      if (this.objectList[i].objectId == event.target.dataset.id) {
        this.objectList[i].isSelected = event.detail.checked;
        break;
      }
    }
  }
  changeObjectSelectionNumber(event) {
    if (event.detail.checked) {
      this.numberOfObjectSelected++;
    } else {
      this.numberOfObjectSelected--;
    }
  }
  handleAllCheckboxChange(event) {
    if (event.detail.checked) {
      this.processObjectList(event);
      this.numberOfObjectSelected = this.objectNames.length;
    } else {
      this.processObjectList(event);
      this.numberOfObjectSelected = 0;
    }
  }
  processObjectList(event) {
    for (let i = 0; i < this.objectList.length; i++) {
      this.objectList[i].isSelected = event.detail.checked;
    }
  }
  isSpinnerLoading(isLoading) {
    window.setTimeout(() => {
      this.isLoading = isLoading;
    }, 1000);
  }
  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }
  handleStepUp() {
    this.showScreen1 = this.step == 1;
    this.showScreen2 = this.step == 2;
    this.showScreen3 = this.step == 3;
    this.currentStep = "" + this.step;
  }
  handleHomepage() {
    console.log("handle home");
    this.homepage = true;
    this.showScreen3 = false;
    this.showScreen1 = false;
    this.showScreen2 = false;
    console.log(this.homepage);
  }
  handleFilter() {
    this.filterByDate = true;
  }
  handleClose() {

    let dates = this.template.querySelectorAll('lightning-input');
      dates.forEach(function(date){
        if(date.name=='fromDate'){
          if(date.value){
            this.fromDate=date.value
          }
           
        }
        else if(date.name=='toDate'){
          if(date.value){
            this.toDate=date.value;
          }
            
        }
    },this);
    console.log(this.fromDate);
    console.log(this.toDate);
    if (this.filterByDate === true) this.filterByDate = false;

    

  }

  handleOpenModal() {
    this.openModal = true;
  }
  handleOpenModal1() {
    this.openModal1 = true;
  }
  handleCloseModal() {
    this.openModal = false;
  }
  handleCloseModal1() {
    this.openModal1 = false;
  }
  handleAwsModal() {
    console.log("inside credentals");
    this.awsModal = true;
    
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
    console.log('yes');
    const parsedData = JSON.parse(JSON.stringify(event.detail));
    this.awsAccessKey = parsedData.accessKey;
    this.awsSecretKey = parsedData.secretKey;
    this.awsRegion = parsedData.regionName;
    this.awsBucket = parsedData.bucketName;
    console.log(this.awsBucket);
    console.log( this.accessKey);
    console.log(parsedData.accessKey);
  }
  handleDate(event) {
    console.log('inside date func');
    console.log(event.target.name);
    const selectedDates = event.target.value;
    if (event.target.name == 'fromDate') {
      this.fromDate = event.target.value;
    }
    if (event.target.name == 'toDate') {
      this.toDate = event.target.value;
    }
    this.validateDate(selectedDates);
  }
  validateDate(selectedDates) {
    const enteredDate = new Date(selectedDates);
    const currDate = new Date();
    if (enteredDate > currDate) {
      this.showToast(
          "Error",
        "Entered Date cannot be more than today's date.",
          "error"
        );
    }
  }
  handleScheduleDate(event) {
    this.schDate = event.target.value;
    this.validateSchDate();
  }

  validateSchDate() {
    const currentDate = new Date();
    const enterDate = new Date(this.schDate);
    if (enterDate < currentDate) {
       this.showToast("Warning", "Scheduled Date cannot be less than today's date", "error");
    }
  }
  
}