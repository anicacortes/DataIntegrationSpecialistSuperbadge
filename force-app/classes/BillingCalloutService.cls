public class BillingCalloutService {

    public static BillingServiceProxy.project proxyProject;

    public static void callBillingService(Project__c newProjectRec) {

        //Get credentials for callout
        ServiceCredentials__c credentials = [SELECT Id, Username__c, Password__c FROM ServiceCredentials__c][0];

        //Fill information of project
        proxyProject = new BillingServiceProxy.project();
        proxyProject.username = credentials.Username__c;
        proxyProject.password = credentials.Password__c;
        proxyProject.projectid = newProjectRec.ProjectRef__c;
        proxyProject.billAmount = newProjectRec.Billable_Amount__c;

        //Callout
        calloutBillingService(newProjectRec.Id);
    }

    @Future(Callout=true)
    private static void calloutBillingService(Id idProj) {
        Project__c newProjectRec = [SELECT Id, Status__c FROM Project__c WHERE Id =: idProj];
        BillingServiceProxy.InvoicesPortSoap11 invoice = new BillingServiceProxy.InvoicesPortSoap11();
        String responseBilling = invoice.billProject(proxyProject);

        List<Project__c> projToUpdate = new List<Project__c>();
        if(responseBilling == 'OK') {
            newProjectRec.Status__c = 'Billed';
            projToUpdate.add(newProjectRec);
        }
        update projToUpdate;
    }
}