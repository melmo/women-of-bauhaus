class FacebookListener {
  AllListener parentListener;
  Facebook facebook;
  String query;
  public FacebookListener(AllListener parentListener) {
    parentListener = parentListener; 
/*
    facebook4j.conf.ConfigurationBuilder cb = new facebook4j.conf.ConfigurationBuilder();
    cb.setDebugEnabled(true)
      .setOAuthAppId("1043227322363579")
      .setOAuthAppSecret("8c716a9ae02e6e5d4e110978eb35944f")
      
      //.setOAuthAccessToken("1043227322363579|vyxhX0LIhC00ctir_VbfuEqjwTQ")//https://graph.facebook.com/oauth/access_token?%20client_id=1043227322363579&client_secret=8c716a9ae02e6e5d4e110978eb35944f&grant_type=client_credentials
      // https://developers.facebook.com/tools/access_token/
      .setOAuthAccessToken("CAAO0z0n4LrsBABvEF3Xr9AvaLu1JsrP3tSyZCSSEawiNqjTbopOGhP6YWlL84T9eKrved8JTiA0s7lCs1vLxjFoXH3ZCPVHZC1hxlzz9ZC2kO6Dw8PnETPgftKkx6SarcTZCCGwRZB9VNJ5Do7MLtiBp5a4uvSWs8RXyzqIlKPZAxTuFvmP0GZArtZAKgYVwm8tt5AD8lGFLMTQZDZD")
      .setOAuthPermissions("read_stream,public_profile");

    FacebookFactory ff = new FacebookFactory(cb.build());
    facebook = ff.getInstance();
    */
    facebook = new FacebookFactory().getInstance();
    facebook.setOAuthAppId("1043227322363579", "8c716a9ae02e6e5d4e110978eb35944f");
    String accessTokenString = "1043227322363579|8c716a9ae02e6e5d4e110978eb35944f";
    AccessToken at = new AccessToken(accessTokenString);
    // Set access token.
    facebook.setOAuthAccessToken(at);
  } 
  
  void setQuery(String query) {
    this.query = query;
  }
  
  void pollQuery() {
    ResponseList<Post> results;
    try {
      results = facebook.searchPosts("watermelon");
      for (Post result : results) {
           System.out.println(result);
       }
    } catch (FacebookException e) {
      println(e.getMessage()); 
    }
  }
}
