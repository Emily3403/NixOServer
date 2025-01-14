{ pkgs, options, config, lib, ... }: {
  age.secrets = {
    Monitoring_host-htpasswd = {
      file = ../../secrets/Monitoring/Nginx/ruwusch-htpasswd.age;
      owner = "nginx";
      group = "nginx";
    };










    Prometheus_photoprism-API-key = {
      file = ../../secrets/Monitoring/Exporters/PhotoPrism-Token.age;
      owner = "prometheus";
    };



    PhotoPrism = {
      file = ../../secrets/PhotoPrism.age;
      owner = "photoprism";
    };



    Piwigo_Mariadb = {
      file = ../../secrets/Piwigo-Mariadb.age;
      owner = "5015";
    };

    Affine_AdminPassword = {
      file = ../../secrets/Affine/Environment.age;
      owner = "root";
    };

    Affine_Postgres = {
      file = ../../secrets/Affine/Postgres.age;
      owner = "root";
    };

    Affine_Redis = {
      file = ../../secrets/Affine/Redis.age;
      owner = "root";
    };


  };
}
