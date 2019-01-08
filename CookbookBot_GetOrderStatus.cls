public class CookbookBot_GetOrderStatus {

    public class OrderOutput{
        @InvocableVariable(required=true)         public String sStatus;
    }
    public class OrderInput{
        @InvocableVariable(required=true)         public String sOrderNumber;
    }

    @InvocableMethod(label='Get Order Status')
    public static List<OrderOutput> getOrderStatus(List<OrderInput> orderInputs)
    {
        Set<String> orderNumbers = new Set<String>();

        for (OrderInput orderInput : orderInputs)
            orderNumbers.add(orderInput.sOrderNumber);

        Map<String, String> mapNameStatus = new Map<String, String>();
        List<Bot_Order__c> orders = [SELECT Name, Status__c FROM Bot_Order__c where Name in :orderNumbers];
        if (orders.size()>0)
        {
            for (Bot_Order__c order : orders)
                mapNameStatus.put(order.Name, order.Status__c);
        }

        List<OrderOutput> orderOutputs = new List<OrderOutput>();
        for (OrderInput orderInput : orderInputs)
        {
            OrderOutput orderOutput = new OrderOutput();
            //orderOutput.sStatus = mapNameStatus.get(orderInput.sOrderNumber);
            if (mapNameStatus.containsKey(orderInput.sOrderNumber)){
              orderOutput.sStatus = mapNameStatus.get(orderInput.sOrderNumber);
            }
            orderOutputs.add(orderOutput);
        }

        return orderOutputs;
    }
}
