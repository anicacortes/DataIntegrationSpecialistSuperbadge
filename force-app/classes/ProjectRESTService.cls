@RestResource(UrlMapping='/project')
global class ProjectRESTService {

    @HttpPost
    global static String postProjectData(String ProjectRef, String ProjectName, String OpportunityId, Date StartDate,
            Date EndDate, Double Amount, String Status) {
        RestRequest req = RestContext.request;

        Savepoint sp = Database.setSavepoint(); //Savepoint before making DML statements
        try {
            Project__c projectRecord = new Project__c();
            projectRecord.Name = ProjectName;
            projectRecord.ProjectRef__c = ProjectRef;
            projectRecord.Opportunity__c = OpportunityId;
            projectRecord.Start_Date__c = StartDate;
            projectRecord.End_Date__c = EndDate;
            projectRecord.Billable_Amount__c = Amount;
            projectRecord.Status__c = Status;


            upsert projectRecord ProjectRef__c;

            Opportunity oppRelated = [SELECT Id FROM Opportunity WHERE Id = :OpportunityId];
            oppRelated.DeliveryInstallationStatus__c = 'In progress';
            update oppRelated;

            return 'OK';
        }
        catch (Exception ex) {
            System.debug('>> Exception with DML statements:' + ex.getMessage());
            Database.rollback(sp);
            return 'Error with the REST service';
        }
    }
}