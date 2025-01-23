public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    private List<Opportunity> newOpportunities;
    private Map<Id, Opportunity> newOpportunitiesMap;
    private List<Opportunity> oldOpportunities;
    private Map<Id, Opportunity> oldOpportunitiesMap;
    
    public OpportunityTriggerHandler() {
        this.newOpportunities = (List<Opportunity>) Trigger.new;
        this.newOpportunitiesMap = (Map<Id,Opportunity>) Trigger.newMap;
        this.oldOpportunities = (List<Opportunity>) Trigger.old;
        this.oldOpportunitiesMap = (Map<Id,Opportunity>) Trigger.oldMap;
    }

    public override void beforeUpdate(){
        for(Opportunity opp : this.newOpportunities){
            if(opp.Amount < 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }

        OpportunityHelper.setPrimaryContact(this.newOpportunities);
    }

    public override void beforeDelete(){
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Id IN :this.oldOpportunities)]);
        for(Opportunity opp : oldOpportunities){
            if(opp.StageName == 'Closed Won'){
                if(accounts.get(opp.AccountId).Industry == 'Banking'){
                    opp.addError('Cannot delete closed opportunity');
                }
            }
        }
    }
}


