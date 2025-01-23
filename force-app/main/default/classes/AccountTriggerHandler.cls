public with sharing class AccountTriggerHandler extends TriggerHandler {
    private List<Account> newAccounts;
    private Map<Id, Account> newAccountMap;
    private List<Account> oldAccounts;
    private Map<Id, Account> oldAccountMap;
    
    public AccountTriggerHandler() {
        this.newAccounts = (List<Account>)Trigger.new;
        this.newAccountMap = (Map<Id,Account>)Trigger.newMap;
        this.oldAccounts = (List<Account>)Trigger.old;
        this.oldAccountMap = (Map<Id,Account>)Trigger.oldMap;
    }

    public override void beforeInsert(){ 
        AccountHelper.setTypeProspect(this.newAccounts);
        AccountHelper.addressCopy(this.newAccounts);
        AccountHelper.setRating(this.newAccounts);
    }

    public override void afterInsert(){
        AccountHelper.defaultContact(this.newAccounts);
    }
}