public class CookbookBot_SOQLQuery {

  public class SOQLQuery {
        @InvocableVariable(required=true)
        public String query;
    }

    public class SOQLQueryResults {
        @InvocableVariable(required=true)
        public String hyperlinks;
    }

    @InvocableMethod(label='SOQL Search')
    public static List<SOQLQueryResults> soqlSearch(List<SOQLQuery> queries)
    {
        String inputQuery = String.escapeSingleQuotes(queries[0].query);
        String queryResult = '';

        System.debug('User Query: ' + inputQuery);

        for (sObject sobj : Database.query(inputQuery)) {
            String hyperlink = recordHyperlink(sobj);
            queryResult = queryResult + hyperlink + '\n\n';
        }

        if(queryResult == '') {
            queryResult = 'No Results Found.';
        }

        List<SOQLQueryResults> recordURLs = new List<SOQLQueryResults>();
        SOQLQueryResults result = new SOQLQueryResults();
    result.hyperlinks = queryResult;
        recordURLs.add(result);

        System.debug(recordURLs);

        return recordURLs;

    }

    public static String recordHyperlink(sObject sobj) {
        String hyperlink = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + sobj.id;
        String encoded = EncodingUtil.urlEncode(hyperlink, 'UTF-8');
        String aTag = '<a href=' + hyperlink +'>Record ID: ' + sobj.id + '</a>';

       return hyperlink;
    }

}
