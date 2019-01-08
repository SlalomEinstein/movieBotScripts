public class CookbookBot_UpdateSubscriptionPlan{

    public class Input{
        @InvocableVariable(required=true)         public String email;
        @InvocableVariable(required=true)         public UpdatePlanType__c newSubscriptionType;
    }

    @InvocableMethod(label='Update Subscription Plan')
    public static void updateSubscriptionPlan(List<Input> inputs)
    {
        Set<String> emails = new Set<String>();

        for (Input input : inputs)
            emails.add(input.email);

        Map<String, Subscription_Plan__c> mapNameStatus = new Map<String, Subscription_Plan__c>();
        List<Subscription_Plan__c> subPlans = [SELECT Name, Plan_Type__c,Contact_Email__c FROM Subscription_Plan__c where Contact__r.email in :emails];

        if (subPlans.size()>0)
        {
            for (Subscription_Plan__c subPlan : subPlans)
                mapNameStatus.put(String.valueOf(subPlan.Contact_Email__c), subPlan);
        }

        List<Subscription_Plan__c> plansToUpdate = new List<Subscription_Plan__c>();

        for (Input input : inputs)
        {
            Subscription_Plan__c plan = new Subscription_Plan__c();
            plan = mapNameStatus.get(input.email);
            plan.Plan_Type__c = input.newSubscriptionType.PlanType__c;
            plansToUpdate.add(plan);
        }

        update plansToUpdate;

    }
}
