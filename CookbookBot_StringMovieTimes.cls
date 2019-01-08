public class CookbookBot_StringMovieTimes {
     public class Input{
        @InvocableVariable(required=true)         public Movie__c MovieChoice;
    }

    @InvocableMethod(label='String Movie times')
    public static List<String> stringMovieTimes(List<Movie__c> MovieChoice) {
        String movieTitle;
        for (Movie__c movie : MovieChoice) {
            movieTitle = movie.Name;
        }

        Datetime oneMinuteAfterNow = system.now().addMinutes(1);
        List<Movie_Showing__c> movieShowings = [SELECT Start_Time__c, Movie_Theater__c
                                                FROM Movie_Showing__c
                                                WHERE Movie__r.Movie_Title__c =: movieTitle
                                                AND Movie_Showing__c.Start_Time__c >=: oneMinuteAfterNow
                                                 LIMIT 7];

        List<String> timeString = new List<String>();
        List<String> timeStringReturn = new List<String>();

        if (movieShowings.size() <= 0) {
            return timeStringReturn;
        }

        for (Movie_Showing__c movieShowing : movieShowings) {
            timeString.add(String.valueOf(movieShowing.Start_Time__c.format('EEE MMM d hh:mm a')));
                           //+ ' @ ' + String.valueOf(movieShowing.Movie_Theater__c));
        }

        String finalReturnString = String.join(timeString, '\n');
        timeStringReturn.add('\n'+finalReturnString);

        return timeStringReturn;

    }
}
