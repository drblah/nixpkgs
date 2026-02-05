{
  db_uri = "mongodb://localhost/open5gs";

  logger = {
    file = {
      path = "/var/log/open5gs/hss.log";
    };
  };

  global = {
    max = {
      ue = 1024;
    };
  };

  hss = {
    freeDiameter = "/etc/freeDiameter/hss.conf";
    metrics = {
      server = [
        {
          address = "127.0.0.8";
          port = 9090;
        }
      ];
    };
  };
}
