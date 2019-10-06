final String authKeyRaghava = 'Bearer 7rv807b6m7eeq0gmdj64bo17ov2qcehl';
final String hostRaghava = 'testsocial.i.tgcloud.us:9000';

String returnHttpUrl(String host, String vertexType, vertexID) //uses
{
  return 'https://$host/graph/vertices/$vertexType/$vertexID';
}