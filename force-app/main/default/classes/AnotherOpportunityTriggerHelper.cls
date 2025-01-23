public with sharing class AnotherOpportunityTriggerHelper {

    public static void createTasks (List<Opportunity> newerOpportunities){
        List<Task> tasksToBeCreated = new List <Task> ();
        for (Opportunity opp : newerOpportunities){
            Task tsk = new Task();
            tsk.Subject = 'Call Primary Contact';
            tsk.WhatId = opp.Id;
            tsk.WhoId = opp.Primary_Contact__c;
            tsk.OwnerId = opp.OwnerId;
            tsk.ActivityDate = Date.today().addDays(3);
            tasksToBeCreated.add(tsk);
        }
        insert tasksToBeCreated;
    }

    public static void updateDescription (List<Opportunity> newerOpportunities1, Map<Id,Opportunity> oldOpportunityMap){
        System.debug(newerOpportunities1.size());

        for (Opportunity newOpp : newerOpportunities1) {
            Opportunity oldOpp = oldOpportunityMap.get(newOpp.Id);

        // Check if the stage has changed
            if (newOpp.StageName != oldOpp.StageName) {
            System.debug(newOpp.StageName);

            newOpp.Description += '\n Stage Change:' + newOpp.StageName + ':' + DateTime.now().format();
            }
        }
    }

    public static void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
        Set<Id> ownerIds = new Set <Id> ();
        for (Opportunity oldOpp : opps){
            ownerIds.add(oldOpp.OwnerId);
        }

        Map<Id, User> ownerMap = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :ownerIds]);

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (Opportunity oldOpp : opps){
            User owner = ownerMap.get(oldOpp.OwnerId);   

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {owner.Email});
            mail.setSubject('Opportunity Deleted : ' + oldOpp.Name);
            mail.setPlainTextBody('Your Opportunity: ' + oldOpp.Name +' has been deleted.');
            mails.add(mail);
        }        
        
        try {
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }

    public static void assignPrimaryContact(Map<Id,Opportunity> oppNewMap) {        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Set<Id> accountIds = new Set <Id>();
    
        for (Opportunity opp : oppNewMap.values()){   
            accountIds.add(opp.AccountId);
        }
                
        Contact primaryContact = [SELECT Id, AccountId FROM Contact WHERE Title = 'VP Sales' AND AccountId IN :accountIds];
    
        for (Opportunity opp : oppNewMap.values()){
            if (opp.Primary_Contact__c == null){
                Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
                oppToUpdate.Primary_Contact__c = primaryContact.Id;
                oppMap.put(opp.Id, oppToUpdate);
            }     
        }
        update oppMap.values();
    }
}
      