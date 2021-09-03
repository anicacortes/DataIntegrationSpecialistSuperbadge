trigger ProjectTrigger on Project__c (after update) {


    Map<Id, Project__c> mapNewProject = Trigger.newMap;
    Map<Id, Project__c> mapOldProject = Trigger.oldMap;

    for (Id key : mapNewProject.keySet()) {

        if(mapNewProject.get(key).Status__c == 'Billable' && mapOldProject.get(key).Status__c != 'Billable') {
            BillingCalloutService.callBillingService(mapNewProject.get(key));
        }
    }
}