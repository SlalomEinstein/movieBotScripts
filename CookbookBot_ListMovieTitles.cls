public without sharing class CookbookBot_ListMovieTitles {

    @InvocableMethod(label='Movie Title List')
    public static List<List<Movie__c>> getMovieTitles() {

        List<Movie__c> moviesWithTimes = new List<Movie__c>();
        List<List<Movie__c>> dynamicMenuMovies = new List<List<Movie__c>>();

    Datetime oneMinuteAfterNow = system.now().addMinutes(1);
        for(Movie__c movie: [SELECT Name, Movie_Title__c, (SELECT id,Start_time__c from movie_showings__r)
                   FROM Movie__c
                   WHERE Movie_Title__c != null
                             ]) {
          if(movie.movie_showings__r.size() > 0) {
                for(Movie_showing__c mShowing : movie.movie_showings__r) {
                    if(mShowing.Start_Time__c >= oneMinuteAfterNow) { //&& mShowing.Start_Time__c <= threeDaysLater) {
                        // We create a new Movie__c record because dynamic menus won't allow a field to be an array.
                        // So we create a new movie without the movie_showings__r array.
                        Movie__c mov = new Movie__c(Name=movie.name, Movie_Title__c=movie.Movie_Title__c);
                        if(!moviesWithTimes.contains(mov)) {
                            moviesWithTimes.add(mov);
                        }
                    }
                }  
          }
        }

        if(moviesWithTimes.size() > 0) {
            dynamicMenuMovies.add(moviesWithTimes);
        }

        return dynamicMenuMovies;
    }
}
