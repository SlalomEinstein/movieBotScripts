public class CookbookBot_GetAccountSettings {

    public class AccountDetails{
        //@InvocableVariable(required=true)
        public String accountDetails;
    }

    public class EmailInput{
        @InvocableVariable(required=true)        public String email;
    }

    @InvocableMethod(label='Get Account Details')
    public static List<Subscription_Plan__c> getAccountDetails(List<EmailInput> emailInputs) {
        List<Subscription_Plan__c> existingAccounts = new List<Subscription_Plan__c>();
        Set<String> emails = new Set<String>();

        for (EmailInput email : emailInputs) // Bulk proof for multiple emails
            emails.add(email.email);

        List<Subscription_Plan__c> subPlans = [SELECT
                                               Id,Name,Contact_Email__c,Plan_Type__c,Plan_Monthly_Cost__c,
                                               Account_Description__c
                                               FROM Subscription_Plan__c
                                               where Contact__r.email in :emails];
       return subPlans;

    }
}
