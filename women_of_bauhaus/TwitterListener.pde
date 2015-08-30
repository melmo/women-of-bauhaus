class TwitterListener {
  
  TwitterStream twitterStream;
  String query;
  StatusListener listener;
  AllListener parentListener;
  final TwitterListener me;

  public TwitterListener(AllListener parentListener) {
    
    this.parentListener = parentListener;
    me = this;
    
    ConfigurationBuilder cb = new ConfigurationBuilder();
    cb.setOAuthConsumerKey("O5Ve27RKWRJr5wsoRYKNJ2Nfl");
    cb.setOAuthConsumerSecret("Ubp3YyJ0vFsaGN9f94OdcZ7VuQq4K0EK8v4LAqjhHvaa4eisj1");
    cb.setOAuthAccessToken("212796679-9hUgFsnV1rA5Z0kgwhnQcuT3iQr7O30Wigyio6MT");
    cb.setOAuthAccessTokenSecret("spoRJul3lh0q3O55uXLSsNvwsTHbAeAGlfxhrI4dlgr22");
  
    listener = new StatusListener() {
      
      @Override
      public void onStatus(Status status) {
          SuccessMessage sm = new SuccessMessage("twitter", me.query, status.getUser().getScreenName(), status.getText());
          me.logSuccess(sm);
      }
  
      @Override
      public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
          System.out.println("Got a status deletion notice id:" + statusDeletionNotice.getStatusId());
      }
  
      @Override
      public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
          System.out.println("Got track limitation notice:" + numberOfLimitedStatuses);
      }
  
      @Override
      public void onScrubGeo(long userId, long upToStatusId) {
          System.out.println("Got scrub_geo event userId:" + userId + " upToStatusId:" + upToStatusId);
      }
  
      @Override
      public void onStallWarning(StallWarning warning) {
          System.out.println("Got stall warning:" + warning);
      }

  
      @Override
      public void onException(Exception ex) {
          ex.printStackTrace();
      }
    };
    
    twitterStream = new TwitterStreamFactory(cb.build()).getInstance();
    twitterStream.addListener(listener);
    
  }
  
  void setQuery(String query) {
    this.query = query;
    me.query = query;
    FilterQuery fq = new FilterQuery(query);
    twitterStream.filter(fq);
  }
  
  void logSuccess(SuccessMessage sm) {
    parentListener.logSuccess(sm);
  }
  
}
