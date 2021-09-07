@IsTest
private class ProjectCalloutServiceTest {
  //Implement mock callout tests here

  @TestSetup
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

    ServiceTokens__c tokenSetting = new ServiceTokens__c();
    tokenSetting.Name = 'Token';
    tokenSetting.Token__c = 'd65c9b43-6248-43eb-9d62-8fdd090d43d2';
    insert tokenSetting;
  }

  @IsTest
  static void postOpportunityToPMSPositiveTest() {
    Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());

    Opportunity oppUpdated = [SELECT Id, StageName FROM Opportunity][0];
    oppUpdated.StageName = 'Closed Won';
    Test.startTest();
    update oppUpdated;
    Test.stopTest();

    Opportunity updatedOpp = [SELECT Id, StageName, Type FROM Opportunity][0];
    System.assertEquals(updatedOpp.StageName, 'Submitted Project');

    List<AsyncApexJob> listJobs = [SELECT Status, NumberOfErrors FROM AsyncApexJob];
    System.assert(listJobs.size() > 0);
  }

  @IsTest
  static void postOpportunityToPMSNegativeTest() {
    Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());

    Opportunity oppUpdated = [SELECT Id, StageName FROM Opportunity][0];
    oppUpdated.StageName = 'Closed Won';
    Test.startTest();
    update oppUpdated;
    Test.stopTest();

    Opportunity updatedOpp = [SELECT Id, StageName, Type FROM Opportunity][0];
    System.assertEquals(updatedOpp.StageName, 'Resubmit Project');

    List<AsyncApexJob> listJobs = [SELECT Status, NumberOfErrors FROM AsyncApexJob];
    System.assert(listJobs.size() > 0);
  }
}