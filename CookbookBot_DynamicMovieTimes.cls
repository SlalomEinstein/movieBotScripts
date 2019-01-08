public class CookbookBot_DynamicMovieTimes {

    public class MovieChoice{
        @InvocableVariable(required=true)         public Movie__c movieChoice;
    }

    @InvocableMethod(label='Dynamic Movie Times')
    public static List<list<Movie_Showing__c>> dynamicMovieTimes(List<MovieChoice> movieChoices)
    {
        List<list<Movie_Showing__c>> movieShowingList = new list<list<Movie_Showing__c>>();
        List<Movie_Showing__c> showTimes = new List<Movie_Showing__c>();

        if (!movieChoices.isEmpty()) {
            Movie__c movieInput = movieChoices[0].movieChoice;
            Datetime now = system.now().addHours(1);
            Datetime threeDaysLater = system.now().addDays(3);
            showTimes = [SELECT Movie_Theater__c, Start_Time__c, Start_Time_String__c
                        FROM Movie_Showing__c
                        WHERE Movie__r.Name =: movieInput.Name
                        AND Movie_Showing__c.Start_Time__c >=: now
                        AND Movie_Showing__c.Start_Time__c <=: threeDaysLater
                        LIMIT 7];
        }

        if (showTimes.size() > 0) {
            movieShowingList.add(showTimes);
        }

        return movieShowingList;

    }
}
