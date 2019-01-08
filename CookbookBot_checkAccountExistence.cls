public class CookbookBot_checkAccountExistence {

    // Output
    //  Returns either a yes/no string for existence
    public class HasAccount{
        @InvocableVariable(required=true)        public String hasAccount;
    }
    // Input
    //  Expect an email to query the account
    public class Input{
        @InvocableVariable(required=true)        public String email;
    }

    @InvocableMethod(label='Check Account Existence')
   public static List<String> checkAccountExistence(List<Input> inputs) {
        List<String> existingAccount = new List<String>();
        Set<String> emails = new Set<String>();

        for (Input emailField : inputs) {// Bulk proof for multiple emails
            emails.add(emailField.email);
        }

        List<Subscription_Plan__c> subPlans = [SELECT Id,Name, Active__c
                                               FROM Subscription_Plan__c
                                               WHERE Contact__r.email in :emails];

        System.debug('Hi');

        System.debug(subPlans);
        if (subPlans.size()>0) {
            for (Subscription_Plan__c subPlan : subPlans) {
                if (subPlan.Active__c.equalsIgnoreCase('Yes')) {
                  existingAccount.add('Yes');
                }
                else {
                existingAccount.add('No');
            }
            }
        }
        else {
            existingAccount.add('No');
        }

        return existingAccount;

    }
}
