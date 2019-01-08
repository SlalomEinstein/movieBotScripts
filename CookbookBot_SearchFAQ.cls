public with sharing class CookbookBot_SearchFAQ {

    public class FAQSearchInput{
        @InvocableVariable(required=true)
        public String sKeyword;
    }

    public class FAQSearchOutput{
        @InvocableVariable(required=true)
        public String sFAQSearchResult;
    }

    @InvocableMethod(label='Search FAQ')
    public static List<FAQSearchOutput> searchFAQ(List<FAQSearchInput> faqSearchInput)
    {
        String sArticleBaseUrl = getCommunityArticleBaseUrl();
        String sKeyword = faqSearchInput[0].sKeyword;
        String sQuery = 'FIND \'' + sKeyword + '\' IN ALL FIELDS RETURNING KnowledgeArticleVersion(Id, Title, UrlName WHERE PublishStatus = \'Online\'AND Language = \'en_US\' AND IsVisibleInPkb = true) WITH SNIPPET (target_length=255) LIMIT 3';
        Search.SearchResults searchResults = Search.find(sQuery);
        List<Search.SearchResult> articlelist = searchResults.get('KnowledgeArticleVersion');
        String sFAQSearchResult = '';
        for (Search.SearchResult searchResult : articlelist)
        {
            KnowledgeArticleVersion article = (KnowledgeArticleVersion)
                searchResult.getSObject();
            String sArticleSummary;
            String sSnippet = searchResult.getSnippet();
            sArticleSummary = summarizeArticleForBot(sArticleBaseUrl, article,sSnippet);
            sFAQSearchResult = sFAQSearchResult + sArticleSummary;
        }
        if (sFAQSearchResult == '') sFAQSearchResult = 'No result found.';
        List<FAQSearchOutput> faqSearchOutputs = new List<FAQSearchOutput>();
        FAQSearchOutput faqSearchOutput = new FAQSearchOutput();
        faqSearchOutput.sFAQSearchResult = sFAQSearchResult;
        faqSearchOutputs.add(faqSearchOutput);
        return faqSearchOutputs;
    }

    public static String summarizeArticleForBot(String sArticleBaseUrl,KnowledgeArticleVersion article, String sSnippet)
    {
        String sSummary, sURL;
        sURL = sArticleBaseUrl + article.UrlName; //remove highlight HTML tag <mark>
        sSummary = 'Article: ' + article.Title + '\n' + sURL + '\n\n';
        //+ '...' + sSnippet.replaceAll('<[^>]+>',' ') + '...\n\n';
        return sSummary;
    }

    public static string getCommunityArticleBaseUrl()
    {
        List<Network> communityNetworks = [SELECT Id FROM Network WHERE Name='MoviePass' ];
        String sArticleBaseUrl = '';
        if (communityNetworks.size()>0)
        {
            Network communityNetwork = communityNetworks[0];
            String sLoginUrl = Network.getLoginUrl(communityNetwork.id);
            sArticleBaseUrl = sLoginUrl.replace('/login', '/article/');
            System.debug('MyDebug - Community Login URL: ' + sLoginUrl);
            System.debug('MyDebug - Article Base URL: ' + sArticleBaseUrl);
        }
        return sArticleBaseUrl;
    }
}
