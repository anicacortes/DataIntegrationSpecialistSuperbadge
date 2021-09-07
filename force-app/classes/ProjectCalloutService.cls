public class ProjectCalloutService {

    @InvocableMethod (Label='Post Opportunity To PMS')
    public static void postOpportunityToPMS(List<Id> oppIds) {
        System.debug('>> Invocated!');

        ServiceTokens__c tokensSetting = [SELECT Id, Token__c FROM ServiceTokens__c][0];
        System.debug('serviceToken:' + tokensSetting);

        //we work with the first id
        ID jobID = System.enqueueJob(new QueueablePMSCall(oppIds, tokensSetting));
    }


    //Inner class to execute async calls
    public class QueueablePMSCall implements Queueable, Database.AllowsCallouts {

        public List<Id> oppList;
        public ServiceTokens__c serviceToken;

        public QueueablePMSCall(List<Id> oppIdsParam, ServiceTokens__c tokenParam) {
            oppList = oppIdsParam;
            serviceToken = tokenParam;
        }

        public void execute(QueueableContext context) {
            System.debug('>> oppList in batch:' + oppList);
            Opportunity oppRecord = [SELECT Id, Name, Account.Name, CloseDate, Amount FROM Opportunity WHERE Id =: oppList.get(0)];
            System.debug('query oppRecord:' + oppRecord);
            System.debug('close date:' + oppRecord.CloseDate);
            String dateStr = String.valueOf(oppRecord.CloseDate).removeEnd(' 00:00:00');
            System.debug('close date:' + dateStr);

            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('opportunityId ', oppRecord.Id);
            gen.writeStringField('opportunityName', oppRecord.Name);
            gen.writeStringField('accountName', oppRecord.Account.Name);
            gen.writeStringField('closeDate', dateStr);
            gen.writeStringField('amount', String.valueOf(oppRecord.Amount.intValue()));
            gen.writeEndObject();
            String body = gen.getAsString();

            /*String body = '{ "opportunityId": "' + oppRecord.Id + '", \n' +
                    '  "opportunityName": "' + oppRecord.Name + '", \n' +
                    '  "accountName": "' + oppRecord.Account.Name + '", \n' +
                    '  "closeDate": "' + dateStr + '", \n' +
                    '  "amount": ' + oppRecord.Amount.intValue() + '}';*/

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:ProjectService');
            req.setMethod('POST');
            req.setBody(body);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('token', serviceToken.Token__c);

            System.debug(req.getBody());
            System.debug(req.getEndpoint());
            System.debug('serviceToken.Token__c:'  + serviceToken.Token__c);

            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('>> Response:' + res);
            System.debug(res.getBody());

            List<Opportunity> oppToUpdate = new List<Opportunity>();
            if(res.getStatusCode() == 201) {
                System.debug('-> Success');
                oppRecord.StageName = 'Submitted Project';
            }
            else {
                System.debug('-> Fail');
                System.debug(res.getStatus());

                oppRecord.StageName = 'Resubmit Project';
            }
            oppToUpdate.add(oppRecord);

            update oppToUpdate;
            System.debug('updated!!');

        }
    }
}