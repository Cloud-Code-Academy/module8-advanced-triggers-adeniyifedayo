public with sharing class AnotherOpportunityTriggerHandler extends TriggerHandler {
    private List<Opportunity> newerOpportunities;
    private Map<Id, Opportunity> newerOpportunitiesMap;
    private List<Opportunity> olderOpportunities;
    private Map<Id, Opportunity> olderOpportunitiesMap;
    
    public static Boolean hasRun = false;

    public AnotherOpportunityTriggerHandler() {
        this.newerOpportunities = (List<Opportunity>) Trigger.new;
        this.newerOpportunitiesMap = (Map<Id,Opportunity>) Trigger.newMap;
        this.olderOpportunities = (List<Opportunity>) Trigger.old;
        this.olderOpportunitiesMap = (Map<Id,Opportunity>) Trigger.oldMap;

        // if (hasRun == true){
        //     TriggerHandler.bypass('AnotherOpportunityTriggerHandler');
        // }

        // hasRun = true;
    }

    public override void beforeInsert(){
        for (Opportunity opp : this.newerOpportunities){
            if (opp.Type == null){
                opp.Type = 'New Customer';
            }
        }
    }   

    public override void beforeDelete(){
        for (Opportunity oldOpp : this.olderOpportunities){
            if (oldOpp.IsClosed){
                oldOpp.addError('Cannot delete closed opportunity');
            }
        }
    }

    public override void afterInsert(){
        AnotherOpportunityTriggerHelper.createTasks(this.newerOpportunities);
    }

    public override void beforeUpdate(){
        AnotherOpportunityTriggerHelper.updateDescription(newerOpportunities, olderOpportunitiesMap);  
    }

    public override void afterDelete(){
        AnotherOpportunityTriggerHelper.notifyOwnersOpportunityDeleted(olderOpportunities);
    }

    public override void afterUndelete(){
        AnotherOpportunityTriggerHelper.assignPrimaryContact(newerOpportunitiesMap);
    }
}