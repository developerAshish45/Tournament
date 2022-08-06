import { LightningElement, wire } from 'lwc';
import daysPassed from '@salesforce/schema/Account.Days__c';
import getDays from '@salesforce/apex/RestaurantLocationTriggerHandler.getDays';

export default class toast_AccountHealth extends LightningElement {
 red = false;
 green = true;
 yellow = false; 
 connectedCallback() {
   this.getLabel();
 }

 @wire(getDays) days; 
 getLabel(){
        console.log("days: "+ JSON.stringify(this.days));
        console.log("days: "+ (this.days.data));
        let daysPassed;
        if (daysPassed > 0) {
            if (daysPassed < 30) {
                this.green = true;
            }
            else if (30 < daysPassed < 60) {
                this.yellow = true
            }
            else if (60 < daysPassed) {
                this.red = true;
            }
        } 
    } 
}