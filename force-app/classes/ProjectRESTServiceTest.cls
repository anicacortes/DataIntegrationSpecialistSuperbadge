@isTest
private class ProjectRESTServiceTest {

  @testSetup
  static void setupData() {

    Account testAcct = new Account();
    testAcct.name = 'Test Account';
    testAcct.type = 'Customer - Direct';
    insert testAcct;

    Opportunity testOpp = new Opportunity();
    testOpp.name = 'Test Opportunity';
    testOpp.AccountId = testAcct.id;
    testOpp.type = 'New Project';
    testOpp.CloseDate = system.today();
    testOpp.StageName = 'Negotiation/Review';
    testOpp.Amount = 500000;
    insert testOpp;

    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    Project__c p = new Project__c();
    p.Opportunity__c = opp.Id;
    p.Name = 'Project Name';
    p.Start_Date__c = Date.today().addDays(-1);
    p.End_Date__c = Date.today();
    p.Billable_Amount__c = 100;
    p.Status__c = 'Billable';
    p.ProjectRef__c = 'Ref23829043';
    insert p;
  }

  @IsTest
  public static void postProjectDataTest() {
    Project__c existingProj = [SELECT Id, ProjectRef__c, Name, Opportunity__c, Status__c FROM Project__c][0];

    Test.startTest();

    String returnMessage = ProjectRESTService.postProjectData('Ref23829043', 'Name Project', existingProj.Opportunity__c,  Date.today(), Date.today(), 1000, 'Running');
    System.assertEquals(returnMessage, 'OK');

    existingProj = [SELECT Id, ProjectRef__c, Name, Opportunity__c, Status__c FROM Project__c][0];
    System.assert(existingProj.Status__c == 'Running');

    Test.stopTest();
  }

  @IsTest
  public static void postProjectDataFailTest() {
    Project__c existingProj = [SELECT Id, ProjectRef__c, Name, Opportunity__c, Status__c FROM Project__c][0];

    Test.startTest();

    String returnMessage = ProjectRESTService.postProjectData('RefNoExist', 'Name No Exist', '4237859735',  Date.today(), Date.today(), 1000, 'Running');
    System.assertNotEquals(returnMessage, 'OK');

    existingProj = [SELECT Id, ProjectRef__c, Name, Opportunity__c, Status__c FROM Project__c][0];
    System.assert(existingProj.Status__c == 'Billable');

    Test.stopTest();
  }
}