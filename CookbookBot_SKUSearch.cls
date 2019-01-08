public class CookbookBot_SKUSearch {

    public class SKUInput {
        @InvocableVariable(required=true)
        public String sku;
    }

    @InvocableMethod(label='SKU Search')
    public static List<String> skuSearch(List<SKUInput> skus)
    {
        String inputSKU = '';
        List<Product2> products;
        List<ContentDocumentLink> allAttachmentParentContains;
        inputSKU = skus[0].sku;

        if (inputSKU != '') {
          products = [SELECT id from Product2 where Product2.SKU__c =: inputSKU];
            if(products.size() > 0) {
              allAttachmentParentContains = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: products[0].id];
            }
        }
        String hyperlink = 'Did not find any documents.';
        List<String> documentIds = new List<String>();
        if (allAttachmentParentContains.size() > 0) {
            hyperlink = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + allAttachmentParentContains[0].ContentDocumentId;
        }
        documentIds.add(hyperlink);

        return documentIds;
    }

}
