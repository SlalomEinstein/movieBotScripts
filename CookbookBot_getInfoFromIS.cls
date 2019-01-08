public class CookbookBot_getInfoFromIS {

  public void getMovieList(){
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint('https://api.internationalshowtimes.com/v4/movies/?countries=US&fields=id,slug,title,poster_image_thumbnail,synopsis,runtime,genres');
    request.setMethod('GET');
    request.setHeader('X-API-Key', 'hfEokf4iMCHmZeJMLUlRfFHWsp7HUGF7');
    HttpResponse response = http.send(request);
    // If the request is successful, parse the JSON response.
    if (response.getStatusCode() == 200) {
      //System.debug('smeers - response - ' + response.getBody());

      String returnedJSON = response.getBody();
      JSON2Apex convertedJSON = JSON2Apex.parse(returnedJSON);
      List<JSON2Apex.Movies> moviesPulled = convertedJSON.Movies;

      List<Movie__c> listOfMoviesToInsert = new List<Movie__c>();
      List<Movie__c> listOfMoviesToUpdate = new List<Movie__c>();
      Map<String, Movie__c> moviesPulledMap = new Map<String, Movie__c>();
      List<String> moviesPulledISID = new List<String>();

      for(JSON2Apex.Movies movieInfo : moviesPulled){
        Movie__c currentMovie = new Movie__c();
        //if the movie doesn't have a name, move onto the next one
        if(movieInfo.title == null){
          continue;
        }
        else{
          currentMovie.Name = movieInfo.title;
        }
        currentMovie.International_Showtimes_ID__c = movieInfo.Id;
        currentMovie.International_Showtimes_Slug__c = movieInfo.slug;
        currentMovie.Movie_Title__c = movieInfo.title;
        currentMovie.International_Showtimes_Poster_Thumbnail__c = movieInfo.poster_image_thumbnail;
        currentMovie.Brief_Synopsis__c = movieInfo.synopsis;
        currentMovie.Runtime_in_Minutes__c = movieInfo.runtime;

        String listOfGenres = '';
        for(JSON2Apex.Genres genreInfo : movieInfo.Genres){
          if(genreInfo.Name != null){
            if(listOfGenres.length() == 0){
              listOfGenres = genreInfo.Name;
            }
            else{
              listOfGenres = listOfGenres + ';' + genreInfo.Name;
            }
          }
        }

        currentMovie.Genre__c = listOfGenres;

        moviesPulledMap.put(currentMovie.International_Showtimes_ID__c, currentMovie);
        moviesPulledISID.add(movieInfo.Id);
      }

      for(Movie__c listOfExistingMovies : [SELECT Id, International_Showtimes_ID__c, International_Showtimes_Slug__c, Name,
                         International_Showtimes_Poster_Thumbnail__c, Brief_Synopsis__c, Runtime_in_Minutes__c,
                         Genre__c
                         FROM Movie__c
                         ]){
        /*WHERE International_Showtimes_ID__c
                         IN :moviesPulledISID*/
        Movie__c movieToUpdate = moviesPulledMap.get(listOfExistingMovies.International_Showtimes_ID__c);
        if(movieToUpdate != null){
          if(listOfExistingMovies.International_Showtimes_Slug__c != movieToUpdate.International_Showtimes_Slug__c ||
            listOfExistingMovies.International_Showtimes_Poster_Thumbnail__c != movieToUpdate.International_Showtimes_Poster_Thumbnail__c ||
            listOfExistingMovies.Name != movieToUpdate.Name ||
            listOfExistingMovies.Brief_Synopsis__c != movieToUpdate.Brief_Synopsis__c ||
            listOfExistingMovies.Runtime_in_Minutes__c != movieToUpdate.Runtime_in_Minutes__c ||
            listOfExistingMovies.Genre__c != movieToUpdate.Genre__c){

            movieToUpdate.Id = listOfExistingMovies.Id;
            listOfMoviesToUpdate.add(movieToUpdate);
            moviesPulledMap.remove(listOfExistingMovies.International_Showtimes_ID__c);
          }
          else{
            moviesPulledMap.remove(listOfExistingMovies.International_Showtimes_ID__c);
          }
        }
      }

      for(String IDsToUpdate : moviesPulledISID){
        if(!moviesPulledMap.isEmpty() && moviesPulledMap.containsKey(IDsToUpdate)){
          listOfMoviesToInsert.add(moviesPulledMap.get(IDsToUpdate));
        }
      }
      //System.debug('smeers - count of movies to INSERT - ' + listOfMoviesToInsert.size());
      //System.debug('smeers - count of movies to UPDATE - ' + listOfMoviesToUpdate.size());

      if(listOfMoviesToInsert.size() > 0){
        insert listOfMoviesToInsert;
      }
      if(listOfMoviesToUpdate.size() > 0){
        update listOfMoviesToUpdate;
      }

    }
    else{
      System.debug('Failed with a status of ' + response.getStatusCode());
    }
  }

  public void getCinemas(){
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint('https://api.internationalshowtimes.com/v4/cinemas/?countries=US');
    request.setMethod('GET');
    request.setHeader('X-API-Key', 'hfEokf4iMCHmZeJMLUlRfFHWsp7HUGF7');
    HttpResponse response = http.send(request);
    // If the request is successful, parse the JSON response.
    if (response.getStatusCode() == 200) {

      String returnedJSON = response.getBody();
      JSON2Apex convertedJSON = JSON2Apex.parse(returnedJSON);
      List<JSON2Apex.Cinemas> cinemasPulled = convertedJSON.Cinemas;

      List<Movie_Theater__c> listOfCinemasToInsert = new List<Movie_Theater__c>();
      List<Movie_Theater__c> listOfCinemasToUpdate = new List<Movie_Theater__c>();
      Map<String, Movie_Theater__c> cinemasPulledMap = new Map<String, Movie_Theater__c>();
      List<String> cinemasPulledISID = new List<String>();

      for(JSON2Apex.Cinemas cinemaInfo : cinemasPulled){
        Movie_Theater__c currentCinema = new Movie_Theater__c();

        //gets the Latitude and longitude of the theater
        currentCinema.Cinema_Location__latitude__s = cinemaInfo.Location.lat;
        currentCinema.Cinema_Location__longitude__s = cinemaInfo.Location.lon;

        //gets the Address of the Cinema
        currentCinema.House_Number__c = cinemaInfo.Location.Address.house;
        currentCinema.Street__c = cinemaInfo.Location.Address.street;
        currentCinema.City__c = cinemaInfo.Location.Address.city;
        currentCinema.State__c = cinemaInfo.Location.Address.state;
        currentCinema.State_Abbreviation__c = cinemaInfo.Location.Address.state_abbr;
        currentCinema.Country__c = cinemaInfo.Location.Address.country;
        currentCinema.Country_Abbreviation__c = cinemaInfo.Location.Address.country_code;

        //null check to see if the ZIP is valid
        if(cinemaInfo.Location.Address.zipcode != null){
          //checks the substring and removes "-XXXX" if the ZIP code is not the standard 5 digits
          currentCinema.ZIP_Code__c = Decimal.valueOf(cinemaInfo.Location.Address.zipcode.substring(0,5));
        }

        //gets the Information about the Cinema
        //verifies that the telephone has no letters in it
        if(cinemaInfo.telephone != null &&
          cinemaInfo.telephone.indexOf('a') < 0 &&
          cinemaInfo.telephone.indexOf('b') < 0 &&
          cinemaInfo.telephone.indexOf('c') < 0 &&
          cinemaInfo.telephone.indexOf('d') < 0 &&
          cinemaInfo.telephone.indexOf('e') < 0 &&
          cinemaInfo.telephone.indexOf('f') < 0 &&
          cinemaInfo.telephone.indexOf('g') < 0 &&
          cinemaInfo.telephone.indexOf('h') < 0 &&
          cinemaInfo.telephone.indexOf('i') < 0 &&
          cinemaInfo.telephone.indexOf('j') < 0 &&
          cinemaInfo.telephone.indexOf('k') < 0 &&
          cinemaInfo.telephone.indexOf('l') < 0 &&
          cinemaInfo.telephone.indexOf('m') < 0 &&
          cinemaInfo.telephone.indexOf('n') < 0 &&
          cinemaInfo.telephone.indexOf('o') < 0 &&
          cinemaInfo.telephone.indexOf('p') < 0 &&
          cinemaInfo.telephone.indexOf('q') < 0 &&
          cinemaInfo.telephone.indexOf('r') < 0 &&
          cinemaInfo.telephone.indexOf('s') < 0 &&
          cinemaInfo.telephone.indexOf('t') < 0 &&
          cinemaInfo.telephone.indexOf('u') < 0 &&
          cinemaInfo.telephone.indexOf('v') < 0 &&
          cinemaInfo.telephone.indexOf('w') < 0 &&
          cinemaInfo.telephone.indexOf('x') < 0 &&
          cinemaInfo.telephone.indexOf('y') < 0 &&
          cinemaInfo.telephone.indexOf('z') < 0 ){
          currentCinema.Cinema_Phone__c = cinemaInfo.telephone;
        }
        //currentCinema.Cinema_Phone__c = cinemaInfo.telephone;
        currentCinema.Cinema_Website__c = cinemaInfo.website;
        currentCinema.International_Showtimes_Cinema_ID__c = cinemaInfo.id;
        currentCinema.International_Showtimes_Cinema_Slug__c = cinemaInfo.slug;
        if(cinemaInfo.name.length() > 80){
          currentCinema.Name = cinemaInfo.name.substring(0,80);
        }
        else{
          currentCinema.Name = cinemaInfo.name;
        }

        cinemasPulledMap.put(currentCinema.International_Showtimes_Cinema_ID__c, currentCinema);
        cinemasPulledISID.add(cinemaInfo.Id);
      }

      /*for(Movie_Theater__c listOfExistingCinemas : [SELECT Id, International_Showtimes_Cinema_ID__c, International_Showtimes_Cinema_Slug__c, Name, Cinema_Website__c,
                          Cinema_Phone__c, Cinema_Location__latitude__s, Cinema_Location__longitude__s, House_Number__c, Street__c, City__c,
                          State__c, State_Abbreviation__c, Country__c, Country_Abbreviation__c, ZIP_Code__c
                          FROM Movie_Theater__c
                          WHERE International_Showtimes_Cinema_ID__c
                          IN :cinemasPulledISID]){
        Movie_Theater__c cinemasToUpdate = cinemasPulledMap.get(listOfExistingCinemas.International_Showtimes_Cinema_ID__c);
        if(listOfExistingCinemas.International_Showtimes_Cinema_ID__c != cinemasToUpdate.International_Showtimes_Cinema_ID__c ||
          listOfExistingCinemas.International_Showtimes_Cinema_Slug__c != cinemasToUpdate.International_Showtimes_Cinema_Slug__c ||
          listOfExistingCinemas.Name != cinemasToUpdate.Name ||
          listOfExistingCinemas.Cinema_Website__c != cinemasToUpdate.Cinema_Website__c ||
          listOfExistingCinemas.Cinema_Phone__c != cinemasToUpdate.Cinema_Phone__c ||
          listOfExistingCinemas.Cinema_Location__latitude__s != cinemasToUpdate.Cinema_Location__latitude__s ||
          listOfExistingCinemas.Cinema_Location__longitude__s != cinemasToUpdate.Cinema_Location__longitude__s ||
          listOfExistingCinemas.House_Number__c != cinemasToUpdate.House_Number__c ||
          listOfExistingCinemas.Street__c != cinemasToUpdate.Street__c ||
          listOfExistingCinemas.City__c != cinemasToUpdate.City__c ||
          listOfExistingCinemas.State__c != cinemasToUpdate.State__c ||
          listOfExistingCinemas.State_Abbreviation__c != cinemasToUpdate.State_Abbreviation__c ||
          listOfExistingCinemas.Country__c != cinemasToUpdate.Country__c ||
          listOfExistingCinemas.Country_Abbreviation__c != cinemasToUpdate.Country_Abbreviation__c ||
          listOfExistingCinemas.ZIP_Code__c != cinemasToUpdate.ZIP_Code__c){

          cinemasToUpdate.Id = listOfExistingCinemas.Id;
          listOfCinemasToUpdate.add(cinemasToUpdate);
          cinemasPulledMap.remove(listOfExistingCinemas.International_Showtimes_Cinema_ID__c);
        }
        else{
          cinemasPulledMap.remove(listOfExistingCinemas.International_Showtimes_Cinema_ID__c);
        }
      }*/

      for(String IDsToUpdate : cinemasPulledISID){
        if(!cinemasPulledMap.isEmpty() && cinemasPulledMap.containsKey(IDsToUpdate)){
          listOfCinemasToInsert.add(cinemasPulledMap.get(IDsToUpdate));
        }
      }

      if(listOfCinemasToInsert.size() > 0){
        insert listOfCinemasToInsert;
      }
      /*if(listOfCinemasToUpdate.size() > 0){
        update listOfCinemasToUpdate;
      }*/

    }
    else{
      System.debug('Failed with a status of ' + response.getStatusCode());
    }
  }

  public void getMovieShowtimes(){

    //batch call: Id batchJobId = Database.executeBatch(new CookbookBot_BatchDeleteShowtimes(), 10);
    //batch call: Id batchJobId = Database.executeBatch(new CookbookBot_BatchGetShowtimes(), 10);
    /*DateTime currentDateTime = datetime.now();
    String currentDateTimeFormatted = currentDateTime.format('yyyy-MM-ddTHH:mm:ss', 'America/Chicago');
    DateTime oneDayFromCurrentDateTime = currentDateTime.addDays(1);
    String oneDayFromCurrentDateTimeFormatted = oneDayFromCurrentDateTime.format('yyyy-MM-ddTHH:mm:ss', 'America/Chicago');
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint('https://api.internationalshowtimes.com/v4/showtimes/?time_from='+ currentDateTime +'&time_to='+ oneDayFromCurrentDateTime + '&countries=US');
    request.setMethod('GET');
    request.setHeader('X-API-Key', 'hfEokf4iMCHmZeJMLUlRfFHWsp7HUGF7');
    HttpResponse response = http.send(request);
    // If the request is successful, parse the JSON response.
    if (response.getStatusCode() == 200) {

      Map<String, Id> listOfMovies = new Map<String, Id>();
      Map<String, Id> listOfCinemas = new Map<String, Id>();

      for(Movie__c moviesToAdd : [SELECT Id, International_Showtimes_ID__c FROM Movie__c]) {
        listOfMovies.put(moviesToAdd.International_Showtimes_ID__c, moviesToAdd.Id);
      }

      for(Movie_Theater__c cinemasToAdd : [SELECT Id, International_Showtimes_Cinema_ID__c FROM Movie_Theater__c]){
        listOfCinemas.put(cinemasToAdd.International_Showtimes_Cinema_ID__c, cinemasToAdd.Id);
      }

      String returnedJSON = response.getBody();
      JSON2Apex convertedJSON = JSON2Apex.parse(returnedJSON);
      List<JSON2Apex.Showtimes> showtimesPulled = convertedJSON.Showtimes;

      List<Movie_Showing__c> listOfShowtimesToInsert = new List<Movie_Showing__c>();
      List<Movie_Showing__c> listOfShowtimesToUpdate = new List<Movie_Showing__c>();
      Map<String, Movie_Showing__c> showtimesPulledMap = new Map<String, Movie_Showing__c>();
      List<String> showtimesPulledISID = new List<String>();

      for(JSON2Apex.Showtimes showtimeInfo : showtimesPulled){
        Movie_Showing__c currentShowtime = new Movie_Showing__c();
        if(showtimeInfo.movie_id == null || showtimeInfo.cinema_id == null){
          continue;
        }
        else{
          currentShowtime.Movie__c = listOfMovies.get(showtimeInfo.movie_id);
          currentShowtime.Movie_Theater__c = listOfCinemas.get(showtimeInfo.cinema_id);
        }


        currentShowtime.Start_Time__c = showtimeInfo.start_at;
        currentShowtime.Is_3D_Showtime__c = showtimeInfo.is_3d;
        currentShowtime.Is_IMAX_Showtime__c = showtimeInfo.is_imax;
        currentShowtime.International_Showtimes_Showtime_ID__c = showtimeInfo.id;

        showtimesPulledMap.put(currentShowtime.International_Showtimes_Showtime_ID__c, currentShowtime);
        showtimesPulledISID.add(showtimeInfo.id);
      }

      for(Movie_Showing__c listOfExistingShowtimes : [SELECT Id, Movie__c, Movie_Theater__c, Start_Time__c, Is_3D_Showtime__c, Is_IMAX_Showtime__c,
                          International_Showtimes_Showtime_ID__c
                          FROM Movie_Showing__c
                          WHERE International_Showtimes_Showtime_ID__c
                          IN :showtimesPulledISID]){
        Movie_Showing__c showtimeToUpdate = showtimesPulledMap.get(listOfExistingShowtimes.International_Showtimes_Showtime_ID__c);

        if(listOfExistingShowtimes.International_Showtimes_Showtime_ID__c != showtimeToUpdate.International_Showtimes_Showtime_ID__c ||
          listOfExistingShowtimes.Movie__c != showtimeToUpdate.Movie__c ||
          listOfExistingShowtimes.Movie_Theater__c != showtimeToUpdate.Movie_Theater__c ||
          listOfExistingShowtimes.Start_Time__c != showtimeToUpdate.Start_Time__c ||
          listOfExistingShowtimes.Is_3D_Showtime__c != showtimeToUpdate.Is_3D_Showtime__c ||
          listOfExistingShowtimes.Is_IMAX_Showtime__c != showtimeToUpdate.Is_IMAX_Showtime__c ){
          showtimeToUpdate.Id = listOfExistingShowtimes.Id;
          listOfShowtimesToUpdate.add(showtimeToUpdate);
          showtimesPulledMap.remove(listOfExistingShowtimes.International_Showtimes_Showtime_ID__c);
        }
        else{
          showtimesPulledMap.remove(listOfExistingShowtimes.International_Showtimes_Showtime_ID__c);
        }
      }

      for(String IDsToUpdate : showtimesPulledISID){
        if(!showtimesPulledMap.isEmpty() && showtimesPulledMap.containsKey(IDsToUpdate)){
          listOfShowtimesToInsert.add(showtimesPulledMap.get(IDsToUpdate));
        }
      }

      if(listOfShowtimesToInsert.size() > 0){
        insert listOfShowtimesToInsert;
      }
      if(listOfShowtimesToUpdate.size() > 0){
        update listOfShowtimesToUpdate;
      }

    }
    else{
      System.debug('Failed with a status of ' + response.getStatusCode());
    }*/
  }

  public void getMovieGenres(){

  }
}
