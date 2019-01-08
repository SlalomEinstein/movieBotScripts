public with sharing class CookbookBot_ListMovieTitles2 {

    @InvocableMethod(label='Movie Title List 2')
    public static List<List<Movie__c>> getMovieTitles() {

        List<List<Movie__c>> dynamicMenuMovies = new List<List<Movie__c>>();
        List<Movie__c> movs = new List<Movie__C>();

        List<Movie__c> moviesWithTimes = [SELECT Name, Movie_Title__c
                   FROM Movie__c
                   WHERE Movie_Title__c != null AND International_Showtimes_ID__c = '999'
                             LIMIT 100];

        if(moviesWithTimes.size() > 0) {
               for(Movie__c mShowing : moviesWithTimes) {
                   Movie__c mov = new Movie__c(Name=mShowing.name, Movie_Title__c=mShowing.Movie_Title__c);
                   movs.add(mov);
                        /*if(!moviesWithTimes.contains(mov)) {
                            dynamicMenuMovies.add(mov);
                        }*/

                }
          }


        if(movs.size() > 0) {
            dynamicMenuMovies.add(movs);
        }

        return dynamicMenuMovies;
    }
}
