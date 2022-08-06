public with sharing class RestaurantLocationTriggerHandler extends TriggerHandler {

    public RestaurantLocationTriggerHandler() {
    }
    @AuraEnabled(cacheable = true)
    public static Decimal getDays() {
      Decimal days;
      for (Account acc : [
        SELECT 
          id , 
          Days__c, 
          Last_Location_Visit_Date__c 
        FROM 
          Account 
      ]) {
        days= acc.Days__c;
      }
      return days;
    }
    public override void beforeInsert() {
      
      for(Restaurant_Location__c location : (List<Restaurant_Location__c>)trigger.new)
        {
            if(location.Last_Visit_Date__c == null){
                location.Last_Visit_Date__c = Date.today();
            }
        } 
    } 

    public override void afterInsert() {
     proccessNewAccount(trigger.new);
   }

    public override void afterUpdate() {
      proccessOldAccount(trigger.old);
      proccessNewAccount(trigger.new);
    }

    public override void afterDelete() {
      proccessOldAccount(trigger.old);
    }

    public static Date latestLocationDate(String accountId, Date restDate) {
      for (Restaurant_Location__c rest : [
        SELECT 
          Id, 
          Last_Visit_Date__c, 
          Account__c from Restaurant_Location__c 
        WHERE 
              Account__c =:accountId
          ]
        ) {
          	if(rest.Last_Visit_Date__c >= restDate) {
               restDate = rest.Last_Visit_Date__c;
            }
          else if (restDate == null) {
              restDate = rest.Last_Visit_Date__c;
          }
      }
      return restDate;
    }  

    public static void proccessNewAccount(List<Restaurant_Location__c> restLocation) {
      List<Account> updateAccountList = new List<Account>();
        Set<Id> restId = new Set<Id>();
        for(Restaurant_Location__c rest : restLocation) {
            restId.add(rest.Id);
        }
      for(Restaurant_Location__c location : [
        SELECT 
          Id, 
          Account__c, 
          Last_Visit_Date__c, 
          Status__c 
        FROM 
          Restaurant_Location__c 
        WHERE 
          Id 
        IN 
          :restId
        ]
      ) {
              if(location.Account__c != null && location.Status__c == 'Active'){
                  Date latestDate = latestLocationDate(Location.Account__c, location.Last_Visit_Date__c);
                  Account acc = new Account(Id = location.Account__c, Last_Location_Visit_Date__c = latestDate);
                  updateAccountList.add(acc);
              }
          }
        if(!updateAccountList.isEmpty()) {
          update updateAccountList;
        } 
    }
    
     public static void proccessOldAccount(List<Restaurant_Location__c> restLocation) {
      List<Account> updateAccountList = new List<Account>();
        Set<Id> restId = new Set<Id>();
        for(Restaurant_Location__c rest : restLocation) {
            restId.add(rest.Account__c);
        }
         
         for (Account acc : [
          SELECT 
            Id 
          FROM 
            Account 
          WHERE 
            Id 
          IN 
            :restId
          ]
        ) {
             acc.Last_Location_Visit_Date__c = latestLocationDate(acc.Id, null);
             updateAccountList.add(acc);
         }
        if(!updateAccountList.isEmpty()) {
          update updateAccountList;
        } 
    }
    
}